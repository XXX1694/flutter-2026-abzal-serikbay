import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/campus_event.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import 'events_tab.dart';
import 'favourites_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Campus Events', 'Favourites', 'Profile'];

  List<CampusEvent> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  void _replace(CampusEvent updated) => setState(
    () => _events = [for (final e in _events) e.id == updated.id ? updated : e],
  );

  void _delete(String id) =>
      setState(() => _events = _events.where((e) => e.id != id).toList());

  void _toggleFavourite(CampusEvent event) =>
      _replace(event.copyWith(favourite: !event.favourite));

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  void _showProfile() {
    Navigator.popUntil(context, (route) => route.isFirst);
    _selectTab(2);
  }

  void _open(CampusEvent event) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onShowProfile: _showProfile,
      ),
    );
  }

  Future<void> _create() async {
    final created = await Navigator.pushNamed<CampusEvent>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _events = [..._events, created]);
  }

  void _about() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Campus Events: find, save and join events on campus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.pop(context);
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'All events return to the seed and the profile is cleared.',
      action: 'Reset',
    );
    if (!ok || !mounted) return;
    setState(() {
      _events = seedEvents();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'Campus Events',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: _about,
            ),
            ListTile(
              title: const Text('Reset data'),
              trailing: const Icon(Icons.restore),
              onTap: _reset,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          EventsTab(
            events: _events,
            onOpen: _open,
            onFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            events: _events,
            onOpen: _open,
            onFavourite: _toggleFavourite,
            onBrowse: () => _selectTab(0),
          ),
          ProfileTab(
            profile: _profile,
            events: _events,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _create,
              tooltip: 'New event',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
