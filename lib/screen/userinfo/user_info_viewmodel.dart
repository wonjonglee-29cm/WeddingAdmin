import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding/data/raw/user_info_raw.dart';
import 'package:wedding/data/repository/member_repository.dart';
import 'package:wedding/screen/userinfo/user_info_guest_type.dart';

import 'user_info_screen.dart';

class UserInfoState {
  final String? name;
  final bool? willAttend;
  final GuestType? guestType;
  final bool? hasCompanion;
  final int? companionCount;
  final bool? willEat;
  final bool isLoading;
  final String? error;
  final UserInfoRaw? userInfo;

  UserInfoState({
    this.name,
    this.willAttend,
    this.guestType,
    this.hasCompanion,
    this.companionCount,
    this.willEat,
    this.isLoading = false,
    this.error,
    this.userInfo,
  });

  UserInfoState copyWith({
    String? name,
    bool? willAttend,
    GuestType? guestType,
    bool? hasCompanion,
    int? companionCount,
    bool? willEat,
    bool? isLoading,
    String? error,
    UserInfoRaw? userInfo,
  }) {
    return UserInfoState(
      name: name ?? this.name,
      willAttend: willAttend ?? this.willAttend,
      guestType: guestType ?? this.guestType,
      hasCompanion: hasCompanion ?? this.hasCompanion,
      companionCount: companionCount ?? this.companionCount,
      willEat: willEat ?? this.willEat,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  bool get isFormValid {
    return willAttend != null && guestType != null && hasCompanion != null && (hasCompanion == false || (hasCompanion == true && companionCount != null)) && willEat != null;
  }
}

class UserInfoViewModel extends StateNotifier<UserInfoState> {
  final MemberRepository _memberRepository;
  final int id;

  UserInfoViewModel(this._memberRepository, this.id) : super(UserInfoState()) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userInfo = await _memberRepository.findMember(id);
      state = state.copyWith(
        isLoading: false,
        willAttend: userInfo.isAttendance,
        guestType: GuestType.fromString(userInfo.guestType),
        hasCompanion: userInfo.isCompanion,
        companionCount: userInfo.isCompanion == true ? userInfo.companionCount : null,
        willEat: userInfo.isMeal,
        userInfo: userInfo,
        name: userInfo.name,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateWillAttend(bool? value) {
    state = state.copyWith(willAttend: value);
  }

  void updateGuestType(GuestType? value) {
    state = state.copyWith(guestType: value);
  }

  void updateHasCompanion(bool? value) {
    if (value == true) {
      state = state.copyWith(
        hasCompanion: value,
        companionCount: state.companionCount ?? 1,
      );
    } else {
      state = state.copyWith(
        hasCompanion: value,
        companionCount: null,
      );
    }
  }

  void updateCompanionCount(int? value) {
    state = state.copyWith(companionCount: value);
  }

  void updateWillEat(bool? value) {
    state = state.copyWith(willEat: value);
  }

  Future<bool> submit() async {
    if (!state.isFormValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _memberRepository.updateMember(
        id: id,
        name: state.name!,
        guestType: state.guestType!.name,
        isAttendance: state.willAttend!,
        isCompanion: state.hasCompanion!,
        companionCount: state.hasCompanion! ? state.companionCount : 0,
        isMeal: state.willEat!,
      );

      state = state.copyWith(userInfo: response, isLoading: false);

      return response.isUpdatedInfo();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }
}