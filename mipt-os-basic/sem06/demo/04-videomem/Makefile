
export VCPKG_ROOT=$(shell pwd)/vcpkg
export VCPKG_INSTALLED=$(shell pwd)/vcpkg_installed
export CXXFLAGS=-I$(VCPKG_INSTALLED)/$(PLATFORM)/include
export CFLAGS=-I$(VCPKG_INSTALLED)/$(PLATFORM)/include
export LDFLAGS=-L$(VCPKG_INSTALLED)/$(PLATFORM)/lib
export PKG_CONFIG_PATH=$(VCPKG_INSTALLED)/$(PLATFORM)/lib/pkgconfig:$(VCPKG_INSTALLED)/$(PLATFORM)/share/pkgconfig:$PKG_CONFIG_PATH

export VK_LOADER_LAYERS_ENABLE="*validation"

CC_SRC=$(wildcard *.c)

# Осторожно: macOS-specific:
PLATFORM=arm64-osx
FRAMEWORKS=\
	-framework Cocoa \
	-framework IOKit \
	-framework CoreFoundation \
	-Wl,-rpath,$(VCPKG_INSTALLED)/$(PLATFORM)/lib/

.PHONY: run clean

a.out: $(CC_SRC) $(VCPKG_ROOT)/vcpkg-libs
	gcc $(CFLAGS) $(LDFLAGS) $(FRAMEWORKS) -g -lvulkan -lglfw3 -fsanitize=address $(CC_SRC)

run: a.out
	@./a.out; echo Код возврата: $$?

$(VCPKG_ROOT)/vcpkg-libs: $(VCPKG_ROOT)/vcpkg-init.sh
	bash -c ". $(VCPKG_ROOT)/vcpkg-init.sh && $(VCPKG_ROOT)/vcpkg install"
	touch $@

$(VCPKG_ROOT)/vcpkg-init.sh:
	mkdir -p $(VCPKG_ROOT)
	curl https://aka.ms/vcpkg-init.sh -L -o $@

clean:
	rm -rf a.out vcpkg vcpkg_installed