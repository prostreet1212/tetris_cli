// lib/tetris_cli.dart
export '../lib/src/board.dart';
// bin/main.dart

import 'package:tetris_cli/ansi_cli_helper.dart' as ansi;
import 'tetris_cli.dart';

void main(List<String> arguments) {
ansi.reset();
ansi.hideCursor();
initGame();
start();
}