import 'package:json_annotation/json_annotation.dart';

part 'coordinate.g.dart';

@JsonSerializable()
class Coordinate {
  final double x;
  final double y;

  Coordinate(this.x, this.y);

  Map<String, dynamic> toJson() => _$CoordinateToJson(this);
  factory Coordinate.fromJson(Map<String, dynamic> json) =>
      _$CoordinateFromJson(json);

  @override
  String toString() {
    return 'Coordinate{x: $x, y: $y}';
  }
}
