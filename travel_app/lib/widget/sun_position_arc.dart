// lib/widgets/sun_position_arc.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async'; // Import async for Timer (used for tooltip auto-hide)
import 'package:intl/intl.dart'; // For time formatting

// --- Custom Painter ---
// Paints the arc, the sun (if visible), and the endpoint markers
class _SunArcPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime; // Current time for the location
  final Color arcColor;
  final Color sunColor;
  final double strokeWidth;
  final double sunRadius;
  final ValueChanged<Offset> onSunPositionCalculated;
  final bool isSunVisible; // Flag to determine if sun should be drawn

  _SunArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
    required this.arcColor,
    required this.sunColor,
    required this.strokeWidth,
    required this.sunRadius,
    required this.onSunPositionCalculated,
    required this.isSunVisible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint setup
    final Paint arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint sunPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;

    // Calculations
    final double radius = size.width / 2;
    // Center arc Y adjusted for sun radius to sit on the baseline
    final Offset center = Offset(radius, size.height - sunRadius);
    Offset sunPosition = Offset.zero; // Default

    // Calculate progress and position, clamping to the arc ends even if sun isn't visible
    final totalDuration = sunset.difference(sunrise).inMinutes;
    final elapsedDuration = currentTime.difference(sunrise).inMinutes;
    // Calculate progress relative to sunrise/sunset, clamp between 0 and 1
    double progress = (totalDuration > 0)
        ? (elapsedDuration / totalDuration).clamp(0.0, 1.0)
        : (currentTime.isBefore(sunrise) ? 0.0 : 1.0); // Clamp to start or end if duration invalid

    final double sunAngle = math.pi - (progress * math.pi); // Angle from 180 (left) to 0 (right)
    final double sunX = center.dx + radius * math.cos(sunAngle);
    final double sunY = center.dy - radius * math.sin(sunAngle); // Y decreases upwards
    sunPosition = Offset(sunX, sunY);


    // Always report the calculated position (for tap target) via callback after the frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
        onSunPositionCalculated(sunPosition);
    });

    // --- Drawing ---
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    // Draw the background semi-circle arc
    canvas.drawArc(arcRect, math.pi, math.pi, false, arcPaint);

    // Draw sun ONLY if it's currently visible (between sunrise and sunset)
    if (isSunVisible) {
        canvas.drawCircle(sunPosition, sunRadius, sunPaint);
    }

    // Always draw small markers at sunrise/sunset ends
    final Paint endMarkerPaint = Paint()..color = arcColor.withOpacity(0.7)..style=PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 3, endMarkerPaint); // Left sunrise marker
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 3, endMarkerPaint); // Right sunset marker
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    // Repaint if any relevant property changes including visibility flag
    return sunrise != oldDelegate.sunrise ||
        sunset != oldDelegate.sunset ||
        currentTime != oldDelegate.currentTime ||
        arcColor != oldDelegate.arcColor ||
        sunColor != oldDelegate.sunColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        sunRadius != oldDelegate.sunRadius ||
        isSunVisible != oldDelegate.isSunVisible ||
        onSunPositionCalculated != oldDelegate.onSunPositionCalculated;
  }
}


// --- StatefulWidget for the Sun Arc Widget ---
class SunPositionArc extends StatefulWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime? currentTime; // Current time in the location's timezone
  final double size; // Diameter of the arc
  final Color arcColor;
  final Color sunColor;
  final Color timeColor; // Color for sunrise/sunset text labels
  final double strokeWidth;
  final double sunRadius;
  // Removed updateInterval, time is controlled externally

  const SunPositionArc({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.currentTime, // Expect parent to provide updated time
    this.size = 200.0,
    this.arcColor = Colors.orangeAccent,
    this.sunColor = Colors.yellow, // Consider Colors.yellow.shade700 for less brightness
    this.timeColor = Colors.black54,
    this.strokeWidth = 2.0,
    this.sunRadius = 8.0,
  });

  @override
  State<SunPositionArc> createState() => _SunPositionArcState();
}

class _SunPositionArcState extends State<SunPositionArc> {
  // State only needed for tooltip visibility and sun's screen position
  bool _showTimeTooltip = false;
  Offset _sunPosition = Offset.zero; // Store the sun's calculated canvas position
  final DateFormat _timeFormatter = DateFormat.jm(); // Formatter like '5:08 PM'

  // No timer needed in this widget anymore

  @override
  void initState() {
    super.initState();
    // No timer initialization
  }

  // No didUpdateWidget needed for timer management

  @override
  void dispose() {
    // No timer to cancel
    super.dispose();
  }

  // Callback from painter to update the sun's screen position state
  void _updateSunPosition(Offset position) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check squared distance for minor optimization and ensure widget is mounted
        if (mounted && (_sunPosition - position).distanceSquared > 0.01) {
           setState(() { _sunPosition = position; });
        }
     });
  }

  // Toggle tooltip visibility on tap, only if sun is visible
  void _handleSunTap() {
     // Check if the current time is actually between sunrise and sunset
     bool isSunCurrentlyVisible = widget.currentTime!.isAfter(widget.sunrise) &&
                                  widget.currentTime!.isBefore(widget.sunset);

     if (!isSunCurrentlyVisible) return; // Do nothing if sun isn't "up"

     print("Sun Tapped! Toggling tooltip. Current state: $_showTimeTooltip"); // Debugging
     setState(() {
       _showTimeTooltip = !_showTimeTooltip;
     });

     // Auto-hide tooltip after 3 seconds if it was just shown
     if (_showTimeTooltip) {
       Future.delayed(const Duration(seconds: 3), () {
         // Check if widget still mounted and if tooltip wasn't manually hidden again
         if (mounted && _showTimeTooltip) {
            setState(() { _showTimeTooltip = false; });
         }
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the sun should be rendered as visible
    // Ensure valid date range before comparison
    final bool isSunVisible = widget.sunset.isAfter(widget.sunrise) &&
                              widget.currentTime!.isAfter(widget.sunrise) &&
                              widget.currentTime!.isBefore(widget.sunset);

    return SizedBox(
      width: widget.size,
      // Adjusted height calculation to ensure enough space
      height: widget.size / 2 + widget.sunRadius + 40, // Height for arc, sun radius, labels, tooltip padding
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none, // Allow tooltip to overflow SizedBox bounds
        children: [
          // --- Layer 1: Custom Painter ---
          // Painter draws the arc always, but the sun only if isSunVisible is true
          CustomPaint(
            size: Size(widget.size, widget.size / 2 + widget.sunRadius), // Canvas size matches arc+sun radius
            painter: _SunArcPainter(
              sunrise: widget.sunrise,
              sunset: widget.sunset,
              currentTime: widget.currentTime!, // Pass the current time from parent
              arcColor: widget.arcColor,
              sunColor: widget.sunColor,
              strokeWidth: widget.strokeWidth,
              sunRadius: widget.sunRadius,
              onSunPositionCalculated: _updateSunPosition, // Callback to get position
              isSunVisible: isSunVisible, // Pass visibility flag
            ),
          ),

          // --- Layer 2: Sunrise and Sunset Time Labels ---
          Positioned(
            bottom: 0, // Position at the very bottom of the SizedBox
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _timeFormatter.format(widget.sunrise),
                    style: TextStyle(fontSize: 12, color: widget.timeColor),
                  ),
                  Text(
                    _timeFormatter.format(widget.sunset),
                    style: TextStyle(fontSize: 12, color: widget.timeColor),
                  ),
                ],
              ),
            ),
          ),

          // --- Layer 3: Tappable Area for Sun ---
          // Build GestureDetector based on calculated _sunPosition
          // It will be positioned correctly even if the sun dot isn't visible (at ends)
          if (_sunPosition != Offset.zero)
            Positioned(
              // Center the tappable area on the sun's calculated position
              left: _sunPosition.dx - (widget.sunRadius * 1.5),
              top: _sunPosition.dy - (widget.sunRadius * 1.5),
              // Make tappable area larger for easier interaction
              width: widget.sunRadius * 3,
              height: widget.sunRadius * 3,
              child: GestureDetector(
                // Only trigger tap if the sun is currently visible on the arc
                onTap: isSunVisible ? _handleSunTap : null,
                behavior: HitTestBehavior.opaque, // Catch taps within bounds
                child: Container(color: Colors.transparent), // Invisible area
              ),
            ),

          // --- Layer 4: Time Tooltip (Conditionally Visible) ---
          // Show only if _showTimeTooltip is true AND position is known
          if (_showTimeTooltip && _sunPosition != Offset.zero)
             Positioned(
                left: 0, // Let Center handle horizontal alignment
                right: 0,
                // Position slightly above the sun's calculated center position
                top: _sunPosition.dy - widget.sunRadius - 22, // Adjust vertical offset as needed
                child: Center(
                   child: IgnorePointer( // Prevent tooltip from blocking gestures
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(4),
                         ),
                         child: Text(
                            // Display the actual currentTime that determined the position
                            _timeFormatter.format(widget.currentTime!),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                         ),
                      ),
                   )
                )
             ),
        ],
      ),
    );
  }
}