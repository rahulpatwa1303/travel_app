// lib/features/cities/presentation/widgets/city_autocomplete_search.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/city_suggestion_model.dart'; // Adjust if necessary
import '../providers/city_search_notifier.dart'; // Adjust if necessary

class CityAutocompleteSearch extends ConsumerStatefulWidget {
  final String? hintText;
  final void Function(CitySearchSuggestion suggestion)? onSuggestionSelected;
  final TextEditingController? controller;

  const CityAutocompleteSearch({
    super.key,
    this.hintText,
    this.onSuggestionSelected,
    this.controller,
  });

  @override
  ConsumerState<CityAutocompleteSearch> createState() =>
      _CityAutocompleteSearchState();
}

class _CityAutocompleteSearchState
    extends ConsumerState<CityAutocompleteSearch> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    if (_focusNode.hasFocus && _textController.text.isNotEmpty) {
      ref.read(citySearchProvider.notifier).search(_textController.text);
      // Overlay creation/update will be handled by ref.listen
    } else {
      // If text becomes empty, clear suggestions and remove overlay
      ref.read(citySearchProvider.notifier).clearSuggestions();
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      if (_textController.text.isNotEmpty) {
        // If focused and text exists, ensure search is triggered (e.g., if overlay was dismissed)
        ref.read(citySearchProvider.notifier).search(_textController.text);
        // Overlay creation/update will be handled by ref.listen
      }
    } else {
      // Delay removal to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted || _focusNode.hasFocus) return; // Check again
        _removeOverlay();
        // Optionally clear suggestions when focus is lost and overlay is removed
        // ref.read(citySearchProvider.notifier).clearSuggestions();
      });
    }
  }

  @override
  void dispose() {
    // Dispose controller only if it was created internally
    if (widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _createOverlay() {
    if (!mounted || _overlayEntry != null) return;

    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (!mounted) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    // final suggestionsState = ref.watch(citySearchProvider); // Not needed here if overlay rebuilds via markNeedsBuild
    // The OverlayEntry builder will have its own BuildContext and can watch the provider.

    return OverlayEntry(
      builder: (context) {
        // Watch the provider inside the OverlayEntry's builder context
        final suggestionsState = ref.watch(citySearchProvider);
        final RenderBox textFieldRenderBox = this.context.findRenderObject() as RenderBox;
        final textFieldSize = textFieldRenderBox.size;

        return Positioned(
          width: textFieldSize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, textFieldSize.height + 5.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250), // Max height for suggestions
                child: suggestionsState.when(
                  data: (suggestions) {
                    // User's debug print:
                    // print('Overlay rendering suggestions: $suggestions, Text: ${_textController.text}');

                    if (!_focusNode.hasFocus &&_textController.text.isEmpty) {
                        // This case should ideally be caught by listeners removing the overlay
                        return const SizedBox.shrink();
                    }

                    if (suggestions.isEmpty && _textController.text.isNotEmpty) {
                      return ListTile(
                        title: Text('No cities found for "${_textController.text}"'),
                        dense: true,
                      );
                    }
                    if (suggestions.isNotEmpty) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return ListTile(
                            leading: (suggestion.images != null && suggestion.images!.isNotEmpty)
                                ? CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(suggestion.images!.first),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      // Optionally log error or show placeholder
                                      // print("Error loading image: ${suggestion.images!.first}");
                                    },
                                  )
                                : null, // Or a default Icon(Icons.location_city)
                            title: Text(suggestion.name),
                            subtitle: Text(suggestion.countryName),
                            dense: true,
                            onTap: () {
                              _textController.text = suggestion.name;
                              _textController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _textController.text.length),
                              );
                              _removeOverlay(); // Remove overlay first
                              _focusNode.unfocus(); // Then unfocus
                              ref.read(citySearchProvider.notifier).clearSuggestions();
                              widget.onSuggestionSelected?.call(suggestion);
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink(); // Fallback if no conditions met
                  },
                  loading: () => const Center(
                    heightFactor: 2,
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                  ),
                  error: (error, stack) {
                    String errorMessage = "An error occurred";
                     if (error is Exception) {
                       errorMessage = error.toString().replaceFirst("Exception: ", "");
                     } else {
                       errorMessage = error.toString();
                     }
                    return ListTile(
                      title: Text(errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      dense: true,
                    );
                  }
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
    ref.listen<AsyncValue<List<CitySearchSuggestion>>>(citySearchProvider, (previous, next) {
      if (!mounted) return;
      final bool hasFocus = _focusNode.hasFocus;
      final bool textNotEmpty = _textController.text.isNotEmpty;

      if (hasFocus && textNotEmpty) {
        // Conditions to show/update overlay:
        // 1. Loading state.
        // 2. Error state.
        // 3. Data state (even if empty, _buildOverlayEntry handles "no results").
        if (next is AsyncLoading || next is AsyncError || next is AsyncData) {
          if (_overlayEntry == null) {
            _createOverlay();
          } else {
            // If overlay exists, and state changes (e.g. loading -> data),
            // tell the existing overlay to rebuild its contents.
            _overlayEntry?.markNeedsBuild();
          }
        }
      } else {
        // If not focused or text becomes empty, remove the overlay.
        _removeOverlay();
      }
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search for a city...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: _textController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    // _onTextChanged will be called, which handles clearing suggestions and overlay
                  },
                )
              : null,
        ),
        onTap: () {
          // If already focused and text is not empty, an tap might be to ensure overlay is visible
          // if it was somehow dismissed.
          if (_focusNode.hasFocus && _textController.text.isNotEmpty) {
            // Check if suggestions need to be fetched again or overlay needs to be reshown
            final currentState = ref.read(citySearchProvider);
            if (currentState is AsyncData && _overlayEntry == null) {
                 _createOverlay(); // Re-create if was removed while still focused with text
            } else if (currentState is! AsyncLoading) {
              // If not loading, might re-trigger search to be sure
              ref.read(citySearchProvider.notifier).search(_textController.text);
            }
          }
        },
        onSubmitted: (value) {
          final currentSuggestions = ref.read(citySearchProvider).asData?.value;
          if (currentSuggestions != null && currentSuggestions.isNotEmpty) {
            final bestMatch = currentSuggestions.firstWhere(
              (s) => s.name.toLowerCase() == value.toLowerCase().trim(),
              orElse: () => currentSuggestions.first, // Fallback to the first suggestion
            );
            _textController.text = bestMatch.name;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
            widget.onSuggestionSelected?.call(bestMatch);
          }
          _removeOverlay();
          _focusNode.unfocus();
          ref.read(citySearchProvider.notifier).clearSuggestions();
        },
      ),
    );
  }
}