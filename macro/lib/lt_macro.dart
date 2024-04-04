import 'package:macros/macros.dart';

macro class AutoToString implements MethodDefinitionMacro {
  const AutoToString();

  @override
  Future<void> buildDefinitionForMethod(
      MethodDeclaration method,
      FunctionDefinitionBuilder builder) async {
    final clazz = await builder.typeDeclarationOf(method.definingType);
    final fields = await builder.fieldsOf(clazz);
    builder.augment(FunctionBodyCode.fromParts([
      '{\n',
      '    // You can add breakpoints here!\n',
      '    return """\n${clazz.identifier.name} {\n',
      for (var field in fields)
        ...[
          '  ${field.identifier.name}: \${',
          field.identifier,
          '}\n',
        ],
      '}""";\n',
      '  }'
    ]));
  }
}
