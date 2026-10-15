import 'package:flutter/material.dart';

import 'models/campus_event.dart';
import 'screens/detail_screen.dart';
import 'screens/event_form_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onShowProfile,
  });

  final CampusEvent event;
  final String profileName;
  final ValueChanged<CampusEvent> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onShowProfile;
}

class FormArgs {
  const FormArgs({this.event});

  final CampusEvent? event;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  return switch ((settings.name, settings.arguments)) {
    (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
    (Routes.form, final FormArgs args) => MaterialPageRoute<CampusEvent>(
      settings: settings,
      builder: (_) => EventFormScreen(event: args.event),
    ),
    _ => null,
  };
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => const NotFoundScreen(),
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    );
  }
}
