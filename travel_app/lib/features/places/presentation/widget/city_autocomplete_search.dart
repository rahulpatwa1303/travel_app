// lib/features/search/presentation/widgets/city_autocomplete_search.dart (example path)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/enums/search_type.dart';
import 'package:travel_app/features/places/domain/city_suggestion_model.dart';
import 'package:travel_app/features/places/domain/place_suggestion_model.dart';
import 'package:travel_app/features/places/presentation/providers/city_search_notifier.dart';

// Import your models and providers
// City


// SearchType enum (defined above or imported)
// enum SearchType { city, place }
// extension SearchTypeExtension on SearchType { /* ... */ }


class UnifiedAutocompleteSearch extends ConsumerStatefulWidget {
  final String? initialHintText;
  final void Function(dynamic suggestion, SearchType type)? onSuggestionSelected;
  final TextEditingController? externalController;

  const UnifiedAutocompleteSearch({
    super.key,
    this.initialHintText,
    this.onSuggestionSelected,
    this.externalController,
  });

  @override
  ConsumerState<UnifiedAutocompleteSearch> createState() =>
      _UnifiedAutocompleteSearchState();
}

class _UnifiedAutocompleteSearchState extends ConsumerState<UnifiedAutocompleteSearch> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _textFieldLink = LayerLink();

  OverlayEntry? _suggestionsOverlayEntry;
  OverlayEntry? _toggleButtonsOverlayEntry;

  SearchType _currentSearchType = SearchType.city;
  final List<bool> _toggleButtonSelection = [true, false]; // [City, Place]

  // Debounce timer for search
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _textController = widget.externalController ?? TextEditingController();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.externalController == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    _removeSuggestionsOverlay();
    _removeToggleButtonsOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;

    _searchDebounce?.cancel();
    if (_focusNode.hasFocus && _textController.text.isNotEmpty) {
      _searchDebounce = Timer(const Duration(milliseconds: 400), () {
        if (!mounted || !_focusNode.hasFocus || _textController.text.isEmpty) return;
        if (_currentSearchType == SearchType.city) {
          ref.read(citySearchProvider.notifier).search(_textController.text);
        } else {
          ref.read(placeSearchProvider.notifier).search(_textController.text);
        }
      });
    } else {
      _clearCurrentSuggestions();
      _removeSuggestionsOverlay(); // Also remove if text becomes empty
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      _showToggleButtonsOverlay();
      // If there's text, the text listener will handle the search.
      // If suggestions were previously dismissed, ensure they are shown if applicable.
      if (_textController.text.isNotEmpty) {
         _triggerOverlayUpdateBasedOnCurrentState();
      }
    } else {
      _removeToggleButtonsOverlay();
      // Delay removal of suggestions overlay to allow tap on a suggestion item
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeSuggestionsOverlay();
        }
      });
    }
  }
  
  void _triggerOverlayUpdateBasedOnCurrentState() {
    final currentProvider = _currentSearchType == SearchType.city
        ? citySearchProvider
        : placeSearchProvider;
    final currentState = ref.read(currentProvider); // Read, don't watch here

    if (currentState is AsyncData && currentState.value!.isNotEmpty ||
        currentState is AsyncLoading ||
        currentState is AsyncError) {
      _showSuggestionsOverlay();
    }
  }

  void _clearCurrentSuggestions() {
    if (_currentSearchType == SearchType.city) {
      ref.read(citySearchProvider.notifier).clearSuggestions();
    } else {
      ref.read(placeSearchProvider.notifier).clearSuggestions();
    }
  }

  // --- Toggle Buttons Overlay Management ---
  void _showToggleButtonsOverlay() {
    if (!mounted || _toggleButtonsOverlayEntry != null) return;
    _toggleButtonsOverlayEntry = _buildToggleButtonsOverlay();
    Overlay.of(context).insert(_toggleButtonsOverlayEntry!);
  }

  void _removeToggleButtonsOverlay() {
    _toggleButtonsOverlayEntry?.remove();
    _toggleButtonsOverlayEntry = null;
  }

  OverlayEntry _buildToggleButtonsOverlay() {
    final RenderBox textFieldRenderBox = context.findRenderObject() as RenderBox;
    final textFieldSize = textFieldRenderBox.size;

    return OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: textFieldSize.width,
        child: CompositedTransformFollower(
          link: _textFieldLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, textFieldSize.height + 2.0), // Position just below TextField
          child: Material(
            elevation: 2.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ToggleButtons(
                isSelected: _toggleButtonSelection,
                onPressed: (int index) {
                  if (!mounted) return;
                  setState(() {
                    for (int i = 0; i < _toggleButtonSelection.length; i++) {
                      _toggleButtonSelection[i] = i == index;
                    }
                    _currentSearchType = index == 0 ? SearchType.city : SearchType.place;
                  });
                  _clearCurrentSuggestions(); // Clear old suggestions
                  _removeSuggestionsOverlay(); // Remove the old overlay immediately
                  if (_textController.text.isNotEmpty) {
                    _onTextChanged(); // Trigger search for the new type if text exists
                  }
                  _toggleButtonsOverlayEntry?.markNeedsBuild(); // Rebuild toggles for visual update
                },
                borderRadius: BorderRadius.circular(6.0),
                selectedBorderColor: Theme.of(context).primaryColor,
                selectedColor: Colors.white,
                fillColor: Theme.of(context).primaryColor,
                color: Theme.of(context).primaryColorDark, // Or onSurface
                constraints: BoxConstraints(
                    minHeight: 36.0,
                    minWidth: (textFieldSize.width / _toggleButtonSelection.length) - 10), // Adjusted width
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(SearchType.city.displayName)),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(SearchType.place.displayName)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Suggestions Overlay Management ---
  void _showSuggestionsOverlay() {
    if (!mounted) return;
    if (_suggestionsOverlayEntry == null) {
      _suggestionsOverlayEntry = _buildSuggestionsOverlay();
      Overlay.of(context).insert(_suggestionsOverlayEntry!);
    } else {
      // If overlay exists, mark it to rebuild with new data/state
      _suggestionsOverlayEntry?.markNeedsBuild();
    }
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlayEntry?.remove();
    _suggestionsOverlayEntry = null;
  }

  OverlayEntry _buildSuggestionsOverlay() {
    final RenderBox textFieldRenderBox = context.findRenderObject() as RenderBox;
    final textFieldSize = textFieldRenderBox.size;
    // Estimate toggle buttons height (adjust if necessary)
    const double toggleButtonsAndPaddingHeight = 50.0; // Approx height of toggle buttons + its padding

    return OverlayEntry(
      builder: (overlayContext) {
        // Watch the correct provider within the Overlay's builder
        final AsyncValue<List<dynamic>> suggestionsAsyncValue =
            _currentSearchType == SearchType.city
                ? ref.watch(citySearchProvider)
                : ref.watch(placeSearchProvider);

        return Positioned(
          width: textFieldSize.width,
          child: CompositedTransformFollower(
            link: _textFieldLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, textFieldSize.height + toggleButtonsAndPaddingHeight + 2.0), // Below toggles
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220), // Max height of suggestions list
                child: suggestionsAsyncValue.when(
                  data: (suggestions) {
                    if (!_focusNode.hasFocus || _textController.text.isEmpty) {
                      // This might be redundant if _removeSuggestionsOverlay is called correctly,
                      // but acts as a safeguard.
                      return const SizedBox.shrink();
                    }
                    if (suggestions.isEmpty) {
                      return ListTile(
                        title: Text(
                            'No ${_currentSearchType.displayName.toLowerCase()}s found for "${_textController.text}"'),
                        dense: true,
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (ctx, index) {
                        final item = suggestions[index];
                        String title = 'Unknown';
                        String subtitle = '';
                        Widget? leading;

                        if (item is CitySearchSuggestion) {
                          title = item.name;
                          subtitle = item.countryName;
                          if (item.images != null && item.images!.isNotEmpty) {
                            leading = CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(item.images!.first),
                                onBackgroundImageError: (e,s) {});
                          }
                        } else if (item is PlaceSearchSuggestion) {
                          title = item.name;
                          subtitle = item.displaySubtitle; // Using the getter
                           if (item.images.isNotEmpty) {
                            leading = CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(item.images.first),
                                onBackgroundImageError: (e,s) {});
                          }
                        }

                        return ListTile(
                          leading: leading,
                          title: Text(title),
                          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                          dense: true,
                          onTap: () {
                            _textController.text = title;
                            _textController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _textController.text.length));
                            _removeSuggestionsOverlay();
                            _removeToggleButtonsOverlay();
                            _focusNode.unfocus();
                            _clearCurrentSuggestions();
                            widget.onSuggestionSelected?.call(item, _currentSearchType);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                      heightFactor: 2.5,
                      child: SizedBox(
                          width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))),
                  error: (err, stack) => ListTile(
                      title: Text('Error loading ${_currentSearchType.displayName.toLowerCase()}s',
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      dense: true),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes for the currently active search type
    // This will trigger showing/updating the suggestions overlay
    final activeSearchProvider = _currentSearchType == SearchType.city
        ? citySearchProvider
        : placeSearchProvider;

    ref.listen(activeSearchProvider, (previous, next) {
      if (!mounted) return;
      if (_focusNode.hasFocus && _textController.text.isNotEmpty) {
        if (next is AsyncData || next is AsyncLoading || next is AsyncError) {
          _showSuggestionsOverlay(); // Create or mark for rebuild
        }
      } else {
        _removeSuggestionsOverlay(); // Remove if no focus or text is empty
      }
    });

    return CompositedTransformTarget(
      link: _textFieldLink,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.initialHintText ?? 'Search for a ${_currentSearchType.displayName.toLowerCase()}...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          suffixIcon: _textController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _textController.clear(); // This will trigger _onTextChanged
                  },
                )
              : null,
        ),
        onTap: () {
          // Ensure overlays are managed correctly on tap, especially if already focused
          if (_focusNode.hasFocus) {
            _showToggleButtonsOverlay();
             if (_textController.text.isNotEmpty) {
                _triggerOverlayUpdateBasedOnCurrentState();
            }
          } else {
            _focusNode.requestFocus(); // _onFocusChanged will handle showing overlays
          }
        },
        onSubmitted: (value) {
          // Basic submit: just unfocus and clear
          _removeSuggestionsOverlay();
          _removeToggleButtonsOverlay();
          _focusNode.unfocus();
          _clearCurrentSuggestions();
        },
      ),
    );
  }
}