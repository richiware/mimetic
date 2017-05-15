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

