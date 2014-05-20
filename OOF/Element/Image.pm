# $Id$
package OOF::Element::Image;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my ($pkg, $filter, %prefs) = @_;
	$prefs{alt} = "" unless exists $prefs{alt};
	$prefs{svg} = $filter->{url_prefix} . $prefs{svg} if
	    exists $prefs{svg} and $prefs{svg} =~ m!^/!;
	$prefs{src} = $filter->{url_prefix} . $prefs{src} if
	    exists $prefs{src} and $prefs{src} =~ m!^/!;
	return $pkg->SUPER::new($filter, \%prefs);
}

1;
