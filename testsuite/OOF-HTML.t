#!/usr/bin/perl -w
# $Id$

use WASP;
use OOF;
use warnings;
use strict;

my $wasp = WASP->new;
my $oof  = OOF->new(filter=>"XHTML", wasp=>$wasp, prefs=>{});

print $oof->p({align=>"justify"}, "sup");

exit 0;
