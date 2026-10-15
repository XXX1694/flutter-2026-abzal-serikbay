sealed class Countdown {
  const Countdown();

  static const length = Duration(hours: 2);

  factory Countdown.of(DateTime startsAt, DateTime now) {
    final left = startsAt.difference(now);
    if (!left.isNegative) return Upcoming(left);
    final ago = now.difference(startsAt);
    if (ago < length) return Started(ago);
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

final class Started extends Countdown {
  const Started(this.ago);

  final Duration ago;
}

final class Ended extends Countdown {
  const Ended();
}
