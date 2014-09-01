# Copyright (c) 2014, Grégoire Duchêne <gduchene@awhk.org>
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all
# copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
# PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

include $(dir $(lastword $(MAKEFILE_LIST)))gnu.ocaml.rules.mk

ifndef OCAMLC
ifdef OCAMLNATIVE
OCAMLC=		ocamlfind ocamlopt
else
OCAMLC=		ocamlfind ocamlc
endif
endif

ifdef PKG
OCAMLFLAGS+=	-linkpkg -package "$(PKG)"
endif

OCAMLFLAGS+=	$(DEBUG)

ifndef PROG
PROG=		a.out
endif

all: ${PROG}

SRC+=		$(CSRC)

ifndef DEPFILE
DEPFILE=	.Makefile.dep
endif

-include $(DEPFILE)

ifdef CSRC
ifndef OCAMLNATIVE
OCAMLFLAGS+=	-custom
endif
endif

OBJ+=		$(patsubst %.c, %.o, $(filter %.c, $(SRC)))

ifdef OCAMLNATIVE
OBJ+=		$(patsubst %.ml, %.cmx, $(filter %.ml, $(SRC)))
CLEAN+=		$(patsubst %.cmx, %.o, $(OBJ))
CLEAN+=		$(patsubst %.cmx, %.cmi, $(OBJ))
else
OBJ+=		$(patsubst %.ml, %.cmo, $(filter %.ml, $(SRC)))
CLEAN+=		$(patsubst %.cmo, %.cmi, $(OBJ))
endif

$(PROG): $(OBJ)
	$(OCAMLC) $(OCAMLFLAGS) -o $@ $^
clean:
	$(RM) $(CLEAN) $(OBJ) $(PROG)
dep:
	printf "SRC+=\t%s\n" `ocamldep -sort *.ml` > $(DEPFILE)
	printf "\n%s\n" "`ocamldep *.mli *.ml`" >> $(DEPFILE)

.DEFAULT_GOAL:=	$(PROG)
.SUFFIXES:
