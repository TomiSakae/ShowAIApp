import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String) onTagSearch;
  final List<String> allTags;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
    required this.onTagSearch,
    required this.allTags,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _showTagDropdown = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _showTagDropdown = !_showTagDropdown;
      if (_showTagDropdown) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2F4E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm công cụ AI...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            widget.onSearch(value);
                          }
                        },
                      ),
                    ),
                    // Tag Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _toggleDropdown,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.tag,
                            color: _showTagDropdown
                                ? const Color(0xFF6C7DFF)
                                : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tags Section
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showTagDropdown ? null : 0,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.allTags.map((tag) {
                        return FilterChip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          selected: false,
                          onSelected: (_) {
                            widget.onTagSearch(tag);
                            _toggleDropdown();
                          },
                          backgroundColor: const Color(0xFF363B64),
                          selectedColor: const Color(0xFF6C7DFF),
                          checkmarkColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
