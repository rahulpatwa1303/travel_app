// lib/features/places/presentation/widget/place_detail_bottom_sheet.dart (New File)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/domain/place_model.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching maps, calls, websites
// Import your Place model and any relevant providers (e.g., for liking)
// Import your like state provider if you have one for the heart button
// import 'package:your_app_name/features/places/presentation/providers/....dart';

class PlaceDetailBottomSheet extends ConsumerWidget {
  final Place place;

  const PlaceDetailBottomSheet({super.key, required this.place});

  Future<void> _launchMapsUrl(double lat, double lon, String query) async {
    // Universal link that tries to open in native map apps
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}&query_place_id=');
    // More specific for Google Maps: Uri.parse('geo:$lat,$lon?q=${Uri.encodeComponent(query)}');
    // For Apple Maps: Uri.parse('maps://?q=${Uri.encodeComponent(query)}&ll=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback or error message
      print('Could not launch $uri');
    }
  }

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $uri');
    }
  }

  Future<void> _launchBrowser(String urlString) async {
    Uri uri = Uri.parse(urlString);
    if (!uri.hasScheme) {
      uri = Uri.parse('http://$urlString'); // Add scheme if missing
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $uri');
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // final isLiked = ref.watch(yourLikeProviderForPlace(place.id)); // Example for like state

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: SingleChildScrollView( // Make content scrollable if it overflows
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Padding at the very bottom
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Handle for dragging
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

              // Image Banner
              if (place.primaryImageUrl != null && !place.usesDefaultImage)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only( // Only if you want banner to also have rounded top
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: Image.network(
                      place.primaryImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              if (place.primaryImageUrl != null && !place.usesDefaultImage) const SizedBox(height: 16),


              // Content Padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Category & Cuisines
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        Chip(label: Text(place.displayCategory), backgroundColor: theme.primaryColorLight.withOpacity(0.2)),
                        ...place.cuisineTypes.map((cuisine) => Chip(label: Text(cuisine.capitalize()))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Opening Hours (Basic for now)
                    if (place.openingHoursRaw != null && place.openingHoursRaw != "Requires scraping")
                      Row(children: [
                        Icon(Icons.access_time, size: 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(place.openingHoursRaw!, style: theme.textTheme.bodyMedium),
                      ])
                    else if (place.openingHoursRaw == "Requires scraping")
                       Row(children: [
                        Icon(Icons.access_time, size: 18, color: Colors.orangeAccent),
                        const SizedBox(width: 8),
                        Text("Opening hours might be available", style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                      ]),
                    if (place.openingHoursRaw != null) const SizedBox(height: 12),


                    // Address
                    if (place.formattedAddress.isNotEmpty)
                      InkWell( // Make address tappable
                        onTap: (place.latitude != null && place.longitude != null)
                            ? () => _launchMapsUrl(place.latitude!, place.longitude!, place.formattedAddress.isNotEmpty ? place.formattedAddress : place.name)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 10),
                              Expanded(child: Text(place.formattedAddress, style: theme.textTheme.bodyLarge)),
                            ],
                          ),
                        ),
                      ),
                    if (place.formattedAddress.isNotEmpty) const SizedBox(height: 20),

                    // Description
                    if (place.description != null && place.description!.isNotEmpty) ...[
                      Text("About", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(place.description!, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 20),
                    ],


                    // Primary Action: Get Directions
                    if (place.latitude != null && place.longitude != null)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48), // Full width
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () => _launchMapsUrl(place.latitude!, place.longitude!, place.formattedAddress.isNotEmpty ? place.formattedAddress : place.name),
                      ),
                    const SizedBox(height: 12),

                    // Secondary Actions Row
                    Row(
                      children: [
                        // Save/Like Button (Example)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(
                              // isLiked ? Icons.favorite : Icons.favorite_border,
                              // color: isLiked ? Colors.red : null,
                              Icons.favorite_border, // Placeholder
                            ),
                            label: const Text('Save'),
                            onPressed: () {
                              // ref.read(yourLikeProviderForPlace(place.id).notifier).toggleLike();
                              print("Save/Like Tapped for ${place.id}");
                            },
                          ),
                        ),
                        if (place.phone != null && place.phone!.isNotEmpty) ...[
                           const SizedBox(width: 10),
                           Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.call_outlined),
                              label: const Text('Call'),
                              onPressed: () => _launchCaller(place.phone!),
                            ),
                          ),
                        ] else if (place.website != null && place.website!.isNotEmpty) ... [
                           const SizedBox(width: 10),
                           Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.language_outlined),
                              label: const Text('Website'),
                              onPressed: () => _launchBrowser(place.website!),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 20),

                    // View Full Details (Optional)
                    // if (you_have_a_full_detail_screen)
                    //   TextButton(
                    //     onPressed: () {
                    //       Navigator.pop(context); // Close bottom sheet
                    //       // context.push('/place/${place.id}/details'); // Navigate
                    //     },
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text('View Full Details & Reviews', style: TextStyle(color: theme.colorScheme.primary)),
                    //         Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension for capitalizing strings (e.g., for cuisine types)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}