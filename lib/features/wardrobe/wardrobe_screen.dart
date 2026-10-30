import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar_progress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/mascot_items.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../home/home_providers.dart';
import '../learning/widgets/round_panels.dart';
import '../profiles/active_profile_provider.dart';
import 'wardrobe_items.dart';
import 'wardrobe_providers.dart';
import 'wardrobe_repository.dart';

enum _Filter { all, colors, accessories }

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  _Filter _filter = _Filter.all;

  void _say(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onTap(
    WardrobeItem item,
    ItemState state,
    String profileId,
    int balance,
  ) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    switch (state) {
      case ItemState.equipped:
      case ItemState.owned:
        Haptics.tap();
        if (item.kind == WardrobeKind.accessory) {
          await repo.toggleAccessory(profileId, item.id);
        } else {
          await repo.useColor(profileId, item.id);
        }
      case ItemState.locked:
        _say(ArProgress.lockedLesson);
      case ItemState.buyable:
        if (balance < item.price) {
          _say(ArProgress.notEnoughStars);
          return;
        }
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(ArProgress.confirmBuyTitle),
            content: Text(ArProgress.confirmBuyBody(item.name, item.price)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(ArProgress.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(ArProgress.buy),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        final result = await repo.buy(profileId, item.id);
        if (!mounted) return;
        Haptics.heavy();
        _say(
          result == PurchaseResult.purchased
              ? ArProgress.purchased(item.name)
              : ArProgress.notEnoughStars,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider).value;
    if (profile == null) return const Scaffold(body: SizedBox.shrink());

    final owned = ref.watch(ownedItemsProvider(profile.id)).value ?? const [];
    final equipped =
        ref.watch(equippedItemsProvider(profile.id)).value ?? const <String>{};
    final attempts = ref.watch(attemptsProvider(profile.id)).value ?? const [];
    final progress =
        ref.watch(lessonProgressProvider(profile.id)).value ?? const [];

    final stars = attempts.fold<int>(0, (s, a) => s + a.starsEarned);
    final balance = WardrobeRepository.balance(stars: stars, owned: owned);
    final ownedSet = WardrobeRepository.ownedIds(owned);
    final lessonDone = progress.any((p) => p.status == LessonStatus.completed);
    final currentColorId = wardrobeItems
        .firstWhere((i) => i.color == profile.color)
        .id;

    ItemState stateOf(WardrobeItem i) => WardrobeRepository.stateOf(
      i,
      owned: ownedSet,
      equipped: equipped,
      lessonCompleted: lessonDone,
      currentColorItemId: currentColorId,
    );

    final shown = [
      for (final i in wardrobeItems)
        if (_filter == _Filter.all ||
            (_filter == _Filter.colors && i.kind == WardrobeKind.color) ||
            (_filter == _Filter.accessories &&
                i.kind == WardrobeKind.accessory))
          i,
    ];
    final wornNames = [
      for (final i in wardrobeItems)
        if (i.kind == WardrobeKind.accessory &&
            equipped.contains(i.id) &&
            stateOf(i) == ItemState.equipped)
          i.name,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: ArProgress.wardrobeTitle,
              subtitle: ArProgress.wardrobeKicker(profile.name),
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.account),
              end: StarsChip(count: balance),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    _Hero(
                      color: profile.color,
                      worn: equipped,
                      caption: wornNames.join(' · '),
                    ),
                    _Filters(
                      current: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    LayoutBuilder(
                      builder: (context, c) {
                        const gap = 10.0;
                        final width = (c.maxWidth - 2 * gap) / 3;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final item in shown)
                              SizedBox(
                                width: width,
                                child: _ItemCard(
                                  item: item,
                                  state: stateOf(item),
                                  profileColor: profile.color,
                                  onTap: () => _onTap(
                                    item,
                                    stateOf(item),
                                    profile.id,
                                    balance,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    LedgeBox(
                      radius: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          spacing: 10,
                          children: [
                            const AppIcon(
                              'shield',
                              size: 22,
                              color: AppColors.teal,
                            ),
                            Expanded(
                              child: Text(
                                ArProgress.wardrobeNote,
                                style: AppTextStyles.label14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.color, required this.worn, required this.caption});

  final ProfileColor color;
  final Set<String> worn;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
        child: Column(
          spacing: 8,
          children: [
            MascotWithItems(size: 150, color: color, items: worn),
            if (caption.isNotEmpty)
              Text(
                caption,
                textAlign: TextAlign.center,
                style: AppTextStyles.body15.copyWith(color: AppColors.tealDark),
              ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.current, required this.onChanged});

  final _Filter current;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _Filter.all: ArProgress.filterAll,
      _Filter.colors: ArProgress.filterColors,
      _Filter.accessories: ArProgress.filterAccessories,
    };
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final f in _Filter.values)
          Semantics(
            button: true,
            selected: f == current,
            label: labels[f],
            excludeSemantics: true,
            child: Material(
              color: f == current ? AppColors.teal : AppColors.mute,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onChanged(f),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    labels[f]!,
                    style: AppTextStyles.body15.copyWith(
                      color: f == current ? AppColors.card : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.state,
    required this.profileColor,
    required this.onTap,
  });

  final WardrobeItem item;
  final ItemState state;
  final ProfileColor profileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final equipped = state == ItemState.equipped;
    final locked = state == ItemState.locked;

    final Widget chip = switch (state) {
      ItemState.equipped => _Chip(
        label: item.kind == WardrobeKind.color
            ? ArProgress.itemInUse
            : ArProgress.itemEquipped,
        icon: 'check',
        fg: AppColors.teal,
        bg: AppColors.tealTint,
      ),
      ItemState.owned => _Chip(
        label: item.kind == WardrobeKind.color
            ? ArProgress.itemUseColor
            : ArProgress.itemOwned,
        fg: AppColors.soft,
        bg: AppColors.mute,
      ),
      ItemState.buyable => _Chip(
        label: ArProgress.itemPrice(item.price),
        icon: 'starf',
        fg: AppColors.amberDark,
        bg: AppColors.amberTint,
        iconAfter: true,
      ),
      ItemState.locked => const _Chip(
        label: ArProgress.lockedLesson,
        icon: 'lock',
        fg: AppColors.soft,
        bg: AppColors.mute,
      ),
    };

    return Semantics(
      button: true,
      label: item.name,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: equipped ? AppColors.teal : AppColors.line,
            width: equipped ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
            child: Opacity(
              opacity: locked ? 0.6 : 1,
              child: Column(
                children: [
                  MascotWithItems(
                    size: 56,
                    color: item.kind == WardrobeKind.color
                        ? item.color!
                        : profileColor,
                    items: item.kind == WardrobeKind.accessory
                        ? {item.id}
                        : const {},
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.captionBold13.copyWith(
                          color: AppColors.ink,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  chip,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.fg,
    required this.bg,
    this.icon,
    this.iconAfter = false,
  });

  final String label;
  final String? icon;
  final Color fg;
  final Color bg;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.chip13.copyWith(color: fg, fontSize: 12),
      ),
    );
    final glyph = icon == null ? null : AppIcon(icon!, size: 14, color: fg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (glyph != null && !iconAfter) glyph,
            text,
            if (glyph != null && iconAfter) glyph,
          ],
        ),
      ),
    );
  }
}
