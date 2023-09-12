// ignore_for_file: avoid_print
import 'dart:io';

import 'package:langchain/langchain.dart';
import 'package:langchain_chroma/langchain_chroma.dart';
import 'package:langchain_openai/langchain_openai.dart';

void main() async {
  final openaiApiKey = Platform.environment['OPENAI_API_KEY']!;
  final embeddings = OpenAIEmbeddings(apiKey: openaiApiKey);
  final vectorStore = Chroma(embeddings: embeddings);

  // Add documents to the vector store
  await vectorStore.addDocuments(
    documents: const [
      Document(
        id: '1',
        pageContent: 'The cat sat on the mat',
        metadata: {'cat': 'animal'},
      ),
      Document(
        id: '2',
        pageContent: 'The dog chased the ball.',
        metadata: {'cat': 'animal'},
      ),
      Document(
        id: '3',
        pageContent: 'The boy ate the apple.',
        metadata: {'cat': 'person'},
      ),
      Document(
        id: '4',
        pageContent: 'The girl drank the milk.',
        metadata: {'cat': 'person'},
      ),
      Document(
        id: '5',
        pageContent: 'The sun is shining.',
        metadata: {'cat': 'natural'},
      ),
    ],
  );

  // Query the vector store
  final res = await vectorStore.similaritySearch(
    query: 'What are they eating?',
    config: const ChromaSimilaritySearch(
      k: 2,
      scoreThreshold: 0.4,
      where: {'cat': 'person'},
    ),
  );
  print(res);
}
