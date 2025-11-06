// lib/screens/proverbs_library_screen.dart

import 'package:flutter/material.dart';
import '../models/proverb_model.dart';
import '../services/database_service.dart';
import '../data/proverbs_data.dart';
import 'proverb_detail_screen.dart';

class ProverbsLibraryScreen extends StatefulWidget {
  const ProverbsLibraryScreen({super.key});

  @override
  State<ProverbsLibraryScreen> createState() => _ProverbsLibraryScreenState();
}

class _ProverbsLibraryScreenState extends State<ProverbsLibraryScreen> {
  List<Proverb> _allProverbs = [];
  List<Proverb> _displayedProverbs = [];
  String? _selectedLetter;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProverbs();
  }

  Future<void> _loadProverbs() async {
    setState(() => _isLoading = true);

    final proverbs = await DatabaseService.instance.getAllProverbs();

    setState(() {
      _allProverbs = proverbs;
      _displayedProverbs = proverbs;
      _isLoading = false;
    });
  }

  void _filterByLetter(String letter) {
    setState(() {
      _selectedLetter = letter;
      _searchController.clear();
      _displayedProverbs = _allProverbs
          .where((p) => p.firstLetter == letter)
          .toList();
    });
  }

  void _searchProverbs(String query) {
    if (query.isEmpty) {
      setState(() {
        _displayedProverbs = _selectedLetter != null
            ? _allProverbs.where((p) => p.firstLetter == _selectedLetter).toList()
            : _allProverbs;
      });
      return;
    }

    setState(() {
      _displayedProverbs = _allProverbs
          .where((p) =>
      p.hausa.toLowerCase().contains(query.toLowerCase()) ||
          (p.english?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedLetter = null;
      _searchController.clear();
      _displayedProverbs = _allProverbs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hausaAlphabet = ProverbsData.getHausaAlphabet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karin Magana'),
        actions: [
          if (_selectedLetter != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Share filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchProverbs,
              style: const TextStyle(color: Colors.black), // Black text for visibility
              decoration: InputDecoration(
                hintText: 'Nemo karin magana...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    _searchProverbs('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Alphabet Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hausaAlphabet.length,
              itemBuilder: (context, index) {
                final letter = hausaAlphabet[index];
                final isSelected = letter == _selectedLetter;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(letter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByLetter(letter);
                      } else {
                        _clearFilter();
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_displayedProverbs.length} Karin Magana',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedLetter != null)
                  Chip(
                    label: Text('Harafi: $_selectedLetter'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: _clearFilter,
                  ),
              ],
            ),
          ),

          // Proverbs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedProverbs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Babu karin magana da ya dace',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _clearFilter,
                    child: const Text('Share filter'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _displayedProverbs.length,
              itemBuilder: (context, index) {
                final proverb = _displayedProverbs[index];
                return _buildProverbCard(context, proverb);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProverbCard(BuildContext context, Proverb proverb) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProverbDetailScreen(proverb: proverb),
            ),
          ).then((_) => _loadProverbs()); // Reload if favorite status changed
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Letter Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    proverb.firstLetter,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Proverb Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proverb.hausa,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (proverb.english != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        proverb.english!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Favorite Icon
              if (proverb.isFavorite)
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}