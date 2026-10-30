import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../account/downloads_providers.dart';
import '../downloads/download_providers.dart';
import 'lesson_view.dart';

final pdfViewerProvider = Provider<Widget Function(Uint8List bytes)>(
  (ref) =>
      (bytes) => _PdfViewer(key: ObjectKey(bytes), bytes: bytes),
);

class AttachmentScreen extends ConsumerWidget {
  const AttachmentScreen({
    super.key,
    required this.lessonId,
    required this.index,
  });

  final String lessonId;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(lessonViewProvider(lessonId)).value;
    final attachments = view?.content?.attachments ?? const [];
    final attachment = index < attachments.length ? attachments[index] : null;

    void back() => context.canPop()
        ? context.pop()
        : context.go(AppRoutes.lesson(lessonId));

    if (attachment == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenTopBar(title: ArLearn.filesTitle, onBack: back),
              if (view != null)
                const Expanded(child: Center(child: Text(ArLearn.filesFailed))),
            ],
          ),
        ),
      );
    }

    final sha = attachment.file;
    final bytes = ref.watch(attachmentBytesProvider(sha));
    final status = ref.watch(
      attachmentStatusProvider((lessonId: lessonId, sha256: sha)),
    );
    final controller = ref.read(downloadControllerProvider.notifier);
    final downloadSize = switch (status) {
      AttachmentNotDownloaded(:final size) when controller.available => size,
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: attachment.title,
              subtitle: view?.lesson.title,
              onBack: back,
            ),
            Expanded(
              child: bytes.when(
                data: (b) => ref.watch(pdfViewerProvider)(b),
                loading: () =>
                    const _Message(text: ArLearn.filesOpening, busy: true),
                error: (e, _) => _Message(
                  text: e is AttachmentUnavailable && e.offline
                      ? ArLearn.filesOffline
                      : ArLearn.filesFailed,
                  onRetry: () => ref.invalidate(attachmentBytesProvider(sha)),
                ),
              ),
            ),
            if (downloadSize != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
                child: RizmaButton(
                  label: ArLearn.filesDownload(formatBytes(downloadSize)),
                  icon: 'download',
                  onPressed: () => controller.requestAttachment(lessonId, sha),
                ),
              )
            else if (status is AttachmentQueued)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  ArLearn.filesDownloading((status.fraction * 100).round()),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.busy = false, this.onRetry});

  final String text;
  final bool busy;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            if (busy) const CircularProgressIndicator(color: AppColors.teal),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.body15,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(
                  ArLearn.filesRetry,
                  style: AppTextStyles.body15.copyWith(color: AppColors.teal),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PdfViewer extends StatefulWidget {
  const _PdfViewer({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  late final _controller = PdfControllerPinch(
    document: PdfDocument.openData(widget.bytes),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: AppColors.sky,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: PdfViewPinch(
                controller: _controller,
                builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                  pageLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                  errorBuilder: (_, _) =>
                      const Center(child: Text(ArLearn.filesFailed)),
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 12,
          start: 0,
          end: 0,
          child: Center(
            child: PdfPageNumber(
              controller: _controller,
              builder: (_, state, page, count) =>
                  state == PdfLoadingState.success
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Text(
                          ArLearn.filesPage(page, count),
                          style: AppTextStyles.caption13.copyWith(
                            color: AppColors.card,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
