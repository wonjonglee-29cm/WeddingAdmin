import 'dart:convert';

class MemberAllRaw {
  final int count;
  final int attendanceCount;
  final int companionCount;
  final int mealCount;
  final List<UserInfoRaw> members;

  MemberAllRaw({
    required this.count,
    required this.attendanceCount,
    required this.companionCount,
    required this.mealCount,
    required this.members,
  });

  Map<String, dynamic> toJson() => {
    'count': count,
    'attendanceCount': attendanceCount,
    'companionCount': companionCount,
    'mealCount': mealCount,
    'members': members.map((member) => member.toJson()).toList(),
  };

  factory MemberAllRaw.fromJson(Map<String, dynamic> json) {
    return MemberAllRaw(
      count: json['count'] ?? 0,
      attendanceCount: json['attendanceCount'] ?? 0,
      companionCount: json['companionCount'] ?? 0,
      mealCount: json['mealCount'] ?? 0,
      members: (json['members'] as List<dynamic>?)
          ?.map((memberJson) => UserInfoRaw.fromJson(memberJson))
          .toList() ?? [],
    );
  }

  // JSON 문자열에서 객체 생성
  factory MemberAllRaw.fromJsonString(String jsonString) {
    return MemberAllRaw.fromJson(json.decode(jsonString));
  }

  // 총 참석자 수 계산 (참석자 + 동반자)
  int getTotalAttendees() {
    return attendanceCount + companionCount;
  }

  // 참석 여부에 따른 멤버 필터링
  List<UserInfoRaw> getAttendingMembers() {
    return members.where((member) => member.isAttendance == true).toList();
  }

  // 식사 여부에 따른 멤버 필터링
  List<UserInfoRaw> getMealMembers() {
    return members.where((member) => member.isMeal == true).toList();
  }

  // 게스트 타입에 따른 멤버 필터링
  List<UserInfoRaw> getMembersByType(String type) {
    return members.where((member) => member.guestType == type).toList();
  }

  // 업데이트 완료된 멤버만 필터링
  List<UserInfoRaw> getUpdatedMembers() {
    return members.where((member) => member.isUpdatedInfo()).toList();
  }
}

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