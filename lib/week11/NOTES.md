# Practice 11 — A Real Server

## Level 1: the wire first

| Request | Status | Body |
|---|---|---|
| `GET /users` | 200, `application/json; charset=utf-8` | a list of 10 users |
| `GET /users/1` | 200 | one object |
| `GET /users/999` | 404 | `{}` |
| `POST /users` with a JSON body | 201 | what I sent plus `"id": 11` (an `id` I send is replaced by 11) |
| `GET /users?id=3` | 200 | a list of one, not an object |

User:

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number | `int` | no |
| name | string | `String` | no |
| username | string | `String` | no |
| email | string | `String` | no |
| address | object | `Address` | no |
| phone | string | `String` | no |
| website | string | `String?` | yes — the one field I treat as optional |
| company | object | `({String name, String catchPhrase})` | no |

Address:

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | `String` | no |
| suite | string | `String` | no |
| city | string | `String` | no |
| zipcode | string | `String` | no |
| geo | object (nested twice) | `Geo` | no |

Geo: `lat`, `lng` — strings (`"-37.3159"`), stored as `double` through `double.parse`.

Company:

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | `String` | no |
| catchPhrase | string | `String` | no |
| bs | string | not read | — |

In all 10 users every field is present and not null.

## Level 2: a model that survives

User 1 pasted as a raw string, `jsonDecode` → `User.fromJson`:

```
User(1, Leanne Graham, Gwenborough)
phoneDigits: 1770736803156442
User.fromJson(user.toJson()) == user: true
```

- `json['lat'] as double` → `type 'String' is not a subtype of type 'double' in type cast`
- `"id": "1"` in the JSON → `type 'String' is not a subtype of type 'int' in type cast`

Both name the type that came and the type I claimed.

## Level 3: the repository

From `main()` before `runApp`:

```
10: Leanne Graham, Ervin Howell, Clementine Bauch, Patricia Lebsack, Chelsey Dietrich, Mrs. Dennis Schulist, Kurtis Weissnat, Nicholas Runolfsdottir V, Glenna Reichert, Clementina DuBuque
not found
created id 11
```

```
$ grep -rn "package:http" lib/
lib/core/api/api_client.dart:7:import 'package:http/http.dart' as http;
lib/main.dart:2:import 'package:http/http.dart' as http;
```

`ApiClient` is the only class that calls http. `main.dart` is the composition root: it only says
`http.Client()`. `UserRepository` builds `Uri.https` and gets decoded JSON from `ApiClient`, so it
does not import http at all.

`_check` without the 404 line, `getById(999)`:

```
BadResponseException users/999: type 'Null' is not a subtype of type 'int' in type cast
```

The body `{}` decoded fine and `fromJson` failed on `id` — my exception, wrong cause. Status first, body second.

In debug every response is logged with `log(..., name: 'api')`: `GET https://jsonplaceholder.typicode.com/users 200`.

## Level 4: the chain

- Without the `BadResponseException()` arm:
  `The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'`
- Host `jsonplaceholder.typicode.co`: Offline view after 492 ms. Host fixed: the list loads again.

## Level 5: two kinds of no network

Time from `load()` to the Offline view, measured with a `Stopwatch` (removed afterwards):

| Case | Device | Time |
|---|---|---|
| Airplane mode | Android emulator, Pixel 9 Pro | 27 ms |
| Packets leave and never return | iOS simulator on a Wi-Fi whose DNS gives `188.114.96.1` for the host: TCP connects, the TLS hello is never answered | 10 013 ms, 10 018 ms |

Same screen in both cases. I did not have a phone on a dead hotspot; the second case is the same
situation on the simulator.

DevTools → Network, second case (`screenshot_timeout.png`): `GET /users`, status `–`, duration
`Pending`. `.timeout()` stops waiting, it does not cancel the request, so the row never gets a
status. With the network back (`screenshot_200.png`): 200, 812 ms, a list of 10.

Save: three taps at the same moment → one `POST /users`, 201, 290 ms. Before I added
`if (_saving) return;` two taps in the same frame sent two POSTs 3 ms apart and the second `pop`
closed the list too — the disabled button only helps after the rebuild.
