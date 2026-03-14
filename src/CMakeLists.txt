cmake_minimum_required(VERSION 3.10)

project(zvec_flutter_android_library VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(ZVEC_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../zvec/zvec-android-arm64")

add_library(zvec_flutter_android SHARED
  "zvec_c.cpp"
)

set_target_properties(zvec_flutter_android PROPERTIES
  PUBLIC_HEADER zvec_c.h
  OUTPUT_NAME "zvec_flutter_android"
)

target_compile_definitions(zvec_flutter_android PUBLIC DART_SHARED_LIB)

target_include_directories(zvec_flutter_android PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${ZVEC_ROOT}/include/include"
)

target_link_directories(zvec_flutter_android PRIVATE "${ZVEC_ROOT}/lib")

if (ANDROID)
  find_library(log-lib log)
  target_link_options(zvec_flutter_android PRIVATE "-Wl,-z,max-page-size=16384")

  target_link_libraries(zvec_flutter_android PRIVATE
    ${log-lib}
    zvec_db zvec_sqlengine zvec_index zvec_proto zvec_common zvec_ailego
    core_framework core_interface
    "-Wl,--whole-archive"
    core_knn_flat core_knn_hnsw core_metric core_quantizer core_utility core_mix_reducer
    "-Wl,--no-whole-archive"
    arrow arrow_dataset arrow_acero arrow_compute arrow_bundled_dependencies parquet
    roaring protobuf rocksdb lz4 antlr4-runtime glog gflags_nothreads re2 thrift utf8proc z
    boost_locale boost_thread boost_charconv boost_container boost_chrono boost_atomic boost_date_time
    c++_shared
  )
endif()
