// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:macros/macros.dart';

macro class Disposable implements ClassDefinitionMacro {
  const Disposable();

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder classBuilder) async {
    final constructors = await classBuilder.constructorsOf(clazz);
    for (var c in constructors) {
      final builder = await classBuilder.buildConstructor(c.identifier);
      builder.augment(body: FunctionBodyCode.fromParts([
        '{\n',
         // 'print("instrumentation for ${clazz.identifier.name}");\n',
        '  }'
      ]));
    }
  }
}
