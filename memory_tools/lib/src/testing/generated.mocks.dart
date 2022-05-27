// Mocks generated by Mockito 5.2.0 from annotations
// in memory_tools/src/testing/generated.dart.
// Do not manually edit this file.

import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [Finalizer].
///
/// See the documentation for Mockito's code generation for more information.
class MockFinalizer<T> extends _i1.Mock implements Finalizer<T> {
  MockFinalizer() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void attach(Object? value, T? finalizationToken, {Object? detach}) =>
      super.noSuchMethod(
          Invocation.method(
              #attach, [value, finalizationToken], {#detach: detach}),
          returnValueForMissingStub: null);
  @override
  void detach(Object? detach) =>
      super.noSuchMethod(Invocation.method(#detach, [detach]),
          returnValueForMissingStub: null);
}
