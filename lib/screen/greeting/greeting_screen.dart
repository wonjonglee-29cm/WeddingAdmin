import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wedding/design/component/ds_appbar.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/di_viewmodel.dart';

// Greeting 화면
class GreetingScreen extends HookConsumerWidget {
  const GreetingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greetingState = ref.watch(greetingViewModelProvider);
    final expandedStates = useState<Set<int>>({}); // Track expanded state for each item

    return Scaffold(
      appBar: refreshAppBar('방명록 모아보기', onPressed: () => {
        ref.read(greetingViewModelProvider.notifier).fetchGreetings()
      }),
      body: greetingState.isLoading && greetingState.greetings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : greetingState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        greetingState.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(greetingViewModelProvider.notifier).fetchGreetings(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(greetingViewModelProvider.notifier).fetchGreetings();
                  },
                  child: greetingState.greetings.isEmpty
                      ? ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('인사말이 없습니다.', style: titleStyle1),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: greetingState.greetings.length,
                          itemBuilder: (context, index) {
                            final greeting = greetingState.greetings[index];
                            final isExpanded = expandedStates.value.contains(index);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Toggle expansion for this specific item
                                    final currentExpandedStates = Set<int>.from(expandedStates.value);
                                    if (currentExpandedStates.contains(index)) {
                                      currentExpandedStates.remove(index);
                                    } else {
                                      currentExpandedStates.add(index);
                                    }
                                    expandedStates.value = currentExpandedStates;
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade700),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          greeting.userName,
                                          style: titleStyle1.copyWith(color: isExpanded ? Colors.blueAccent.shade700 : Colors.black),
                                        ),
                                        Icon(
                                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: Colors.grey.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isExpanded)
                                  Container(
                                    margin: const EdgeInsets.only(left: 16.0, bottom: 24.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: Colors.grey.shade300, width: 8.0),
                                        top: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                        right: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                        bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      greeting.message,
                                      style: bodyStyle1,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
    );
  }
}
