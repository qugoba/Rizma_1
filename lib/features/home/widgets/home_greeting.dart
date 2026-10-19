import 'package:flutter/material.dart';

import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/rizma_look.dart';
import '../../../core/widgets/mascot.dart';
import '../home_state.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final firstDay = state.isFirstDay;
    final calm = RizmaLook.of(context).calm;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calm && state.hasActivity
                      ? [
                          ArStrings.gradeName(profile.grade),
                          ArStrings.stars(state.stars),
                          if (state.streak > 0)
                            ArStrings.streakDays(state.streak),
                        ].join(' • ')
                      : ArStrings.gradeName(profile.grade),
                  style: AppTextStyles.caption12,
                ),
                Text(
                  firstDay
                      ? ArStrings.homeFirstDayGreeting(profile.name)
                      : ArStrings.homeGreeting(profile.name),
                  style: AppTextStyles.title26,
                ),
                Text(
                  firstDay
                      ? ArStrings.homeFirstDaySubtitle
                      : ArStrings.homeAskToday,
                  style: AppTextStyles.body15.copyWith(color: AppColors.soft),
                ),
              ],
            ),
          ),
          if (!calm) Mascot(size: 72, color: profile.color),
        ],
      ),
    );
  }
}
