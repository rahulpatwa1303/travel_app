import 'package:flutter/material.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart';

class CarouselViewWidget extends StatefulWidget {
  final List<TopPlace> places;

  const CarouselViewWidget({super.key, required this.places});

  @override
  State<CarouselViewWidget> createState() => _CarouselViewWidgetState();
}

class _CarouselViewWidgetState extends State<CarouselViewWidget> {
  late ScrollController _scrollController;
  double _currentScrollOffset = 0.0;

  // --- Configuration for the effect ---
  // How much larger the center item should be
  final double _maxScale = 1.0;
  final double _minScale = 0.8;
  // How much the non-center items should fade
  final double _maxOpacity = 1.0;
  final double _minOpacity = 0.5;
  // The width of each item *before* scaling
  final double _itemBaseWidth = 280.0; // Adjust as needed
  // Total width including margin for calculations
  final double _itemWidthWithMargin =
      280.0 + 8.0; // itemBaseWidth + horizontal margin * 2
  // --- End Configuration ---

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // --- Initial centering attempt (optional but nice) ---
    // Calculate initial offset to center the first item (or near it)
    // This requires knowing the screen width, which is tricky in initState.
    // A post-frame callback is safer, or just let the user scroll initially.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted && _scrollController.hasClients) {
    //     double screenWidth = MediaQuery.of(context).size.width;
    //     double initialOffset = (_itemWidthWithMargin / 2.0) - (screenWidth / 2.0);
    //     // Clamp offset to valid range
    //     initialOffset = initialOffset.clamp(
    //       _scrollController.position.minScrollExtent,
    //       _scrollController.position.maxScrollExtent,
    //     );
    //      // Uncomment below to jump initially (might feel abrupt)
    //     // _scrollController.jumpTo(initialOffset);
    //     // setState(() {
    //     //   _currentScrollOffset = initialOffset;
    //     // });
    //   }
    // });
    // --- End Initial centering ---
  }

  void _onScroll() {
    if (mounted && _scrollController.hasClients) {
      setState(() {
        _currentScrollOffset = _scrollController.offset;
      });
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
    // Get the center position of the viewport (ListView)
    double viewportCenter = (MediaQuery.of(context).size.width / 2.0);

    return SizedBox(
      // Increase height slightly to accommodate scaled items
      height: 450,
      child: ListView.builder(
        cacheExtent: 9999,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.places.length,
        padding: const EdgeInsets.only(left: 2),
        // Add padding so items can visually center nicely
        // padding: EdgeInsets.symmetric(
        //   horizontal: viewportCenter - (_itemBaseWidth / 2),
        // ),
        itemBuilder: (context, index) {
          final place = widget.places[index];

          // Calculate the center position of *this* specific item in the scroll view
          double itemCenter =
              (index * _itemWidthWithMargin) + (_itemWidthWithMargin / 2);

          // Calculate the difference between the item's center and the current scroll center
          double difference =
              itemCenter - (_currentScrollOffset + viewportCenter);

          // Calculate scale based on difference - closer to center = larger scale
          // Normalize difference relative to an item's width (or viewport width) for consistent scaling
          double scaleFactor = (difference.abs() / (_itemWidthWithMargin * 1.5))
              .clamp(0.0, 1.0); // Adjust 1.5 factor
          double scale = _maxScale - (scaleFactor * (_maxScale - _minScale));
          scale = scale.clamp(
            _minScale,
            _maxScale,
          ); // Ensure scale is within bounds

          // Calculate opacity based on difference - closer to center = full opacity
          double opacityFactor = (difference.abs() /
                  (_itemWidthWithMargin * 1.0))
              .clamp(0.0, 1.0); // Adjust 1.0 factor
          double opacity =
              _maxOpacity - (opacityFactor * (_maxOpacity - _minOpacity));
          opacity = opacity.clamp(
            _minOpacity,
            _maxOpacity,
          ); // Ensure opacity is within bounds

          // --- Optional: Add 3D Rotation/Perspective ---
          // double rotationY = (difference / (_itemWidthWithMargin * 2.0)).clamp(-0.5, 0.5); // Adjust factors
          // rotationY *= -1; // Adjust direction if needed
          // --- End Rotation ---

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              // --- Optional: Apply Rotation ---
              // child: Transform(
              //   transform: Matrix4.identity()
              //     ..setEntry(3, 2, 0.001) // Perspective
              //     ..rotateY(rotationY), // Apply Y rotation
              //   alignment: FractionalOffset.center,
              // --- End Rotation Wrapper ---
              child: Container(
                width: _itemBaseWidth, // Use the base width here
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias, // Important for image clipping
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Placeholder - Replace with actual image loading
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),

                            child: Container(
                              // Use Image.network for real images

                              // Placeholder:
                              color:
                                  Colors
                                      .blueGrey[300], // Changed color slightly
                              child:
                                  place.usesDefaultImage
                                      ? Image.asset(
                                        'assets/city.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                      : Image.network(
                                        place.imageUrl!,
                                        key: ValueKey(place.imageUrl),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  'assets/city.png',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                          12.0,
                        ), // Increased padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              place.tags!["addr:city"] ?? '',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.normal),
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
              // ) // Closing bracket for optional Transform widget
            ),
          );
        },
      ),
    );
  }
}
