import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/design/component/ds_appbar.dart';
import 'package:wedding/design/component/ds_bottom_button.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/di_viewmodel.dart';
import 'package:wedding/screen/userinfo/user_info_guest_type.dart';

class UserInfoScreen extends HookConsumerWidget {
  final int id;  // 여기에 ID 매개변수 추가

  const UserInfoScreen({
    super.key,
    required this.id,  // required로 필수값 설정
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(userInfoViewModelProvider(id));
    final viewModel = ref.read(userInfoViewModelProvider(id).notifier);

    final companionCounts = List.generate(10, (i) => i + 1);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    useEffect(() {
      if (state.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        });
      }
      return null;
    }, [state.error]);

    return Scaffold(
      appBar: closeAppBar(context, '참석 정보', onPressed: () => Navigator.pop(context)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    itemsGap,
                    const SizedBox(
                      width: double.infinity,
                      child: Text('참석의 부담은 가지지 말아주시고,\n정성껏 준비하기 위해 여쭙는 것이니\n참석 정보를 알려주시면 감사하겠습니다.', style: bodyStyle1, textAlign: TextAlign.center),
                    ),
                    itemsGap,
                    itemsGap,
                    buildSelectionButtons('결혼식 참석 여부를 알려 주세요.', {true: '참석', false: '불참'}, state.willAttend, (value) => viewModel.updateWillAttend(value), description: '(나중에 수정할 수 있어요.)'),
                    buildSection(
                      '신랑측 하객인가요, 신부측 하객인가요?',
                      buildBottomSheetSelector<GuestType>(
                        context: context,
                        title: '하객 분류',
                        selectedValue: state.guestType,
                        options: GuestType.values.toList(),
                        getLabel: (type) => type.title,
                        onChanged: (value) => viewModel.updateGuestType(value),
                      ),
                    ),
                    buildSelectionButtons('식사를 하고 가시나요?', {true: '식사 함', false: '식사 안함'}, state.willEat, (value) => viewModel.updateWillEat(value), description: '(식사 이후 샴페인과 함께 경품 타임이 있습니다)'),
                    buildSelectionButtons(
                      '동행인이 있나요?',
                      {true: '있음', false: '없음'},
                      state.hasCompanion,
                      (value) => viewModel.updateHasCompanion(value),
                    ),
                    if (state.hasCompanion == true)
                      buildSection(
                          '같이 오는 분은 총 몇명인가요?',
                          buildBottomSheetSelector<int>(
                            context: context,
                            title: '동행인 수',
                            selectedValue: state.companionCount,
                            options: companionCounts,
                            getLabel: (count) => '$count명',
                            onChanged: (value) => viewModel.updateCompanionCount(value),
                          ),
                          description: '• 본인을 제외한 동행인 수를 선택해주세요.\n• 유아도 식사를 할 경우 1인으로 계산해 주세요'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: bottomButtonWidget(
                onPressed: state.isFormValid
                    ? () async {
                        final success = await viewModel.submit();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                text: '제출할게요',
                isEnabled: state.isFormValid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, Widget child, {String? description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle2),
        const SizedBox(height: 4),
        if (description != null) ...[
          Text(description, style: bodyStyle2.copyWith(color: Colors.grey)),
          title2Gap,
        ],
        child,
        itemsGap,
      ],
    );
  }

  Widget buildSelectionButtons(String title, Map<bool, String> options, bool? groupValue, ValueChanged<bool?> onChanged, {String? description}) {
    return buildSection(
      title,
      Row(
        children: options.entries.map((entry) {
          final bool value = entry.key;
          final String text = entry.value;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: EdgeInsets.only(
                  right: value ? 4 : 0,
                  left: !value ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: groupValue == value ? primaryColor : Colors.grey,
                    width: groupValue == value ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: bodyStyle1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      description: description,
    );
  }

  Widget buildBottomSheetSelector<T>({
    required BuildContext context,
    required String title,
    required T? selectedValue,
    required List<T> options,
    required String Function(T value) getLabel,
    required Function(T?) onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Text(
                      title,
                      style: titleStyle2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final value = options[index];
                        return InkWell(
                          onTap: () {
                            onChanged(value);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            width: double.infinity,
                            child: Text(
                              getLabel(value),
                              style: bodyStyle1.copyWith(
                                color: selectedValue == value ? primaryColor : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedValue != null ? primaryColor : Colors.grey,
            width: selectedValue != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedValue != null ? getLabel(selectedValue) : '선택해주세요',
              style: selectedValue == null ? bodyStyle1.copyWith(color: Colors.grey) : bodyStyle1.copyWith(color: Colors.black),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
