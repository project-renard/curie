use Renard::Curie::Setup;
package Renard::Curie::App;
# ABSTRACT: A document viewing application

use Moo 2.001001;

use Renard::Curie::Helper;

extends q(Renard::Curie::Component::MainWindow);

use File::Spec;
use File::Basename;
use Module::Util qw(:all);
use Renard::Curie::Types qw(InstanceOf Path Str DocumentModel File);
use Getopt::Long::Descriptive;

=for Pod::Coverage ui_file

=cut
has ui_file => (
	is => 'ro',
	isa => File,
	coerce => 1,
	default => sub {
		my $module_name = 'Renard::Curie::Component::MainWindow';
		my $package_last_component = (split(/::/, $module_name))[-1];
		my $module_file = find_installed($module_name);
		File::Spec->catfile(dirname($module_file), "@{[ $package_last_component ]}.glade")
	},
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
		$self->open_pdf_document( $pdf_filename );
	}
}

=func main

  fun main()

Application entry point.

=cut
method main() {
	$self = __PACKAGE__->new unless ref $self;
	$self->process_arguments;
	$self->show_all;
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

1;
