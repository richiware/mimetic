cmake_minimum_required (VERSION 3.1)
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS ON)

project(libmimetic CXX)

set(VERSION "1.0")

if(XW_BUILD_LIBMIMETIC)
	set(CMAKE_INSTALL_PREFIX "${XW_3RDP_ROOT}")
endif() 


set (TRERDP_ROOT "${CMAKE_INSTALL_PREFIX}")
set (LIBMIMETIC_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

#########################################################
#
#       string macros 
#
########################################################

# Replace slashes by backslashes in a string.
macro (slashes_to_backslashes output input)
    string (REGEX REPLACE "/" "\\\\" ${output} ${input})
endmacro ()

# Filter a list of items using a regular expression.
macro (filter_list output_list input_list regex)
    foreach (item ${input_list})
        if (${item} MATCHES ${regex})
            list (APPEND ${output_list} ${item})
        endif ()
    endforeach ()
endmacro ()

# Convert a semicolon-separated list to a whitespace-separated string.
macro (convert_list_to_string output_string input_list)
    foreach (item ${input_list})
        if (DEFINED ${output_string})
            set (${output_string} "${${output_string}} ${item}")
        else ()
            set (${output_string} "${item}")
        endif ()
    endforeach ()
endmacro ()

# Assign a whitespace-separated string to a variable, given a list.
macro (set_to_string output_variable first_arg)
    set (arg_list ${first_arg} ${ARGN})
    convert_list_to_string (${output_variable} "${arg_list}")
endmacro ()

#[[
#add in project tree in solution files and return them as sources for project
# @param [in/out]    all_files_list        - list of all files, it can be used for target sources list
# @param [in]        start_dir             - starting dir for scan   
# @param [in]        root_dir              - root dir against it will do relative paths  
# @param [in]        root_grp              - eventual virtual folder for visual studio
# @param [in]        dir_exclusion_regexp  - directory exclusion regexp  
# @param [in]        file_exclusion_regexp - file exclusion regexp
#]]   
function(add_sources_dir all_files_list start_dir root_dir root_grp dir_exclusion_regexp file_exclusion_regexp)
    #curent relative dir
    if ( "${root_dir}" STREQUAL "${start_dir}" )
      set(rel_dir "")
    else()
      string(REPLACE  "${root_dir}/" "" rel_dir  ${start_dir} )
      slashes_to_backslashes(rel_grp ${rel_dir})
    endif()
    #message(STATUS "grp:" ${rel_grp})
    
    set(dir_list "")
    set(file_list "")
    
    file( GLOB this_directory_all_files "${start_dir}/*" )
    FOREACH(file ${this_directory_all_files})
        if(NOT (${file} MATCHES ".*CVS.*"))
            
            if(IS_DIRECTORY ${file})
               if("${dir_exclusion_regexp}" STREQUAL "" OR NOT ("${file}" MATCHES "${dir_exclusion_regexp}"))
                   string(REPLACE  "${root_dir}/" "" rel_path  ${file} ) 
                   #message(STATUS "dir:" ${rel_path})
                   list (APPEND dir_list ${file})
               endif()
            else()
               if("${file_exclusion_regexp}" STREQUAL "" OR NOT ("${file}" MATCHES "${file_exclusion_regexp}"))
                   string(REPLACE  "${start_dir}/" "" rel_path  ${file} ) 
                   if(NOT (${rel_path} MATCHES "(.*\\.txt)"))
                       #message(STATUS "file:" ${rel_path})
                       list (APPEND file_list ${file})
                   endif()
               endif()
            endif() 
        endif()
    ENDFOREACH()
    
    #make group of files in visual project
    list(LENGTH file_list files_cnt)
    list(LENGTH dir_list dirs_cnt)
    
    if(${files_cnt} GREATER 0)
        #message(STATUS "adding in [" "${root_grp}" "]: " ${rel_grp} "->" "${file_list}")
        if("${root_grp}" STREQUAL "")
            source_group("${rel_grp}" FILES ${file_list})
        else()
            if ("${rel_grp}" STREQUAL "" )
               source_group("${root_grp}" FILES ${file_list})
            else()
               source_group("${root_grp}\\${rel_grp}" FILES ${file_list})
            endif()
        endif()        
    endif()
    
    if(${dirs_cnt} GREATER 0)
        foreach(dir ${dir_list})
            set(children_files "")
            #message(STATUS "go for:" ${dir})
            add_sources_dir(children_files ${dir} ${root_dir} "${root_grp}" "${dir_exclusion_regexp}" "${file_exclusion_regexp}")
            #message(STATUS "children:" "${children_files}")
            list(APPEND file_list ${children_files})
        endforeach()
        
    endif()
    
    set(${all_files_list} ${file_list} PARENT_SCOPE) 
    
endfunction()


if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	
	# All configurations.
	set (preprocessor_definitions_common
		WIN32
		_WIN64
		_MBCS
		_LIB
		_CRT_SECURE_NO_WARNINGS
		_CRT_NONSTDC_NO_DEPRECATE
		_SCL_SECURE_NO_WARNINGS		
	)
	
else()
	# All configurations.
	set (preprocessor_definitions_common
		WIN32
		_MBCS
		_LIB
		_USE_32BIT_TIME_T
		_CRT_SECURE_NO_WARNINGS
		_CRT_NONSTDC_NO_DEPRECATE
		_SCL_SECURE_NO_WARNINGS			
	)

endif()



# Debug configuration.
set (preprocessor_definitions_debug
)

# Release configuration.
set (preprocessor_definitions_release
)




#--------------------------------------------------------------------------------------------------
# Compilation/linking flags.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (compiler_flags_common
    /MP                                     # Multi-processor Compilation
    /GF                                     # Enable String Pooling

)
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (compiler_flags_common
        ${compiler_flags_common}
		/W4
		/WX-
		/Zp8
		
    )
else ()
    set (compiler_flags_common
        ${compiler_flags_common}
        /W3                                 # Treat Warnings 3
		/WX-
		/Zp4
    )
endif ()

set (exe_linker_flags_common
    /WX										# Treat Warnings as errors
)
set (shared_lib_linker_flags_common
    ${exe_linker_flags_common}
    /OPT:NOREF
)

# Debug configuration.
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (compiler_flags_debug
        /Zi		# set Debug Information Format to Program Database
		-wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4189 -wd4706 
    )
else ()
    set (compiler_flags_debug
        /ZI                                 # set Debug Information Format to Program Database for Edit & Continue
		-wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4189 -wd4706 
    )
endif ()

set (compiler_flags_debug
    ${compiler_flags_debug}
    /MDd                                    # set Runtime Library to Multi-threaded Debug DLL
)

# Release configuration.
set (compiler_flags_release
    /Zi                                     # set Debug Information Format to Program Database
    /Ox                                     # Full Optimization
    /Ob2                                    # set Inline Function Expansion to Any Suitable
    /Oi                                     # Enable Intrinsic Functions
    /Ot                                     # Favor Fast Code
    /Oy                                     # Omit Frame Pointers
    /MD                                     # set Runtime Library to Multi-threaded DLL
	/EHsc
)
if (CMAKE_SIZEOF_VOID_P EQUAL 4)
    set (compiler_flags_release
        ${compiler_flags_release}
        /fp:fast                            # set Floating Point Model to Fast, in 32-bit builds only because of a bug in VS 2010:
    )                                       # http://connect.microsoft.com/VisualStudio/feedback/details/518015/nan-comparison-under-the-64-bit-compiler-is-incorrect
endif ()


# Release configuration for warnings.
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (compiler_flags_release
        ${compiler_flags_release}
        -wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4189 -wd4706 
    )
else ()
    set (compiler_flags_release
        ${compiler_flags_release}                               # set Debug Information Format to Program Database for Edit & Continue
		-wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4189 -wd4706 
    )
endif ()


set (exe_linker_flags_release
)
set (shared_lib_linker_flags_release
    ${exe_linker_flags_release}
)

# Ship configuration.
set (compiler_flags_ship
    /GL                                     # Enable link-time code generation
)
set (exe_linker_flags_ship
    /LTCG                                   # Use Link Time Code Generation
    /INCREMENTAL:NO                         # Disable Incremental Linking
)
set (shared_lib_linker_flags_ship
    ${exe_linker_flags_ship}
)

# Profile configuration.
set (exe_linker_flags_profile
    /DEBUG                                  # Generate Debug Info
)
set (shared_lib_linker_flags_profile
    ${exe_linker_flags_profile}
)


# All configurations.
set (preprocessor_definitions_common
    ${preprocessor_definitions_common}
)
if (CMAKE_SIZEOF_VOID_P MATCHES 4)
    set (preprocessor_definitions_common
        ${preprocessor_definitions_common}
        ARCH32
)
elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
    set (preprocessor_definitions_common
        ${preprocessor_definitions_common}
        ARCH64
)
else ()
    message (FATAL_ERROR "Cannot determine pointer size")
endif ()

# Debug configuration.
set (preprocessor_definitions_debug
    ${preprocessor_definitions_debug}
    ${preprocessor_definitions_common}
    DEBUG
    _DEBUG
)

# Release configuration.
set (preprocessor_definitions_release
    ${preprocessor_definitions_release}
    ${preprocessor_definitions_common}
    NDEBUG
)


# A convenience macro to apply the preprocessor definitions to all configurations of a given target.
macro (apply_preprocessor_definitions target)
    set_property (TARGET ${target} APPEND PROPERTY
        #  COMPILE_DEFINITIONS_DEBUG ${preprocessor_definitions_debug}
        COMPILE_DEFINITIONS $<$<CONFIG:Debug>:${preprocessor_definitions_debug}>
    )
    set_property (TARGET ${target} APPEND PROPERTY
        # COMPILE_DEFINITIONS_RELEASE ${preprocessor_definitions_release}
        COMPILE_DEFINITIONS $<$<CONFIG:Release>:${preprocessor_definitions_release}>
    )    
endmacro ()


#--------------------------------------------------------------------------------------------------
# Compilation/linking flags.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (compiler_flags_common
    ${compiler_flags_common}
)
set (exe_linker_flags_common
    ${exe_linker_flags_common}
)
set (shared_lib_linker_flags_common
    ${shared_lib_linker_flags_common}
)

# Debug configuration.
set (compiler_flags_debug
    ${compiler_flags_debug}
    ${compiler_flags_common}
)
set (exe_linker_flags_debug
    ${exe_linker_flags_debug}
    ${exe_linker_flags_common}
)
set (shared_lib_linker_flags_debug
    ${shared_lib_linker_flags_debug}
    ${shared_lib_linker_flags_common}
)

# Release configuration.
set (compiler_flags_release
    ${compiler_flags_release}
    ${compiler_flags_common}
)
set (exe_linker_flags_release
    ${exe_linker_flags_release}
    ${exe_linker_flags_common}
)
set (shared_lib_linker_flags_release
    ${shared_lib_linker_flags_release}
    ${shared_lib_linker_flags_common}
)



# Apply Debug configuration compilation/linking flags.
convert_list_to_string (CMAKE_CXX_FLAGS_DEBUG "${compiler_flags_debug}")
convert_list_to_string (CMAKE_EXE_LINKER_FLAGS_DEBUG "${exe_linker_flags_debug}")
convert_list_to_string (CMAKE_SHARED_LINKER_FLAGS_DEBUG "${shared_lib_linker_flags_debug}")

# Apply Release configuration compilation/linking flags.
convert_list_to_string (CMAKE_CXX_FLAGS_RELEASE "${compiler_flags_release}")
convert_list_to_string (CMAKE_EXE_LINKER_FLAGS_RELEASE "${exe_linker_flags_release}")
convert_list_to_string (CMAKE_SHARED_LINKER_FLAGS_RELEASE "${shared_lib_linker_flags_release}")


include_directories(${CMAKE_CURRENT_SOURCE_DIR})




if(XW_BUILD_LIBMIMETIC)
    set(CMAKE_INSTALL_PREFIX "${XW_3RDP_ROOT}")
    # xw includes
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../..)
endif() 


macro(set_lib_names target)
    SET_TARGET_PROPERTIES( ${target} PROPERTIES
        OUTPUT_NAME "${target}"
    )
    
    if (NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
        #we need avoid linux "lib" prefix
        SET_TARGET_PROPERTIES( ${target} PROPERTIES PREFIX "")
    endif()
    
endmacro()

# ---------- Set MS Visual version -----------------------
set (XW_3RDP_ROOT ${CMAKE_INSTALL_PREFIX})

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

    if( "${VC_VERSION}" STREQUAL "" )
    
        set ( VC_VERSION 14 )
    
    endif()

endif()


#============================================================================
# libmimetic 
#============================================================================

#FILE(GLOB_RECURSE  libmimetic_hdrs ${CMAKE_CURRENT_SOURCE_DIR}/mimetic/*.h)
#FILE(GLOB_RECURSE  libmimetic_src ${CMAKE_CURRENT_SOURCE_DIR}/mimetic/*.cxx)

add_sources_dir(libmimetic_hdrs ${CMAKE_CURRENT_SOURCE_DIR}/mimetic ${CMAKE_CURRENT_SOURCE_DIR} "" "" "(.*\.cxx$|.*\.in$|.*\.am$|.*mmfile\.h$)")
add_sources_dir(libmimetic_src ${CMAKE_CURRENT_SOURCE_DIR}/mimetic ${CMAKE_CURRENT_SOURCE_DIR} "" "" "(.*\.h$|.*\.in$|.*\.am$|.*mmfile\.cxx$)")

#this need port to win (it is possible!)
if ( "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
    list(REMOVE_ITEM libmimetic_hdrs
        ${CMAKE_CURRENT_SOURCE_DIR}/mimetic/os/mmfile.cxx
    )
	list(REMOVE_ITEM libmimetic_src
        ${CMAKE_CURRENT_SOURCE_DIR}/mimetic/os/mmfile.h
    )
endif()


add_library(libmimetic  ${libmimetic_hdrs} ${libmimetic_src})


apply_preprocessor_definitions (libmimetic)

#if builded inside xwee src tree use also this
if(XW_BUILD_LIBMIMETIC)
    set_bindir_properties(libmimetic)
endif()

set_lib_names(libmimetic)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS libmimetic
        RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
        LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${libmimetic_hdrs} DESTINATION "${CMAKE_INSTALL_PREFIX}/include/mimetic")
endif()