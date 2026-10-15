import 'dart:async';

import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../models/countdown.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _Menu { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CampusEvent _event;
  DateTime _now = DateTime.now();
  late final Timer _timer;

  String get _name => widget.args.profileName;

  @override
  void initState() {
    super.initState();
    _event = widget.args.event;
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _apply(CampusEvent event) {
    setState(() => _event = event);
    widget.args.onChanged(event);
  }

  Future<void> _register() async {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.args.onShowProfile,
          ),
        ),
      );
      return;
    }
    final ok = await confirm(
      context,
      title: 'Register?',
      message: 'Add $_name to "${_event.title}"?',
      action: 'Register',
    );
    if (!ok || !mounted) return;
    _apply(_event.copyWith(attendees: [..._event.attendees, _name]));
  }

  void _leave() {
    _apply(
      _event.copyWith(
        attendees: [
          for (final name in _event.attendees)
            if (name != _name) name,
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<CampusEvent>(
      context,
      Routes.form,
      arguments: FormArgs(event: _event),
    );
    if (edited == null || !mounted) return;
    _apply(edited);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete event?',
      message: '"${_event.title}" will be removed.',
      action: 'Delete',
    );
    if (!ok || !mounted) return;
    widget.args.onDelete(_event.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final registered = _name.isNotEmpty && _event.contains(_name);
    final VoidCallback? action = registered
        ? _leave
        : _event.isFull
        ? null
        : _register;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_event.title, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<_Menu>(
              onSelected: (item) => switch (item) {
                _Menu.edit => _edit(),
                _Menu.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _Menu.edit, child: Text('Edit')),
                PopupMenuItem(value: _Menu.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(
              event: _event,
              countdown: Countdown.of(_event.startsAt, _now),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Attendees (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(event: _event),
                  _NamesTab(names: _event.attendees, you: _name),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: action,
              child: Text(
                registered
                    ? 'Cancel registration'
                    : _event.isFull
                    ? 'Full'
                    : 'Register',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event, required this.countdown});

  final CampusEvent event;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(
                event.category.icon,
                size: 36,
                color: event.category.color(scheme),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(label: Text(event.category.label)),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Chip(
              label: Text(switch (countdown) {
                Upcoming(:final left) => 'In ${formatDuration(left)}',
                Started(:final ago) => 'Started ${formatDuration(ago)} ago',
                Ended() => 'Ended',
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.event});

  final CampusEvent event;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = event.places;
    return ListView(
      children: [
        ListTile(
          title: const Text('When'),
          subtitle: Text(formatDateTime(event.startsAt)),
        ),
        ListTile(
          title: Text(event.online ? 'Link' : 'Place'),
          subtitle: Text(event.location),
        ),
        ListTile(
          title: const Text('Places'),
          subtitle: Text('$taken of ${event.capacity} taken, $free free'),
        ),
        if (event.description case final description?)
          ListTile(title: const Text('About'), subtitle: Text(description)),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.names, required this.you});

  final List<String> names;
  final String you;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody on the list yet',
      );
    }
    return ListView.separated(
      itemCount: names.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final isYou = names[index] == you;
        return ListTile(
          selected: isYou,
          title: Text(names[index]),
          trailing: isYou ? const Text('You') : null,
        );
      },
    );
  }
}
