enum Connection { none, waiting, active, done }

String statusWithIfs(
  Connection connection,
  bool hasData,
  bool hasError,
) {
  // #docregion if-chain
  if (connection == Connection.waiting) {
    return 'Loading';
  } else if (hasData) {
    return 'Got data';
  } else if (hasError) {
    return 'Got an error';
  } else {
    return 'Nothing yet';
  }
  // #enddocregion if-chain
}

String status(Connection connection, bool hasData, bool hasError) {
  // #docregion switch
  // @note one record, matched column by column
  return switch ((connection, hasData, hasError)) {
    (Connection.waiting, _, _) => 'Loading',
    (_, true, _) => 'Got data',
    (_, _, true) => 'Got an error',
    // @note _ in every slot catches whatever is left
    _ => 'Nothing yet',
  };
  // #enddocregion switch
}

// #docregion matrix
enum Move { rock, paper, scissors }

enum Outcome { win, lose, draw }

Outcome play(Move me, Move them) {
  return switch ((me, them)) {
    // @note binds both values and compares them in a guard
    (final a, final b) when a == b => Outcome.draw,
    (Move.rock, Move.scissors) ||
    (Move.paper, Move.rock) ||
    (Move.scissors, Move.paper) => Outcome.win,
    _ => Outcome.lose,
  };
}
// #enddocregion matrix
