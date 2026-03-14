# zvec_flutter

Flutter Android FFI wrapper around the bundled `zvec-android-arm64` build.

This package follows the same approach used in the local `edgemind` app: a
small C-compatible wrapper over the zvec C++ API, then a Dart `dart:ffi`
surface for Flutter.

## Scope

- Android only
- `arm64-v8a` only
- Default schema: `id`, `vector`, `content`, `metadata`, `hash`
- Default vector index: HNSW with inner product

## Python-Like Dart API

```dart
final schema = CollectionSchema(
  name: 'example',
  vectors: const VectorSchema(
    'embedding',
    DataType.VECTOR_FP32,
    4,
    indexParam: HnswIndexParam(metricType: MetricType.IP),
  ),
);

final collection = create_and_open(
  path: '/data/user/0/your.app/files/zvec_demo',
  schema: schema,
);

collection.insert([
  Doc(
    id: 'doc_1',
    vectors: {
      'embedding': [0.1, 0.2, 0.3, 0.4],
    },
    fields: {
      'content': 'Flutter talks to zvec through FFI.',
      'hash': 'doc_1',
    },
  ),
]);

final results = collection.query(
  const VectorQuery('embedding', vector: [0.4, 0.3, 0.3, 0.1]),
  topk: 10,
);
```

## Notes

- The repository tracks the final prebuilt `arm64-v8a` JNI bridge `libzvec_flutter_android.so` only.
- The Android build copies `libc++_shared.so` from Android NDK `28.2.13676358` at build time.
- Maintainers can rebuild the native bridge from source in this repository by passing `-PzvecFlutterBuildFromSource=true` to the Android build.
- The example app in `example/` shows end-to-end usage with local storage and search.
- The high-level Dart API follows the upstream Python naming and concepts where practical, but the current Android wrapper supports one primary dense vector field and stores extra scalar fields in JSON metadata.
- If you want to regenerate low-level bindings later, point `ffigen` at `src/zvec_c.h`.

