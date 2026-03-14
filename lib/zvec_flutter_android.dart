// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

const String _libraryName = 'zvec_flutter_android';

DynamicLibrary? _cachedLibrary;
_ZvecBindings? _cachedBindings;

DynamicLibrary get _library {
  _cachedLibrary ??= () {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'zvec_flutter_android currently supports Android only.',
      );
    }
    return DynamicLibrary.open('lib$_libraryName.so');
  }();
  return _cachedLibrary!;
}

_ZvecBindings get _bindings => _cachedBindings ??= _ZvecBindings(_library);

final class _NativeSearchResult extends Struct {
  external Pointer<Utf8> id;

  @Float()
  external double score;

  external Pointer<Utf8> metadata;
  external Pointer<Utf8> content;
}

typedef _CreateCollectionNative =
    Int32 Function(
      Pointer<Utf8> path,
      Pointer<Utf8> name,
      Uint32 dimension,
      Pointer<Pointer<Void>> out,
    );
typedef _CreateCollectionDart =
    int Function(
      Pointer<Utf8> path,
      Pointer<Utf8> name,
      int dimension,
      Pointer<Pointer<Void>> out,
    );

typedef _OpenCollectionNative =
    Int32 Function(Pointer<Utf8> path, Pointer<Pointer<Void>> out);
typedef _OpenCollectionDart =
    int Function(Pointer<Utf8> path, Pointer<Pointer<Void>> out);

typedef _CloseCollectionNative = Int32 Function(Pointer<Void> collection);
typedef _CloseCollectionDart = int Function(Pointer<Void> collection);

typedef _DestroyCollectionNative = Int32 Function(Pointer<Void> collection);
typedef _DestroyCollectionDart = int Function(Pointer<Void> collection);

typedef _FlushNative = Int32 Function(Pointer<Void> collection);
typedef _FlushDart = int Function(Pointer<Void> collection);

typedef _OptimizeNative = Int32 Function(Pointer<Void> collection);
typedef _OptimizeDart = int Function(Pointer<Void> collection);

typedef _HasFieldNative =
    Int32 Function(Pointer<Void> collection, Pointer<Utf8> field);
typedef _HasFieldDart =
    int Function(Pointer<Void> collection, Pointer<Utf8> field);

typedef _InsertNative =
    Int32 Function(
      Pointer<Void> collection,
      Pointer<Utf8> id,
      Pointer<Float> vector,
      Uint32 dimension,
      Pointer<Utf8> content,
      Pointer<Utf8> metadataJson,
      Pointer<Utf8> hash,
    );
typedef _InsertDart =
    int Function(
      Pointer<Void> collection,
      Pointer<Utf8> id,
      Pointer<Float> vector,
      int dimension,
      Pointer<Utf8> content,
      Pointer<Utf8> metadataJson,
      Pointer<Utf8> hash,
    );

typedef _InsertBatchNative =
    Int32 Function(
      Pointer<Void> collection,
      Pointer<Pointer<Utf8>> ids,
      Pointer<Float> vectors,
      Pointer<Pointer<Utf8>> hashes,
      Uint32 dimension,
      Uint32 count,
    );
typedef _InsertBatchDart =
    int Function(
      Pointer<Void> collection,
      Pointer<Pointer<Utf8>> ids,
      Pointer<Float> vectors,
      Pointer<Pointer<Utf8>> hashes,
      int dimension,
      int count,
    );

typedef _DeleteNative =
    Int32 Function(Pointer<Void> collection, Pointer<Utf8> id);
typedef _DeleteDart = int Function(Pointer<Void> collection, Pointer<Utf8> id);

typedef _DeleteByFilterNative =
    Int32 Function(Pointer<Void> collection, Pointer<Utf8> filter);
typedef _DeleteByFilterDart =
    int Function(Pointer<Void> collection, Pointer<Utf8> filter);

typedef _FetchNative =
    Int32 Function(
      Pointer<Void> collection,
      Pointer<Pointer<Utf8>> ids,
      Uint32 count,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );
typedef _FetchDart =
    int Function(
      Pointer<Void> collection,
      Pointer<Pointer<Utf8>> ids,
      int count,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );

typedef _SearchNative =
    Int32 Function(
      Pointer<Void> collection,
      Pointer<Float> query,
      Uint32 dimension,
      Uint32 topK,
      Pointer<Utf8> filter,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );
typedef _SearchDart =
    int Function(
      Pointer<Void> collection,
      Pointer<Float> query,
      int dimension,
      int topK,
      Pointer<Utf8> filter,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );

typedef _SearchThresholdNative =
    Int32 Function(
      Pointer<Void> collection,
      Pointer<Float> query,
      Uint32 dimension,
      Uint32 topK,
      Float minScore,
      Pointer<Utf8> filter,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );
typedef _SearchThresholdDart =
    int Function(
      Pointer<Void> collection,
      Pointer<Float> query,
      int dimension,
      int topK,
      double minScore,
      Pointer<Utf8> filter,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );

typedef _ListSourcesNative =
    Int32 Function(
      Pointer<Void> collection,
      Uint32 dimension,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );
typedef _ListSourcesDart =
    int Function(
      Pointer<Void> collection,
      int dimension,
      Pointer<Pointer<_NativeSearchResult>> results,
      Pointer<Uint32> outCount,
    );

typedef _CountNative =
    Int32 Function(Pointer<Void> collection, Pointer<Uint64> outCount);
typedef _CountDart =
    int Function(Pointer<Void> collection, Pointer<Uint64> outCount);

typedef _GetDimensionNative = Uint32 Function(Pointer<Void> collection);
typedef _GetDimensionDart = int Function(Pointer<Void> collection);

typedef _FreeResultsNative =
    Void Function(Pointer<_NativeSearchResult> results, Uint32 count);
typedef _FreeResultsDart =
    void Function(Pointer<_NativeSearchResult> results, int count);

typedef _GetLastErrorNative = Pointer<Utf8> Function();
typedef _GetLastErrorDart = Pointer<Utf8> Function();

class _ZvecBindings {
  _ZvecBindings(DynamicLibrary library)
    : zvecCreateCollection = library
          .lookup<NativeFunction<_CreateCollectionNative>>(
            'zvec_create_collection',
          )
          .asFunction(),
      zvecOpenCollection = library
          .lookup<NativeFunction<_OpenCollectionNative>>('zvec_open_collection')
          .asFunction(),
      zvecCloseCollection = library
          .lookup<NativeFunction<_CloseCollectionNative>>(
            'zvec_close_collection',
          )
          .asFunction(),
      zvecDestroy = library
          .lookup<NativeFunction<_DestroyCollectionNative>>('zvec_destroy')
          .asFunction(),
      zvecFlush = library
          .lookup<NativeFunction<_FlushNative>>('zvec_flush')
          .asFunction(),
      zvecOptimize = library
          .lookup<NativeFunction<_OptimizeNative>>('zvec_optimize')
          .asFunction(),
      zvecHasField = library
          .lookup<NativeFunction<_HasFieldNative>>('zvec_has_field')
          .asFunction(),
      zvecInsert = library
          .lookup<NativeFunction<_InsertNative>>('zvec_insert')
          .asFunction(),
      zvecInsertBatch = library
          .lookup<NativeFunction<_InsertBatchNative>>('zvec_insert_batch')
          .asFunction(),
      zvecDelete = library
          .lookup<NativeFunction<_DeleteNative>>('zvec_delete')
          .asFunction(),
      zvecDeleteByFilter = library
          .lookup<NativeFunction<_DeleteByFilterNative>>(
            'zvec_delete_by_filter',
          )
          .asFunction(),
      zvecFetch = library
          .lookup<NativeFunction<_FetchNative>>('zvec_fetch')
          .asFunction(),
      zvecSearch = library
          .lookup<NativeFunction<_SearchNative>>('zvec_search')
          .asFunction(),
      zvecSearchWithThreshold = library
          .lookup<NativeFunction<_SearchThresholdNative>>(
            'zvec_search_with_threshold',
          )
          .asFunction(),
      zvecListSources = library
          .lookup<NativeFunction<_ListSourcesNative>>('zvec_list_sources')
          .asFunction(),
      zvecCount = library
          .lookup<NativeFunction<_CountNative>>('zvec_count')
          .asFunction(),
      zvecGetDimension = library
          .lookup<NativeFunction<_GetDimensionNative>>('zvec_get_dimension')
          .asFunction(),
      zvecFreeResults = library
          .lookup<NativeFunction<_FreeResultsNative>>('zvec_free_results')
          .asFunction(isLeaf: true),
      zvecGetLastError = library
          .lookup<NativeFunction<_GetLastErrorNative>>('zvec_get_last_error')
          .asFunction(isLeaf: true);

  final _CreateCollectionDart zvecCreateCollection;
  final _OpenCollectionDart zvecOpenCollection;
  final _CloseCollectionDart zvecCloseCollection;
  final _DestroyCollectionDart zvecDestroy;
  final _FlushDart zvecFlush;
  final _OptimizeDart zvecOptimize;
  final _HasFieldDart zvecHasField;
  final _InsertDart zvecInsert;
  final _InsertBatchDart zvecInsertBatch;
  final _DeleteDart zvecDelete;
  final _DeleteByFilterDart zvecDeleteByFilter;
  final _FetchDart zvecFetch;
  final _SearchDart zvecSearch;
  final _SearchThresholdDart zvecSearchWithThreshold;
  final _ListSourcesDart zvecListSources;
  final _CountDart zvecCount;
  final _GetDimensionDart zvecGetDimension;
  final _FreeResultsDart zvecFreeResults;
  final _GetLastErrorDart zvecGetLastError;
}

class ZvecException implements Exception {
  const ZvecException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'ZvecException(code: $code, message: $message)';
}

enum StatusCode {
  OK,
  NOT_FOUND,
  ALREADY_EXISTS,
  INVALID_ARGUMENT,
  PERMISSION_DENIED,
  FAILED_PRECONDITION,
  RESOURCE_EXHAUSTED,
  UNAVAILABLE,
  INTERNAL_ERROR,
  NOT_SUPPORTED,
  UNKNOWN,
}

enum DataType {
  UNDEFINED,
  BINARY,
  STRING,
  BOOL,
  INT32,
  INT64,
  UINT32,
  UINT64,
  FLOAT,
  DOUBLE,
  VECTOR_BINARY32,
  VECTOR_BINARY64,
  VECTOR_FP16,
  VECTOR_FP32,
  VECTOR_FP64,
  SPARSE_VECTOR_FP16,
  SPARSE_VECTOR_FP32,
}

enum IndexType { UNDEFINED, HNSW, IVF, FLAT, INVERT }

enum MetricType { UNDEFINED, L2, IP, COSINE, MIPSL2 }

enum QuantizeType { UNDEFINED, FP16, INT8, INT4 }

class Status {
  const Status({required this.code, this.message = ''});

  const Status.ok() : code = StatusCode.OK, message = '';

  final StatusCode code;
  final String message;

  bool ok() => code == StatusCode.OK;

  @override
  String toString() => 'Status(code: $code, message: $message)';
}

class CollectionOption {
  const CollectionOption({
    this.readOnly = false,
    this.enableMmap = true,
    this.maxBufferSize = 64 * 1024 * 1024,
  });

  final bool readOnly;
  final bool enableMmap;
  final int maxBufferSize;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'read_only': readOnly,
    'enable_mmap': enableMmap,
    'max_buffer_size': maxBufferSize,
  };

  factory CollectionOption.fromJson(Map<String, dynamic> json) {
    return CollectionOption(
      readOnly: json['read_only'] as bool? ?? false,
      enableMmap: json['enable_mmap'] as bool? ?? true,
      maxBufferSize: json['max_buffer_size'] as int? ?? 64 * 1024 * 1024,
    );
  }
}

abstract class IndexParam {
  const IndexParam(this.type);

  final IndexType type;

  Map<String, dynamic> toJson();
}

abstract class VectorIndexParam extends IndexParam {
  const VectorIndexParam(
    super.type, {
    this.metricType = MetricType.IP,
    this.quantizeType = QuantizeType.UNDEFINED,
  });

  final MetricType metricType;
  final QuantizeType quantizeType;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'metric_type': metricType.name,
    'quantize_type': quantizeType.name,
  };
}

class InvertIndexParam extends IndexParam {
  const InvertIndexParam({
    this.enableRangeOptimization = true,
    this.enableExtendedWildcard = false,
  }) : super(IndexType.INVERT);

  final bool enableRangeOptimization;
  final bool enableExtendedWildcard;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'enable_range_optimization': enableRangeOptimization,
    'enable_extended_wildcard': enableExtendedWildcard,
  };
}

class HnswIndexParam extends VectorIndexParam {
  const HnswIndexParam({
    super.metricType = MetricType.IP,
    this.m = 32,
    this.efConstruction = 200,
    super.quantizeType = QuantizeType.UNDEFINED,
  }) : super(IndexType.HNSW);

  final int m;
  final int efConstruction;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    ...super.toJson(),
    'm': m,
    'ef_construction': efConstruction,
  };
}

class FlatIndexParam extends VectorIndexParam {
  const FlatIndexParam({
    super.metricType = MetricType.IP,
    super.quantizeType = QuantizeType.UNDEFINED,
  }) : super(IndexType.FLAT);
}

class IVFIndexParam extends VectorIndexParam {
  const IVFIndexParam({
    super.metricType = MetricType.IP,
    this.nList = 1024,
    this.nIters = 10,
    this.useSoar = false,
    super.quantizeType = QuantizeType.UNDEFINED,
  }) : super(IndexType.IVF);

  final int nList;
  final int nIters;
  final bool useSoar;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    ...super.toJson(),
    'n_list': nList,
    'n_iters': nIters,
    'use_soar': useSoar,
  };
}

abstract class QueryParam {
  const QueryParam({
    required this.type,
    this.radius = 0.0,
    this.isLinear = false,
    this.isUsingRefiner = false,
  });

  final IndexType type;
  final double radius;
  final bool isLinear;
  final bool isUsingRefiner;
}

class HnswQueryParam extends QueryParam {
  const HnswQueryParam({
    this.ef = 32,
    super.radius = 0.0,
    super.isLinear = false,
    super.isUsingRefiner = false,
  }) : super(type: IndexType.HNSW);

  final int ef;
}

class IVFQueryParam extends QueryParam {
  const IVFQueryParam({
    this.nprobe = 10,
    this.scaleFactor = 10,
    super.isUsingRefiner = false,
  }) : super(type: IndexType.IVF);

  final int nprobe;
  final double scaleFactor;
}

class FieldSchema {
  const FieldSchema(
    this.name,
    this.dataType, {
    this.nullable = false,
    this.indexParam,
  });

  final String name;
  final DataType dataType;
  final bool nullable;
  final IndexParam? indexParam;

  bool get isVectorField => false;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': 'field',
    'name': name,
    'data_type': dataType.name,
    'nullable': nullable,
    'index_param': indexParam?.toJson(),
  };
}

class VectorSchema extends FieldSchema {
  const VectorSchema(
    super.name,
    super.dataType,
    this.dimension, {
    super.indexParam = const HnswIndexParam(),
    super.nullable = false,
  });

  final int dimension;

  @override
  bool get isVectorField => true;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': 'vector',
    'name': name,
    'data_type': dataType.name,
    'dimension': dimension,
    'nullable': nullable,
    'index_param': indexParam?.toJson(),
  };
}

class CollectionSchema {
  CollectionSchema({
    required this.name,
    List<FieldSchema> fields = const <FieldSchema>[],
    Object? vectors,
    this.maxDocCountPerSegment,
  }) : fields = List<FieldSchema>.unmodifiable(fields),
       vectors = List<VectorSchema>.unmodifiable(_normalizeVectors(vectors));

  final String name;
  final List<FieldSchema> fields;
  final List<VectorSchema> vectors;
  final int? maxDocCountPerSegment;

  VectorSchema get primaryVector {
    if (vectors.isEmpty) {
      throw const ZvecException(
        -1,
        'CollectionSchema must define one vector field.',
      );
    }
    return vectors.first;
  }

  FieldSchema? get_field(String fieldName) {
    for (final field in <FieldSchema>[...fields, ...vectors]) {
      if (field.name == fieldName) {
        return field;
      }
    }
    return null;
  }

  bool has_field(String fieldName) => get_field(fieldName) != null;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'fields': fields.map((field) => field.toJson()).toList(),
    'vectors': vectors.map((vector) => vector.toJson()).toList(),
    'max_doc_count_per_segment': maxDocCountPerSegment,
  };

  factory CollectionSchema.fromJson(Map<String, dynamic> json) {
    final rawFields = (json['fields'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();
    final rawVectors = (json['vectors'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    return CollectionSchema(
      name: json['name'] as String? ?? 'default',
      fields: rawFields.map(_fieldSchemaFromJson).toList(),
      vectors: rawVectors.map(_vectorSchemaFromJson).toList(),
      maxDocCountPerSegment: json['max_doc_count_per_segment'] as int?,
    );
  }

  static List<VectorSchema> _normalizeVectors(Object? vectors) {
    if (vectors == null) {
      return const <VectorSchema>[];
    }
    if (vectors is VectorSchema) {
      return <VectorSchema>[vectors];
    }
    if (vectors is List<VectorSchema>) {
      return vectors;
    }
    if (vectors is Iterable<VectorSchema>) {
      return vectors.toList();
    }
    throw ArgumentError.value(
      vectors,
      'vectors',
      'Must be a VectorSchema or Iterable<VectorSchema>.',
    );
  }
}

class CollectionStats {
  const CollectionStats({
    required this.docCount,
    this.indexCompleteness = const <String, double>{},
  });

  final int docCount;
  final Map<String, double> indexCompleteness;
}

class Doc {
  Doc({
    required this.id,
    Map<String, dynamic>? fields,
    Map<String, List<double>>? vectors,
    this.score,
  }) : fields = Map<String, dynamic>.unmodifiable(
         fields ?? <String, dynamic>{},
       ),
       vectors = Map<String, List<double>>.unmodifiable(
         (vectors ?? <String, List<double>>{}).map(
           (key, value) => MapEntry(key, List<double>.unmodifiable(value)),
         ),
       );

  final String id;
  final Map<String, dynamic> fields;
  final Map<String, List<double>> vectors;
  final double? score;

  Map<String, dynamic> get_all() => <String, dynamic>{
    'id': id,
    'score': score,
    'fields': fields,
    'vectors': vectors,
  };
}

class VectorQuery {
  const VectorQuery(
    this.fieldName, {
    required this.vector,
    this.filter,
    this.includeVector = false,
    this.includeDocId = false,
    this.outputFields,
    this.queryParam,
  });

  final String fieldName;
  final List<double> vector;
  final String? filter;
  final bool includeVector;
  final bool includeDocId;
  final List<String>? outputFields;
  final QueryParam? queryParam;
}

class ZvecInsertRequest {
  const ZvecInsertRequest({
    required this.id,
    required this.vector,
    this.content,
    this.metadata,
    this.hash,
  });

  final String id;
  final List<double> vector;
  final String? content;
  final Map<String, dynamic>? metadata;
  final String? hash;
}

class ZvecSearchHit {
  const ZvecSearchHit({
    required this.id,
    required this.score,
    this.content,
    this.metadataJson,
    this.metadata,
  });

  final String id;
  final double score;
  final String? content;
  final String? metadataJson;
  final Map<String, dynamic>? metadata;

  String? get hash => metadata?['hash'] as String?;
}

class ZvecCollection {
  ZvecCollection._(this._handle);

  final Pointer<Void> _handle;
  bool _closed = false;

  static ZvecCollection create({
    required String path,
    required int dimension,
    String name = 'default',
  }) {
    final pathPointer = path.toNativeUtf8();
    final namePointer = name.toNativeUtf8();
    final out = calloc<Pointer<Void>>();

    try {
      final status = _bindings.zvecCreateCollection(
        pathPointer,
        namePointer,
        dimension,
        out,
      );
      _throwIfFailed(status);
      return ZvecCollection._(out.value);
    } finally {
      calloc.free(pathPointer);
      calloc.free(namePointer);
      calloc.free(out);
    }
  }

  static ZvecCollection open(String path) {
    final pathPointer = path.toNativeUtf8();
    final out = calloc<Pointer<Void>>();

    try {
      final status = _bindings.zvecOpenCollection(pathPointer, out);
      _throwIfFailed(status);
      return ZvecCollection._(out.value);
    } finally {
      calloc.free(pathPointer);
      calloc.free(out);
    }
  }

  static ZvecCollection createOrOpen({
    required String path,
    required int dimension,
    String name = 'default',
  }) {
    final collectionDirectory = Directory(path);
    if (collectionDirectory.existsSync()) {
      final collection = open(path);
      final currentDimension = collection.dimension;
      if (currentDimension != dimension) {
        collection.close();
        throw ZvecException(
          -1,
          'Existing collection dimension is $currentDimension, expected $dimension.',
        );
      }
      return collection;
    }

    collectionDirectory.parent.createSync(recursive: true);
    return create(path: path, dimension: dimension, name: name);
  }

  int get dimension {
    _ensureOpen();
    return _bindings.zvecGetDimension(_handle);
  }

  int get count {
    _ensureOpen();
    final out = calloc<Uint64>();
    try {
      final status = _bindings.zvecCount(_handle, out);
      _throwIfFailed(status);
      return out.value;
    } finally {
      calloc.free(out);
    }
  }

  bool hasField(String field) {
    _ensureOpen();
    final fieldPointer = field.toNativeUtf8();
    try {
      return _bindings.zvecHasField(_handle, fieldPointer) == 1;
    } finally {
      calloc.free(fieldPointer);
    }
  }

  void insert({
    required String id,
    required List<double> vector,
    String? content,
    Map<String, dynamic>? metadata,
    String? hash,
  }) {
    _ensureOpen();
    _ensureVectorMatchesDimension(vector);

    final idPointer = id.toNativeUtf8();
    final contentPointer = _nullableUtf8(content);
    final metadataPointer = _nullableUtf8(
      metadata == null ? null : jsonEncode(metadata),
    );
    final hashPointer = _nullableUtf8(hash);
    final vectorPointer = _toFloatPointer(vector);

    try {
      final status = _bindings.zvecInsert(
        _handle,
        idPointer,
        vectorPointer,
        vector.length,
        contentPointer,
        metadataPointer,
        hashPointer,
      );
      _throwIfFailed(status);
    } finally {
      calloc.free(idPointer);
      _freeNullableUtf8(contentPointer);
      _freeNullableUtf8(metadataPointer);
      _freeNullableUtf8(hashPointer);
      calloc.free(vectorPointer);
    }
  }

  void insertBatch(List<ZvecInsertRequest> documents) {
    _ensureOpen();
    if (documents.isEmpty) {
      return;
    }

    final dimension = this.dimension;
    for (final document in documents) {
      if (document.vector.length != dimension) {
        throw ZvecException(
          -1,
          'Vector dimension ${document.vector.length} does not match collection dimension $dimension.',
        );
      }
    }

    final needsRichInsert = documents.any(
      (document) => document.content != null || document.metadata != null,
    );

    if (needsRichInsert) {
      for (final document in documents) {
        insert(
          id: document.id,
          vector: document.vector,
          content: document.content,
          metadata: document.metadata,
          hash: document.hash,
        );
      }
      return;
    }

    final ids = calloc<Pointer<Utf8>>(documents.length);
    final hashes = calloc<Pointer<Utf8>>(documents.length);
    final vectors = calloc<Float>(documents.length * dimension);

    try {
      for (var index = 0; index < documents.length; index++) {
        ids[index] = documents[index].id.toNativeUtf8();
        hashes[index] = _nullableUtf8(documents[index].hash);
        for (var vectorIndex = 0; vectorIndex < dimension; vectorIndex++) {
          vectors[index * dimension + vectorIndex] =
              documents[index].vector[vectorIndex];
        }
      }

      final status = _bindings.zvecInsertBatch(
        _handle,
        ids,
        vectors,
        hashes,
        dimension,
        documents.length,
      );
      _throwIfFailed(status);
    } finally {
      for (var index = 0; index < documents.length; index++) {
        calloc.free(ids[index]);
        _freeNullableUtf8(hashes[index]);
      }
      calloc.free(ids);
      calloc.free(hashes);
      calloc.free(vectors);
    }
  }

  void delete(String id) {
    _ensureOpen();
    final idPointer = id.toNativeUtf8();
    try {
      final status = _bindings.zvecDelete(_handle, idPointer);
      _throwIfFailed(status);
    } finally {
      calloc.free(idPointer);
    }
  }

  void deleteByFilter(String filter) {
    _ensureOpen();
    final filterPointer = filter.toNativeUtf8();
    try {
      final status = _bindings.zvecDeleteByFilter(_handle, filterPointer);
      _throwIfFailed(status);
    } finally {
      calloc.free(filterPointer);
    }
  }

  List<ZvecSearchHit> fetch(List<String> ids) {
    _ensureOpen();
    if (ids.isEmpty) {
      return const <ZvecSearchHit>[];
    }

    final idPointers = calloc<Pointer<Utf8>>(ids.length);
    final results = calloc<Pointer<_NativeSearchResult>>();
    final outCount = calloc<Uint32>();

    try {
      for (var index = 0; index < ids.length; index++) {
        idPointers[index] = ids[index].toNativeUtf8();
      }

      final status = _bindings.zvecFetch(
        _handle,
        idPointers,
        ids.length,
        results,
        outCount,
      );
      _throwIfFailed(status);
      return _readSearchResults(results.value, outCount.value);
    } finally {
      for (var index = 0; index < ids.length; index++) {
        calloc.free(idPointers[index]);
      }
      calloc.free(idPointers);
      calloc.free(results);
      calloc.free(outCount);
    }
  }

  List<ZvecSearchHit> search({
    required List<double> query,
    int topK = 5,
    double? minScore,
    String? filter,
  }) {
    _ensureOpen();
    _ensureVectorMatchesDimension(query);

    final queryPointer = _toFloatPointer(query);
    final filterPointer = _nullableUtf8(filter);
    final results = calloc<Pointer<_NativeSearchResult>>();
    final outCount = calloc<Uint32>();

    try {
      final status = minScore == null
          ? _bindings.zvecSearch(
              _handle,
              queryPointer,
              query.length,
              topK,
              filterPointer,
              results,
              outCount,
            )
          : _bindings.zvecSearchWithThreshold(
              _handle,
              queryPointer,
              query.length,
              topK,
              minScore,
              filterPointer,
              results,
              outCount,
            );
      _throwIfFailed(status);
      return _readSearchResults(results.value, outCount.value);
    } finally {
      calloc.free(queryPointer);
      _freeNullableUtf8(filterPointer);
      calloc.free(results);
      calloc.free(outCount);
    }
  }

  List<ZvecSearchHit> listSources() {
    _ensureOpen();
    final results = calloc<Pointer<_NativeSearchResult>>();
    final outCount = calloc<Uint32>();

    try {
      final status = _bindings.zvecListSources(
        _handle,
        dimension,
        results,
        outCount,
      );
      _throwIfFailed(status);
      return _readSearchResults(results.value, outCount.value);
    } finally {
      calloc.free(results);
      calloc.free(outCount);
    }
  }

  void flush() {
    _ensureOpen();
    _throwIfFailed(_bindings.zvecFlush(_handle));
  }

  void optimize() {
    _ensureOpen();
    _throwIfFailed(_bindings.zvecOptimize(_handle));
  }

  void close() {
    if (_closed) {
      return;
    }
    _throwIfFailed(_bindings.zvecCloseCollection(_handle));
    _closed = true;
  }

  void destroy() {
    _ensureOpen();
    _throwIfFailed(_bindings.zvecDestroy(_handle));
    _closed = true;
  }

  void _ensureOpen() {
    if (_closed) {
      throw const ZvecException(-1, 'Collection has already been closed.');
    }
  }

  void _ensureVectorMatchesDimension(List<double> vector) {
    final expectedDimension = dimension;
    if (vector.length != expectedDimension) {
      throw ZvecException(
        -1,
        'Vector dimension ${vector.length} does not match collection dimension $expectedDimension.',
      );
    }
  }

  List<ZvecSearchHit> _readSearchResults(
    Pointer<_NativeSearchResult> results,
    int count,
  ) {
    if (results == nullptr || count == 0) {
      return const <ZvecSearchHit>[];
    }

    try {
      final hits = <ZvecSearchHit>[];
      for (var index = 0; index < count; index++) {
        final nativeResult = results[index];
        final metadataJson = _stringOrNull(nativeResult.metadata);
        hits.add(
          ZvecSearchHit(
            id: _stringOrNull(nativeResult.id) ?? '',
            score: nativeResult.score,
            content: _stringOrNull(nativeResult.content),
            metadataJson: metadataJson,
            metadata: _decodeMetadata(metadataJson),
          ),
        );
      }
      return hits;
    } finally {
      _bindings.zvecFreeResults(results, count);
    }
  }
}

Pointer<Float> _toFloatPointer(List<double> values) {
  final pointer = calloc<Float>(values.length);
  for (var index = 0; index < values.length; index++) {
    pointer[index] = values[index];
  }
  return pointer;
}

Pointer<Utf8> _nullableUtf8(String? value) {
  if (value == null) {
    return nullptr;
  }
  return value.toNativeUtf8();
}

void _freeNullableUtf8(Pointer<Utf8> value) {
  if (value != nullptr) {
    calloc.free(value);
  }
}

String? _stringOrNull(Pointer<Utf8> value) {
  if (value == nullptr) {
    return null;
  }
  return value.toDartString();
}

Map<String, dynamic>? _decodeMetadata(String? metadataJson) {
  if (metadataJson == null || metadataJson.isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(metadataJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {
    return null;
  }

  return null;
}

void _throwIfFailed(int status) {
  if (status == 0) {
    return;
  }

  final messagePointer = _bindings.zvecGetLastError();
  final message = messagePointer == nullptr
      ? 'zvec operation failed with status $status'
      : messagePointer.toDartString();
  throw ZvecException(status, message);
}

const String _collectionMetadataFileName =
    '.zvec_flutter_android.collection.json';

class Collection {
  Collection._({
    required this.path,
    required this.schema,
    required this.option,
    required ZvecCollection raw,
  }) : _raw = raw;

  final String path;
  final CollectionSchema schema;
  final CollectionOption option;
  final ZvecCollection _raw;
  bool _closed = false;

  CollectionStats get stats => CollectionStats(
    docCount: _raw.count,
    indexCompleteness: <String, double>{schema.primaryVector.name: 1.0},
  );

  void destroy() {
    if (_closed) {
      return;
    }
    _raw.destroy();
    _closed = true;
  }

  void flush() {
    _ensureOpen();
    _raw.flush();
  }

  void optimize() {
    _ensureOpen();
    _raw.optimize();
  }

  List<Status> insert(List<Doc> docs) {
    _ensureOpen();
    final results = <Status>[];

    for (final doc in docs) {
      try {
        final vector = doc.vectors[schema.primaryVector.name];
        if (vector == null) {
          throw ZvecException(
            -1,
            'Doc ${doc.id} is missing vector field ${schema.primaryVector.name}.',
          );
        }

        final mapped = _mapFieldsForNative(doc.fields);
        _raw.insert(
          id: doc.id,
          vector: vector,
          content: mapped.content,
          metadata: mapped.metadata,
          hash: mapped.hash,
        );
        results.add(const Status.ok());
      } catch (error) {
        results.add(_statusFromError(error));
      }
    }

    return results;
  }

  Map<String, Doc> fetch(List<String> ids) {
    _ensureOpen();
    final docs = <String, Doc>{};
    for (final hit in _raw.fetch(ids)) {
      final doc = _docFromHit(hit);
      docs[doc.id] = doc;
    }
    return docs;
  }

  List<Status> delete(List<String> ids) {
    _ensureOpen();
    final results = <Status>[];

    for (final id in ids) {
      try {
        _raw.delete(id);
        results.add(const Status.ok());
      } catch (error) {
        results.add(_statusFromError(error));
      }
    }

    return results;
  }

  void delete_by_filter(String filter) {
    _ensureOpen();
    _raw.deleteByFilter(filter);
  }

  List<Doc> query(VectorQuery query, {int topk = 10}) {
    _ensureOpen();

    if (query.fieldName != schema.primaryVector.name) {
      throw ZvecException(
        -1,
        'This wrapper currently supports one vector field named ${schema.primaryVector.name}.',
      );
    }

    if (query.includeVector) {
      throw UnsupportedError(
        'includeVector is not supported by the current Android wrapper.',
      );
    }

    final minScore = query.queryParam?.radius == 0.0
        ? null
        : query.queryParam?.radius;

    final hits = _raw.search(
      query: query.vector,
      topK: topk,
      minScore: minScore,
      filter: query.filter,
    );

    return hits
        .map((hit) => _docFromHit(hit, outputFields: query.outputFields))
        .toList();
  }

  void close() {
    if (_closed) {
      return;
    }
    _raw.close();
    _closed = true;
  }

  void _ensureOpen() {
    if (_closed) {
      throw const ZvecException(-1, 'Collection has already been closed.');
    }
  }

  Doc _docFromHit(ZvecSearchHit hit, {List<String>? outputFields}) {
    final fields = <String, dynamic>{...(hit.metadata ?? <String, dynamic>{})};
    if (hit.content != null) {
      fields.putIfAbsent('content', () => hit.content);
    }
    if (hit.hash != null) {
      fields.putIfAbsent('hash', () => hit.hash);
    }

    if (outputFields != null && outputFields.isNotEmpty) {
      fields.removeWhere((key, _) => !outputFields.contains(key));
    }

    return Doc(id: hit.id, score: hit.score, fields: fields);
  }
}

Collection createAndOpen({
  required String path,
  required CollectionSchema schema,
  CollectionOption option = const CollectionOption(),
}) {
  final raw = ZvecCollection.create(
    path: path,
    name: schema.name,
    dimension: schema.primaryVector.dimension,
  );
  _writeCollectionMetadata(path, schema, option);
  return Collection._(path: path, schema: schema, option: option, raw: raw);
}

Collection open(
  String path, {
  CollectionOption option = const CollectionOption(),
}) {
  final raw = ZvecCollection.open(path);
  final metadata = _readCollectionMetadata(path);
  final schema =
      metadata?.schema ??
      CollectionSchema(
        name: _defaultCollectionName(path),
        fields: const <FieldSchema>[
          FieldSchema('id', DataType.STRING),
          FieldSchema('content', DataType.STRING, nullable: true),
          FieldSchema('metadata', DataType.STRING, nullable: true),
          FieldSchema('hash', DataType.STRING, nullable: true),
        ],
        vectors: VectorSchema('vector', DataType.VECTOR_FP16, raw.dimension),
      );
  final resolvedOption = metadata?.option ?? option;
  return Collection._(
    path: path,
    schema: schema,
    option: resolvedOption,
    raw: raw,
  );
}

Collection create_and_open({
  required String path,
  required CollectionSchema schema,
  CollectionOption? option,
}) {
  return createAndOpen(
    path: path,
    schema: schema,
    option: option ?? const CollectionOption(),
  );
}

void init() {}

class _MappedNativeFields {
  const _MappedNativeFields({this.content, this.metadata, this.hash});

  final String? content;
  final Map<String, dynamic>? metadata;
  final String? hash;
}

_MappedNativeFields _mapFieldsForNative(Map<String, dynamic> fields) {
  final mutableFields = Map<String, dynamic>.from(fields);
  final content = mutableFields.remove('content');
  final hash = mutableFields.remove('hash');

  return _MappedNativeFields(
    content: content?.toString(),
    metadata: mutableFields.isEmpty ? null : mutableFields,
    hash: hash?.toString(),
  );
}

Status _statusFromError(Object error) {
  if (error is ZvecException) {
    return Status(
      code: _statusCodeFromNative(error.code),
      message: error.message,
    );
  }
  return Status(code: StatusCode.UNKNOWN, message: error.toString());
}

StatusCode _statusCodeFromNative(int code) {
  switch (code) {
    case 0:
      return StatusCode.OK;
    case -1:
      return StatusCode.INVALID_ARGUMENT;
    case -2:
      return StatusCode.NOT_FOUND;
    case -4:
      return StatusCode.INTERNAL_ERROR;
    case -5:
      return StatusCode.ALREADY_EXISTS;
    case -6:
      return StatusCode.NOT_SUPPORTED;
    default:
      return StatusCode.UNKNOWN;
  }
}

String _collectionMetadataPath(String path) =>
    '$path/$_collectionMetadataFileName';

void _writeCollectionMetadata(
  String path,
  CollectionSchema schema,
  CollectionOption option,
) {
  final file = File(_collectionMetadataPath(path));
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    jsonEncode(<String, dynamic>{
      'schema': schema.toJson(),
      'option': option.toJson(),
    }),
  );
}

_StoredCollectionMetadata? _readCollectionMetadata(String path) {
  final file = File(_collectionMetadataPath(path));
  if (!file.existsSync()) {
    return null;
  }

  try {
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _StoredCollectionMetadata(
      schema: CollectionSchema.fromJson(
        decoded['schema'] as Map<String, dynamic>,
      ),
      option: CollectionOption.fromJson(
        decoded['option'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  } catch (_) {
    return null;
  }
}

class _StoredCollectionMetadata {
  const _StoredCollectionMetadata({required this.schema, required this.option});

  final CollectionSchema schema;
  final CollectionOption option;
}

String _defaultCollectionName(String path) {
  final parts = path.split('/').where((part) => part.isNotEmpty).toList();
  return parts.isEmpty ? 'default' : parts.last;
}

FieldSchema _fieldSchemaFromJson(Map<String, dynamic> json) {
  return FieldSchema(
    json['name'] as String,
    _dataTypeFromName(json['data_type'] as String? ?? 'UNDEFINED'),
    nullable: json['nullable'] as bool? ?? false,
    indexParam: _indexParamFromJson(
      json['index_param'] as Map<String, dynamic>?,
    ),
  );
}

VectorSchema _vectorSchemaFromJson(Map<String, dynamic> json) {
  return VectorSchema(
    json['name'] as String,
    _dataTypeFromName(json['data_type'] as String? ?? 'VECTOR_FP16'),
    json['dimension'] as int? ?? 0,
    nullable: json['nullable'] as bool? ?? false,
    indexParam: _indexParamFromJson(
      json['index_param'] as Map<String, dynamic>?,
    ),
  );
}

IndexParam? _indexParamFromJson(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }

  switch (_indexTypeFromName(json['type'] as String? ?? 'UNDEFINED')) {
    case IndexType.HNSW:
      return HnswIndexParam(
        metricType: _metricTypeFromName(json['metric_type'] as String? ?? 'IP'),
        m: json['m'] as int? ?? 32,
        efConstruction: json['ef_construction'] as int? ?? 200,
        quantizeType: _quantizeTypeFromName(
          json['quantize_type'] as String? ?? 'UNDEFINED',
        ),
      );
    case IndexType.FLAT:
      return FlatIndexParam(
        metricType: _metricTypeFromName(json['metric_type'] as String? ?? 'IP'),
        quantizeType: _quantizeTypeFromName(
          json['quantize_type'] as String? ?? 'UNDEFINED',
        ),
      );
    case IndexType.IVF:
      return IVFIndexParam(
        metricType: _metricTypeFromName(json['metric_type'] as String? ?? 'IP'),
        nList: json['n_list'] as int? ?? 1024,
        nIters: json['n_iters'] as int? ?? 10,
        useSoar: json['use_soar'] as bool? ?? false,
        quantizeType: _quantizeTypeFromName(
          json['quantize_type'] as String? ?? 'UNDEFINED',
        ),
      );
    case IndexType.INVERT:
      return InvertIndexParam(
        enableRangeOptimization:
            json['enable_range_optimization'] as bool? ?? true,
        enableExtendedWildcard:
            json['enable_extended_wildcard'] as bool? ?? false,
      );
    case IndexType.UNDEFINED:
      return null;
  }
}

DataType _dataTypeFromName(String name) {
  return DataType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => DataType.UNDEFINED,
  );
}

IndexType _indexTypeFromName(String name) {
  return IndexType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => IndexType.UNDEFINED,
  );
}

MetricType _metricTypeFromName(String name) {
  return MetricType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => MetricType.UNDEFINED,
  );
}

QuantizeType _quantizeTypeFromName(String name) {
  return QuantizeType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => QuantizeType.UNDEFINED,
  );
}
