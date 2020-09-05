define rwildcard
$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
endef
ifeq ($(OS),Windows_NT)
    CLEAR = cls
    LS = dir
    TOUCH =>> 
    RM = del /F /Q
    CPF = copy /y
    RMDIR = -RMDIR /S /Q
    MKDIR = -mkdir
    ERRIGNORE = 2>NUL || (exit 0)
    SEP=\\
else
    CLEAR = clear
    LS = ls
    TOUCH = touch
    CPF = cp -f
    RM = rm -rf 
    RMDIR = rm -rf 
    MKDIR = mkdir -p
    ERRIGNORE = 2>/dev/null
    SEP=/
endif
ifeq ($(findstring cmd.exe,$(SHELL)),cmd.exe)
DEVNUL := NUL
WHICH := where
else
DEVNUL := /dev/null
WHICH := which
endif
null :=
space := ${null} ${null}
PSEP = $(strip $(SEP))
PWD ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
# ${ } is a space
${space} := ${space}
HOST_USER ?= $(shell id -un)
TIME ?= $(shell date '+%Y%m%d-%H:%M:%S')
THIS_FILE := $(lastword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
IMAGES := $(notdir $(patsubst %/,%,$(dir $(wildcard ./*/.))))
.PHONY: $(IMAGES)
.SILENT: $(IMAGES)
.PHONY: images
.SILENT: images
ALL :
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(IMAGES)
images:
	- $(info $(IMAGES))
.PHONY: build
.SILENT: build
$(IMAGES):
	- $(info Building $@)
	- @docker build -t fjolsvin/$@:latest $@
	- @docker push fjolsvin/$@:latest
