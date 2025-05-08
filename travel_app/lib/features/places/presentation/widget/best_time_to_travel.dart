// lib/features/places/presentation/screens/city_details_screen.dart

import 'package:flutter/material.dart';
// Import helpers and providers
import 'package:travel_app/features/places/presentation/controllers/helper.dart';

  Widget buildBestTimeSection(
    BuildContext context,
   List<TravelPeriod> parsedTravelPeriods, 
    String? rawBestTimeText,
  ) {
    // Your existing implementation for the best time carousel or raw text
    if (parsedTravelPeriods.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Best Time to Travel:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: parsedTravelPeriods.length,
              // Add some padding around the list
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 4,
              ), // Adjust horizontal if needed
              itemBuilder: (context, index) {
                final period = parsedTravelPeriods[index];
                // --- Create a Card for each period ---
                return Container(
                  width: 200, // Adjust width as needed
                  margin: EdgeInsets.only(
                    right: index < parsedTravelPeriods.length - 1 ? 12.0 : 0,
                  ), // Add spacing between cards
                  child: Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias, // Good for consistency
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center, // Center content vertically
                        children: [
                          Text(
                            period.when,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2, // Allow wrapping for longer 'when'
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (period.why.isNotEmpty) ...[
                            const SizedBox(
                              height: 6,
                            ), // Space between when and why
                            Expanded(
                              // Allow 'why' text to fill remaining space
                              child: Text(
                                period.why,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[700]),
                                // Allow multiple lines for reason
                                overflow:
                                    TextOverflow
                                        .ellipsis, // Add ellipsis if too long
                                maxLines: 3, // Limit max lines
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
                // --- End Card ---
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else if (rawBestTimeText != null && rawBestTimeText.isNotEmpty) {
      return Column(/* ... Raw Text Fallback ... */);
    } else {
      return const SizedBox.shrink();
    }
  }
