import 'dart:convert';
import 'package:collection/collection.dart';

class MatchModel {
  String id;
  List<String> userIds;

  MatchModel({
    required this.id,
    required this.userIds,
  });

  MatchModel copyWith({
    String? id,
    List<String>? userIds,
  }) {
    return MatchModel(
      id: id ?? this.id,
      userIds: userIds ?? this.userIds,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'userIds': userIds});

    return result;
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      userIds: List<String>.from(map['userIds']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchModel.fromJson(String source) =>
      MatchModel.fromMap(json.decode(source));

  @override
  String toString() => 'MatchModel(id: $id, userIds: $userIds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is MatchModel &&
        other.id == id &&
        listEquals(other.userIds, userIds);
  }

  @override
  int get hashCode => id.hashCode ^ userIds.hashCode;
}
