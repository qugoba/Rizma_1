import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateProfileDraft {
  const CreateProfileDraft({required this.name, required this.grade});

  final String name;
  final int grade;
}

class CreateProfileDraftNotifier extends Notifier<CreateProfileDraft?> {
  @override
  CreateProfileDraft? build() => null;

  void save({required String name, required int grade}) {
    state = CreateProfileDraft(name: name, grade: grade);
  }

  void clear() => state = null;
}

final createProfileDraftProvider =
    NotifierProvider<CreateProfileDraftNotifier, CreateProfileDraft?>(
      CreateProfileDraftNotifier.new,
    );
