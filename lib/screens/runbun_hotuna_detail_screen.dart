// lib/screens/runbun_hotuna_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/photo_quiz_model.dart';
import '../models/proverb_model.dart';
import '../services/database_service.dart';

class RunbunHotunaDetailScreen extends StatefulWidget {
  final PhotoQuizItem item;

  const RunbunHotunaDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<RunbunHotunaDetailScreen> createState() => _RunbunHotunaDetailScreenState();
}

class _RunbunHotunaDetailScreenState extends State<RunbunHotunaDetailScreen> {
  List<Proverb> _relatedProverbs = [];
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedProverbs();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await DatabaseService.instance.isImageFavorite(widget.item.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _loadRelatedProverbs() async {
    try {
      // Search for proverbs containing the Hausa name as a keyword
      final proverbs = await DatabaseService.instance.searchProverbs(widget.item.hausaName);

      setState(() {
        _relatedProverbs = proverbs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        // Remove from favorites
        await DatabaseService.instance.removeFavoriteImage(widget.item.id);
        setState(() {
          _isFavorite = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yanzu baya daga jerin abubuwan da aka fi so'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add to favorites
        await DatabaseService.instance.addFavoriteImage({
          'itemId': widget.item.id,
          'category': widget.item.category,
          'hausaName': widget.item.hausaName,
          'englishName': widget.item.englishName,
          'imagePath': widget.item.imagePath,
          'addedAt': DateTime.now().toIso8601String(),
        });
        setState(() {
          _isFavorite = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An adana a cikin jerin abubuwan da aka fi so ❤️'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ba daidai bane! Sake gwadawa'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF1E1E1E),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.asset(
                    widget.item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF2A2A2A),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.white38,
                        ),
                      );
                    },
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Names at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.hausaName,
                          style: const TextStyle(
                            color: Color(0xFFFFB300),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.englishName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description if available
                  if (widget.item.description != null) ...[
                    _buildSectionHeader('Bayani', Icons.info_outline),
                    const SizedBox(height: 12),
                    Card(
                      color: const Color(0xFF1E1E1E),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.item.description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Cultural note if available
                  if (widget.item.culturalNote != null) ...[
                    _buildSectionHeader('Bayanin Al\'ada', Icons.star_outline),
                    const SizedBox(height: 12),
                    Card(
                      color: const Color(0xFF2A2A2A),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFFB300),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.item.culturalNote!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Related Proverbs Section
                  _buildSectionHeader(
                    'Karin Magana mai alaƙa da ${widget.item.hausaName}',
                    Icons.format_quote,
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFB300),
                        ),
                      ),
                    )
                  else if (_relatedProverbs.isEmpty)
                    Card(
                      color: const Color(0xFF1E1E1E),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 50,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ba a sami Karin Magana mai alaƙa da "${widget.item.hausaName}" ba!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        // Count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Karin Magana ${_relatedProverbs.length}',
                            style: const TextStyle(
                              color: Color(0xFFFFB300),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Proverbs list
                        ..._relatedProverbs.map((proverb) => _buildProverbCard(proverb)),
                      ],
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFFB300),
          size: 24,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFB300),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProverbCard(Proverb proverb) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showProverbDetail(proverb);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hausa proverb with highlight
              RichText(
                text: _buildHighlightedText(
                  proverb.hausa,
                  widget.item.hausaName,
                ),
              ),

              if (proverb.english != null) ...[
                const SizedBox(height: 8),
                Text(
                  proverb.english!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Tap hint
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Danna dan samun cikakken bayani',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(String text, String highlight) {
    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerHighlight);

    while (index >= 0) {
      // Add text before highlight
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: text.substring(index, index + highlight.length),
        style: const TextStyle(
          color: Color(0xFFFFB300),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          backgroundColor: Color(0x33FFB300),
        ),
      ));

      start = index + highlight.length;
      index = lowerText.indexOf(lowerHighlight, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ));
    }

    return TextSpan(children: spans);
  }

  void _showProverbDetail(Proverb proverb) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Hausa proverb
                Text(
                  proverb.hausa,
                  style: const TextStyle(
                    color: Color(0xFFFFB300),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),

                if (proverb.english != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    proverb.english!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],

                if (proverb.meaningHausa != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Ma\'ana:',
                    style: TextStyle(
                      color: Color(0xFFFFB300),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    proverb.meaningHausa!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],

                if (proverb.meaningEnglish != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    proverb.meaningEnglish!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}