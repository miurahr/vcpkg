## # vcpkg_test_msbuild
##
## Post-built msbuild test for port package.
##
## ## Usage:
## ```cmake
## vcpkg_test_msbuild(INCLUDE_FILE <include filename>  INCLUDE_DIR <include directory from build root> 
##                    LIBRARIES <lib path name from build root>) 
## ```
##
## Test a built package whether it can be found from other msbuild project
##
## ## Parameters:
##
##  INCLUDE_FILE  mandatory
##
##  INCLUDE_DIR
##
##  LIBRARIES
##
## ## Notes:
## This command should be called at an end of portfile.cmake. 
##
function(vcpkg_test_msbuild)
  cmake_parse_arguments(_tc "" "INCLUDE_DIR;INCLUDE_FILE" "LIBRARIES" ${ARGN})
  if(_tc_INCLUDE_DIR)
    set(TEST_TARGET_INCLUDE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${_tc_INCLUDE_DIR})
  else()
    set(TEST_TARGET_INCLUDE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
  endif()
  set(TEST_TARGET_INCLUDE_FILE ${_tc_INCLUDE_FILE})
  set(TEST_TARGET_LIBRARIES ${_tc_LIBRARIES})

  message(STATUS "Performing post-build msbuild test")
  # Generate test source testproject.vcxproj
  file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg-test-source)
  set(VCPKG_TEST_PROJECT_MAINC ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg-test-source/main.cpp)
  file(WRITE  ${PCPKG_TEST_PROJECT_MAINC} "#include <${TEST_TARGET_INCLUDE_FILE}>")
  file(APPEND ${PCPKG_TEST_PROJECT_MAINC} "int main() {return0;}")
  set(VCPKG_TEST_PROJECT_VCXPROJ ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg-test-source/testproject.vcxproj)
  file(WRITE  ${VCPKG_TEST_PROJECT_VCXPROJ} '<Project DefaultTargets="Build" ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '<ItemGroup>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '  <ProjectConfiguration Include="Debug|Win32">')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '    <Platform>Win32</Platform>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '    </ProjectConfiguration>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '  <ProjectConfiguration Include="Release|Win32">')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '    <Configuration>Release</Configuration>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '    <Platform>Win32</Platform>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '  </ProjectConfiguration>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '</ItemGroup>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '<Import Project="$(VCTargetsPath)\Microsoft.Cpp.default.props"/>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '<PropertyGroup>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} "  <IncludePath Condition=\"'$(AdditionalIncludePath)'!=''\">$(IncludePath);$(AdditionalIncludePath)</IncludePath>")
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '  <ConfigurationType>Application</ConfigurationType>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '  <PlatformToolset>v141</PlatformToolset>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '</PropertyGroup>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props"/>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '<ItemGroup>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '  <ClCompile Include="main.cpp" />')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '</ItemGroup>')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '<Import Project="$(VCTargetsPath)\Microsoft.Cpp.Targets" />')
  file(APPEND ${VCPKG_TEST_PROJECT_VCXPROJ} '</Project>')
  set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/test-${TARGET_TRIPLET}-msbuild")
  execute_process(
    COMMAND msbuild testproject.vcxproj
            /p:configuration:debug
            /p:AdditionalIncludePath:${TEST_TARGET_INCLUDE_PATH}
    OUTPUT_FILE "${LOGPREFIX}-out.log"
    ERROR_FILE "${LOGPREFIX}-err.log"
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg-test-source)
  if(error_code)
    message(FATAL_ERROR "Post-build test failed")
  endif()
  message(STATUS "Performing post-build test done")
endfunction()
