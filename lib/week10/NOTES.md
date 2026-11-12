# Practice 10 — The Data Arrives Later

## Level 1: event loop order

Code in `main()` before `runApp`:

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

**Predicted:** A, C, (first frame), then after 2 s: B, 6 students.

**Actual:** A, C, `fetchStudents #1`, first frame — and only 2 s later B and `6 students`.
Nothing waited for the timer: `main()` ran to the end, the loop drew the screen,
the two callbacks came later as events.

With three calls in a row: `fetchStudents #1 #2 #3`, then B, `6 students`, `6 students` and
`Unhandled Exception: Instance of 'NoConnectionException'` — the app kept running as if nothing happened.

With `sleep(const Duration(seconds: 2))` instead of `await Future.delayed`: the first frame
is drawn only after 2 s — the loop is blocked, not waiting.

Bug I hit: first I checked `calls % 3` **after** the await. Three calls started at once all saw
`calls == 3` and all three failed. Fix: `final call = ++calls;` before the await — the line after
await runs later, when `calls` has already changed.

## Level 2: setState after dispose

Without `if (!mounted) return;`, opening the screen and pressing Back within 2 s:

```
setState() called after dispose(): _StudentsScreenState#1a2b3(lifecycle state: defunct, not mounted)
```

With the guards back: Back during loading — nothing in the console.

## Level 3: FutureBuilder

- Future stored in a field: flipping the Switch 10 times → console shows only `fetchStudents #1`, no flicker.
- `future: _api.fetchStudents()` inline in build: spinner on every flip, `#2 #3 #4 …`, every third fails.
- `hasData` checked first while the server is down: spinner forever. `hasError` first → error view with Retry.

## Level 4: countdown

- **Version B with `cancel()`**: Back at 7 → console stops at `tick 7`.
- **Version B without `cancel()`**: one second later `setState() called after dispose(): _CountdownBState#…(lifecycle state: defunct, not mounted)`,
  and the console keeps printing `tick 6`, `tick 5` … `tick 0` with nobody on screen. That is the leak.
- **Version A (StreamBuilder)**: no cancel in my code, Back at 7 → console stops. StreamBuilder cancelled for me.

## Level 5: errors that do not vanish

`onPressed: () { _api.save(n); Navigator.pop(context); }` — `flutter analyze` flags it with
`unawaited_futures`. Second Save pops the screen and the console says:

```
Unhandled Exception: Bad state: server rejected 6
```

**The user saw a success.**

Honest version: `await` + `try / on StateError`, `context.mounted` after the await, pop only on
success, otherwise a SnackBar `server rejected 6`. While saving the button is disabled and
shows a spinner — a fast double tap makes one request, not two.
