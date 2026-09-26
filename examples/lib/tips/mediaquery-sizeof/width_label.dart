import 'package:flutter/widgets.dart';

/// Shows the screen width. Depends on the size only.
class WidthLabel extends StatelessWidget {
  const WidthLabel({super.key, this.onBuild});

  /// Lets tests count builds.
  final VoidCallback? onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    // #docregion size-of
    // @note subscribes to the size and nothing else
    final width = MediaQuery.sizeOf(context).width;
    return Text('${width.round()} px wide');
    // #enddocregion size-of
  }
}

/// Shows the screen width, but depends on all of MediaQuery.
class WidthLabelOf extends StatelessWidget {
  const WidthLabelOf({super.key, this.onBuild});

  /// Lets tests count builds.
  final VoidCallback? onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    // #docregion of
    // @note subscribes to every MediaQuery property
    final width = MediaQuery.of(context).size.width;
    return Text('${width.round()} px wide');
    // #enddocregion of
  }
}

/// A few of the other aspect getters.
class SafeHeader extends StatelessWidget {
  const SafeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion others
    final padding = MediaQuery.paddingOf(context);
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final scaler = MediaQuery.textScalerOf(context);
    // #enddocregion others
    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: Text(
        landscape ? 'Landscape' : 'Portrait',
        textScaler: scaler,
      ),
    );
  }
}
