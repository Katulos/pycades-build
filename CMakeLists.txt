cmake_minimum_required(VERSION 3.15...3.27)

set(PROJECT_MAJOR_VERSION 0)
set(PROJECT_MINOR_VERSION 1)
set(PROJECT_PATCH_VERSION 70200)

set(PROJECT_VERSION ${PROJECT_MAJOR_VERSION}.${PROJECT_MINOR_VERSION}.${PROJECT_PATCH_VERSION})

project(
    pycades
    LANGUAGES CXX
)

if (CMAKE_VERSION VERSION_LESS 3.18)
  set(DEV_MODULE Development)
else()
  set(DEV_MODULE Development.Module)
endif()

find_package(Python COMPONENTS Interpreter ${DEV_MODULE} REQUIRED)

set(CMAKE_CXX_STANDARD 11)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/pycades-source)

set(PATCHED_SRC_DIR ${CMAKE_BINARY_DIR}/patched_src)

file(COPY ${SRC_DIR} DESTINATION ${PATCHED_SRC_DIR})

find_package(Patch REQUIRED)

message("-- Applying ${CMAKE_CURRENT_SOURCE_DIR}/patches/001-move-version-define-and-rename-lib.patch")

execute_process(
    COMMAND ${Patch_EXECUTABLE} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/001-move-version-define-and-rename-lib.patch
    WORKING_DIRECTORY ${PATCHED_SRC_DIR}
    RESULT_VARIABLE PATCH_RESULT
)

if(NOT PATCH_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to apply patch")
endif()

set(pycades_LIB_SRCS
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCades.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesAbout.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesAlgorithm.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesAttribute.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesAttributes.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesBasicConstraints.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesBlobs.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesCertificate.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesCertificates.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesCertificateStatus.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesCRL.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesEncodedData.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesEnvelopedData.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesEKU.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesEKUs.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesExtension.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesExtensions.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesExtendedKeyUsage.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesHashedData.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesKeyUsage.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesOID.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesPrivateKey.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesPublicKey.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesRawSignature.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesRecipients.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesSignatureStatus.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesSignedData.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesSignedXML.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesSigner.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesSigners.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesStore.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesSymmetricAlgorithm.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyCadesVersion.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyEnrollContainer.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyEnrollContainers.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyEnrollContainerKey.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyEnrollContainerKeys.cpp
    ${PATCHED_SRC_DIR}/pycades-source/src/PyEnrollCspInformation.cpp
)

find_package(Boost REQUIRED)

execute_process(
    COMMAND bash -c "if type dpkg > /dev/null 2>&1; then dpkg -l | grep cprocsp-pki-cades | awk '{print \$3}'; else rpm -qa | grep cprocsp-pki-cades; fi | cut -d. -f1 | cut -d- -f1"
    OUTPUT_VARIABLE CPRO_CADES_VERSION_MAJOR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND bash -c "if type dpkg > /dev/null 2>&1; then dpkg -l | grep cprocsp-pki-cades | awk '{print \$3}'; else rpm -qa | grep cprocsp-pki-cades; fi | cut -d. -f2 | cut -d- -f1"
    OUTPUT_VARIABLE CPRO_CADES_VERSION_MINOR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND bash -c "if type dpkg > /dev/null 2>&1; then dpkg -l | grep cprocsp-pki-cades | awk '{print \$3}'; else rpm -qa | grep cprocsp-pki-cades; fi | cut -d. -f3 | cut -d- -f1"
    OUTPUT_VARIABLE CPRO_CADES_VERSION_BUILD
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message("-- Found cprocsp-pki-cades: ${CPRO_CADES_VERSION_MAJOR}.${CPRO_CADES_VERSION_MINOR}.${CPRO_CADES_VERSION_BUILD}")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-write-strings -Wno-deprecated-declarations -Wno-narrowing")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(pycades_DIRS
    /opt/cprocsp/include
    /opt/cprocsp/include/cpcsp
    /opt/cprocsp/include/pki/atl
    /opt/cprocsp/include/pki/cppcades
    /opt/cprocsp/include/pki/cplib
    /opt/cprocsp/include/pki
    ${PATCHED_SRC_DIR}/pycades-source/src/cplib
    ${PATCHED_SRC_DIR}/pycades-source/src
)

include_directories(
    ${Boost_INCLUDE_DIRS}
    ${Python_INCLUDE_DIRS}
    ${pycades_DIRS}
)

Python_add_library(_pycades MODULE ${pycades_LIB_SRCS} WITH_SOABI)

target_compile_definitions(_pycades PRIVATE
    UNIX
    SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
    CPRO_CADES_VERSION_MAJOR=${CPRO_CADES_VERSION_MAJOR}
    CPRO_CADES_VERSION_MINOR=${CPRO_CADES_VERSION_MINOR}
    CPRO_CADES_VERSION_BUILD=${CPRO_CADES_VERSION_BUILD}
    PYCADES_VERSION="${PROJECT_VERSION}"
)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64|ARM64")
    target_compile_definitions(_pycades PRIVATE
        UNIX
        PROC_TYPE_ARM64=7
        PROCESSOR_TYPE=PROC_TYPE_ARM64
    )
    message("-- Enabled ARM64-specific definitions")
endif()

find_library(FOUND_LIB_CPPCADES
    NAMES cppcades
    HINTS
        /opt/cprocsp/lib/amd64
        /opt/cprocsp/lib/ia32
        /opt/cprocsp/lib/aarch64
    REQUIRED
)

target_link_libraries(_pycades PRIVATE ${FOUND_LIB_CPPCADES})

find_library(FOUND_LIB_CPLIB
    NAMES cplib
    HINTS
        /opt/cprocsp/lib/amd64
        /opt/cprocsp/lib/ia32
        /opt/cprocsp/lib/aarch64
    REQUIRED
)

target_link_libraries(_pycades PRIVATE ${FOUND_LIB_CPLIB})

if(DEFINED PY_BUILD_CMAKE_IMPORT_NAME AND NOT "${PY_BUILD_CMAKE_IMPORT_NAME}" STREQUAL "")
    install(TARGETS _pycades
        EXCLUDE_FROM_ALL
        COMPONENT python_modules
        DESTINATION ${PY_BUILD_CMAKE_IMPORT_NAME})

    install(FILES ${SRC_DIR}/src/pycades.pyi
        DESTINATION ${PY_BUILD_CMAKE_IMPORT_NAME}
        RENAME _pycades.pyi
        COMPONENT python_modules) 
endif()