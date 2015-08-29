define WELCOME_MESSAGE
default.inc not found, generating now
-----------------------------------------------------
|                                                   |
|             Magic C/C++ Makefile                  |
|                   - Eric Lunderberg               |
|                                                   |
-----------------------------------------------------

  This is a makefile intended for compiling any
C/C++ project.  It will find all source files,
compile them appropriately into executables and
libraries, and track all dependencies.

  The makefile itself should not need to be
modified.  A "default.inc" file has been generated,
which contains many options for customizing the
behavior of the makefile for your particular
project.  The initial behavior assumes that most source
files are located in src, include files are
located in include, and source files containing
"int main()" are in the main directory.

  Additional description of the behavior of the
makefile can be found in "default.inc".
endef #WELCOME_MESSAGE

define DEFAULT_INC_CONTENTS
# The C compiler to be used
CC       = gcc

# The C++ compiler to be used
CXX      = g++

# The archiver to be used
AR       = ar

# The command to remove files
RM       = rm -f

# Flags to be passed to both C and C++ code
CPPFLAGS =

# Flags to be passed to C code
CFLAGS   =

# Flags to be passed to C++ code
CXXFLAGS = -g -O3

# Flags to be passed to the linker, prior to listing of object files.
LDFLAGS  =

# Flags to be passed to the linker, after the listing of object files.
LDLIBS   =

# If BUILD_SHARED is non-zero, shared libraries will be generated.  If
# BUILD_SHARED is greater than BUILD_STATIC, executables will be
# linked against the shared libraries.
BUILD_SHARED = 1

# If BUILD_STATIC is non-zero, static libraries will be generated.  If
# BUILD_STATIC is greater than BUILD_SHARED, executables will be
# linked against the static libraries.
BUILD_STATIC = 0

# Mandatory arguments to both C and C++ compilers.  These arguments
# will be passed even if CPPFLAGS has been overridden by command-line
# arguments.
CPPFLAGS_EXTRA = -Iinclude

# Mandatory arguments to the C compiler.  These arguments will be
# passed even if CFLAGS has been overriden by command-line arguments.
CFLAGS_EXTRA =

# Mandatory arguments to the C++ compiler.  These arguments will be
# passed even if CXXFLAGS has been overridden by command-line arguments.
CXXFLAGS_EXTRA =

# Mandatory arguments to the linker, before the listing of object
# files.  These arguments will be passed even if LDFLAGS has been
# overridden by command-line arguments.
LDFLAGS_EXTRA  = -Llib -Wl,-rpath,\$$ORIGIN/../lib -Wl,--no-as-needed

# Mandatory arguments to the linker, after the listing of object
# files.  These arguments will be passed even if LDLIBS has been
# overridden by command-line arguments.
LDLIBS_EXTRA   =

# Flag to generate position-independent code.  This is passed to
# object files being compiled to shared libraries, but not to any
# other object files.
PIC_FLAG = -fPIC

# A space-delimited list of file extensions to be compiled as C code.
# No element of this list should be present in CPP_EXT.
C_EXT   = c

# A space-delimited list of file extensions to be compiled as C++
# code.  No element of this list should be present in C_EXT.
CPP_EXT = C cc cpp cxx c++ cp

# A function that, when given the name of a library, should return the
# output file of a shared library.  For example, the default version,
# when passed "libMyLibrary" as $(1), will return "lib/libMyLibrary.so".
SHARED_LIBRARY_NAME = $(patsubst %,lib/%.so,$(1))

# A function that, when given the name of a library, should return the
# output file of a static library.  For example, the default version,
# when passed "libMyLibrary" as $(1), will return "lib/libMyLibrary.a".
STATIC_LIBRARY_NAME = $(patsubst %,lib/%.a,$(1))

#   A macro to determine whether executables will be linked against
# static libraries or shared libraries.  By default, will compile
# against the shared libraries if BUILD_SHARED has a greater numeric
# value than BUILD_STATIC, and will compile against the static
# libraries otherwise.
#   To always link against shared libraries, change this variable to
# 0.  To always link against static libraries, change this variable to 1.
LINK_AGAINST_STATIC = $(shell test $(BUILD_SHARED) -gt $(BUILD_STATIC); echo $$?)

# A function that, given the base name of a source file, returns the
# output filename of the executable.  For example, the default
# version, when passed "MyProgram" as $(1), will return "bin/MyProgram".
EXE_NAME     = bin/$(1)

endef # DEFAULT_INC_CONTENTS

# Needed to replace newline with \n prior to printing.
define newline


endef

# Eval DEFAULT_INC_CONTENTS first.  This ensures that all required
# variables are defined, even if the default.inc present is from an
# older version of the makefile.
$(eval $(DEFAULT_INC_CONTENTS))

# If default.inc does not exist, create it and display the welcome
# message.
ifeq (,$(wildcard default.inc))
    $(shell echo '$(subst $(newline),\n,$(value DEFAULT_INC_CONTENTS))' > default.inc)
    $(error $(WELCOME_MESSAGE))
endif

BUILD = default
include default.inc

# If the BUILD variable has been defined from the command line,
# include the appropriate build-target file.
ifneq ($(BUILD),default)
    include build-targets/$(BUILD).inc
endif

# Additional flags that are necessary to compile.
# Even if not specified on the command line, these should be present.

ALL_CPPFLAGS = $(CPPFLAGS) $(CPPFLAGS_EXTRA)
ALL_CXXFLAGS = $(CXXFLAGS) $(CXXFLAGS_EXTRA)
ALL_CFLAGS   = $(CFLAGS)   $(CFLAGS_EXTRA)
ALL_LDFLAGS  = $(LDFLAGS)  $(LDFLAGS_EXTRA)
ALL_LDLIBS   = $(LDLIBS)   $(LDLIBS_EXTRA)

# EVERYTHING PAST HERE SHOULD WORK AUTOMATICALLY

.SECONDARY:
.SECONDEXPANSION:
.PHONY: all clean force

include PrettyPrint.inc

find_in_dir = $(foreach ext,$(2),$(wildcard $(1)/*.$(ext)))
o_file_name = $(foreach file,$(1),build/$(BUILD)/build/$(basename $(file)).o)

# Find the source files that will be used.
EXE_SRC_FILES = $(call find_in_dir,.,$(CPP_EXT) $(C_EXT))
EXECUTABLES = $(foreach cc,$(EXE_SRC_FILES),$(call EXE_NAME,$(basename $(cc))))
SRC_FILES = $(call find_in_dir,src/,$(CPP_EXT) $(C_EXT))
O_FILES = $(call o_file_name,$(SRC_FILES))

# Find each library to be made.
LIBRARY_FOLDERS   = $(wildcard lib?*)
LIBRARY_INCLUDES  = $(patsubst %,-I%/include,$(LIBRARY_FOLDERS))
ALL_CPPFLAGS     += $(LIBRARY_INCLUDES)
LIBRARY_FLAGS     = $(patsubst lib%,-l%,$(LIBRARY_FOLDERS))
ifneq ($(LINK_AGAINST_STATIC),1)
    ALL_LDLIBS       += $(LIBRARY_FLAGS)
endif
library_src_files = $(foreach src_dir,$(2),$(call find_in_dir,$(1)/$(src_dir),$(CPP_EXT) $(C_EXT)))
library_o_files   = $(call o_file_name,$(call library_src_files,$(1),$(2)))
library_os_files   = $(addsuffix s,$(call library_o_files,$(1),$(2)))

ifneq ($(BUILD_STATIC),0)
    STATIC_LIBRARY_OUTPUT = $(foreach lib,$(LIBRARY_FOLDERS),$(call STATIC_LIBRARY_NAME,$(lib)))
endif

ifneq ($(BUILD_SHARED),0)
    SHARED_LIBRARY_OUTPUT = $(foreach lib,$(LIBRARY_FOLDERS),$(call SHARED_LIBRARY_NAME,$(lib)))
endif

all: default.inc $(EXECUTABLES) $(STATIC_LIBRARY_OUTPUT) $(SHARED_LIBRARY_OUTPUT)
	@printf "%b" "$(DGREEN)Compilation successful$(NO_COLOR)\n"

# Update dependencies with each compilation
ALL_CPPFLAGS += -MMD
-include $(shell find build -name "*.d" 2> /dev/null)

.build-target: force
	@echo $(BUILD) | cmp -s - $@ || echo $(BUILD) > $@

$(call EXE_NAME,%): build/$(BUILD)/$(call EXE_NAME,%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

$(call SHARED_LIBRARY_NAME,lib%): build/$(BUILD)/$(call SHARED_LIBRARY_NAME,lib%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

$(call STATIC_LIBRARY_NAME,lib%): build/$(BUILD)/$(call STATIC_LIBRARY_NAME,lib%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

ifeq ($(LINK_AGAINST_STATIC),0)
build/$(BUILD)/$(call EXE_NAME,%): build/$(BUILD)/build/%.o $(O_FILES) | $(SHARED_LIBRARY_OUTPUT)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ $(ALL_LDLIBS) -o $@,Linking  )
else
build/$(BUILD)/$(call EXE_NAME,%): build/$(BUILD)/build/%.o $(O_FILES) $(STATIC_LIBRARY_OUTPUT)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ $(ALL_LDLIBS) -o $@,Linking  )
endif

define CPP_BUILD_RULES
build/$$(BUILD)/build/%.o: %.$(1)
	@$$(call run_and_test,$$(CXX) -c $$(ALL_CPPFLAGS) $$(ALL_CXXFLAGS) $$< -o $$@,Compiling)

build/$$(BUILD)/build/%.os: %.$(1)
	@$$(call run_and_test,$$(CXX) -c $$(PIC_FLAG) $$(ALL_CPPFLAGS) $$(ALL_CXXFLAGS) $$< -o $$@,Compiling)
endef

$(foreach ext,$(CPP_EXT),$(eval $(call CPP_BUILD_RULES,$(ext))))


define C_BUILD_RULES
build/$$(BUILD)/build/%.o: %.$(1)
	@$$(call run_and_test,$$(CC) -c $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@,Compiling)

build/$$(BUILD)/build/%.os: %.$(1)
	@$$(call run_and_test,$$(CC) -c $$(PIC_FLAG) $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@,Compiling)
endef

$(foreach ext,$(C_EXT),$(eval $(call C_BUILD_RULES,$(ext))))


define library_commands

    ifneq ($$(BUILD_STATIC),0)
       STATIC_LIBRARY := $$(call STATIC_LIBRARY_NAME,$(1))
    else
       STATIC_LIBRARY :=
    endif

    ifneq ($$(BUILD_SHARED),0)
       SHARED_LIBRARY := $$(call SHARED_LIBRARY_NAME,$(1))
    else
       SHARED_LIBRARY :=
    endif

    LIBRARY = $$(SHARED_LIBRARY) $$(STATIC_LIBRARY)
    LIBRARY_SRC_DIRS = src

    -include $(1)/Makefile.inc

    build/$$(BUILD)/$$(call SHARED_LIBRARY_NAME,$(1)): $$(call library_os_files,$(1),$$(LIBRARY_SRC_DIRS))
	@$$(call run_and_test,$$(CXX) $$(ALL_LDFLAGS) $$^ -shared $$(SHARED_LDLIBS) -o $$@,Linking  )

    build/$$(BUILD)/$$(call STATIC_LIBRARY_NAME,$(1)): $$(call library_o_files,$(1),$$(LIBRARY_SRC_DIRS))
	@$$(call run_and_test,$$(AR) rcs $$@ $$^,Linking  )
endef

$(foreach lib,$(LIBRARY_FOLDERS),$(eval $(call library_commands,$(lib))))



clean:
	@printf "%b" "$(DYELLOW)Cleaning$(NO_COLOR)\n"
	@$(RM) -r bin build lib .build-target
