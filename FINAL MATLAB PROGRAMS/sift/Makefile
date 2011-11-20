# file:        Makefile
# author:      Andrea Vedaldi
# description: Build SIFT mex files

DIST=sift
VER=0.9.12

# --------------------------------------------------------------------
#                                                       Error messages
# --------------------------------------------------------------------

err_no_arch  =
err_no_arch +=$(shell echo "** Unknown host architecture '$(UNAME)'. This identifier"   1>&2)
err_no_arch +=$(shell echo "** was obtained by running 'uname -sm'. Edit the Makefile " 1>&2)
err_no_arch +=$(shell echo "** to add the appropriate configuration."                   1>&2)
err_no_arch +=Configuration failed

# --------------------------------------------------------------------
#                                                        Configuration
# --------------------------------------------------------------------

CFLAGS           += -I. -pedantic -Wall -g -O3
CFLAGS           += -Wno-variadic-macros
LDFLAGS          +=
MEX_CFLAGS        = CFLAGS='$$CFLAGS $(CFLAGS)'

# Determine on the flight the system we are running on
Darwin_PPC_ARCH    := mac
Darwin_i386_ARCH   := mci
Linux_i386_ARCH    := glx
Linux_i686_ARCH    := glx
Linux_x86_64_ARCH  := g64
Linux_unknown_ARCH := glx

UNAME             := $(shell uname -sm)
ARCH              := $($(shell echo "$(UNAME)" | tr \  _)_ARCH)

mac_CFLAGS       := -faltivec
mac_MEX_CFLAGS   := 
mac_MEX_SUFFIX   := mexmac

mci_CFLAGS       :=
mci_MEX_CFLAGS   :=
mci_MEX_SUFFIX   := mexmaci

glx_CFLAGS       :=
glx_MEX_CFLAGS   :=
glx_MEX_SUFFIX   := mexglx

g64_CFLAGS       :=
g64_MEX_CFLAGS   :=
g64_MEX_SUFFIX   := mexa64

CFLAGS           += $($(ARCH)_CFLAGS)
MEX_SUFFIX       := $($(ARCH)_MEX_SUFFIX)
MEX_CFLAGS       += $($(ARCH)_MEX_CFLAGS)
BINDIST          := $(DIST)-$(VER)-bin

ifeq ($(ARCH),)
die:=$(error $(err_no_arch))
endif

# --------------------------------------------------------------------
#
# --------------------------------------------------------------------

src :=\
imsmooth.c \
siftlocalmax.c \
siftrefinemx.c \
siftormx.c \
siftdescriptor.c \
siftmatch.c

%.$(MEX_SUFFIX) : %.c
	mex -I. $(MEX_CFLAGS) $< -o $*

tgt = $(src:.c=.$(MEX_SUFFIX))

.PHONY: all
all: $(tgt)

# PDF documentation
.PHONY: doc
doc: doc/sift.pdf doc/index.html doc/default.css

doc/index.html : $(wildcard *.m)
	mdoc --output=$@ . -x extra

doc/default.css : sift_gendoc.css
	ln -s ../sift_gendoc.css doc/default.css	

doc/sift.pdf : doc/*.tex doc/*.bib doc/figures/*
	cd doc ; \
	for k in 1 2 3 ; \
	do \
	  pdflatex -file-line-error-style -interaction batchmode \
	    sift.tex ; \
	  if test "$$k" = '1' ; \
	  then \
	    bibtex sift.aux ; \
	  fi ; \
	done

.PHONY: clean
clean:
	rm -f $(tgt)
	rm -f doc/*.log
	rm -f doc/*.aux
	rm -f doc/*.toc
	rm -f doc/*.blg
	rm -f doc/*.out

.PHONY: distclean
distclean: clean
	rm -f *.mexmac *.mexglx *.mexmaci *.dll
	rm -f $(DIST)-*.zip
	rm -rf $(BINDIST)
	rm -f `find . -name '.DS_Store'`
	rm -f `find . -name '*~'`
	rm -f doc/sift.pdf doc/index.html doc/default.css

.PHONY: zip
zip: dist

.PHONY: dist
dist: distclean
	echo Version $(VER) >TIMESTAMP
	echo Archive created on `date` >>TIMESTAMP
	echo On `uname -a` >>TIMESTAMP
	cd .. ; zip -q -r sift/$(DIST)-$(VER).zip sift -x "sift/.git/*"

.PHONY: bindist
bindist: all
	test -e $(BINDIST) || mkdir $(BINDIST)
	cp *.mex* *.dll $(BINDIST)
	cd $(BINDIST) ; strip -S *.$(MEX_SUFFIX)
	zip -qr $(BINDIST).zip $(BINDIST)
