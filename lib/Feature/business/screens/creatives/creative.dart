import 'package:flutter/material.dart';

class CreativesScreen extends StatelessWidget {
  const CreativesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final creatives = <CreativeItem>[
      CreativeItem(
        imageUrl:
        'https://images.pexels.com/photos/3760852/pexels-photo-3760852.jpeg',
        showAddCreativeCta: false,
      ),
      CreativeItem(
        imageUrl:
        'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg',
        showAddCreativeCta: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Creatives',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: creatives.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return CreativeCard(item: creatives[index]);
        },
      ),
    );
  }
}

/// ======== DATA MODEL ========

class CreativeItem {
  final String imageUrl;
  final bool showAddCreativeCta;

  CreativeItem({
    required this.imageUrl,
    this.showAddCreativeCta = false,
  });
}

/// ======== CARD WIDGET ========

class CreativeCard extends StatelessWidget {
  const CreativeCard({super.key, required this.item});

  final CreativeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // IMAGE + optional "Add Creative" overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 3.3, // tall square-ish image
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // Example "READY TO USE" label at top center (optional)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'READY TO USE POST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Cyan "+ Add Creative" pill for second card
                if (item.showAddCreativeCta)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C4E8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        // handle add creative tap
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Creative',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Share / Download / Delete row
          Row(
            children: [
              // Share button (black)
              Expanded(
                flex: 4,
                child: _bigActionButton(
                  background: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  icon: Icons.ios_share,
                  label: 'Share',
                  onTap: () {
                    // share action
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Download button (white with grey border)
              Expanded(
                flex: 4,
                child: _bigActionButton(
                  background: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.grey.shade300,
                  icon: Icons.download_rounded,
                  label: 'Download',
                  onTap: () {
                    // download action
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Delete icon button (red)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF4D4D)),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // delete action
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFF4D4D),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shared button builder for Share / Download
  Widget _bigActionButton({
    required Color background,
    required Color textColor,
    required Color borderColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}