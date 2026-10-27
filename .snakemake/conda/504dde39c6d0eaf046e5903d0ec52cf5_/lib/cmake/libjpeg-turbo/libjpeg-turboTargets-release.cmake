#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "libjpeg-turbo::jpeg" for configuration "Release"
set_property(TARGET libjpeg-turbo::jpeg APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(libjpeg-turbo::jpeg PROPERTIES
  IMPORTED_LOCATION_RELEASE "/media/Store/Daniel/Data_sharing_evaluation/ODDPub/ODDPub_from_Pure/.snakemake/conda/504dde39c6d0eaf046e5903d0ec52cf5_/lib/libjpeg.so.8.3.2"
  IMPORTED_SONAME_RELEASE "libjpeg.so.8"
  )

list(APPEND _cmake_import_check_targets libjpeg-turbo::jpeg )
list(APPEND _cmake_import_check_files_for_libjpeg-turbo::jpeg "/media/Store/Daniel/Data_sharing_evaluation/ODDPub/ODDPub_from_Pure/.snakemake/conda/504dde39c6d0eaf046e5903d0ec52cf5_/lib/libjpeg.so.8.3.2" )

# Import target "libjpeg-turbo::turbojpeg" for configuration "Release"
set_property(TARGET libjpeg-turbo::turbojpeg APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(libjpeg-turbo::turbojpeg PROPERTIES
  IMPORTED_LOCATION_RELEASE "/media/Store/Daniel/Data_sharing_evaluation/ODDPub/ODDPub_from_Pure/.snakemake/conda/504dde39c6d0eaf046e5903d0ec52cf5_/lib/libturbojpeg.so.0.5.0"
  IMPORTED_SONAME_RELEASE "libturbojpeg.so.0"
  )

list(APPEND _cmake_import_check_targets libjpeg-turbo::turbojpeg )
list(APPEND _cmake_import_check_files_for_libjpeg-turbo::turbojpeg "/media/Store/Daniel/Data_sharing_evaluation/ODDPub/ODDPub_from_Pure/.snakemake/conda/504dde39c6d0eaf046e5903d0ec52cf5_/lib/libturbojpeg.so.0.5.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
