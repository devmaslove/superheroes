import 'package:json_annotation/json_annotation.dart';
import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';

part 'superhero.g.dart';

@JsonSerializable()
class Superhero {
  final String id;
  final String name;
  final Biography biography;
  final Powerstats powerstats;
  final ServerImage image;

  Superhero({
    required this.name,
    required this.biography,
    required this.image,
    required this.powerstats,
    required this.id,
  });

  factory Superhero.fromJson(final Map<String, dynamic> json) =>
      _$SuperheroFromJson(json);

  Map<String, dynamic> toJson() => _$SuperheroToJson(this);

  @override
  String toString() {
    return 'Superhero{id: $id, name: $name, biography: $biography, powerstats: $powerstats, image: $image';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Superhero &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          biography == other.biography &&
          powerstats == other.powerstats &&
          image == other.image;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      biography.hashCode ^
      powerstats.hashCode ^
      image.hashCode;
}
