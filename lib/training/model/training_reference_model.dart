import 'package:good_posture_good_exercise/training/model/coordinate.dart';
import 'package:json_annotation/json_annotation.dart';

part 'training_reference_model.g.dart';

@JsonSerializable()
class TrainingReferenceModel {
  Coordinate leftHand;
  Coordinate rightHand;
  Coordinate leftShoulder;
  Coordinate rightShoulder;
  Coordinate leftElbow;
  Coordinate rightElbow;

  TrainingReferenceModel(this.leftHand, this.rightHand, this.leftShoulder,
      this.rightShoulder, this.leftElbow, this.rightElbow);

  Map<String, dynamic> toJson() => _$TrainingReferenceModelToJson(this);

  factory TrainingReferenceModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingReferenceModelFromJson(json);

  @override
  String toString() {
    return 'TrainingReferenceModel{leftHand: $leftHand, rightHand: $rightHand, leftShoulder: $leftShoulder, rightShoulder: $rightShoulder, leftElbow: $leftElbow, rightElbow: $rightElbow}';
  }
}
