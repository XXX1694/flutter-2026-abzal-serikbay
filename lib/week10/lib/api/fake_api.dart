import 'package:flutter/foundation.dart';

class Student {
  const Student({required this.name, required this.group, this.gpa});
  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

// Level 1: the API that does not exist yet. It must feel like a
// network: slow, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});
  final bool empty; // true -> the server has no students
  int calls = 0; // how many times fetchStudents() ran
  // static: each screen makes its own FakeApi, but the server counts
  // every save in the app, so the second Save is rejected even after
  // the first one closed the screen.
  static int saves = 0;

  Future<List<Student>> fetchStudents() async {
    final call =
        ++calls; // remember which call this is: calls may grow while we wait
    debugPrint('fetchStudents #$call');
    await Future.delayed(const Duration(seconds: 2));
    if (call % 3 == 0) throw NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    final call = ++saves;
    await Future.delayed(const Duration(seconds: 1));
    if (call % 2 == 0) throw StateError('server rejected $value');
  }
}
