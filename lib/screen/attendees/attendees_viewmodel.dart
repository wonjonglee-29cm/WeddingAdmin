import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/member_all_raw.dart';
import 'package:wedding/data/raw/user_info_raw.dart';
import 'package:wedding/data/repository/member_repository.dart';

sealed class UIState {
  const UIState();
}

class Loading extends UIState {
  const Loading();
}

class Error extends UIState {
  final String message;

  const Error(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Error &&
              runtimeType == other.runtimeType &&
              message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class Content extends UIState {
  const Content();
}

class AttendeesState {
  final MemberAllRaw? memberAllRaw;
  final List<UserInfoRaw> filteredMembers;
  final String searchQuery;
  final GuestInfoFilterType selectedInfoFilterType;
  final GuestTypeFilterType selectedTypeFilterType;
  final UIState uiState;

  AttendeesState({
    this.memberAllRaw,
    this.filteredMembers = const [],
    this.searchQuery = '',
    this.selectedInfoFilterType = GuestInfoFilterType.all,
    this.selectedTypeFilterType = GuestTypeFilterType.all,
    this.uiState = const Content(),
  });

  // Factory constructors 수정
  factory AttendeesState.initial() => AttendeesState();

  factory AttendeesState.loading() => AttendeesState(
    uiState: const Loading(),
  );

  factory AttendeesState.error(String message) => AttendeesState(
    uiState: Error(message),
  );

  AttendeesState copyWith({
    MemberAllRaw? memberAllRaw,
    List<UserInfoRaw>? filteredMembers,
    String? searchQuery,
    GuestInfoFilterType? selectedInfoFilterType,
    GuestTypeFilterType? selectedTypeFilterType,
    UIState? uiState,
  }) {
    return AttendeesState(
      memberAllRaw: memberAllRaw ?? this.memberAllRaw,
      filteredMembers: filteredMembers ?? this.filteredMembers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedInfoFilterType: selectedInfoFilterType ?? this.selectedInfoFilterType,
      selectedTypeFilterType: selectedTypeFilterType ?? this.selectedTypeFilterType,
      uiState: uiState ?? this.uiState,
    );
  }
}

enum GuestInfoFilterType {
  all('전체'),
  attendance('참석가능'),
  notAttendance('참석불가능'),
  companion('동행인수'),
  meal('총 식사인원');

  final String label;
  const GuestInfoFilterType(this.label);

  // 표시할 텍스트 가져오기
  String get displayText => label;

  // 문자열에서 enum으로 변환 (혹시 필요할 경우)
  static GuestInfoFilterType fromString(String value) {
    return GuestInfoFilterType.values.firstWhere(
          (type) => type.label == value,
      orElse: () => GuestInfoFilterType.all,
    );
  }
}

enum GuestTypeFilterType {
  all('전체'),
  both('둘 다'),
  groom('신랑측'),
  bride('신부측'),
  none('선택안함');

  final String label;
  const GuestTypeFilterType(this.label);

  String get displayText => label;

  static GuestTypeFilterType fromString(String value) {
    return GuestTypeFilterType.values.firstWhere(
          (type) => type.label == value,
      orElse: () => GuestTypeFilterType.all,
    );
  }
}

class AttendeesViewModel extends StateNotifier<AttendeesState> {
  final MemberRepository _memberRepository;

  AttendeesViewModel(this._memberRepository) : super(AttendeesState.initial()) {
    loadAttendees();
  }

  Future<void> loadAttendees() async {
    state = state.copyWith(uiState: const Loading());

    try {
      final memberAllRaw = await _memberRepository.getAll();
      state = state.copyWith(
        memberAllRaw: memberAllRaw,
        uiState: const Content(),
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(uiState: Error(e.toString()));
    }
  }

  void setInitialState() {
    state = AttendeesState.initial();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setGuestInfoFilter(GuestInfoFilterType filterType) {
    state = state.copyWith(selectedInfoFilterType: filterType);
    _applyFilters();
  }

  void setGuestTypeFilter(GuestTypeFilterType filterType) {
    state = state.copyWith(selectedTypeFilterType: filterType);
    _applyFilters();
  }

  void _applyFilters() {
    if (state.memberAllRaw == null) return;

    var filteredList = state.memberAllRaw!.members.where((member) {
      // 이름 검색 필터
      final nameMatches = member.name?.toLowerCase().contains(state.searchQuery.toLowerCase()) ?? false;

      // 게스트 정보 필터
      bool infoMatches = switch (state.selectedInfoFilterType) {
        GuestInfoFilterType.all => true,
        GuestInfoFilterType.attendance => member.isAttendance ?? false,
        GuestInfoFilterType.notAttendance => member.isAttendance != true,
        GuestInfoFilterType.meal => member.isMeal ?? false,
        GuestInfoFilterType.companion => member.isCompanion ?? false,
      };

      // 게스트 타입 필터
      bool typeMatches = switch (state.selectedTypeFilterType) {
        GuestTypeFilterType.all => true,
        GuestTypeFilterType.none => member.guestType == null,
        GuestTypeFilterType.both => member.guestType == 'BOTH',
        GuestTypeFilterType.groom => member.guestType == 'GROOM',
        GuestTypeFilterType.bride => member.guestType == 'BRIDE',
      };

      return nameMatches && infoMatches && typeMatches;
    }).toList();

    // 이름 오름차순 정렬
    filteredList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    state = state.copyWith(filteredMembers: filteredList);
  }

  // 임시로 삭제 함수 구현
  Future<bool> deleteAttendee(int id) async {
    try {
      // API 호출이 있다고 가정합니다.
      // await _memberRepository.deleteMember(id);

      // 성공 시 목록에서 제거
      if (state.memberAllRaw != null) {
        final updatedMembers = state.memberAllRaw!.members.where((member) => member.id != id).toList();

        // 새로운 MemberAllRaw 객체를 생성해 상태 업데이트
        final updatedAllRaw = MemberAllRaw(
          count: updatedMembers.length,
          attendanceCount: updatedMembers.where((m) => m.isAttendance == true).length,
          companionCount: updatedMembers.where((m) => m.isCompanion == true).length,
          mealCount: updatedMembers.where((m) => m.isMeal == true).length,
          members: updatedMembers,
        );

        state = state.copyWith(memberAllRaw: updatedAllRaw);
        _applyFilters();
      }

      return true;
    } catch (e) {
      state = state.copyWith(uiState: Error(e.toString()));
      return false;
    }
  }
}

