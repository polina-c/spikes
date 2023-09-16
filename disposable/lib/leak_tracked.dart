/// This file is linked in doc:
/// https://docs.google.com/document/d/1hlGY6HnsH5EJhpQDFm-_e-Sr9euQf6jE74TxkqDxhGY/edit?resourcekey=0--7J08lEADd6HpaTGC1B-Pw

// ---------------------------------------
// Code for 'package:collection/disposable.dart'

// Also, code of https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/foundation/memory_allocations.dart
// will be copied here, with note to use flutter lib when possible, because it is optimized by a flag for production code.

/// List of memory leak types.
///
/// Used to define set of memory leaks that should be included or excluded.
class LeakTypes {
  LeakTypes(
      {required this.library,
      required this.notDisposed,
      required this.notGCed});

  /// Library as it is reported to [ObjectCreated.library].
  final String library;

  /// List of classes for notDisposed leaks.
  ///
  /// The class name should be as reported to [ObjectCreated.className].
  final List<String> notDisposed;

  /// List of classes for notGCed leaks.
  ///
  /// The class name should be as reported to [ObjectCreated.className].
  final List<String> notGCed;
}
