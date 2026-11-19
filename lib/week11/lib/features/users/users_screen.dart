import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'state_views.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: m.loading
          ? const LoadingView()
          : switch (m.error) {
              null => UserList(m.items),
              NoConnectionException() => Offline(onRetry: m.load),
              NotFoundException() ||
              UnauthorizedException() => const GenericError(),
              ServerException(:final status) => ServerError(
                status,
                onRetry: m.load,
              ),
              BadResponseException() => const GenericError(),
            },
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});
  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<UsersModel>().load,
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text(
              [
                u.email,
                if (u.address.city.isNotEmpty) u.address.city,
              ].join(' · '),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => UserDetailScreen(u)),
            ),
          );
        },
      ),
    );
  }
}
