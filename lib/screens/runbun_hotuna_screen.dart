// lib/screens/runbun_hotuna_screen.dart

import 'package:flutter/material.dart';
import '../models/photo_quiz_model.dart';
import '../data/photo_quiz_data.dart';
import 'runbun_hotuna_detail_screen.dart';

class RunbunHotunaScreen extends StatefulWidget {
  const RunbunHotunaScreen({super.key});

  @override
  State<RunbunHotunaScreen> createState() => _RunbunHotunaScreenState();
}

class _RunbunHotunaScreenState extends State<RunbunHotunaScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  List<PhotoQuizItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  void _loadAllItems() {
    setState(() {
      _allItems = PhotoQuizData.getAllItems();
    });
  }

  List<PhotoQuizItem> get _filteredItems {
    var items = _allItems;

    // Filter by category
    if (_selectedCategory != 'all') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final hausaMatch = item.hausaName.toLowerCase().contains(_searchQuery.toLowerCase());
        final englishMatch = item.englishName.toLowerCase().contains(_searchQuery.toLowerCase());
        return hausaMatch || englishMatch;
      }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Runbun Hotuna',
          style: TextStyle(color: Color(0xFFFFB300)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nemo hoto...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB300)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Category filter
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('all', 'Gaba ɗaya', Icons.grid_view),
                    _buildCategoryChip('animals', 'Dabbobi', Icons.pets),
                    _buildCategoryChip('food', 'Abinci', Icons.restaurant),
                    _buildCategoryChip('traditional', 'Gargajiya', Icons.account_balance),
                    _buildCategoryChip('plants', 'Tsire-tsire', Icons.eco),
                    _buildCategoryChip('cities', 'Birane', Icons.location_city),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: _filteredItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ba a sami hoto ba',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Result count
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'hotuna ${_filteredItems.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid of images
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildImageCard(_filteredItems[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : const Color(0xFFFFB300),
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        selectedColor: const Color(0xFFFFB300),
        checkmarkColor: Colors.black,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildImageCard(PhotoQuizItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RunbunHotunaDetailScreen(item: item),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.white38,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Names
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.hausaName,
                    style: const TextStyle(
                      color: Color(0xFFFFB300),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.englishName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}