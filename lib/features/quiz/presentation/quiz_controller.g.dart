// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuizController)
final quizControllerProvider = QuizControllerProvider._();

final class QuizControllerProvider
    extends $AsyncNotifierProvider<QuizController, QuizState> {
  QuizControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizControllerHash();

  @$internal
  @override
  QuizController create() => QuizController();
}

String _$quizControllerHash() => r'4df3d60084e90813452eea099d04f708f45026a9';

abstract class _$QuizController extends $AsyncNotifier<QuizState> {
  FutureOr<QuizState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<QuizState>, QuizState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuizState>, QuizState>,
              AsyncValue<QuizState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
