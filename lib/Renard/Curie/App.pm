use Renard::Incunabula::Common::Setup;
package Renard::Curie::App;
# ABSTRACT: A document viewing application

use Moo 2.001001;

use Renard::Incunabula::Frontend::Gtk3::Helper;

use File::Spec;
use File::Basename;
use Module::Util qw(:all);
use Renard::Incunabula::Common::Types qw(InstanceOf Str);
use Renard::Incunabula::Document::Types qw(DocumentModel);
use Getopt::Long::Descriptive;

use MooX::Role::Logger ();

use Renard::Curie::Component::MainWindow;
use Renard::Curie::ViewModel::ViewManager;

=attr main_window

The toplevel L<Renard::Curie::Component::MainWindow> component for this application.

=cut
has main_window => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Component::MainWindow'],
);

=attr view_manager

The view manager model for this application.

=cut
has view_manager => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::ViewModel::ViewManager'],
);

=method process_arguments

  method process_arguments()

Processes arguments given in C<@ARGV>.

=cut
method process_arguments() {
	my ($opt, $usage) = describe_options(
		"%c %o <filename>",
		[ 'version',        "print version and exit"                             ],
		[ 'short-version',  "print just the version number (if exists) and exit" ],
		[ 'help',           "print usage message and exit"                       ],
	);

	print($usage->text), exit if $opt->help;

	if($opt->version) {
		say("Project Renard Curie @{[ _get_version() ]}");
		say("Distributed under the same terms as Perl 5.");
		exit;
	}

	if($opt->short_version) {
		say(_get_version()), exit
	}

	my $pdf_filename = shift @ARGV;

	if( $pdf_filename ) {
		$self->_logger->infof("opening the file %s", $pdf_filename);
		$self->view_manager->open_pdf_document( $pdf_filename );
	}
}

=func main

  fun main()

Application entry point.

=cut
method main() {
	$self = __PACKAGE__->new unless ref $self;
	$self->process_arguments;
	$self->main_window->show_all;
	$self->run;
}

=method run

  method run()

Displays L</window> and starts the L<Gtk3> event loop.

=cut
method run() {
	$self->_logger->info("starting the Gtk main event loop");
	Gtk3::main;
}

=func _get_version

  fun _get_version() :ReturnType(Str)

Returns the version of the application if there is one.
Otherwise returns the C<Str> C<'dev'> to indicate that this is a
development version.

=cut
fun _get_version() :ReturnType(Str) {
	return $Renard::Curie::App::VERSION // 'dev'
}

with qw(
	MooX::Role::Logger
);

1;
