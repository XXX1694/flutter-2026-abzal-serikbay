import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final json = await _api.get(Uri.https(_api.host, '/users'));
    return _read('users', () {
      return [
        for (final u in json as List<dynamic>)
          User.fromJson(u as Map<String, dynamic>),
      ];
    });
  }

  Future<User> getById(int id) async {
    final json = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _read('users/$id', () {
      return User.fromJson(json as Map<String, dynamic>);
    });
  }

  Future<User> create(User draft) async {
    final json = await _api.post(
      Uri.https(_api.host, '/users'),
      draft.toJson(),
    );
    return _read('users', () {
      return User.fromJson(json as Map<String, dynamic>);
    });
  }

  T _read<T>(String path, T Function() parse) {
    try {
      return parse();
    } on TypeError catch (e) {
      throw BadResponseException('$path: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$path: $e');
    }
  }
}
