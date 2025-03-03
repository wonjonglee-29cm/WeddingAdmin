class UserInfoRaw {
  final int id;
  final String? name;
  final String? guestType;
  final bool? isAttendance;
  final bool? isCompanion;
  final int? companionCount;
  final bool? isMeal;

  UserInfoRaw({
    required this.id,
    required this.name,
    this.guestType,
    this.isAttendance,
    this.isCompanion,
    this.companionCount,
    this.isMeal,
  });

  bool isUpdatedInfo() {
    return guestType != null &&
        isAttendance != null &&
        isCompanion != null &&
        companionCount != null &&
        isMeal != null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'guestType': guestType?.toUpperCase(),
    'isAttendance': isAttendance,
    'isCompanion': isCompanion,
    'companionCount': companionCount,
    'isMeal': isMeal,
  };

  factory UserInfoRaw.fromJson(Map<String, dynamic> json) {
    return UserInfoRaw(
      id: json['id'],
      name: json['name'],
      guestType: json['guestType'],
      isAttendance: json['attendance'],
      isCompanion: json['companion'],
      companionCount: json['companionCount'],
      isMeal: json['meal'],
    );
  }
}