import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_collection.dart';

int compareByDate(CampusEvent a, CampusEvent b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
  return a.startsAt.compareTo(b.startsAt);
}

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onFavourite;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _search = TextEditingController();
  String _query = '';
  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  List<CampusEvent> get _visible {
    final query = _query.trim().toLowerCase();
    final matches = widget.events.where(
      (e) =>
          (_showPast || !e.isPast) &&
          (_category == null || e.category == _category) &&
          e.title.toLowerCase().contains(query),
    );
    return [...matches]..sort(compareByDate);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in EventCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(category.icon),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No events match',
                  actionLabel: _query.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : EventCollection(
                  events: visible,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
