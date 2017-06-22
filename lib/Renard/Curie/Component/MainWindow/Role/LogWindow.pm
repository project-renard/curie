use Renard::Curie::Setup;
package Renard::Curie::Component::MainWindow::Role::LogWindow;
# ABSTRACT: Role for log window

use Moo::Role;

use Renard::Curie::Component::LogWindow;
use Renard::Curie::Types qw(InstanceOf);

use Log::Any::Adapter;


=attr log_window

A L<Renard::Curie::Component::LogWindow> for the application's logging.

=cut
has log_window => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Component::LogWindow'],
);

after setup_window => method() {
	my $log_win = Renard::Curie::Component::LogWindow->new( app => $self );
	Log::Any::Adapter->set('+Renard::Curie::Log::Any::Adapter::LogWindow',
		log_window => $log_win );
	$self->log_window( $log_win );
};

1;
