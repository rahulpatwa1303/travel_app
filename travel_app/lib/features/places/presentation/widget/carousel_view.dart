import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/router/app_router.dart';
// No longer needs direct provider import for likes if passing state via params
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart';
// Import the like button widget (adjust path if necessary)
import 'package:travel_app/widget/floating_heart_button.dart';

class CarouselViewWidget extends StatefulWidget {
  final List<TopPlace> places;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final bool canLoadMore;
  // --- Parameters for Like Functionality ---
  final Set<int> favoritePlaceIds; // Use the Set from the notifier state
  final Function(int placeId, bool isCurrentlyLiked)
  onLikeChanged; // Callback remains (passes CURRENT state)
  final Set<int> placesBeingLiked; // Pass down the loading state
  // --- END Parameters for Like Functionality ---

  const CarouselViewWidget({
    super.key,
    required this.places,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.canLoadMore,
    // --- Update constructor ---
    required this.favoritePlaceIds,
    required this.onLikeChanged,
    required this.placesBeingLiked,
    // --- End Update ---
  });

  @override
  State<CarouselViewWidget> createState() => _CarouselViewWidgetState();
}

class _CarouselViewWidgetState extends State<CarouselViewWidget> {
  late ScrollController _scrollController;
  double _currentScrollOffset = 0.0;

  // Configuration
  final double _maxScale = 1.0;
  final double _minScale = 0.8;
  final double _maxOpacity = 1.0;
  final double _minOpacity = 0.5;
  final double _itemBaseWidth = 280.0;
  final double _itemWidthWithMargin = 280.0 + 8.0;
  final double _scrollThreshold = 200.0;
  // Padding constants for positioning calculation
  final double _cardOuterMarginVertical = 12.0;
  final double _cardOuterMarginHorizontal = 4.0;
  final double _cardInnerImagePadding = 12.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    setState(() {
      _currentScrollOffset = _scrollController.offset;
    });
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (widget.canLoadMore && maxScroll - currentScroll <= _scrollThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double viewportCenter = (MediaQuery.of(context).size.width / 2.0);
    final itemCount = widget.places.length + (widget.isLoadingMore ? 1 : 0);

    return SizedBox(
      height: 450,
      child: ListView.builder(
        cacheExtent: _itemWidthWithMargin * 3,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        padding: const EdgeInsets.only(left: 10),
        itemBuilder: (context, index) {
          // --- Loading Indicator Logic ---
          if (index == widget.places.length && widget.isLoadingMore) {
            return _buildLoadingIndicator();
          }
          if (index >= widget.places.length) {
            return const SizedBox.shrink();
          }
          // --- End Loading Indicator ---

          final place = widget.places[index];
          // Determine state from passed parameters
          final bool isCurrentlyLiked = widget.favoritePlaceIds.contains(
            place.id,
          );
          final bool isLikingThisPlace = widget.placesBeingLiked.contains(
            place.id,
          );

          // Scale/Opacity calculation for the card
          double itemCenter =
              (index * _itemWidthWithMargin) + (_itemWidthWithMargin / 2);
          double difference =
              itemCenter - (_currentScrollOffset + viewportCenter);
          double scaleFactor = (difference.abs() / (_itemWidthWithMargin * 1.5))
              .clamp(0.0, 1.0);
          double scale = _maxScale - (scaleFactor * (_maxScale - _minScale));
          scale = scale.clamp(_minScale, _maxScale);
          double opacityFactor =
              (difference.abs() / (_itemWidthWithMargin * 1.0)).clamp(0.0, 1.0);
          double opacity =
              _maxOpacity - (opacityFactor * (_maxOpacity - _minOpacity));
          opacity = opacity.clamp(_minOpacity, _maxOpacity);

          final heroTag = 'place-image-${place.id}';
          // --- OUTER STACK FOR LAYERING CARD AND BUTTON ---
          return Stack(
            children: [
              // --- CHILD 1: The Card structure (fades/scales) ---
              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    // Helps define bounds for Positioned
                    width: _itemBaseWidth,
                    margin: EdgeInsets.symmetric(
                      horizontal: _cardOuterMarginHorizontal,
                      vertical: _cardOuterMarginVertical,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          final detailPath = AppRoutePaths.cityDetails
                              .replaceFirst(':placeId', place.id.toString());
                          // detailPath should now be '/place/199' (if place.id is 199)
                          print(
                            'Navigating to: $detailPath',
                          ); // Add this print statement
                          context.push(detailPath,extra: place);
                        },
                        child: Column(
                          // Card's internal Column
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Area
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(_cardInnerImagePadding),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Hero(
                                    tag: heroTag,
                                    child: _buildPlaceImage(place),
                                  ),
                                ),
                              ),
                            ),
                            // Text Area
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                _cardInnerImagePadding,
                                0,
                                _cardInnerImagePadding,
                                _cardInnerImagePadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    place.country.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ), // End Card's Column
                    ), // End Card
                  ), // End Container
                ), // End Transform.scale
              ), // End Opacity
              // --- CHILD 2: The Like Button (directly in OUTER Stack) ---
              // Use this for places
              // Positioned( // <--- Correctly placed here
              //   // Calculate position relative to the Container above
              //   top: _cardOuterMarginVertical + _cardInnerImagePadding - 4, // Adjust for visual alignment
              //   right: _cardOuterMarginHorizontal + _cardInnerImagePadding - 4, // Adjust for visual alignment
              //   child: isLikingThisPlace
              //       ? Container( // Spinner when liking/disliking
              //           padding: const EdgeInsets.all(4.0),
              //           width: 36, // Fixed size for spinner container
              //           height: 36,
              //           decoration: BoxDecoration( // Optional: Add background scrim for spinner
              //              color: Colors.black.withOpacity(0.3),
              //              shape: BoxShape.circle,
              //           ),
              //           child: const CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              //         )
              //       : Material( // Like Button when not loading
              //           color: Colors.transparent,
              //           borderRadius: BorderRadius.circular(20),
              //           child: FloatingHeartLikeButton(
              //             initialIsLiked: isCurrentlyLiked,
              //             size: 28,
              //             onLikedChanged: (bool liked) {
              //               // Pass the *current* liked status to the handler
              //               widget.onLikeChanged(place.id, isCurrentlyLiked);
              //             },
              //           ),
              //         ),
              // ), // --- End Positioned ---
            ], // --- End Outer Stack Children ---
          ); // --- End Outer Stack ---
        },
      ),
    );
  }

  // Helper to build the loading indicator at the end
  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        width: _itemBaseWidth * 0.5, // Smaller than a full card
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  // Helper widget for handling image loading
  Widget _buildPlaceImage(TopPlace place) {
    final imageUrl = place.imageUrl;
    final bool useDefault =
        place.usesDefaultImage || imageUrl == null || imageUrl.isEmpty;

    if (useDefault) {
      return Image.asset(
        'assets/city.png', // Your default asset
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity, // Ensure it fills the Expanded space
      );
    } else {
      return Image.network(
        imageUrl,
        key: ValueKey(imageUrl), // Good practice for lists
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity, // Ensure it fills the Expanded space
        errorBuilder:
            (context, error, stackTrace) => Image.asset(
              'assets/city.png', // Fallback on network error
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
  }
}
