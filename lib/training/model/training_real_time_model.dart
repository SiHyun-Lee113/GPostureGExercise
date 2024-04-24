import 'package:good_posture_good_exercise/dev_utils/logger.dart';
import 'package:good_posture_good_exercise/training/model/coordinate.dart';
import 'package:good_posture_good_exercise/training/model/training_reference_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'training_real_time_model.g.dart';

@JsonSerializable()
class TrainingRealTimeModel {
  List<Coordinate> leftHand = [];
  List<Coordinate> rightHand = [];
  List<Coordinate> leftShoulder = [];
  List<Coordinate> rightShoulder = [];
  List<Coordinate> leftElbow = [];
  List<Coordinate> rightElbow = [];

  TrainingRealTimeModel();

  Map<String, dynamic> toJson() => _$TrainingRealTimeModelToJson(this);

  factory TrainingRealTimeModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingRealTimeModelFromJson(json);

  void addCoordinates(
    Coordinate leftHand,
    Coordinate rightHand,
    Coordinate leftShoulder,
    Coordinate rightShoulder,
    Coordinate leftElbow,
    Coordinate rightElbow,
  ) {
    if (verificationCoordinate(leftHand)) this.leftHand.add(leftHand);
    if (verificationCoordinate(rightHand)) this.rightHand.add(rightHand);
    if (verificationCoordinate(leftShoulder))
      this.leftShoulder.add(leftShoulder);
    if (verificationCoordinate(rightShoulder))
      this.rightShoulder.add(rightShoulder);
    if (verificationCoordinate(leftElbow)) this.leftElbow.add(leftElbow);
    if (verificationCoordinate(rightElbow)) this.rightElbow.add(rightElbow);
  }

  bool verificationCoordinate(Coordinate coordinate) {
    if (coordinate.x < 0 || coordinate.y < 0) return false;
    return true;
  }

  TrainingReferenceModel calTrainingRFModel() {
    Coordinate leftHand = calAverage(this.leftHand);
    Coordinate rightHand = calAverage(this.rightHand);
    Coordinate leftShoulder = calAverage(this.leftShoulder);
    Coordinate rightShoulder = calAverage(this.rightShoulder);
    Coordinate leftElbow = calAverage(this.leftElbow);
    Coordinate rightElbow = calAverage(this.rightElbow);

    siHyunLogger(TrainingReferenceModel(leftHand, rightHand, leftShoulder,
            rightShoulder, leftElbow, rightElbow)
        .toString());

    return TrainingReferenceModel(leftHand, rightHand, leftShoulder,
        rightShoulder, leftElbow, rightElbow);
  }

  Coordinate calAverage(List<Coordinate> coordinates) {
    double avgX = 0.0;
    double avgY = 0.0;

    for (var coordinate in coordinates) {
      avgX += coordinate.x;
      avgY += coordinate.y;
    }

    avgX = avgX / coordinates.length;
    avgY = avgY / coordinates.length;

    return Coordinate(avgX, avgY);
  }
}
