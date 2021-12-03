import 'package:flutter/cupertino.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class AlignmentInfo {
  final String name;
  final Color color;

  const AlignmentInfo._(this.name, this.color);

  static const bad = AlignmentInfo._("Bad", SuperheroesColors.red);
  static const good = AlignmentInfo._("Good", SuperheroesColors.green);
  static const neutral = AlignmentInfo._("Neutral", SuperheroesColors.grey);

  static AlignmentInfo? fromAlignment(final String alignment) {
    switch (alignment) {
      case "bad":
        return bad;
      case "good":
        return good;
      case "neutral":
        return neutral;
      default:
        return null;
    }
  }
}
