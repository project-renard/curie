use Renard::Curie::Setup;
package Renard::Curie::Log::Any::Adapter::LogWindow;
# ABSTRACT: Log::Any adapter that directs messages to the log window component

# These methods are generated for all Log::Any adapters
=for :header
=for Pod::Coverage
alert critical debug emergency error info notice trace warning
is_alert is_critical is_debug is_emergency is_error is_info is_notice is_trace is_warning

=cut

use Moo;

use Renard::Curie::Types qw(InstanceOf);
use Log::Any::Adapter::Util ();

extends 'Log::Any::Adapter::Base';

=attr log_window

Required attribute that links this adapter to the
L<Renard::Curie::Component::LogWindow> where the messages
will appear.

=cut
has log_window => (
	is => 'ro',
	isa => InstanceOf['Renard::Curie::Component::LogWindow'],
	#required => 1,
);

# Create logging methods: debug, info, etc.
foreach my $method ( Log::Any::Adapter::Util::logging_methods() ) {
	no strict 'refs'; ## no critic : we are creating methods
	*$method = sub {
		my $self = shift;
		$self->log_window->log( category => $self->{category}, level => $method, message => $_[0] );
	};
}

# Create detection methods: is_debug, is_info, etc.
foreach my $method ( Log::Any::Adapter::Util::detection_methods() ) {
	no strict 'refs'; ## no critic : we are creating methods
	*$method = sub { 1 };
}

1;
