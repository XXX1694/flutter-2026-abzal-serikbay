import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

typedef _Values = ({
  String title,
  EventCategory? category,
  bool online,
  String location,
  String capacity,
  DateTime? date,
  TimeOfDay? time,
  String description,
});

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});

  final CampusEvent? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CampusEvent _initial;
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _capacity;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  EventCategory? _category;
  late bool _online;
  DateTime? _date;
  TimeOfDay? _time;
  late final _Values _opened;
  bool _saving = false;

  bool get _isNew => widget.event == null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _initial = event ?? CampusEvent.empty();
    _title = TextEditingController(text: _initial.title);
    _location = TextEditingController(text: _initial.location);
    _capacity = TextEditingController(text: '${_initial.capacity}');
    _description = TextEditingController(text: _initial.description ?? '');
    _online = _initial.online;
    if (event != null) {
      _category = event.category;
      _date = DateUtils.dateOnly(event.startsAt);
      _time = TimeOfDay.fromDateTime(event.startsAt);
    }
    _dateText = TextEditingController(
      text: event == null ? '' : formatDate(event.startsAt),
    );
    _timeText = TextEditingController(
      text: event == null ? '' : formatTime(event.startsAt),
    );
    _opened = _values;
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _capacity.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _locationFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  _Values get _values => (
    title: _title.text,
    category: _category,
    online: _online,
    location: _location.text,
    capacity: _capacity.text,
    date: _date,
    time: _time,
    description: _description.text,
  );

  bool get _dirty => _values != _opened;

  DateTime? get _startsAt => switch ((_date, _time)) {
    (final date?, final time?) => DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ),
    _ => null,
  };

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateCategory(EventCategory? value) =>
      value == null ? 'Choose a category' : null;

  String? _validateLocation(String? value) {
    final location = value?.trim() ?? '';
    if (location.isEmpty) {
      return _online ? 'Link is required' : 'Place is required';
    }
    if (_online && !location.contains('://')) return 'Link must contain ://';
    return null;
  }

  String? _validateCapacity(String? value) {
    final capacity = int.tryParse(value?.trim() ?? '');
    if (capacity == null) return 'Enter a whole number';
    if (capacity < 1 || capacity > 500) return 'From 1 to 500';
    final taken = widget.event?.count ?? 0;
    if (capacity < taken) return '$taken already registered';
    return null;
  }

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    final startsAt = _startsAt;
    if (_time == null) return 'Pick a time';
    if (_isNew && startsAt != null && !startsAt.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateText.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeText.text = formatClock(picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final (category, startsAt) = (_category, _startsAt);
    if (category == null || startsAt == null) return;
    final description = _description.text.trim();
    final event = CampusEvent(
      id: _isNew ? '${DateTime.now().microsecondsSinceEpoch}' : _initial.id,
      title: _title.text.trim(),
      category: category,
      startsAt: startsAt,
      capacity: int.parse(_capacity.text.trim()),
      location: _location.text.trim(),
      attendees: _initial.attendees,
      online: _online,
      description: description.isEmpty ? null : description,
      favourite: _initial.favourite,
    );
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, event);
  }

  Future<void> _confirmDiscard() async {
    final discard = await confirm(
      context,
      title: 'Discard changes?',
      message: 'Your edits will be lost.',
      action: 'Discard',
    );
    if (!discard || !mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return PopScope<CampusEvent>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                validator: _validateTitle,
                onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                onTapOutside: _unfocus,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              gap,
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                validator: _validateCategory,
                onChanged: (value) => setState(() => _category = value),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in EventCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon),
                          const SizedBox(width: 12),
                          Text(category.label),
                        ],
                      ),
                    ),
                ],
              ),
              gap,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online'),
                value: _online,
                onChanged: (value) => setState(() => _online = value),
              ),
              gap,
              TextFormField(
                controller: _location,
                focusNode: _locationFocus,
                textInputAction: TextInputAction.next,
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                validator: _validateLocation,
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                onTapOutside: _unfocus,
                decoration: InputDecoration(
                  labelText: _online ? 'Link' : 'Place',
                  border: const OutlineInputBorder(),
                ),
              ),
              gap,
              TextFormField(
                controller: _capacity,
                focusNode: _capacityFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validator: _validateCapacity,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: _unfocus,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateText,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: _validateDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: _validateTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              gap,
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                onTapOutside: _unfocus,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
