import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'category_service.g.dart';

@Riverpod(keepAlive: true)
class CategoryService extends _$CategoryService {
  static const _key = 'user_categories';
  static const _defaultCategories = ['IDs', 'Receipts', 'Contracts', 'Other'];

  @override
  List<String> build() {
    _loadCategories();
    return _defaultCategories;
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key);
    if (stored != null && stored.isNotEmpty) {
      state = stored;
    } else {
      state = _defaultCategories;
    }
  }

  Future<void> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    
    // Case insensitive check
    if (state.any((c) => c.toLowerCase() == trimmed.toLowerCase())) return;
    
    final newList = [...state, trimmed];
    state = newList;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newList);
  }

  Future<void> removeCategory(String category) async {
    final newList = state.where((c) => c != category).toList();
    if (newList.isEmpty) newList.add('Other'); // Absolute fallback
    state = newList;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newList);
  }
}
