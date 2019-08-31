# The build configuration (debug or release)
CONFIG := release

lib_version := 1.0.5
lib_soname := 1.0
lib_file := libnumbertext-$(lib_soname).a
lib_src := libnumbertext-$(lib_version)/src
lib_out := $(lib_src)/.libs/$(lib_file)

# Extension packaging options
EXTENSION := pg_libnumbertext
DATA := sql/$(EXTENSION)--*.sql
REGRESS := regression

# Build options
cpp_files := $(wildcard src/*.cpp)

# The native module to build
MODULE_big := pg_libnumbertext
# The object files that go into the module
OBJS := $(patsubst %.cpp,%.o,$(cpp_files))
DATA := $(wildcard sql/pg_libnumbertext--*.sql) $(wildcard libnumbertext-$(lib_version)/data/*.sor)

# C flags
PG_CPPFLAGS := -fPIC -std=c++14
PG_CPPFLAGS += -Isrc/ -I/usr/include -I libnumbertext-$(lib_version)/src
PG_CPPFLAGS += -Wall -Wextra
ifeq ($(CONFIG),debug)
	PG_CPPFLAGS += -g -Og
else
	PG_CPPFLAGS += -O3
endif
# Extra libraries to link
SHLIB_LINK := -L$(lib_src)/.libs -l:$(lib_file) -lstdc++

.PHONY: dependencies
dependencies: $(lib_out)

$(OBJS): libnumbertext-$(lib_version)
pg_libnumbertext.so: $(lib_out)

$(lib_out): libnumbertext-$(lib_version)
	cd libnumbertext-$(lib_version) && \
	autoreconf -i && \
	./configure CXXFLAGS=-fPIC && \
	make

libnumbertext-$(lib_version): libnumbertext-$(lib_version).tar.xz
	tar xf $<

.PHONY: extra_clean
clean: extra_clean
extra_clean:
	rm -rf libnumbertext-$(lib_version)

# Load PGXS.
PG_CONFIG := pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

.DEFAULT_GOAL := all