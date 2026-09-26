import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/switch-on-records/status.dart';

void main() {
  test('the switch agrees with the if chain on every input', () {
    for (final connection in Connection.values) {
      for (final hasData in [true, false]) {
        for (final hasError in [true, false]) {
          expect(
            status(connection, hasData, hasError),
            statusWithIfs(connection, hasData, hasError),
            reason: '($connection, $hasData, $hasError)',
          );
        }
      }
    }
  });

  test('cases are tried top to bottom', () {
    expect(status(Connection.waiting, true, true), 'Loading');
    expect(status(Connection.done, true, true), 'Got data');
    expect(status(Connection.done, false, true), 'Got an error');
    expect(status(Connection.none, false, false), 'Nothing yet');
  });

  test('rock paper scissors covers all nine pairs', () {
    expect(play(Move.rock, Move.rock), Outcome.draw);
    expect(play(Move.rock, Move.scissors), Outcome.win);
    expect(play(Move.paper, Move.rock), Outcome.win);
    expect(play(Move.scissors, Move.paper), Outcome.win);
    expect(play(Move.rock, Move.paper), Outcome.lose);
    expect(play(Move.paper, Move.scissors), Outcome.lose);
    expect(play(Move.scissors, Move.rock), Outcome.lose);
    for (final m in Move.values) {
      expect(play(m, m), Outcome.draw);
    }
  });
}
