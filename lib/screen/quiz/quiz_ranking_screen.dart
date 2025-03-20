import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/quiz_ranking_raw.dart';
import 'package:wedding/design/component/ds_appbar.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/di_viewmodel.dart';
import 'package:wedding/screen/quiz/quiz_ranking_viewmodel.dart';

// 사용자 상세 정보 다이얼로그
class _UserDetailsDialog extends HookWidget {
  final QuizRankingRaw ranking;

  const _UserDetailsDialog({
    super.key,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context) {
    // 애니메이션 효과
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      animationController.forward();
      return null; // dispose 함수를 반환하지 않도록 수정
    }, []);

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(animationController),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animationController),
        child: AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  ranking.user.name?.substring(0, 1) ?? '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ranking.user.name ?? '이름 없음',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('ID', ranking.user.id.toString()),
              _buildInfoItem('타입', _getGuestTypeText(ranking.user.guestType ?? '')),
              _buildInfoItem('참석 여부', ranking.user.isAttendance == true ? '참석' : '불참'),
              _buildInfoItem('동반자 여부', ranking.user.isCompanion == true ? '있음' : '없음'),
              _buildInfoItem('동반자 수', '${ranking.user.companionCount ?? 0}명'),
              _buildInfoItem('식사 여부', ranking.user.isMeal == true ? '식사 참여' : '식사 불참'),
              const Divider(),
              _buildInfoItem('퀴즈 정답 수', ranking.correctCount.toString(), isHighlighted: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.blue.shade700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizRankingScreen extends ConsumerStatefulWidget {
  const QuizRankingScreen({super.key});

  @override
  ConsumerState<QuizRankingScreen> createState() => _QuizRankingScreenState();
}

class _QuizRankingScreenState extends ConsumerState<QuizRankingScreen> {
  @override
  Widget build(BuildContext context) {
    // ViewModel 상태 구독
    final state = ref.watch(quizRankingViewModelProvider);

    return Scaffold(
      appBar: refreshAppBar('퀴즈 랭킹 확인하기', onPressed: () => {ref.read(quizRankingViewModelProvider.notifier).loadRankings()}),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(QuizRankingState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(quizRankingViewModelProvider.notifier).loadRankings();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.rankings.isEmpty) {
      return const Center(child: Text('랭킹 데이터가 없습니다.'));
    }

    return ListView.builder(
      itemCount: state.rankings.length,
      itemBuilder: (context, index) {
        return _RankingItem(
          ranking: state.rankings[index],
          position: index + 1,
        );
      },
    );
  }
}

// 랭킹 아이템 위젯 (HookWidget 사용)
class _RankingItem extends HookWidget {
  final QuizRankingRaw ranking;
  final int position;

  const _RankingItem({
    super.key,
    required this.ranking,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    // 상위 3위까지는 특별한 스타일 적용
    final positionColor = useMemoized(() {
      if (position == 1) {
        return Colors.amber; // 금메달
      } else if (position == 2) {
        return Colors.grey.shade400; // 은메달
      } else if (position == 3) {
        return Colors.brown.shade300; // 동메달
      }
      return null;
    }, [position]);

    // 애니메이션 효과 추가
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final animation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(animationController),
    );

    useEffect(() {
      animationController.forward();
      return null; // dispose 함수를 반환하지 않도록 수정
    }, []);

    return Opacity(
        opacity: animation,
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation)),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showUserDetailsDialog(context, ranking),
                    borderRadius: BorderRadius.circular(8.0),
                    child: Ink(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            // 순위 표시
                            CircleAvatar(
                              backgroundColor: positionColor ?? Colors.grey.shade200,
                              radius: 18,
                              child: Text(
                                position.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: positionColor != null ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 사용자 정보
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ranking.user.name ?? '이름 없음',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '타입: ${_getGuestTypeText(ranking.user.guestType ?? '')}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 점수 표시
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '정답수: ${ranking.correctCount}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // 화살표 아이콘
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  // 사용자 정보 팝업 다이얼로그 표시
  void _showUserDetailsDialog(BuildContext context, QuizRankingRaw ranking) {
    showDialog(
      context: context,
      builder: (context) => _UserDetailsDialog(ranking: ranking),
    );
  }
}

String _getGuestTypeText(String guestType) {
  switch (guestType.toUpperCase()) {
    case 'GROOM':
      return '신랑 측';
    case 'BRIDE':
      return '신부 측';
    case 'BOTH':
      return '양가 공통';
    default:
      return guestType.isEmpty ? '미지정' : guestType;
  }
}
