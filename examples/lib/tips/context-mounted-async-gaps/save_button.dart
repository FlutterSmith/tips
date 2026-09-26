import 'package:flutter/material.dart';

/// Saves, then closes the current route.
class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.save});

  final Future<void> Function() save;

  @override
  Widget build(BuildContext context) {
    // #docregion mounted
    return ElevatedButton(
      onPressed: () async {
        await save();
        // @note the widget may be gone by now
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: const Text('Save'),
    );
    // #enddocregion mounted
  }
}

/// Saves, then shows a SnackBar even if the route was closed.
class SaveAndNotifyButton extends StatelessWidget {
  const SaveAndNotifyButton({super.key, required this.save});

  final Future<void> Function() save;

  @override
  Widget build(BuildContext context) {
    // #docregion capture
    return ElevatedButton(
      onPressed: () async {
        // @note look it up while the context is still valid
        final messenger = ScaffoldMessenger.of(context);
        await save();
        messenger.showSnackBar(
          const SnackBar(content: Text('Saved')),
        );
      },
      child: const Text('Save'),
    );
    // #enddocregion capture
  }
}

/// A State has its own `mounted` getter.
class DraftEditor extends StatefulWidget {
  const DraftEditor({super.key, required this.save});

  final Future<void> Function() save;

  @override
  State<DraftEditor> createState() => _DraftEditorState();
}

class _DraftEditorState extends State<DraftEditor> {
  var _status = 'Draft';

  // #docregion state
  Future<void> _publish() async {
    await widget.save();
    // @note State.mounted: same check, no context needed
    if (!mounted) return;
    setState(() => _status = 'Published');
  }
  // #enddocregion state

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: _publish, child: Text(_status));
  }
}
