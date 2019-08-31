# The build configuration (debug or release)
CONFIG := release

lib_version := 1.0.5
lib_soname := 1.0
lib_file := libnumbertext-$(lib_soname).a
lib_src := libnumbertext-$(lib_version)/src
lib_out := $(lib_src)/.libs/$(lib_file)

# Tool paths
PG_CONFIG := pg_config
pg_share_dir = $(shell $(PG_CONFIG) --sharedir)

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

# Extensions of default PGXS rules

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

.PHONY: clean_dependencies
clean: clean_dependencies
clean_dependencies:
	rm -rf libnumbertext-$(lib_version)

.PHONY: install_data
install: install_data
install_data: libnumbertext-$(lib_version)
	mkdir -p $(pg_share_dir)/extension/pg_libnumbertext_data
	chmod 0755 $(pg_share_dir)/extension/pg_libnumbertext_data
	for data_file in $(wildcard libnumbertext-$(lib_version)/data/*.sor); do \
		install -m 0644 $$data_file $(pg_share_dir)/extension/pg_libnumbertext_data; \
	done

# Load PGXS.
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

.DEFAULT_GOAL := all