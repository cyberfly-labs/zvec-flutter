import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zvec_flutter/zvec_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Collection? _collection;
  List<Doc> _hits = const <Doc>[];
  String _status = 'Preparing local zvec collection...';
  String? _collectionPath;
  int _documentCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/zvec_example_db';
      final schema = CollectionSchema(
        name: 'demo',
        fields: const <FieldSchema>[
          FieldSchema('content', DataType.STRING, nullable: true),
          FieldSchema('hash', DataType.STRING, nullable: true),
          FieldSchema('topic', DataType.STRING, nullable: true),
        ],
        vectors: const VectorSchema(
          'embedding',
          DataType.VECTOR_FP32,
          4,
          indexParam: HnswIndexParam(metricType: MetricType.IP),
        ),
      );
      final collection = Directory(path).existsSync()
          ? open(path)
          : create_and_open(path: path, schema: schema);

      _collection = collection;
      _collectionPath = path;

      if (collection.stats.docCount == 0) {
        _seedDocuments();
      }

      _runSearch();
    } catch (error) {
      setState(() {
        _status = 'Initialization failed: $error';
      });
    }
  }

  void _seedDocuments() {
    final collection = _collection;
    if (collection == null) {
      return;
    }

    collection.insert(<Doc>[
      Doc(
        id: 'doc-1',
        vectors: <String, List<double>>{
          'embedding': <double>[0.92, 0.08, 0.01, 0.00],
        },
        fields: <String, dynamic>{
          'content': 'zvec is good for semantic search on Android devices.',
          'topic': 'android',
          'hash': 'doc-1',
        },
      ),
      Doc(
        id: 'doc-2',
        vectors: <String, List<double>>{
          'embedding': <double>[0.87, 0.10, 0.02, 0.01],
        },
        fields: <String, dynamic>{
          'content':
              'Flutter can talk to zvec through dart:ffi and a small C wrapper.',
          'topic': 'flutter',
          'hash': 'doc-2',
        },
      ),
      Doc(
        id: 'doc-3',
        vectors: <String, List<double>>{
          'embedding': <double>[0.05, 0.10, 0.90, 0.02],
        },
        fields: <String, dynamic>{
          'content': 'This note is about recipes, not vector search.',
          'topic': 'other',
          'hash': 'doc-3',
        },
      ),
    ]);
    collection.flush();
    collection.optimize();
  }

  void _runSearch() {
    final collection = _collection;
    if (collection == null) {
      return;
    }

    final hits = collection.query(
      const VectorQuery(
        'embedding',
        vector: <double>[0.90, 0.08, 0.01, 0.00],
        queryParam: HnswQueryParam(radius: 0.0),
      ),
      topk: 3,
    );

    setState(() {
      _hits = hits;
      _documentCount = collection.stats.docCount;
      _status = 'Collection ready at ${_collectionPath ?? 'unknown path'}';
    });
  }

  Future<void> _resetDatabase() async {
    final collection = _collection;
    final path = _collectionPath;
    if (collection == null || path == null) {
      return;
    }

    collection.destroy();
    try {
      await Directory(path).delete(recursive: true);
    } catch (_) {
      // Ignore missing or already-removed directories during reset.
    }
    setState(() {
      _collection = null;
      _hits = const <Doc>[];
      _documentCount = 0;
      _status = 'Database reset. Recreating...';
    });
    await _initialize();
  }

  @override
  void dispose() {
    _collection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF005F73),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F1EA),
      useMaterial3: true,
    );

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(title: const Text('zvec Flutter Android Example')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEBEA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bundled arm64 zvec database',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    Text('Documents: $_documentCount'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: _collection == null
                        ? null
                        : () {
                            _seedDocuments();
                            _runSearch();
                          },
                    child: const Text('Seed Demo Data'),
                  ),
                  OutlinedButton(
                    onPressed: _collection == null ? null : _runSearch,
                    child: const Text('Run Search'),
                  ),
                  OutlinedButton(
                    onPressed: _collection == null ? null : _resetDatabase,
                    child: const Text('Reset DB'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Top Search Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _hits.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final hit = _hits[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hit.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Score: ${(hit.score ?? 0).toStringAsFixed(4)}'),
                          const SizedBox(height: 6),
                          Text(
                            (hit.fields['content'] as String?) ?? 'No content',
                          ),
                          if (hit.fields.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Fields: ${hit.fields}'),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
