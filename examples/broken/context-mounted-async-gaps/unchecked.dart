// expect: use_build_context_synchronously
import 'package:flutter/material.dart';

class UncheckedSaveButton extends StatelessWidget {
  const UncheckedSaveButton({super.key, required this.save});

  final Future<void> Function() save;

  @override
  Widget build(BuildContext context) {
    // #docregion unchecked
    return ElevatedButton(
      onPressed: () async {
        await save();
        Navigator.of(context).pop();
      },
      child: const Text('Save'),
    );
    // #enddocregion unchecked
  }
}
