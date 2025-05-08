// city_map_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CityMapSection extends StatefulWidget { // CHANGED to StatefulWidget
  final double latitude;
  final double longitude;
  final String cityName;

  const CityMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  @override
  State<CityMapSection> createState() => _CityMapSectionState();
}

class _CityMapSectionState extends State<CityMapSection> { // NEW State class
  final MapController _mapController = MapController(); // Initialize MapController

  @override
  void dispose() {
    _mapController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _zoomIn() {
    // Note: flutter_map's move method takes center and zoom.
    // We need to get the current center if we only want to zoom.
    // Or, simpler, just increase zoom without changing center explicitly if current zoom is known.
    // However, a direct zoom method is _mapController.setZoom(currentZoom + 1);
    // For simplicity, let's use move which also sets center.

    // A more direct way to zoom:
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 1) { // Prevent zooming out too much
      _mapController.move(_mapController.camera.center, currentZoom - 1);
    }
  }

  void _recenter() {
    _mapController.move(
      LatLng(widget.latitude, widget.longitude),
      12.0, // Reset to initial zoom, or store initial zoom if it can change
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.latitude == 0.0 && widget.longitude == 0.0) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        height: 200,
        child: Text(
          "Map data (latitude/longitude) is not available for ${widget.cityName}.",
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Text(
              "Location of ${widget.cityName}",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: Stack( // Use Stack to overlay controls on the map
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FlutterMap(
                    mapController: _mapController, // Assign the controller
                    options: MapOptions(
                      initialCenter: LatLng(widget.latitude, widget.longitude),
                      initialZoom: 12.0,
                      // onMapEvent: (event) { // Optional: listen to map events if needed
                      //   if (event is MapEventMove || event is MapEventRotate) {
                      //     // Could update some state here if you want to track current center/zoom
                      //   }
                      // },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(widget.latitude, widget.longitude),
                            child: Tooltip(
                              message: widget.cityName,
                              child: Icon(
                                Icons.location_pin,
                                color: theme.colorScheme.primary,
                                size: 40.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // --- MAP CONTROLS ---
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Important for Column in Stack
                    children: <Widget>[
                      FloatingActionButton.small(
                        heroTag: 'zoomInFabMapSection', // Unique heroTag
                        onPressed: _zoomIn,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                        foregroundColor: theme.colorScheme.onSurface,
                        elevation: 2,
                        child: const Icon(Icons.add),
                        tooltip: 'Zoom In',
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoomOutFabMapSection', // Unique heroTag
                        onPressed: _zoomOut,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                        foregroundColor: theme.colorScheme.onSurface,
                        elevation: 2,
                        child: const Icon(Icons.remove),
                        tooltip: 'Zoom Out',
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'recenterFabMapSection', // Unique heroTag
                        onPressed: _recenter,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                        foregroundColor: theme.colorScheme.onSurface,
                        elevation: 2,
                        child: const Icon(Icons.my_location),
                        tooltip: 'Recenter',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}