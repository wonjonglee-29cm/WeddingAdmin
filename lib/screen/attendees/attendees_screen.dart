import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// 참석자 모델
class AttendeeModel {
  final int id;
  final String name;
  final String? guestType;
  final bool? isAttendance;
  final bool? isCompanion;
  final int? companionCount;
  final bool? isMeal;

  AttendeeModel({
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

  // 복사본 생성
  AttendeeModel copyWith({
    int? id,
    String? name,
    String? guestType,
    bool? isAttendance,
    bool? isCompanion,
    int? companionCount,
    bool? isMeal,
  }) {
    return AttendeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      guestType: guestType ?? this.guestType,
      isAttendance: isAttendance ?? this.isAttendance,
      isCompanion: isCompanion ?? this.isCompanion,
      companionCount: companionCount ?? this.companionCount,
      isMeal: isMeal ?? this.isMeal,
    );
  }
}

// 참석자 목록 모델
class AttendeesListModel {
  final int count;
  final int attendanceCount;
  final int companionCount;
  final int mealCount;
  final List<AttendeeModel> attendees;

  AttendeesListModel({
    required this.count,
    required this.attendanceCount,
    required this.companionCount,
    required this.mealCount,
    required this.attendees,
  });
}

// 참석자 상태 클래스
class AttendeesState {
  final bool isLoading;
  final AttendeesListModel? attendeesList;
  final String? errorMessage;
  final String searchQuery;
  final String filterType; // 'ALL', 'GROOM', 'BRIDE'

  AttendeesState({
    this.isLoading = false,
    this.attendeesList,
    this.errorMessage,
    this.searchQuery = '',
    this.filterType = 'ALL',
  });

  AttendeesState copyWith({
    bool? isLoading,
    AttendeesListModel? attendeesList,
    String? errorMessage,
    String? searchQuery,
    String? filterType,
  }) {
    return AttendeesState(
      isLoading: isLoading ?? this.isLoading,
      attendeesList: attendeesList ?? this.attendeesList,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
    );
  }

  // 필터링된 참석자 목록
  List<AttendeeModel> get filteredAttendees {
    if (attendeesList == null) return [];

    return attendeesList!.attendees.where((attendee) {
      // 검색어 필터링
      final matchesQuery = searchQuery.isEmpty ||
          attendee.name.toLowerCase().contains(searchQuery.toLowerCase());

      // 게스트 타입 필터링
      final matchesType = filterType == 'ALL' ||
          attendee.guestType == filterType;

      return matchesQuery && matchesType;
    }).toList();
  }
}

// 참석자 ViewModel
class AttendeesViewModel extends StateNotifier<AttendeesState> {
  AttendeesViewModel() : super(AttendeesState()) {
    fetchAttendees();
  }

  Future<void> fetchAttendees() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 실제 API 호출을 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 샘플 데이터
      final sampleAttendees = [
        AttendeeModel(
          id: 1,
          name: "홍길동",
          guestType: "GROOM",
          isAttendance: true,
          isCompanion: true,
          companionCount: 2,
          isMeal: true,
        ),
        AttendeeModel(
          id: 2,
          name: "김철수",
          guestType: "GROOM",
          isAttendance: true,
          isCompanion: false,
          companionCount: 0,
          isMeal: true,
        ),
        AttendeeModel(
          id: 3,
          name: "이영희",
          guestType: "BRIDE",
          isAttendance: true,
          isCompanion: true,
          companionCount: 1,
          isMeal: true,
        ),
        AttendeeModel(
          id: 4,
          name: "박지민",
          guestType: "BRIDE",
          isAttendance: false,
          isCompanion: false,
          companionCount: 0,
          isMeal: false,
        ),
      ];

      // 전체 정보 계산
      final totalCount = sampleAttendees.length;
      final attendingCount = sampleAttendees.where((a) => a.isAttendance == true).length;
      final companionCount = sampleAttendees
          .where((a) => a.isCompanion == true)
          .fold(0, (sum, a) => sum + (a.companionCount ?? 0));
      final mealCount = sampleAttendees.where((a) => a.isMeal == true).length;

      final attendeesList = AttendeesListModel(
        count: totalCount,
        attendanceCount: attendingCount,
        companionCount: companionCount,
        mealCount: mealCount,
        attendees: sampleAttendees,
      );

      state = state.copyWith(
        isLoading: false,
        attendeesList: attendeesList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '참석자 정보를 불러오는데 실패했습니다: ${e.toString()}',
      );
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateFilter(String filterType) {
    state = state.copyWith(filterType: filterType);
  }

  Future<void> updateAttendee(AttendeeModel updatedAttendee) async {
    try {
      // 실제로는 API 호출이 필요함
      await Future.delayed(const Duration(milliseconds: 500));

      if (state.attendeesList == null) return;

      final updatedAttendees = state.attendeesList!.attendees.map((attendee) {
        if (attendee.id == updatedAttendee.id) {
          return updatedAttendee;
        }
        return attendee;
      }).toList();

      // 전체 정보 다시 계산
      final totalCount = updatedAttendees.length;
      final attendingCount = updatedAttendees.where((a) => a.isAttendance == true).length;
      final companionCount = updatedAttendees
          .where((a) => a.isCompanion == true)
          .fold(0, (sum, a) => sum + (a.companionCount ?? 0));
      final mealCount = updatedAttendees.where((a) => a.isMeal == true).length;

      final attendeesList = AttendeesListModel(
        count: totalCount,
        attendanceCount: attendingCount,
        companionCount: companionCount,
        mealCount: mealCount,
        attendees: updatedAttendees,
      );

      state = state.copyWith(attendeesList: attendeesList);
    } catch (e) {
      // 에러 처리
      debugPrint('참석자 정보 업데이트 실패: ${e.toString()}');
    }
  }
}

// 참석자 Provider
final attendeesProvider = StateNotifierProvider<AttendeesViewModel, AttendeesState>((ref) {
  return AttendeesViewModel();
});

// 참석자 화면
class AttendeesScreen extends HookConsumerWidget {
  const AttendeesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendeesState = ref.watch(attendeesProvider);
    final viewModel = ref.read(attendeesProvider.notifier);

    // 검색 컨트롤러
    final searchController = useTextEditingController();

    useEffect(() {
      searchController.addListener(() {
        viewModel.updateSearchQuery(searchController.text);
      });
      return () => searchController.dispose();
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('참석자 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchAttendees(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: '참석자 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 필터 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterButton(
                  context,
                  'ALL',
                  '전체',
                  attendeesState.filterType == 'ALL',
                  viewModel,
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  'GROOM',
                  '신랑측',
                  attendeesState.filterType == 'GROOM',
                  viewModel,
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  'BRIDE',
                  '신부측',
                  attendeesState.filterType == 'BRIDE',
                  viewModel,
                ),
              ],
            ),
          ),

          // 요약 정보
          if (attendeesState.attendeesList != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('총 인원', '${attendeesState.attendeesList!.count}명'),
                  _buildSummaryItem('참석', '${attendeesState.attendeesList!.attendanceCount}명'),
                  _buildSummaryItem('동반자', '${attendeesState.attendeesList!.companionCount}명'),
                  _buildSummaryItem('식사', '${attendeesState.attendeesList!.mealCount}명'),
                ],
              ),
            ),

          // 리스트 뷰
          Expanded(
            child: attendeesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendeesState.errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    attendeesState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchAttendees(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
                : attendeesState.filteredAttendees.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
              itemCount: attendeesState.filteredAttendees.length,
              itemBuilder: (context, index) {
                final attendee = attendeesState.filteredAttendees[index];
                return _buildAttendeeItem(context, attendee, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
      BuildContext context,
      String filterValue,
      String label,
      bool isSelected,
      AttendeesViewModel viewModel,
      ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => viewModel.updateFilter(filterValue),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          foregroundColor: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeItem(
      BuildContext context,
      AttendeeModel attendee,
      AttendeesViewModel viewModel,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 이름 및 기본 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendee.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '게스트 타입: ${_getGuestTypeText(attendee.guestType)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (attendee.isAttendance != null)
                    Text(
                      '참석 여부: ${attendee.isAttendance! ? '참석' : '불참'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  if (attendee.isCompanion != null && attendee.isCompanion!)
                    Text(
                      '동반자: ${attendee.companionCount}명',
                      style: const TextStyle(fontSize: 14),
                    ),
                  if (attendee.isMeal != null)
                    Text(
                      '식사 여부: ${attendee.isMeal! ? '식사함' : '식사 안함'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),

            // 수정 버튼
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, attendee, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  String _getGuestTypeText(String? guestType) {
    if (guestType == null) return '미정';
    switch (guestType) {
      case 'GROOM':
        return '신랑측';
      case 'BRIDE':
        return '신부측';
      case 'BOTH':
        return '양가';
      default:
        return guestType;
    }
  }

  Future<void> _showEditDialog(
      BuildContext context,
      AttendeeModel attendee,
      AttendeesViewModel viewModel,
      ) async {
    // 수정 가능한 임시 값 설정
    bool isAttending = attendee.isAttendance ?? false;
    bool hasCompanion = attendee.isCompanion ?? false;
    int companionCount = attendee.companionCount ?? 0;
    bool hasMeal = attendee.isMeal ?? false;
    String guestType = attendee.guestType ?? 'GROOM';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${attendee.name} 정보 수정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 게스트 타입
                    const Text('게스트 타입:', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: guestType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'GROOM', child: Text('신랑측')),
                        DropdownMenuItem(value: 'BRIDE', child: Text('신부측')),
                        DropdownMenuItem(value: 'BOTH', child: Text('양가')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => guestType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 참석 여부
                    CheckboxListTile(
                      title: const Text('참석'),
                      value: isAttending,
                      onChanged: (value) {
                        setState(() => isAttending = value ?? false);
                      },
                    ),

                    // 동반자 여부
                    CheckboxListTile(
                      title: const Text('동반자 있음'),
                      value: hasCompanion,
                      onChanged: (value) {
                        setState(() => hasCompanion = value ?? false);
                      },
                    ),

                    // 동반자 수
                    if (hasCompanion)
                      Row(
                        children: [
                          const Text('동반자 수:'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Slider(
                              value: companionCount.toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: companionCount.toString(),
                              onChanged: (value) {
                                setState(() => companionCount = value.toInt());
                              },
                            ),
                          ),
                          Text('$companionCount명'),
                        ],
                      ),

                    // 식사 여부
                    CheckboxListTile(
                      title: const Text('식사'),
                      value: hasMeal,
                      onChanged: (value) {
                        setState(() => hasMeal = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    // 업데이트된 정보 생성
                    final updatedAttendee = attendee.copyWith(
                      guestType: guestType,
                      isAttendance: isAttending,
                      isCompanion: hasCompanion,
                      companionCount: hasCompanion ? companionCount : 0,
                      isMeal: hasMeal,
                    );

                    // 상태 업데이트
                    viewModel.updateAttendee(updatedAttendee);

                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}