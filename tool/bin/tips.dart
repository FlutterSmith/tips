import 'dart:io';

import 'package:tips_cli/tips_cli.dart';

Future<void> main(List<String> args) async {
  exitCode = await runTips(args);
}
