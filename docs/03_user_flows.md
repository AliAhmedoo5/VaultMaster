# User Flows & Screen Map — VaultMaster

## 1. Application Screen Map (Mermaid State Graph)

This graph maps the exact navigation state transitions across the VaultMaster mobile application (`lib/features/`) and the web sandbox simulation (`website/demo.html`).

```mermaid
stateDiagram-v2
  [*] --> WelcomeScreen : App Launch / Page Open
  
  state WelcomeScreen {
    [*] --> RotatingSafeWheel : @keyframes rotateWheel (15s loop)
  }

  WelcomeScreen --> LoginScreen : Click 'GET STARTED'
  
  state LoginScreen {
    [*] --> Idle
    Idle --> Authenticating : Click 'CONTINUE WITH GOOGLE'
  }

  LoginScreen --> WelcomeScreen : Click Back Arrow (←)
  LoginScreen --> SplashScreen : Google Auth Success (Duration: 500ms)

  state SplashScreen {
    [*] --> AnimateIcon : Scale (0.7 -> 1.0) + Fade In
    AnimateIcon --> StatusUpdate : 'Syncing Nexus Archive...'
  }

  SplashScreen --> SecurityDashboard : Duration: 2200ms

  state SecurityDashboard {
    [*] --> DocumentListView
    DocumentListView --> CategoryFilter : Tap Chip ('Work', 'Legal', etc.)
    DocumentListView --> RealtimeSearch : Type Query in Search Bar
    DocumentListView --> FloatingIngestionMenu : Tap FAB (+)
  }

  SecurityDashboard --> VaultPinScreen : Click '🔒 Security Vault' Card
  SecurityDashboard --> DocumentScanner : Click '📸 Document Scanner' Card
  SecurityDashboard --> WelcomeScreen : Click 'Sign Out' (via SplashScreen 'Logging out...')

  state VaultPinScreen {
    [*] --> PinInput
    PinInput --> PinInput : Enter Digit (Dots Fill 1..3)
    PinInput --> PinCheck : Enter 4th Digit ('1234')
    PinCheck --> UnlockedVault : PIN Valid
    PinCheck --> PinInput : PIN Invalid (Shake & Error Toast)
  }

  UnlockedVault --> SecurityDashboard : Click Back Arrow (←)

  state DocumentScanner {
    [*] --> ViewfinderActive : Pulsing Cyan Bounding Box
    ViewfinderActive --> PageCaptured : Press Camera Shutter Button
    PageCaptured --> IngestionMenu : Click 'Save as PDF'
  }

  state IngestionMenu {
    [*] --> FormInput : Title & Category Chips
    FormInput --> GuardrailCheck : Click 'Encrypt & Save'
    GuardrailCheck --> FormInput : Empty Title/File Discarded
    GuardrailCheck --> SecurityDashboard : Valid Record Saved + Toast
  }

  IngestionMenu --> SecurityDashboard : Click Cancel / Close
```

---

## 2. Core Workflow Flowcharts

### 2.1 Onboarding & Authentication Flow (`Welcome` -> `Login` -> `Splash` -> `Dashboard`)
```mermaid
flowchart TD
  A[User Opens App / Web Demo] --> B[Render WelcomeScreen]
  B --> C[Display Rotating Safe Wheel Animation & Value Proposition]
  C --> D{User Action}
  D -->|Click GET STARTED| E[Transition to LoginScreen]
  E --> F{Select Sign-In Method}
  F -->|Click CONTINUE WITH GOOGLE| G[Show 'AUTHENTICATING...' Toast / State for 500ms]
  F -->|Click Back Arrow ←| B
  G --> H[Render SplashScreen with real assets/icon.png]
  H --> I[Execute Cubic-Bezier Scale & Fade Animation for 2200ms]
  I --> J[Display Subtitle: 'Syncing Nexus Archive...']
  J --> K[Transition to SecurityDashboard]
  K --> L[Show Toast: '✅ OK you are sign in']
```

### 2.2 Document Scanning & Categorization Flow (`Scanner` -> `Ingestion` -> `Dashboard`)
```mermaid
flowchart TD
  A[Dashboard: User Taps FAB + or 'Document Scanner' Card] --> B[Open DocumentScanner Viewfinder]
  B --> C[ML Kit Vision Engine Runs Edge Detection]
  C --> D[Render Cyan Overlay on Detected Page Corners]
  D --> E[User Taps Shutter Capture Button]
  E --> F[Perspective Correction & Auto-Crop Applied]
  F --> G[Update Page Count Badge: 'Pages: 1']
  G --> H{Next Action}
  H -->|Scan Another Page| C
  H -->|Click 'Save as PDF'| I[Open IngestionMenu Modal]
  I --> J[User Enters Document Title & Selects Category Chip e.g. 'Work']
  J --> K[User Clicks 'Encrypt & Save to Vault']
  K --> L{Check Guardrails: !title && !file}
  L -->|Empty| M[Discard Modal without Saving]
  L -->|Valid / Smart Title Inferred| N[Encrypt Blob via AES-GCM & Save to SQLCipher]
  N --> O[Append Document Card to Active Dashboard List]
  O --> P[Show Success Snackbar & Close Modal]
```

### 2.3 Security Vault Verification Flow (`PIN Keypad` -> `Unlocked Vault`)
```mermaid
flowchart TD
  A[User Taps '🔒 Security Vault' Card on Dashboard] --> B[Open VaultPinScreen Keypad]
  B --> C[Display 4 Empty PIN Dots & Digital Pad]
  C --> D[User Enters Digit 1, 2, 3]
  D --> E[Highlight Dots with Cyan Glow .pin-dot.filled]
  E --> F[User Enters Digit 4]
  F --> G[Execute PBKDF2 Hash Verification against Keychain Salt]
  G --> H{Is PIN == '1234'?}
  H -->|Yes| I[Unlock SQLCipher Vault Key]
  I --> J[Transition to UnlockedVault Screen]
  J --> K[Display Encrypted Confidential Records]
  H -->|No| L[Trigger Keypad Shake Animation]
  L --> M[Display Error Toast: 'Invalid PIN. Try again.']
  M --> N[Reset PIN Dots to Empty]
```

### 2.4 Offline Cloud Sync Queue Flow
```mermaid
flowchart TD
  A[Document Saved Locally to SQLCipher Database] --> B{Check Network Connectivity}
  B -->|No Internet / Offline| C[Set sync_status = 'pending']
  C --> D[Display Cloud Icon with Muted Badge on Card]
  D --> E[Background OS Connectivity Listener Waiting...]
  E -->|Network Restored Wi-Fi/Cellular| F[Trigger Batch Sync Worker]
  B -->|Online| F
  F --> G[Update sync_status = 'uploading']
  G --> H[Stream Encrypted Blob to Cloudinary Endpoint]
  H --> I{Upload Result}
  I -->|Success 200 OK| J[Receive Cloud CDN URL]
  J --> K[Update DB record: sync_status = 'synced', cloud_url = URL]
  K --> L[Update Card Icon to Green Checkmark Check-Gold]
  I -->|Failure / Timeout| M[Update DB record: sync_status = 'error']
  M --> N[Schedule Exponential Backoff Retry]
```

---

## 3. Edge Cases & Exception Handling

1. **App Backgrounding During Active Scanning**:
   - *Trigger*: User receives a phone call while `DocumentScanner` is open with 3 pages captured.
   - *Handling*: The un-ingested page buffers (`temp_page_1..3.jpg`) are cached inside the application temporary directory (`getTemporaryDirectory()`). Upon returning, the scanner restores the session and page count badge without data loss.
2. **Missing Document Title on Save**:
   - *Trigger*: User leaves the title input blank in `IngestionMenu` after scanning a tax form.
   - *Handling*: Per user guardrails (`Smart Title Fallback`), the system extracts the first line of OCR text (e.g., `Form 1040 Individual Income Tax`) and applies it as the record title. If no OCR text exists, it generates a timestamped name (`Scan_2026-07-17_2048`).
3. **Repeated Invalid PIN Attempts**:
   - *Trigger*: User enters an incorrect PIN more than 5 consecutive times on `VaultPinScreen`.
   - *Handling*: The keypad triggers an exponential lockout timer (`30s -> 60s -> 5m`) and logs a security warning toast (`Too many attempts. Keypad locked for 30s.`).
