import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_collection.dart';
import 'events_tab.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = events.where((e) => e.favourite).toList()
      ..sort(compareByDate);
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse events',
        onAction: onBrowse,
      );
    }
    return EventCollection(
      events: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
