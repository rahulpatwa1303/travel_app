import 'package:flutter/material.dart';
import 'package:travel_app/core/networking/fetch_location_file.dart'; // Adjust import
import 'package:travel_app/features/places/domain/top_place_model.dart'; // Adjust import
import 'dart:developer' as developer;
// Optional: import 'package:cached_network_image/cached_network_image.dart';

class CarouselItemCard extends StatefulWidget {
  final TopPlace place;
  final WikimediaApiService apiService;
  final double scale;
  final double opacity;
  final double itemBaseWidth;

  const CarouselItemCard({
    super.key,
    required this.place,
    required this.apiService,
    required this.scale,
    required this.opacity,
    required this.itemBaseWidth,
  });

  @override
  State<CarouselItemCard> createState() => _CarouselItemCardState();
}

class _CarouselItemCardState extends State<CarouselItemCard> {
  late Future<String?> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the image URL ONCE when the item card state is initialized
    _imageUrlFuture = widget.apiService.fetchImageUrlForPoi(
      widget.place.name,
      widget.place.tags, // Pass the tags
    );
    developer.log('initState: Fetching image for ${widget.place.name}', name: 'CarouselItemCard');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> currentTags = widget.place.tags ?? {};

    return FutureBuilder<String?>(
      future: _imageUrlFuture, // Use the stored future!
      builder: (context, snapshot) {
        Widget imageDisplayWidget;

        // --- Image Display Logic (same as before) ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          imageDisplayWidget = const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          if (snapshot.hasError) {
            developer.log('FutureBuilder error: ${snapshot.error}', name: 'CarouselItemCard');
          } else {
            developer.log('FutureBuilder completed with null data for ${widget.place.name}', name: 'CarouselItemCard');
          }
          imageDisplayWidget = Container(
            color: Colors.blueGrey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.white70),
            ),
          );
        } else {
          final imageUrl = snapshot.data!;
          // Use Image.network or CachedNetworkImage
          imageDisplayWidget = Image.network( // Consider CachedNetworkImage for better performance
            imageUrl,
            key: ValueKey(imageUrl), // Add a key for better widget identity
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
            },
            errorBuilder: (context, error, stackTrace) {
              developer.log('Image.network failed to load $imageUrl: $error', name: 'CarouselItemCard');
              return Container(
                color: Colors.blueGrey[300],
                child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.white70)),
              );
            },
          );
           // Example with CachedNetworkImage (add dependency first)
           // imageDisplayWidget = CachedNetworkImage(
           //    imageUrl: imageUrl,
           //    key: ValueKey(imageUrl),
           //    fit: BoxFit.cover,
           //    width: double.infinity,
           //    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
           //    errorWidget: (context, url, error) {
           //       developer.log('CachedNetworkImage failed to load $url: $error', name: 'CarouselItemCard');
           //       return Container(
           //          color: Colors.blueGrey[300],
           //          child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.white70)),
           //       );
           //    },
           // );
        }
        // --- End Image Display Logic ---


        // --- Structure of your Card (pass scale/opacity from widget props) ---
        return Opacity(
          opacity: widget.opacity, // Use widget.opacity
          child: Transform.scale(
            scale: widget.scale, // Use widget.scale
            child: Container(
              width: widget.itemBaseWidth, // Use widget.itemBaseWidth
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: imageDisplayWidget, // <-- Use the built image widget
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2), // Small spacing
                          Text(
                            currentTags['addr:city'] ?? 'Unknown City',
                            style: Theme.of(context).textTheme.bodySmall, // Slightly smaller style
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}