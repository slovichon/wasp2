# $Id$

TESTS+=		OOF-XHTML.t
TESTS+=		Webstr.t

all: test

test:
	. ./env-setup;							\
	for i in ${TESTS}; do						\
		perl -W $$i;						\
	done
