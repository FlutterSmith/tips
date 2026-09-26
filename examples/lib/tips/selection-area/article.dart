import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// An article whose text can be selected across widgets.
class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, this.onSelectionChanged});

  /// Lets tests read what the user selected.
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // #docregion area
      // @note one selection across every Text below
      body: SelectionArea(
        onSelectionChanged: onSelectionChanged,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sourdough basics'),
            const Text('Feed the starter twice a day.'),
            // @note skipped by selection and copy
            SelectionContainer.disabled(
              child: TextButton(
                onPressed: () {},
                child: const Text('Share'),
              ),
            ),
            const Text('Bake at 250 degrees.'),
          ],
        ),
      ),
      // #enddocregion area
    );
  }
}
