import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/website.dart';
import '../widgets/website_card.dart';

class SearchPage extends StatefulWidget {
  final String? initialSearchTerm;
  final bool isTagSearch;

  const SearchPage({
    Key? key,
    this.initialSearchTerm,
    this.isTagSearch = false,
  }) : super(key: key);

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
    if (widget.initialSearchTerm != null) {
      _performSearch(widget.initialSearchTerm!, isTag: widget.isTagSearch);
    }
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

  void _performSearch(String searchTerm, {bool isTag = false}) {
    _handleSearch(searchTerm, isTag: isTag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Tự động focus khi vào màn hình
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm công cụ AI...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: (value) => _performSearch(value),
        ),
      ),
      body: Column(
        children: [
          // Tags scroll horizontally
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allTags.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: ActionChip(
                    label: Text(
                      _allTags[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.grey[800],
                    onPressed: () =>
                        _handleSearch(_allTags[index], isTag: true),
                  ),
                ),
              ),
            ),
          ),
          if (_displayTerm.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
