import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import 'event_card.dart';

class EventCollection extends StatelessWidget {
  const EventCollection({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onFavourite;

  Widget _card(CampusEvent event) => EventCard(
    event: event,
    onTap: () => onOpen(event),
    onFavourite: () => onFavourite(event),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              childAspectRatio: 2.4,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) => _card(events[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
          itemCount: events.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) => _card(events[index]),
        );
      },
    );
  }
}
