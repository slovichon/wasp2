# $Id$

=head

=cut

package Timestamp;

use POSIX ();
use Timestamp::Diff;
use strict;
use warnings;

our $VERSION = 0.1;

#use overload
#	'+'	=> \&op_add,
#	'+='	=> \&op_addeq,
#	'-'	=> \&op_sub,
#	'-='	=> \&op_subeq,
#	'<'	=> \&op_lt,
#	'>'	=> \&op_gt,
#	'<='	=> \&op_le,
#	'>='	=> \&op_ge,
#	'=='	=> \&op_eq,
#	'<=>'	=> \&op_cmp,
#	'cmp'	=> \&op_cmp,
#	'""'	=> \&op_str,
#	'='	=> \&op_dup;

sub new {
	my $class = shift;

	# Create new object
	my $this = bless {
		yr	=> undef,
		mon	=> undef,
		day	=> undef,
		hr	=> undef,
		min	=> undef,
		sec	=> undef,
		usec	=> undef,
		tz	=> undef,
	}, ref($class) || $class;

	# Clone from previous object or ref
	if ((ref($class) eq "HASH") or (ref($class) eq __PACKAGE__)) {
		%$this = %$class;
	} elsif (defined($_[0])) {
		# YYYY MM DD HH MM SS (14)
		if ($_[0] =~ /^\d{14}$/) {
			$this->set_string($_[0]);

		# Unix timestamp
		} elsif ($_[0] =~ /^\d+$/) {
			$this->set_unix($_[0]);

		# Verbose form (named keys)
		} elsif (@_ > 1) {
			$this->set(@_);
		}
	} else {
		# Unrecognized; set to current time
		$this->set_now;
	}

	return $this;
}

sub set_string {
	my ($this, $string) = @_;
	return undef unless $string &&
		$string =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/;
	return $this->set(
		year	=> $1,
		month	=> $2,
		day	=> $3,
		hour	=> $4,
		min	=> $5,
		sec	=> $6,
	);
}

sub set_unix {
	my ($this, $ts) = @_;
	return undef unless $ts && $ts =~ /^\d+$/;
	my ($sec, $min, $hr, $day, $mon, $yr) = localtime($ts);
	return $this->set(
		sec	=> $sec,
		min	=> $min,
		hr	=> $hr,
		day	=> $day,
		mon	=> $mon + 1,
		yr	=> $yr + 1900,
	);
}

sub set_now {
	my $this = shift;
#	$this->{tz}  = POSIX::strftime("%Z", localtime(time()));
	return $this->set_unix(time());
}

sub set {
	my ($this, %parts) = @_;

	my %aliases = (
		usecs		=> "usec",	ms		=> "usec",
		millisec	=> "usec",	millisecs	=> "usec",
		milliseconds	=> "usec",
		secs		=> "sec",	second		=> "sec",
		seconds		=> "sec",
		mins		=> "min",	minute		=> "min",
		minutes		=> "min",
		hrs		=> "hr",	hours		=> "hr",
		hour		=> "hr",
		days		=> "day",
		month		=> "mon",	months		=> "mon",
		yrs		=> "yr",	years		=> "yr",
		year		=> "yr",
		timezone	=> "tz",
	);

	# Expand aliases
	my ($k, $v);
	while (($k, $v) = each(%aliases)) {
		if (exists $parts{$k}) {
			$parts{$v} = $parts{$k};
			delete $parts{$k};
		}
	}

	#$this->{$_} = $parts{$_} foreach qw(usec sec min hr mon day yr tz);
	#%$this = %parts;
	$this->{usec} = $parts{usec}	if exists $parts{usec};
	$this->{sec}  = $parts{sec}	if exists $parts{sec};
	$this->{min}  = $parts{min}	if exists $parts{min};
	$this->{hr}   = $parts{hr}	if exists $parts{hr};
	$this->{day}  = $parts{day}	if exists $parts{day};
	$this->{mon}  = $parts{mon}	if exists $parts{mon};
	$this->{yr}   = $parts{yr}	if exists $parts{yr};
	# Do previous timezone offset conversion?
	$this->{tz}   = $parts{tz}	if exists $parts{tz};

	$this->_fix();

	return $this;
}

sub _fix {
	my $this = shift;
	my $days;

	$this->{min} += int($this->{sec}/60);
	$this->{min}-- if $this->{sec} < 0;
	$this->{sec} %= 60;

	$this->{hr} += int($this->{min}/60);
	$this->{hr}-- if $this->{min} < 0;
	$this->{min} %= 60;

	$this->{day} += int($this->{hr}/24);
	$this->{day}-- if $this->{hr} < 0;
	$this->{hr} %= 24;

	$this->{yr} += int($this->{mon}/12);
	$this->{yr}-- if $this->{mon} < 0;
	$this->{mon} %= 12;

	if ($this->{day} < 0) {
=comment
		$days = $this->days_in_month(($this->{mon}-1)%12, $this->{yr});

		while ($this->{day} < 0) {
			$this->{mon}-- if $this->{day} > $days;
			$this->{day} += $days;
	
			$this->{yr} += int($this->{mon}/12);
			$this->{yr}-- if $this->{mon} < 0;
			$this->{mon} %= 12;
	
			$days = $this->days_in_month($this->{mon}, $this->{yr});
		}
=cut
	} else {
		$days = $this->days_in_month($this->{mon}, $this->{yr});

		while ($this->{day} > $days) {
			$this->{mon}++ if $this->{day} > $days;
			$this->{day} -= $days;
	
			$this->{yr} += int($this->{mon}/12);
			$this->{yr}-- if $this->{mon} < 0;
			$this->{mon} %= 12;
	
			$days = $this->days_in_month($this->{mon}, $this->{yr});
		}
	}

	$this->{yr} += int($this->{mon}/12);
	$this->{yr}-- if $this->{mon} < 0;
	$this->{mon} %= 12;
}

sub days_in_month {
	my ($this, $m, $y) = @_;
	my ($days, $isleap);
	$isleap = $this->is_leap_year($y) ? 1 : 0;
	return (
		[0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
		[0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
	)[$isleap]->[$m];
}

sub is_leap_year {
	my ($this, $y) = @_;
	return (($y % 100 != 0) && ($y % 4 == 0)) || ($y % 400 == 0);
}

sub format {
	my ($this, $fmt) = @_;

	$fmt = "%F %r" unless $fmt;

	return POSIX::strftime($fmt,
		$this->sec, $this->min, $this->hr,
		$this->day, $this->mon-1, $this->yr-1900);
}

# Accessors
sub usec {
	my ($this, $usec) = @_;
	if (@_ == 2) {
		$usec = 0 unless $usec && $usec =~ /^\d+$/;
		$this->{usec} = $usec;
		$this->_fix;
	}
	return $this->{usec};
}

sub sec	{
	my ($this, $sec) = @_;
	if (@_ == 2) {
		$sec = 0 unless $sec && $sec =~ /^\d+$/;
		$this->{sec} = $sec;
		$this->_fix;
	}
	return $this->{sec};
}

sub min {
	my ($this, $min) = @_;
	if (@_ == 2) {
		$min = 0 unless $min && $min =~ /^\d+$/;
		$this->{min} = $min;
		$this->_fix;
	}
	return $this->{min};
}

sub hr {
	my ($this, $hr) = @_;
	if (@_ == 2) {
		$hr = 0 unless $hr && $hr =~ /^\d+$/;
		$this->{hr} = $hr;
		$this->_fix;
	}
	return $this->{hr};
}

sub day	{
	my ($this, $day) = @_;
	if (@_ == 2) {
		$day = 0 unless $day && $day =~ /^\d+$/;
		$this->{day} = $day;
		$this->_fix;
	}
	return $this->{day};
}

sub mon {
	my ($this, $mon) = @_;
	if (@_ == 2) {
		$mon = 0 unless $mon && $mon =~ /^\d+$/;
		$this->{mon} = $mon;
		$this->_fix;
	}
	return $this->{mon};
}

sub yr {
	my ($this, $yr) = @_;
	if (@_ == 2) {
		$yr = 0 unless $yr && $yr =~ /^\d+$/;
		$this->{yr} = $yr;
		$this->_fix;
	}
	return $this->{yr};
}

sub tz {
	my ($this, $tz) = @_;
	if (@_ == 2) {
		$this->{tz} = $tz if $this->valid_timezone($tz);
		# We should probably call _fix() and have it
		# do timezone adjustment.
#		$this->_fix;
	}
	return $this->{tz};
}

# Aliases
sub usecs; 	sub ms;			sub millisec;
sub millisecs; 	sub milliseconds;	sub secs;
sub second;	sub seconds;		sub mins;
sub minute;	sub minutes;		sub hrs;
sub hour;	sub hours;		sub days;
sub month;	sub months;		sub yrs;
sub years;	sub year;		sub timezone;

*usecs		= \&usec;
*ms		= \&usec;
*millisec	= \&usec;
*millisecs	= \&usec;
*milliseconds 	= \&usec;
*secs		= \&sec;
*second		= \&sec;
*seconds	= \&sec;
*mins		= \&min;
*minute		= \&min;
*minutes	= \&min;
*hrs		= \&hr;
*hour		= \&hr;
*hours		= \&hr;
*days		= \&day;
*month		= \&mon;
*months		= \&mon;
*yrs		= \&yr;
*years		= \&yr;
*year	 	= \&yr;
*timezone	= \&tz;

sub set_current;

*set_current 	= \&set_now;

sub get_string {
	my $this = shift;

	return sprintf("%04d" . "%02d" x 5,
			$this->yr, $this->mon, $this->day,
			$this->hr, $this->min, $this->sec);
}

sub get_unix {
	my $this = shift;

	return POSIX::mktime(
		$this->sec, $this->min, $this->hr,
		$this->day, $this->mon-1, $this->yr-1900);
}

=comment
my $ts = Timestamp->new(sec=>4, min=>6, ...);
$ts += Timestamp::Diff->new(day=>1);
=cut

=comment
	sub op_add {
		my ($obj,$arg) = @_;

		if (ref($arg) eq ref($obj))
		{
			$obj->{$_} += $arg->{$_} foreach (@_fields);
		} else {
			# Else treat it as seconds
			$obj->{second} += $arg;
		}

		return;
	}

	sub op_addeq {
	}

	sub op_lt {
		my ($obj,$arg)	= @_;
		my $op		= $obj->new($arg);

		foreach (@_fields)
		{
			return $obj->$_ - $op->$_ < 0 ? 1 : 0 if $obj->$_ - $op->$_;
		}

		# Must be equal, so $obj is not less than $op
		return 0;
	}

	sub op_le {
		return &less_than or &eq;
	}

	sub op_eq {
		my ($obj,$arg)	= @_;
		my $op		= $obj->new($arg);
		my $ret		= 0;

		# Tally up how many are the same
		foreach (@_fields) {
			$ret .= $obj->$_ == $op->$_ ? 1 : 0;
		}

		# They're equal if all are the same
		return $ret == @_fields;
	}

	sub op_gt {
		my ($obj,$arg) = @_;

		return $arg->less_than($obj);
	}

	sub op_ge {
		return &greater_than or &eq;
	}
}

=cut

1;
