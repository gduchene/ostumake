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

_FNDFLAGS=	. $(_MAXDEPTH) -type f -regex $(_PAT) $(_EXL)

ifdef NOSUBDIR
_MAXDEPTH=	-maxdepth 1
endif

ifdef EXCL
_EXL=		$(foreach e,$(EXCL),-not -regex '.*$e.*')
endif

MENHIR?=	menhir
OCAMLDEP?=	ocamldep
OCAMLLEX?=	ocamllex

.DEFAULT_GOAL:=	obj

_DEP=		$(foreach e,$(_SRC),$(dir $e)$(patsubst %.ml,.%.d,$(notdir $e)))
_FND=		find
_PAT=		'.*ml[ily]*'
_SRC=		$(shell $(_FND) $(_FNDFLAGS))
_ORD=		$(CSRC) $(shell $(OCAMLDEP) $(_INC) -sort $(_SRC))
_INC=		$(foreach e,$(sort $(foreach e,$(_SRC),$(dir $e))),-I '$e')

ifdef CSRC
ifndef OCAMLNATIVE
OCAMLFLAGS+=	-custom
endif
endif

ifndef OCAMLC
ifdef OCAMLNATIVE
OCAMLC=		ocamlfind ocamlopt
else
OCAMLC=		ocamlfind ocamlc
endif
endif

ifdef PKG
OCAMLFLAGS+=	-linkpkg -package '$(PKG)'
endif

OCAMLFLAGS+=	$(DEBUG)

ifndef NOSUBDIR
OCAMLFLAGS+=	$(_INC)
endif

_OBJ=		$(patsubst %.c,%.o,$(filter %.c,$(_ORD)))

ifdef OCAMLNATIVE
_OBJ+=		$(patsubst %.ml,%.cmx,$(filter %.ml,$(_ORD)))
_CLN+=		$(patsubst %.cmx,%.o,$(filter %.cmx,$(_OBJ)))
_CLN+=		$(patsubst %.cmx,%.cmi,$(filter %.cmx,$(_OBJ)))
else
_OBJ+=		$(patsubst %.ml,%.cmo,$(filter %.ml,$(_ORD)))
_CLN+=		$(patsubst %.cmo,%.cmi,$(filter %.cmo,$(_OBJ)))
endif

_INT=		$(patsubst %.mly,%.ml,$(filter %.mly,$(_SRC)))
_INT+=		$(patsubst %.mll,%.ml,$(filter %.mll,$(_SRC)))
_CLN+=		$(patsubst %.ml,%.mli,$(_INT))

-include $(_DEP)

.%.d:		%.ml
	$(OCAMLDEP) $(_INC) $< > $@

all:		$(_OBJ)

clean:
	$(RM) $(_CLN) $(_INT) $(_OBJ) $(PROG)

dep:		$(_DEP)

dist-clean:	clean
	$(RM) $(_DEP)

obj:		$(_OBJ)

.PHONY:		dep

ifndef OSTUMAKE_DEBUG
.SILENT:	$(_DEP)
endif

.SUFFIXES:
