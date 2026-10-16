import 'dart:async';
import 'package:flutter/material.dart';
import '../models/autocomplete_result.dart';
import '../services/mhj_maps_service.dart';

/// Autocomplete search field (equivalent of `free_map`'s `FmSearchField`),
/// powered by Photon with debounce.
///
/// ```dart
/// MhjMapsSearchField(
///   hintText: 'Search address…',
///   onSelected: (place) => controller.moveTo(
///     MhjMapsLatLng(lat: place.lat, lng: place.lng),
///   ),
/// )
/// ```
class MhjMapsSearchField extends StatefulWidget {
  final MhjMapsService? service;
  final ValueChanged<AutocompleteResult>? onSelected;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final int limit;
  final Duration debounce;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final Widget Function(AutocompleteResult place)? leadingBuilder;
  final TextEditingController? controller;

  const MhjMapsSearchField({
    super.key,
    this.service,
    this.onSelected,
    this.onChanged,
    this.hintText = 'Search address…',
    this.limit = 5,
    this.debounce = const Duration(milliseconds: 400),
    this.decoration,
    this.textStyle,
    this.leadingBuilder,
    this.controller,
  });

  @override
  State<MhjMapsSearchField> createState() => _MhjMapsSearchFieldState();
}

class _MhjMapsSearchFieldState extends State<MhjMapsSearchField> {
  late final TextEditingController _controller;
  late final MhjMapsService _service;
  Timer? _debounce;
  List<AutocompleteResult> _options = [];
  bool _loading = false;
  bool _open = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _service = widget.service ?? MhjMapsService();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _options = [];
        _open = false;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(widget.debounce, () => _search(value));
  }

  Future<void> _search(String query) async {
    if (query == _lastQuery && _options.isNotEmpty) {
      setState(() => _open = true);
      return;
    }
    setState(() => _loading = true);
    try {
      final results =
          await _service.autocomplete(query.trim(), limit: widget.limit);
      _lastQuery = query;
      if (!mounted) return;
      setState(() {
        _options = results;
        _open = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _select(AutocompleteResult place) {
    _controller.text = place.displayName.isNotEmpty
        ? place.displayName
        : place.name;
    setState(() {
      _open = false;
      _options = [];
    });
    FocusScope.of(context).unfocus();
    widget.onSelected?.call(place);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          onTap: () {
            if (_options.isNotEmpty) setState(() => _open = true);
          },
          style: widget.textStyle,
          decoration: (widget.decoration ??
                  InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    filled: true,
                  ))
              .copyWith(
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                          setState(() {
                            _options = [];
                            _open = false;
                          });
                        },
                      )
                    : null,
          ),
        ),
        if (_open && _options.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: kElevationToShadow[4],
            ),
            constraints: const BoxConstraints(maxHeight: 260),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final place = _options[i];
                  return ListTile(
                    dense: true,
                    leading: widget.leadingBuilder?.call(place) ??
                        const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(
                      place.name.isNotEmpty ? place.name : place.displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      place.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => _select(place),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
