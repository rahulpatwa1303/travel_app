// lib/features/places/presentation/screens/city_details_screen.dart (Create this file)

import 'package:flutter/material.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart'; // Assuming you might pass the whole object later

class CityDetailsScreen extends StatelessWidget {
  final String placeId; // Received as String from router path parameter

  const CityDetailsScreen({
    super.key,
    required this.placeId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch actual place details using placeId (e.g., using a provider)
    // For now, just display the ID and a placeholder image for Hero

    // Construct the Hero tag EXACTLY as it will be in the source widget
    final heroTag = 'place-image-$placeId';

    return Scaffold(
      appBar: AppBar(
        title: Text('Details for Place $placeId'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hero Animation Destination ---
            Hero(
              tag: heroTag,
              child: Container( // Placeholder container
                 height: 300,
                 color: Colors.blueGrey[300],
                 child: Center(
                   child: Icon(Icons.image, size: 100, color: Colors.white.withOpacity(0.5)),
                 ),
                 // TODO: Replace with actual Image.network or similar once data is fetched
                 // child: Image.network(
                 //   placeDetails.imageUrl, // Replace with actual image URL
                 //   fit: BoxFit.cover,
                 //   width: double.infinity,
                 //   height: 300,
                 // ),
              ),
            ),
            // --- End Hero Animation ---

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Place Name (ID: $placeId)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Country Name',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                  ),
                  // TODO: Add more details fetched based on placeId
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}