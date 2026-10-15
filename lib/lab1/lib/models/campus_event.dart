import 'dart:collection';

import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.memory),
  sports('Sports', Icons.sports_soccer),
  music('Music', Icons.music_note),
  career('Career', Icons.work_outline),
  art('Art', Icons.palette_outlined);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.sports => scheme.tertiary,
    EventCategory.music => scheme.secondary,
    EventCategory.career => scheme.error,
    EventCategory.art => scheme.outline,
  };
}

class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.capacity,
    required this.location,
    List<String> attendees = const [],
    this.online = false,
    this.description,
    this.favourite = false,
  }) : _attendees = attendees;

  CampusEvent.empty()
    : this(
        id: '',
        title: '',
        category: EventCategory.tech,
        startsAt: DateTime.now(),
        capacity: 20,
        location: '',
      );

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final int capacity;
  final String location;
  final List<String> _attendees;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get attendees => UnmodifiableListView(_attendees);

  int get count => _attendees.length;

  int get free => capacity - count;

  bool get isFull => free <= 0;

  bool get isPast => startsAt.isBefore(DateTime.now());

  ({int taken, int free}) get places => (taken: count, free: free);

  bool contains(String name) => _attendees.any((n) => n == name);

  CampusEvent copyWith({
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    int? capacity,
    String? location,
    List<String>? attendees,
    bool? online,
    String? description,
    bool? favourite,
  }) {
    return CampusEvent(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      capacity: capacity ?? this.capacity,
      location: location ?? this.location,
      attendees: attendees ?? _attendees,
      online: online ?? this.online,
      description: description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }
}
