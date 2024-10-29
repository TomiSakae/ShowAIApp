import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/website.dart';
import '../widgets/search_bar.dart';
import '../widgets/website_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _apiService = ApiService();
  List<Website> _websites = [];
  List<String> _allTags = [];
  bool _isLoading = false;
  String? _error;
  String _displayTerm = '';
  bool _isTagSearch = false;

  @override
  void initState() {
    super.initState();
    _loadInitialTags();
  }

  Future<void> _loadInitialTags() async {
    try {
      final result = await _apiService.searchWebsites(query: '');
      setState(() {
        _allTags = List<String>.from(result['tags'] ?? []);
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
      debugPrint('Không thể tải tags: $e');
    }
  }

  Future<void> _handleSearch(String term, {bool isTag = false}) async {
    if (term.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _displayTerm = term;
      _isTagSearch = isTag;
    });

    try {
      final result = await _apiService.searchWebsites(
        query: isTag ? null : term,
        tag: isTag ? term : null,
      );

      setState(() {
        _websites = result['websites'];
        _allTags = result['tags'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2A3284),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SafeArea(
                  child: CustomSearchBar(
                    onSearch: (term) => _handleSearch(term),
                    onTagSearch: (tag) => _handleSearch(tag, isTag: true),
                    allTags: _allTags,
                  ),
                ),
                if (_displayTerm.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _isTagSearch
                          ? 'Kết quả của tag: $_displayTerm'
                          : 'Kết quả của: $_displayTerm',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    if (_websites.isEmpty) {
      return const Center(child: Text('Không tìm thấy kết quả'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _websites.length,
      itemBuilder: (context, index) {
        return WebsiteCard(
          website: _websites[index],
          onTagClick: (tag) => _handleSearch(tag, isTag: true),
        );
      },
    );
  }
}
