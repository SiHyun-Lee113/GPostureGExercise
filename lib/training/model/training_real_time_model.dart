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

  Coordinate calXHighRow(List<Coordinate> coordinates) {
    double highX = 0.0;
    double rowX = 0.0;

    coordinates.sort(xComparator);

    int tenPercentIndex = (coordinates.length * 0.1).round();

    List<Coordinate> topTen =
        coordinates.sublist(coordinates.length - tenPercentIndex);
    List<Coordinate> bottomTen = coordinates.sublist(0, tenPercentIndex);

    var forHighX = calAverage(topTen);
    var forRowX = calAverage(bottomTen);

    highX = forHighX.x;
    rowX = forRowX.x;

    return Coordinate(highX, rowX);
  }

  Coordinate calYHighRow(List<Coordinate> coordinates) {
    double highY = 0.0;
    double rowY = 0.0;

    coordinates.sort(yComparator);

    int tenPercentIndex = (coordinates.length * 0.1).round();

    List<Coordinate> topTen =
        coordinates.sublist(coordinates.length - tenPercentIndex);
    List<Coordinate> bottomTen = coordinates.sublist(0, tenPercentIndex);

    var forHighY = calAverage(topTen);
    var forRowY = calAverage(bottomTen);

    highY = forHighY.y;
    rowY = forRowY.y;

    return Coordinate(highY, rowY);
  }

  int xComparator(Coordinate pre, Coordinate next) {
    if (pre.x < next.x) {
      return -1;
    } else if (pre.x > next.x) {
      return 1;
    } else {
      return 0;
    }
  }

  int yComparator(Coordinate pre, Coordinate next) {
    if (pre.y < next.y) {
      return -1;
    } else if (pre.y > next.y) {
      return 1;
    } else {
      return 0;
    }
  }
}
