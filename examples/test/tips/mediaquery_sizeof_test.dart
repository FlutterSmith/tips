import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/mediaquery-sizeof/width_label.dart';

void main() {
  var sizeOfBuilds = 0;
  var ofBuilds = 0;

  // One instance, reused across pumps, so only MediaQuery
  // dependencies can trigger a rebuild.
  final labels = Directionality(
    textDirection: TextDirection.ltr,
    child: Column(
      children: [
        WidthLabel(onBuild: () => sizeOfBuilds++),
        WidthLabelOf(onBuild: () => ofBuilds++),
      ],
    ),
  );

  Widget withData(MediaQueryData data) =>
      MediaQuery(data: data, child: labels);

  setUp(() {
    sizeOfBuilds = 0;
    ofBuilds = 0;
  });

  const base = MediaQueryData(size: Size(400, 800));

  testWidgets('both show the width', (tester) async {
    await tester.pumpWidget(withData(base));
    expect(find.text('400 px wide'), findsNWidgets(2));
  });

  testWidgets('an unrelated change rebuilds only MediaQuery.of', (
    tester,
  ) async {
    await tester.pumpWidget(withData(base));
    expect((sizeOfBuilds, ofBuilds), (1, 1));

    // The keyboard opens: viewInsets change, size does not.
    await tester.pumpWidget(
      withData(
        base.copyWith(viewInsets: const EdgeInsets.only(bottom: 300)),
      ),
    );
    expect(sizeOfBuilds, 1);
    expect(ofBuilds, 2);

    await tester.pumpWidget(
      withData(base.copyWith(platformBrightness: Brightness.dark)),
    );
    expect(sizeOfBuilds, 1);
    expect(ofBuilds, 3);
  });

  testWidgets('a size change rebuilds both', (tester) async {
    await tester.pumpWidget(withData(base));
    await tester.pumpWidget(
      withData(base.copyWith(size: const Size(800, 400))),
    );
    expect((sizeOfBuilds, ofBuilds), (2, 2));
    expect(find.text('800 px wide'), findsNWidgets(2));
  });

  testWidgets('the other aspect getters read their values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(800, 400),
            padding: EdgeInsets.only(top: 24),
          ),
          child: SafeHeader(),
        ),
      ),
    );
    expect(find.text('Landscape'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Landscape')).dy, 24);
  });
}
