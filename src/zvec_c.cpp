#include "zvec_c.h"

#include <zvec/ailego/utility/float_helper.h>
#include <zvec/db/collection.h>
#include <zvec/db/doc.h>
#include <zvec/db/options.h>
#include <zvec/db/schema.h>

#include <cstdio>

#if defined(ANDROID)
#include <android/log.h>
#endif

#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#if defined(ANDROID)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "ZvecFlutter", __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "ZvecFlutter", __VA_ARGS__)
#else
#define LOGE(...)                                                             \
  do {                                                                        \
    std::fprintf(stderr, "[ERROR] ZvecFlutter: ");                           \
    std::fprintf(stderr, __VA_ARGS__);                                        \
    std::fprintf(stderr, "\n");                                              \
  } while (0)
#define LOGI(...)                                                             \
  do {                                                                        \
    std::fprintf(stderr, "[INFO] ZvecFlutter: ");                            \
    std::fprintf(stderr, __VA_ARGS__);                                        \
    std::fprintf(stderr, "\n");                                              \
  } while (0)
#endif

static thread_local std::string g_last_error;

static void set_error(const std::string &error) {
  g_last_error = error;
}

const char *zvec_get_last_error(void) {
  return g_last_error.empty() ? "" : g_last_error.c_str();
}

static char *copy_string(const std::string &value) {
  char *out = static_cast<char *>(malloc(value.size() + 1));
  if (!out) {
    return nullptr;
  }
  std::memcpy(out, value.c_str(), value.size() + 1);
  return out;
}

struct ZvecCollectionImpl {
  zvec::Collection::Ptr collection;
  std::mutex mutex;
};

static zvec::DataType detect_vector_data_type(
    const zvec::Collection::Ptr &collection) {
  auto schema_result = collection->Schema();
  if (!schema_result.has_value()) {
    return zvec::DataType::VECTOR_FP16;
  }

  auto vector_fields = schema_result.value().vector_fields();
  if (vector_fields.empty()) {
    return zvec::DataType::VECTOR_FP16;
  }

  return vector_fields[0]->data_type();
}

static std::string encode_query_vector(const zvec::Collection::Ptr &collection,
                                       const float *query,
                                       uint32_t dimension) {
  zvec::DataType vector_data_type = detect_vector_data_type(collection);
  if (vector_data_type == zvec::DataType::VECTOR_FP32) {
    return std::string(reinterpret_cast<const char *>(query),
                       dimension * sizeof(float));
  }

  thread_local std::vector<uint16_t> query_fp16;
  if (query_fp16.size() != dimension) {
    query_fp16.resize(dimension);
  }
  zvec::ailego::FloatHelper::ToFP16(query, dimension, query_fp16.data());
  return std::string(reinterpret_cast<const char *>(query_fp16.data()),
                     dimension * sizeof(uint16_t));
}

static ZvecStatus convert_status(const zvec::Status &status) {
  if (status.ok()) {
    return ZVEC_OK;
  }

  set_error(status.message());

  switch (status.code()) {
  case zvec::StatusCode::INVALID_ARGUMENT:
    return ZVEC_ERROR_INVALID_PARAM;
  case zvec::StatusCode::NOT_FOUND:
    return ZVEC_ERROR_NOT_FOUND;
  case zvec::StatusCode::ALREADY_EXISTS:
    return ZVEC_ERROR_ALREADY_EXISTS;
  case zvec::StatusCode::NOT_SUPPORTED:
    return ZVEC_ERROR_NOT_SUPPORTED;
  default:
    return ZVEC_ERROR_INTERNAL;
  }
}

static uint64_t hash_string(const std::string &value) {
  uint64_t hash = 14695981039346656037ULL;
  for (char character : value) {
    hash ^= static_cast<uint8_t>(character);
    hash *= 1099511628211ULL;
  }
  return hash == 0 ? 1 : hash;
}

ZvecStatus zvec_create_collection(const char *path, const char *name,
                                  uint32_t dimension, ZvecCollection *out) {
  if (!path || !name || !out || dimension == 0) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  zvec::CollectionSchema schema(name);
  schema.add_field(
      std::make_shared<zvec::FieldSchema>("id", zvec::DataType::STRING));
  schema.add_field(std::make_shared<zvec::FieldSchema>(
      "vector", zvec::DataType::VECTOR_FP16, dimension, false,
      std::make_shared<zvec::HnswIndexParams>(zvec::MetricType::IP)));
  schema.add_field(std::make_shared<zvec::FieldSchema>(
      "content", zvec::DataType::STRING, true));
  schema.add_field(std::make_shared<zvec::FieldSchema>(
      "metadata", zvec::DataType::STRING, true));
  schema.add_field(std::make_shared<zvec::FieldSchema>(
      "hash", zvec::DataType::STRING, true,
      std::make_shared<zvec::InvertIndexParams>()));

  zvec::CollectionOptions options{false, true};
  auto result = zvec::Collection::CreateAndOpen(path, schema, options);
  if (!result.has_value()) {
    LOGE("Failed to create collection at %s: %s", path,
         result.error().message().c_str());
    return convert_status(result.error());
  }

  *out = new ZvecCollectionImpl{result.value()};
  return ZVEC_OK;
}

ZvecStatus zvec_open_collection(const char *path, ZvecCollection *out) {
  if (!path || !out) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  zvec::CollectionOptions options;
  auto result = zvec::Collection::Open(path, options);
  if (!result.has_value()) {
    LOGE("Failed to open collection at %s: %s", path,
         result.error().message().c_str());
    return convert_status(result.error());
  }

  *out = new ZvecCollectionImpl{result.value()};
  return ZVEC_OK;
}

ZvecStatus zvec_close_collection(ZvecCollection coll) {
  if (!coll) {
    return ZVEC_OK;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  delete impl;
  return ZVEC_OK;
}

ZvecStatus zvec_flush(ZvecCollection coll) {
  if (!coll) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  return convert_status(impl->collection->Flush());
}

ZvecStatus zvec_optimize(ZvecCollection coll) {
  if (!coll) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  auto status = impl->collection->Optimize();
  if (!status.ok()) {
    LOGE("Optimize failed: %s", status.message().c_str());
  }
  return convert_status(status);
}

int zvec_has_field(ZvecCollection coll, const char *field) {
  if (!coll || !field) {
    return 0;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  auto schema = impl->collection->Schema();
  if (schema && schema->has_field(field)) {
    return 1;
  }
  return 0;
}

ZvecStatus zvec_destroy(ZvecCollection coll) {
  if (!coll) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  auto status = impl->collection->Destroy();
  delete impl;
  return convert_status(status);
}

ZvecStatus zvec_insert(ZvecCollection coll, const char *id, const float *vector,
                       uint32_t dimension, const char *content,
                       const char *metadata_json, const char *hash_value) {
  if (!coll || !id || !vector || dimension == 0) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);

  zvec::Doc document;
  document.set_pk(id);
  document.set_doc_id(hash_string(id) ^ dimension);
  document.set("id", std::string(id));

  zvec::DataType vector_data_type = detect_vector_data_type(impl->collection);
  if (vector_data_type == zvec::DataType::VECTOR_FP32) {
    std::vector<float> vector_fp32(vector, vector + dimension);
    document.set("vector", std::move(vector_fp32));
  } else {
    thread_local std::vector<zvec::float16_t> vector_fp16;
    if (vector_fp16.size() != dimension) {
      vector_fp16.resize(dimension);
    }
    zvec::ailego::FloatHelper::ToFP16(
        vector, dimension,
        reinterpret_cast<uint16_t *>(vector_fp16.data()));
    document.set("vector", std::move(vector_fp16));
  }

  if (content) {
    document.set("content", std::string(content));
  }

  if (metadata_json) {
    document.set("metadata", std::string(metadata_json));
  }

  if (hash_value) {
    document.set("hash", std::string(hash_value));
  }

  std::vector<zvec::Doc> docs = {std::move(document)};
  auto result = impl->collection->Upsert(docs);
  if (!result.has_value()) {
    LOGE("Insert failed for %s: %s", id, result.error().message().c_str());
    return convert_status(result.error());
  }

  for (auto &status : result.value()) {
    if (!status.ok()) {
      return convert_status(status);
    }
  }

  return ZVEC_OK;
}

ZvecStatus zvec_insert_batch(ZvecCollection coll, const char **ids,
                             const float *vectors, const char **hashes,
                             uint32_t dimension, uint32_t count) {
  if (!coll || !ids || !vectors || dimension == 0 || count == 0) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);

  std::vector<zvec::Doc> docs;
  docs.reserve(count);
  zvec::DataType vector_data_type = detect_vector_data_type(impl->collection);

  for (uint32_t index = 0; index < count; ++index) {
    const char *id = ids[index];
    if (!id || *id == '\0') {
      set_error("zvec_insert_batch: ids contains null or empty values");
      return ZVEC_ERROR_INVALID_PARAM;
    }

    zvec::Doc document;
    document.set_pk(id);
    document.set_doc_id(hash_string(id) ^ dimension);
    document.set("id", std::string(id));

    if (vector_data_type == zvec::DataType::VECTOR_FP32) {
      const float *source = &vectors[index * dimension];
      std::vector<float> vector_fp32(source, source + dimension);
      document.set("vector", std::move(vector_fp32));
    } else {
      thread_local std::vector<zvec::float16_t> vector_fp16;
      if (vector_fp16.size() != dimension) {
        vector_fp16.resize(dimension);
      }
      zvec::ailego::FloatHelper::ToFP16(
          &vectors[index * dimension], dimension,
          reinterpret_cast<uint16_t *>(vector_fp16.data()));
      document.set("vector", std::move(vector_fp16));
    }

    if (hashes && hashes[index]) {
      document.set("hash", std::string(hashes[index]));
    }

    docs.push_back(std::move(document));
  }

  auto result = impl->collection->Upsert(docs);
  if (!result.has_value()) {
    LOGE("Batch insert failed: %s", result.error().message().c_str());
    return convert_status(result.error());
  }

  for (auto &status : result.value()) {
    if (!status.ok()) {
      return convert_status(status);
    }
  }

  return convert_status(impl->collection->Flush());
}

ZvecStatus zvec_delete(ZvecCollection coll, const char *id) {
  if (!coll || !id) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  std::vector<std::string> ids = {std::string(id)};
  auto result = impl->collection->Delete(ids);
  if (!result.has_value()) {
    return convert_status(result.error());
  }

  for (auto &status : result.value()) {
    if (!status.ok()) {
      return convert_status(status);
    }
  }

  return ZVEC_OK;
}

ZvecStatus zvec_delete_by_filter(ZvecCollection coll, const char *filter) {
  if (!coll || !filter) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  return convert_status(impl->collection->DeleteByFilter(std::string(filter)));
}

ZvecStatus zvec_search(ZvecCollection coll, const float *query,
                       uint32_t dimension, uint32_t topk, const char *filter,
                       ZvecSearchResult **results, uint32_t *out_count) {
  return zvec_search_with_threshold(coll, query, dimension, topk, -3.4e38f,
                                    filter, results, out_count);
}

ZvecStatus zvec_search_with_threshold(ZvecCollection coll, const float *query,
                                      uint32_t dimension, uint32_t topk,
                                      float min_score, const char *filter,
                                      ZvecSearchResult **results,
                                      uint32_t *out_count) {
  if (!coll || !query || !results || !out_count || dimension == 0) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  *results = nullptr;
  *out_count = 0;

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);

  zvec::VectorQuery query_request;
  query_request.topk_ = filter ? topk : std::min(topk + 4, 64u);
  query_request.field_name_ = "vector";
  query_request.query_vector_ =
      encode_query_vector(impl->collection, query, dimension);
  query_request.output_fields_ = std::vector<std::string>{"id", "metadata", "content"};
  query_request.include_vector_ = false;

  if (filter) {
    query_request.filter_ = std::string(filter);
    uint32_t ef_search = std::max(48u, std::min(192u, topk * 4));
    query_request.query_params_ = std::make_shared<zvec::HnswQueryParams>(
        ef_search, min_score > -100.0f ? min_score : -2.0f, false, false);
  } else {
    uint32_t ef_search = std::max(48u, std::min(128u, topk * 3));
    query_request.query_params_ =
        std::make_shared<zvec::HnswQueryParams>(ef_search, -2.0f, false, false);
  }

  auto query_result = impl->collection->Query(query_request);
  if (filter && (!query_result.has_value() || query_result.value().empty())) {
    auto flat_params = std::make_shared<zvec::FlatQueryParams>();
    flat_params->set_is_linear(true);
    flat_params->set_radius(min_score > -100.0f ? min_score : -100000.0f);
    query_request.query_params_ = flat_params;
    query_result = impl->collection->Query(query_request);
  }

  if (!query_result.has_value()) {
    return convert_status(query_result.error());
  }

  std::vector<zvec::Doc::Ptr> filtered_docs;
  for (auto &doc : query_result.value()) {
    if (doc->score() >= min_score) {
      filtered_docs.push_back(doc);
    }
  }

  if (filtered_docs.empty()) {
    return ZVEC_OK;
  }

  *out_count = static_cast<uint32_t>(filtered_docs.size());
  *results = static_cast<ZvecSearchResult *>(
      malloc(sizeof(ZvecSearchResult) * (*out_count)));
  if (!*results) {
    set_error("zvec_search_with_threshold: out of memory allocating results");
    *out_count = 0;
    return ZVEC_ERROR_INTERNAL;
  }

  size_t index = 0;
  for (auto &doc : filtered_docs) {
    ZvecSearchResult &result = (*results)[index++];
    result.id = copy_string(doc->pk());
    result.score = doc->score();

    auto content = doc->get<std::string>("content");
    result.content = content ? copy_string(*content) : nullptr;

    auto metadata = doc->get<std::string>("metadata");
    result.metadata = metadata ? copy_string(*metadata) : nullptr;
  }

  return ZVEC_OK;
}

ZvecStatus zvec_list_sources(ZvecCollection coll, uint32_t dimension,
                             ZvecSearchResult **results, uint32_t *out_count) {
  if (!coll || !results || !out_count || dimension == 0) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  *results = nullptr;
  *out_count = 0;

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);

  auto stats = impl->collection->Stats();
  if (stats.has_value() && stats.value().doc_count == 0) {
    return ZVEC_OK;
  }

  zvec::VectorQuery query_request;
  query_request.topk_ = 100;
  query_request.field_name_ = "vector";

  thread_local std::vector<float> query_vector;
  if (query_vector.size() != dimension) {
    query_vector.assign(dimension, 0.0f);
  } else {
    std::fill(query_vector.begin(), query_vector.end(), 0.0f);
  }
  query_vector[0] = 1.0f;

  query_request.query_vector_ =
      encode_query_vector(impl->collection, query_vector.data(), dimension);
  query_request.output_fields_ = std::vector<std::string>{"id", "metadata", "content"};
  query_request.include_vector_ = false;
  query_request.query_params_ =
      std::make_shared<zvec::HnswQueryParams>(256, -2.0f, false, false);

  auto query_result = impl->collection->Query(query_request);
  if (!query_result.has_value()) {
    return convert_status(query_result.error());
  }

  auto docs = query_result.value();
  if (docs.empty()) {
    return ZVEC_OK;
  }

  *out_count = static_cast<uint32_t>(docs.size());
  *results = static_cast<ZvecSearchResult *>(
      malloc(sizeof(ZvecSearchResult) * (*out_count)));
  if (!*results) {
    set_error("zvec_list_sources: out of memory allocating results");
    *out_count = 0;
    return ZVEC_ERROR_INTERNAL;
  }

  size_t index = 0;
  for (auto &doc : docs) {
    ZvecSearchResult &result = (*results)[index++];
    result.id = copy_string(doc->pk());
    result.score = 1.0f;

    auto content = doc->get<std::string>("content");
    result.content = content ? copy_string(*content) : nullptr;

    auto metadata = doc->get<std::string>("metadata");
    result.metadata = metadata ? copy_string(*metadata) : nullptr;
  }

  return ZVEC_OK;
}

ZvecStatus zvec_fetch(ZvecCollection coll, const char **ids, uint32_t count,
                      ZvecSearchResult **results, uint32_t *out_count) {
  if (!coll || !ids || !results || !out_count || count == 0) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  *results = nullptr;
  *out_count = 0;

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);

  std::vector<std::string> primary_keys;
  for (uint32_t index = 0; index < count; ++index) {
    if (ids[index]) {
      primary_keys.push_back(std::string(ids[index]));
    }
  }

  if (primary_keys.empty()) {
    return ZVEC_OK;
  }

  auto fetch_result = impl->collection->Fetch(primary_keys);
  if (!fetch_result.has_value()) {
    return convert_status(fetch_result.error());
  }

  auto doc_map = fetch_result.value();
  std::vector<zvec::Doc::Ptr> found_docs;
  found_docs.reserve(primary_keys.size());
  for (const auto &primary_key : primary_keys) {
    auto iterator = doc_map.find(primary_key);
    if (iterator != doc_map.end() && iterator->second != nullptr) {
      found_docs.push_back(iterator->second);
    }
  }

  if (found_docs.empty()) {
    return ZVEC_OK;
  }

  *out_count = static_cast<uint32_t>(found_docs.size());
  *results = static_cast<ZvecSearchResult *>(
      malloc(sizeof(ZvecSearchResult) * (*out_count)));
  if (!*results) {
    set_error("zvec_fetch: out of memory allocating results");
    *out_count = 0;
    return ZVEC_ERROR_INTERNAL;
  }

  size_t index = 0;
  for (auto &doc : found_docs) {
    ZvecSearchResult &result = (*results)[index++];
    result.id = copy_string(doc->pk());
    result.score = 1.0f;

    auto content = doc->get<std::string>("content");
    result.content = content ? copy_string(*content) : nullptr;

    auto metadata = doc->get<std::string>("metadata");
    result.metadata = metadata ? copy_string(*metadata) : nullptr;
  }

  return ZVEC_OK;
}

ZvecStatus zvec_count(ZvecCollection coll, uint64_t *out_count) {
  if (!coll || !out_count) {
    return ZVEC_ERROR_INVALID_PARAM;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  auto stats = impl->collection->Stats();
  if (!stats.has_value()) {
    return convert_status(stats.error());
  }

  *out_count = stats.value().doc_count;
  return ZVEC_OK;
}

uint32_t zvec_get_dimension(ZvecCollection coll) {
  if (!coll) {
    return 0;
  }

  auto *impl = static_cast<ZvecCollectionImpl *>(coll);
  std::lock_guard<std::mutex> lock(impl->mutex);
  auto schema_result = impl->collection->Schema();
  if (!schema_result.has_value()) {
    return 0;
  }

  auto vector_fields = schema_result.value().vector_fields();
  if (vector_fields.empty()) {
    return 0;
  }

  return vector_fields[0]->dimension();
}

void zvec_free_string(char *str) {
  if (str) {
    free(str);
  }
}

void zvec_free_results(ZvecSearchResult *results, uint32_t count) {
  if (!results) {
    return;
  }

  for (uint32_t index = 0; index < count; ++index) {
    zvec_free_string(results[index].id);
    zvec_free_string(results[index].metadata);
    zvec_free_string(results[index].content);
  }
  free(results);
}