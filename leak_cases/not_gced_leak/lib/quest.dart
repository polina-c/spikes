import 'package:flutter/material.dart';

typedef AnswerBuilder = String Function(int);

class QuestController {
  String? answer;
  AnswerBuilder? _answerBuilder;

  void setAnswerBuilderIfNull(AnswerBuilder builder) =>
      _answerBuilder ??= builder;

  void buildAnswer(int value) {
    answer = _answerBuilder?.call(value) ?? 'Answer builder is not set yet.';
  }
}

class Quest extends StatefulWidget {
  const Quest({
    Key? key,
    required this.value,
    required this.controller,
  }) : super(key: key);
  final int value;
  final QuestController controller;

  @override
  State<Quest> createState() => _QuestState();
}

class _QuestState extends State<Quest> {
  @override
  initState() {
    widget.controller.answer = null;
    super.initState();
  }

  _openAnswer(BuildContext context) {
    widget.controller.setAnswerBuilderIfNull((value) =>
        '$value is odd with probability 1/${identityHashCode(context)}.');

    final val = widget.value;
    final controller = widget.controller;
    setState(() {
      controller.buildAnswer(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.answer != null) {
      return Text(widget.controller.answer!);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Is ${widget.value} even or odd?'),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _openAnswer(context),
          child: const Text('Open Answer'),
        )
      ],
    );
  }
}
