import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/user_info_raw.dart';
import 'package:wedding/design/component/ds_appbar.dart';
import 'package:wedding/design/component/ds_textfield.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/attendees/attendees_viewmodel.dart';
import 'package:wedding/screen/di_viewmodel.dart';
import 'package:wedding/screen/userinfo/user_info_screen.dart';

class AttendeesScreen extends HookConsumerWidget {
  const AttendeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final attendeesState = ref.watch(attendeesViewModelProvider);
    final attendeesViewModel = ref.read(attendeesViewModelProvider.notifier);

    return Scaffold(
      appBar: normalAppBar('참석자 정보 확인'),
      body: switch (attendeesState.uiState) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final message) => Center(child: Text('에러가 발생했습니다: $message')),
        Content() when attendeesState.memberAllRaw == null => const Center(child: Text('데이터가 없습니다.')),
        Content() => _buildContent(context, attendeesState, attendeesViewModel, searchController),
      },
    );
  }

  Widget _buildContent(BuildContext context, AttendeesState state, AttendeesViewModel viewModel, TextEditingController searchController) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: TextFieldWidget(
              controller: searchController,
              decoration: defaultDecor(hint: '하객 이름을 입력해주세요', labelText: '하객 찾기').copyWith(prefixIcon: const Icon(Icons.search)),
              onChanged: (value) {
                viewModel.setSearchQuery(value);
              }),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: GuestInfoFilterType.values.map((filterType) {
                  String count = switch (filterType) {
                    GuestInfoFilterType.all => '${state.memberAllRaw!.count}명',
                    GuestInfoFilterType.attendance => '${state.memberAllRaw!.attendanceCount}명',
                    GuestInfoFilterType.notAttendance => '${state.memberAllRaw!.count - state.memberAllRaw!.attendanceCount}명',
                    GuestInfoFilterType.companion => '${state.memberAllRaw!.companionCount}명',
                    GuestInfoFilterType.meal => '${state.memberAllRaw!.mealCount}명',
                  };

                  return _buildFilterTab(
                    context,
                    filterType.displayText,
                    count,
                    state.selectedInfoFilterType,
                        (type) => viewModel.setGuestInfoFilter(type),
                  );
                }).toList(),
              ),
              Row(
                children: GuestTypeFilterType.values.map((filterType) {
                  return _buildFilterTab(
                    context,
                    filterType.displayText,
                    null,
                    state.selectedTypeFilterType,
                        (type) => viewModel.setGuestTypeFilter(type),
                  );
                }).toList(),
              )
            ],
          ),
        ),

        // 게스트 목록
        Expanded(
          child: ListView.separated(
            itemCount: state.filteredMembers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = state.filteredMembers[index];
              return AttendeeListItem(
                member: member,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInfoScreen(id: member.id),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteConfirmDialog(
                    context,
                    member.id,
                    member.name ?? '이름 없음',
                    viewModel,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab<T>(BuildContext context,
      String title,
      String? count,
      T selectedType,
      Function(T) onSelected,) {
    // 선택된 값 확인
    bool isSelected = false;
    T filterType;

    if (T == GuestInfoFilterType) {
      isSelected = (selectedType as GuestInfoFilterType).displayText == title;
      filterType = GuestInfoFilterType.fromString(title) as T;
    } else {
      isSelected = (selectedType as GuestTypeFilterType).displayText == title;
      filterType = GuestTypeFilterType.fromString(title) as T;
    }

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(filterType),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: titleStyle3.copyWith(color: isSelected ? Colors.white : Colors.black),
              ),
              if (count != null && count.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  count,
                  style: bodyStyle3.copyWith(color: isSelected ? Colors.white : Colors.grey),
                ),
              ],
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context,
      int id,
      String name,
      AttendeesViewModel notifier,) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('참석자 삭제'),
            content: Text('정말 $name님을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await notifier.deleteAttendee(id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name님이 삭제되었습니다.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
                    );
                  }
                },
                child: const Text('예'),
              ),
            ],
          ),
    );
  }
}

class AttendeeListItem extends StatelessWidget {
  final UserInfoRaw member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AttendeeListItem({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name ?? '이름 없음',
                      style: titleStyle3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '- 하객 정보: ${_getGuestTypeText(member.guestType ?? '')}',
                      style: bodyStyle4,
                    ),
                    const SizedBox(height: 1),
                    Text('- 참석 여부: ${member.isAttendance == true ? '참석' : '미참석'}', style: bodyStyle4),
                    const SizedBox(height: 1),
                    Text('- 식사 여부: ${member.isMeal == true ? '식사함' : '식사 안함'}', style: bodyStyle4),
                    const SizedBox(height: 1),
                    if (member.isCompanion == true) Text('  동반자 수: ${member.companionCount ?? 0}명', style: bodyStyle4) else
                      const Text('- 동반자 수: 없음', style: bodyStyle4),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    TextButton(
                      onPressed: onDelete,
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    )
                  ],
                )
              ],
            ),
          ],
        )),);
  }

  String _getGuestTypeText(String type) {
    switch (type.toUpperCase()) {
      case 'BOTH':
        return '둘 다';
      case 'GROOM':
        return '신랑측';
      case 'BRIDE':
        return '신부측';
      default:
        return '선택안함';
    }
  }
}
