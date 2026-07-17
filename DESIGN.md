---
name: Nexus Archive
colors:
  surface: '#fbf8ff'
  surface-dim: '#dbd9e1'
  surface-bright: '#fbf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2fb'
  surface-container: '#efecf5'
  surface-container-high: '#eae7ef'
  surface-container-highest: '#e4e1ea'
  on-surface: '#1b1b21'
  on-surface-variant: '#454652'
  inverse-surface: '#303036'
  inverse-on-surface: '#f2eff8'
  outline: '#767683'
  outline-variant: '#c6c5d4'
  surface-tint: '#4c56af'
  primary: '#000666'
  on-primary: '#ffffff'
  primary-container: '#1a237e'
  on-primary-container: '#8690ee'
  inverse-primary: '#bdc2ff'
  secondary: '#4c616c'
  on-secondary: '#ffffff'
  secondary-container: '#cfe6f2'
  on-secondary-container: '#526772'
  tertiary: '#380b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#5c1800'
  on-tertiary-container: '#e17c5a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000767'
  on-primary-fixed-variant: '#343d96'
  secondary-fixed: '#cfe6f2'
  secondary-fixed-dim: '#b4cad6'
  on-secondary-fixed: '#071e27'
  on-secondary-fixed-variant: '#354a53'
  tertiary-fixed: '#ffdbd0'
  tertiary-fixed-dim: '#ffb59d'
  on-tertiary-fixed: '#390c00'
  on-tertiary-fixed-variant: '#7b2e12'
  background: '#fbf8ff'
  on-background: '#1b1b21'
  surface-variant: '#e4e1ea'
typography:
  display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  max-width: 1440px
---

## Brand & Style

The brand personality is rooted in **Modern Utility**: a synthesis of high-performance efficiency and quiet reliability. It is designed for professionals who manage high volumes of critical information and require a digital environment that feels as organized and secure as a physical vault, yet as agile as a modern workspace.

The design style follows a **Modern Corporate** aesthetic with a strong emphasis on **Minimalism**. The interface prioritizes clarity over decoration, using heavy whitespace to reduce cognitive load and a limited, purposeful color palette to drive focus. Every interaction should feel intentional, precise, and instantaneous, evoking a sense of calm control and absolute data integrity.

## Colors

The palette is anchored by **Navy (#1A237E)** to establish authority and trust. **Slate (#455A64)** provides a secondary, neutral layer for supporting UI elements and metadata. 

Backgrounds utilize a series of **Soft Grays** (starting at #F8F9FA) to separate the canvas from the content, while pure white surfaces indicate active workspaces or document containers. 

**Semantic Color Coding** is applied strictly to file identification:
- **Red:** PDF documents.
- **Blue:** Word/Text processing.
- **Green:** Spreadsheets/Data sets.
- **Orange:** Media and Image assets.
- **Amber:** Directory/Folder structures.

This color logic ensures that users can scan complex file lists and instantly categorize their contents without reading labels.

## Typography

The design system utilizes **Inter** exclusively for its exceptional legibility at small sizes and its systematic, utilitarian character. 

**Hierarchy Rules:**
- **Display & Headlines:** Use tighter letter-spacing and heavier weights to anchor pages.
- **Body Text:** Standard weight for maximum readability in document descriptions and metadata.
- **Labels:** Small caps or medium weights are used for utility text like file sizes, timestamps, and status tags to differentiate them from primary content.
- **Scale:** For mobile devices, `display` typography should scale down to 24px (`headline-lg`) to maintain visual balance on narrow viewports.

## Layout & Spacing

This design system employs a **12-column fluid grid** for desktop and a **4-column grid** for mobile. 

- **The 8px Rhythm:** All spacing and component dimensions are increments of 8px (or 4px for fine-tuning).
- **Whitespace:** Use generous padding (24px+) between major sections to prevent the interface from feeling cramped, even when data-heavy.
- **Alignment:** Content is left-aligned by default to support the Western "F-pattern" scanning behavior, which is critical for document browsing.
- **Responsive Behavior:** Sidebars are persistent on desktop (280px width) but collapse into bottom sheets or slide-over menus on mobile to prioritize the document view.

## Elevation & Depth

To maintain a clean, "utility" feel, the system uses **Tonal Layering** rather than heavy shadows. 

- **Level 0 (Background):** Soft Gray (#F8F9FA) - The canvas.
- **Level 1 (Surface):** White (#FFFFFF) - Used for cards, list items, and sidebar navigation. These should have a subtle 1px border (#E0E4E8) instead of a shadow.
- **Level 2 (Floating):** Used for modals, dropdowns, and context menus. These employ a highly diffused, low-opacity shadow (0px 8px 24px rgba(26, 35, 126, 0.08)) to suggest they are lifted off the page.
- **Active State:** Selected items use a subtle Navy tint (5% opacity) to indicate focus without adding visual weight.

## Shapes

The shape language is **Soft**. A 4px (0.25rem) base radius is applied to all standard components (buttons, input fields, and checkboxes) to convey a modern, approachable feel while maintaining professional structural integrity. 

Large containers like document preview cards use the `rounded-lg` (8px) setting. Circular shapes are reserved strictly for user avatars and "Add New" Floating Action Buttons to help them stand out from the rectangular document grid.

## Components

- **Buttons:** Primary buttons use a solid Navy background with white text. Secondary buttons use a Slate outline. Action icons (e.g., "Download", "Share") are monochrome Slate until hovered, at which point they take on the Navy primary color.
- **Document Cards:** Feature a prominent semantic color bar at the top or a large file-type icon. Metadata (size, date) is rendered in `label-md` using a Slate-600 color.
- **Lists:** High-density rows with a 1px bottom border. Hover states are indicated by a change in background color to a very light gray (#F1F3F4).
- **Input Fields:** Flat white background with a 1px Slate-200 border. On focus, the border transitions to Navy 2px. Labels are always visible above the field in `label-sm`.
- **Chips/Status Tags:** Used for document tags (e.g., "Pending", "Approved"). These use low-saturation background tints and high-saturation text of the same hue for maximum accessibility.
- **File Icons:** Line-art style icons with a consistent stroke weight (1.5px) to match the Inter typeface. Icons should be paired with the semantic color logic defined in the Color section.