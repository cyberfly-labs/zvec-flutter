#ifndef ZVEC_C_H
#define ZVEC_C_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *ZvecCollection;

typedef enum {
  ZVEC_OK = 0,
  ZVEC_ERROR_INVALID_PARAM = -1,
  ZVEC_ERROR_NOT_FOUND = -2,
  ZVEC_ERROR_IO = -3,
  ZVEC_ERROR_INTERNAL = -4,
  ZVEC_ERROR_ALREADY_EXISTS = -5,
  ZVEC_ERROR_NOT_SUPPORTED = -6,
} ZvecStatus;

typedef struct {
  char *id;
  float score;
  char *metadata;
  char *content;
} ZvecSearchResult;

ZvecStatus zvec_create_collection(const char *path, const char *name,
                                  uint32_t dimension, ZvecCollection *out);

ZvecStatus zvec_open_collection(const char *path, ZvecCollection *out);

ZvecStatus zvec_close_collection(ZvecCollection coll);

ZvecStatus zvec_flush(ZvecCollection coll);

ZvecStatus zvec_optimize(ZvecCollection coll);

int zvec_has_field(ZvecCollection coll, const char *field);

ZvecStatus zvec_destroy(ZvecCollection coll);

ZvecStatus zvec_insert(ZvecCollection coll, const char *id, const float *vector,
                       uint32_t dimension, const char *content,
                       const char *metadata_json, const char *hash);

ZvecStatus zvec_insert_batch(ZvecCollection coll, const char **ids,
                             const float *vectors, const char **hashes,
                             uint32_t dimension, uint32_t count);

ZvecStatus zvec_delete(ZvecCollection coll, const char *id);

ZvecStatus zvec_delete_by_filter(ZvecCollection coll, const char *filter);

ZvecStatus zvec_fetch(ZvecCollection coll, const char **ids, uint32_t count,
                      ZvecSearchResult **results, uint32_t *out_count);

ZvecStatus zvec_search(ZvecCollection coll, const float *query,
                       uint32_t dimension, uint32_t topk, const char *filter,
                       ZvecSearchResult **results, uint32_t *out_count);

ZvecStatus zvec_search_with_threshold(ZvecCollection coll, const float *query,
                                      uint32_t dimension, uint32_t topk,
                                      float min_score, const char *filter,
                                      ZvecSearchResult **results,
                                      uint32_t *out_count);

ZvecStatus zvec_list_sources(ZvecCollection coll, uint32_t dimension,
                             ZvecSearchResult **results, uint32_t *out_count);

ZvecStatus zvec_count(ZvecCollection coll, uint64_t *out_count);

uint32_t zvec_get_dimension(ZvecCollection coll);

void zvec_free_string(char *str);

void zvec_free_results(ZvecSearchResult *results, uint32_t count);

const char *zvec_get_last_error(void);

#ifdef __cplusplus
}
#endif

#endif