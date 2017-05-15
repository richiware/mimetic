#--------------------------------------------------------------------------------------------------
# gcc 4.x.x on Linux, generating 32-bit or 64-bit binaries.
#--------------------------------------------------------------------------------------------------

set (platform "linux-gcc4")


#--------------------------------------------------------------------------------------------------
# Preprocessor definitions.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (preprocessor_definitions_common
    NO_DEFINES
    FULLCAST
	GCC_LIN
	GCC
	GCC_LIN2
	BOOST_ALL_NO_LIB
	BOOST_ALL_DYN_LINK
	BOOST_CHRONO_HEADER_ONLY
	_CRT_SECURE_NO_WARNINGS
	_CRT_NONSTDC_NO_DEPRECATE
	_SCL_SECURE_NO_WARNINGS
)

# Debug configuration.
set (preprocessor_definitions_debug
)

# Release configuration.
set (preprocessor_definitions_release
)


#--------------------------------------------------------------------------------------------------
# Compilation/Linking Flags.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (compiler_flags_common
	-std=c++11
	-fPIC
	#-Werror                                 # Treat Warnings As Errors
)

if(XW_BUILD_PERSERVE_FRAME_POINTER)
    set (compiler_flags_common
        ${compiler_flags_common}
        -fno-omit-frame-pointer                  # profiling per avere stack pointers
    )
endif(XW_BUILD_PERSERVE_FRAME_POINTER)

set (exe_linker_flags_common
    #-Werror                                 # Treat Warnings As Errors
)
set (shared_lib_linker_flags_common
    #-Werror                                 # Treat Warnings As Errors
)

# Debug configuration.

# Release configuration.
set (compiler_flags_release
#    -O3                                     # Maximum optimization
#Since -O2 and higher sets _FORTIFY_SOURCE=2 by default, and it clashes with some code tricks we used, we have to
#undefine the preprocessor definition and define it again with the level we can afford, that is 1.
    -U_FORTIFY_SOURCE
    -D_FORTIFY_SOURCE=1
    -g
)

# Ship configuration.

# Profile configuration.


