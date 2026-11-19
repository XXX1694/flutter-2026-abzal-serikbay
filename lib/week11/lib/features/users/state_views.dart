import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Message(Icons.wifi_off, 'No connection', onRetry: onRetry);
  }
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});
  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Message(Icons.cloud_off, 'Server error $status', onRetry: onRetry);
  }
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Message(Icons.error_outline, 'Something went wrong');
  }
}

class _Message extends StatelessWidget {
  const _Message(this.icon, this.text, {this.onRetry});
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(text),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
