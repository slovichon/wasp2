# $Id$

=head1 NAME

WASP - Web Application Structure for Perl programs

=head1 SYNOPSIS

 use WASP;

 my $wasp = WASP->new;

 # Behaviorial methods
 $wasp->die_on_errors([$bool]);
 $wasp->display_errors([$bool]);
 $wasp->log_errors($file);
 $wasp->handle_errors($sub);

 # Accessor methods
 $wasp->will_die_on_errors;
 $wasp->will_display_errors;
 $wasp->will_log;
 $wasp->error_log;
 $wasp->will_handle;
 $wasp->error_handler;
 $wasp->has_module($mod);

 # Action methods
 $wasp->throw($errmsg);

=head1 DESCRIPTION

WASP is a means to provide structure for Web applications.
The core module mostly provides error-handling routines, but is intended,
if all components of a Web application system use it, to provide a consistent
set of behaviors which are all robust, are easy to set up and execute,
and are clean, concise, and predictable.

=head2 Administrators

Administrators of WASP-obeying Web applications may wish to refine the behavior
of WASP actions, so that when something fails in the application, the administrator
may rest at ease knowing the application will behave as he or she has configured it
to do so.
In this case, an administrator will only care about the behaviorial methods and
perhaps the accessor methods, to set and retrieve the behaviorial semantics of WASP.

=head2 Programmers

Programmers using WASP, most likely for adding consistency in his or her Web
application, will only need to know of the core action methods.
The behaviorial and accessor methods are only for refining what exactly happens
when a core action is to be executed and a programmer need not know these exact
details.

=cut
package WASP;

our $VERSION = 0.2;

use strict;
use warnings;

=head1 ROUTINES

=over

=item my $wasp = WASP-E<gt>new;

Create a new WASP instance.

=cut
sub new {
	my $pkg = shift;
	return bless {
			die_on_errors	=> 1,
			display_errors	=> 0,
			error_log	=> undef,
			error_handler	=> undef,
		}, ref $pkg || $pkg;
}

=item $wasp-E<gt>die_on_errors([$bool]);

This behaviorial method affects the invocation of Perl's C<die> on error.
If no value is given, calling this method will turn the calling of Perl's
C<die> on.
Otherwise, the value of the Boolean argument will determine whether or not
to invoke Perl's C<die> on error.

=cut
sub die_on_errors {
	$_[0]->{die_on_errors} = !(defined $_[1] xor $_[1]);
}

=item $wasp-E<gt>will_die_on_errors;

This accessor method is used to determine if Perl's C<die> will be invoked
if an error is raised.

=cut
sub will_die_on_errors {
	return $_[0]->{die_on_errors};
}

=item $wasp-E<gt>display_errors([$bool]);

This behaviorial method affects the printing of error messages to standard
output on error.
In no value is given, calling this method will turn the displaying of error
messages on.
Otherwise, the value of the Boolean argument will determine whether or not
to print error messages on error.

=cut
sub display_errors {
	$_[0]->{display_errors} = !(defined $_[1] xor $_[1]);
}

=item $wasp-E<gt>will_display_errors;

This accessor method is used to determine if error messages will be
printed to standard output if an error is raised.

=cut
sub will_display_errors {
	return $_[0]->{display_errors};
}

=item $wasp-E<gt>log_errors($file);

This behaviorial method affects the logging of error messages on error.
The argued file will attempt to be opened in append mode and an
error message, in the form below, will attempt to be placed at the end
of the log file.

S<Cannot do something; detail1: description1; detail2: description2; detailN: ...>

Note that if an error arises and the error log file cannot be written to, logging
will simply be ignored (as opposed to, say an infinite loop of handling an
error and generating an error because of the inability to log the first error).

Calling this method with an undefined argument will effectively disable error
message logging.

=cut
sub log_errors {
	$_[0]->{error_log} = $_[1];
}

=item $wasp-E<gt>will_log;

This accessor method is used to determine if error messages will attempt to be
logged if an error is raised.

Perhaps this method should be named E<quot>will_try_to_log.E<quot>
But it isn't, for hopefully obvious reasons.

=cut
sub will_log {
	return defined $_[0]->{error_log};
}

=item $wasp-E<gt>error_log;

This accessor method is used to determine to which file error messages will be
attempted to be written if an error is raised.

=cut
sub error_log {
	return $_[0]->{error_log};
}

=item $wasp-E<gt>handle_errors($sub);

This behaviorial method affects the delegation of error-handling to other
user-defined routines on error.
An anonymous subroutine or subroutine reference may be given as an argument
whose instructions will be processed on error.

=cut
sub handle_errors {
	$_[0]->{error_handler} = $_[1];
}

=item $wasp-E<gt>will_handle;

This accessor method is used to determine whether or not a delegated
error-handling routine is to be used if an error is raised.

=cut
sub will_handle {
	return defined $_[0]->{error_handler};
}

=item $wasp-E<gt>error_handler;

This accessor method is used to determine the delegated error-handling routine
that will be invoked if an error is raised.  It will return either a reference
to an anonymous or named subroutine, or C<undef>, if no such delegate ever
specified.

=cut
sub error_handler {
	return $_[0]->{error_handler};
}

=item $wasp-E<gt>has_module($mod);

This accessor method can be used to determine if the given Perl module exists and
can be loaded.
It will not load the module, but instead return the full path to the module in
question if it can be found in the include path or an C<undef> value.

=cut
sub has_module {
	# XXX: portable across different operating systems
	(my $file = "$_[1].pm") =~ s!::!/!g;
	foreach my $path (@INC) {
		return "$path/$file" if -f "$path/$file";
	}
	return undef;
}

=item $wasp-E<gt>throw($errmsg);

This action method performs an exception raise.
The actual semantics of what will happen can be heavily modified by the available
error-handling behaviorial methods.
By default C<throw> will try to append to the given error message information such
as the operating system error message (e.g., as the result of failed I/O or a
filesystem problem).
It will also attempt to trace back through all subroutine calls to find the origin
of the problem (in most cases going too far to provide useful information) and when
the error report was generated.

If logging is enabled (see C<log_errors>), the error message will then attempt to be
written to the log file.
If the logging request cannot be fulfilled, additional error information related to
the failed logging attempt is appended to the error message and further logging
action is ignored.

Next, errors are displayed to standard output (see C<display_errors>) if configuration
specifies that they should.

Next, if error-handling delegation has been requested (see C<handle_errors>), the error
message is passed as the first and only argument to the delegated subroutine in place
of the current subroutine call, effectively removing traces that the WASP error-handling
subroutine was ever invoked.

Lastly, Perl's C<die> function will be invoked with the error message if the WASP
instance has been configured to do so.

=cut
sub throw {
	my $this = shift;
	my ($modpkg, undef, $modline) = caller;
	my ($pkg, $file, $line);
	# Backtrace to origin
	my $i = 0;
	do {
		($pkg, $file, $line) = caller($i);
		$i++;
	} while (defined $pkg && $pkg ne "main");
	# See if we went too far
	($pkg, $file, $line) = caller(--$i) unless defined $pkg;
	my $errmsg = "WASP error: " . (@_ ? join '', @_ : "(not specified)");
	# Append module information (if it's a module)
	unless ($modpkg eq "main") {
		$errmsg .= "; module: $modpkg:$modline";
	}
	# Append other useful information
	$errmsg .= "; OS error: $!" if $!;
	$errmsg .= "; Backtrace: $file:$line" .
		   "; Date: " . localtime(time()) . "\n";
	# Log
	if ($this->{error_log}) {
		local *LOG;
		if (open(LOG, ">>", $this->{error_log})) {
			print LOG $errmsg;
			close LOG;
		} else {
			$errmsg .= "Could not log error" .
				   "; file: " . $this->{error_log} .
				   "; OS Error: $!\n";
		}
	}
	# Display
	print $errmsg if $this->{display_errors};
	if ($this->{error_handler}) {
		@_ = ($errmsg);
		goto &{ $this->{error_handler} };
	}
	CORE::die($errmsg) if $this->{die_on_errors};
}

=back

=head1 BUGS

Because at the current time, so much of WASP is related to error-handling, some
part of the code should be organized into a C<WASP::Error> module, whereas WASP
should concentrate on core application functionality.

=head1 AUTHOR

Jared Yanovich E<lt>jaredy@closeedge.netE<gt>

=cut

1;
