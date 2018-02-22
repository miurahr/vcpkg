include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/librasterlite2-1.0.0-devel)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/librasterlite2-sources/librasterlite2-1.0.0-devel.tar.gz"
    FILENAME "librasterlite2-1.0.0-devel.tar.gz"
    SHA512 5692eb79b62a1a46882028ec03cc4c73106e9aa9bd600a381314ad2841762e04f70ffa1d01703643a5bdb63e3c3dd238ede626f22e304b896f673d4871dac90c 
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-cmake-Add-CMake-build-scripts.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-cmake-Generate-config.h.patch
        ${CMAKE_CURRENT_LIST_DIR}/0003-cmake-Support-tests-and-tools-build.patch
        ${CMAKE_CURRENT_LIST_DIR}/0004-cmake-Generate-project-config.cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/0005-cmake-Update-dependencies.patch
        ${CMAKE_CURRENT_LIST_DIR}/0006-cmake-bump-version-1.0.0.1.patch
        ${CMAKE_CURRENT_LIST_DIR}/0007-cmake-OMIT-CHARLS-2.0-and-some-refactoring.patch
        ${CMAKE_CURRENT_LIST_DIR}/0008-win32-fix-include-unistd.h.patch
        ${CMAKE_CURRENT_LIST_DIR}/0009-libopenjpeg-Update-configure-scripts.patch
        ${CMAKE_CURRENT_LIST_DIR}/0010-win32-fix-syntax-error.patch
        ${CMAKE_CURRENT_LIST_DIR}/0011-cmake-Fix-config.cmake-installation.patch
        ${CMAKE_CURRENT_LIST_DIR}/0012-cmake-win32-link-transitive-dependencies-and-wsock.patch
        ${CMAKE_CURRENT_LIST_DIR}/0013-cmake-use-target_compile_definisions.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(ENALBE_SHARED_LIBS OFF)
else()
    set(ENALBE_SHARED_LIBS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_SHARED_LIBS=${ENABLE_SHARED_LIBS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/librasterlite2 RENAME copyright)

# fixup installations
vcpkg_fixup_cmake_targets(CONFIG_PATH share/librasterlite2)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
foreach(TDIR IN ITEMS "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/debug")
    file(GLOB TOOLFILES ${TDIR}/bin/*.exe)
    file(COPY ${TOOLSFILES} DESTINATION ${TDIR}/tools/)
    file(REMOVE ${TOOLFILES})
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()
