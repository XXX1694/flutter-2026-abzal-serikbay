import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()]),
      body: ListView(children: [for (final b in books) _BookRow(b)]),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow(this.b);

  final Book b;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${b.title}');
    final added = context.watch<Cart>().items.contains(b);
    return ListTile(
      title: Text(b.title),
      subtitle: Text(b.author),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => context.read<Cart>().add(b),
              child: const Text('Add'),
            ),
    );
  }
}
