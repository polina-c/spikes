// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:macros/macros.dart';

macro class Disposable implements ClassDefinitionMacro {
  const Disposable();

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration theClass, TypeDefinitionBuilder classBuilder) async {

    final constructors = await classBuilder.constructorsOf(theClass);
    // ignore: deprecated_member_use, better alternative is under construction
    //classBuilder.resolveIdentifier(Uri(scheme: 'package:flutter/src/foundation/memory_allocations.dart path: ''), 'FlutterMemoryAllocations');
    final library = theClass.library.uri.toString();
    final className = theClass.identifier.name;
    for (var c in constructors) {
      final builder = await classBuilder.buildConstructor(c.identifier);
      builder.augment(body: FunctionBodyCode.fromParts([
        // '''
        //   if (kFlutterMemoryAllocationsEnabled) {
        //     FlutterMemoryAllocations.instance.dispatchObjectCreated(
        //       library: '$library',
        //       className: '$className',
        //       object: this,
        //     );
        //   }
        // ''',
        'assert(true);',

        // '{\n',
        //  // 'print("instrumentation for ${clazz.identifier.name}");\n',
        // '  }'
      ]));
    }
  }
}
