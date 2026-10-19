import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/rizma_look.dart';
import '../features/account/account_providers.dart';
import '../features/profiles/active_profile_provider.dart';
import 'router.dart';

const _maxContentWidth = 480.0;

class _RizmaScrollBehavior extends MaterialScrollBehavior {
  const _RizmaScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class RizmaApp extends ConsumerWidget {
  const RizmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(activePrefsProvider).value?.fontSize.scale ?? 1;
    final grade = ref.watch(activeProfileProvider).value?.grade;

    return MaterialApp.router(
      title: 'Rizma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.forLook(RizmaLook.forGrade(grade)),
      scrollBehavior: const _RizmaScrollBehavior(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final systemScale = media.textScaler.scale(1);

        return ColoredBox(
          color: AppColors.mute,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(systemScale * fontScale),
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
