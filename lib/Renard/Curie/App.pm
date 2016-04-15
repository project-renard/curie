use Modern::Perl;
package Renard::Curie::App;

use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';
use File::Spec;
use File::Basename;

use Moo;
use URI::file;

use Renard::Curie::Error;
use Renard::Curie::Helper;
use Renard::Curie::Model::Document::PDF;
use Renard::Curie::Component::PageDrawingArea;
use Renard::Curie::Component::AbiWordDocumentEditor;

use constant UI_FILE =>
	File::Spec->catfile(dirname(__FILE__), "curie.glade");

has window => ( is => 'lazy' );
	sub _build_window {
		my ($self) = @_;
		my $window = $self->builder->get_object('main-window');
	}

has builder => ( is => 'lazy', clearer => 1 );
	sub _build_builder {
		Gtk3::Builder->new ();
	}

has page_document_component => ( is => 'rw' );

sub setup_gtk {
	# stub out the GDL loading for now. Docking is not yet used.
	##Glib::Object::Introspection->setup(
		##basename => 'Gdl',
		##version => '3',
		##package => 'Gdl', );
}

sub setup_window {
	my ($self) = @_;

	$self->builder->add_from_file( UI_FILE );
	$self->builder->connect_signals;
}

sub run {
	my ($self) = @_;
	$self->window->show_all;
	Gtk3::main;
}

sub BUILD {
	my ($self) = @_;
	setup_gtk;

	$self->setup_window;

	$self->window->signal_connect(destroy => sub { Gtk3::main_quit });
	$self->window->set_default_size( 800, 600 );
}

sub process_arguments {
	my ($self) = @_;
	my $filename = shift @ARGV;
	if( $filename ) {
		$self->open_filename_by_ext( $filename );
	} else {
		warn "No filename given";
	}
}

sub main {
	my $self = __PACKAGE__->new;
	$self->process_arguments;
	$self->run;
}

sub open_filename_by_ext {
	my ($self, $filename ) = @_;
	if( $filename =~ /\.pdf$/i ) {
		$self->open_pdf_document( $filename );
	} elsif ( $filename =~ /\.(rtf|odt|doc[x]?)$/i ) {
		$self->open_word_processor_document( $filename );
	}
}

sub open_pdf_document {
	my ($self, $pdf_filename) = @_;

	if( not -f $pdf_filename ) {
		Renard::Curie::Error::IO::FileNotFound
			->throw("PDF filename does not exist: $pdf_filename");
	}

	my $doc = Renard::Curie::Model::Document::PDF->new(
		filename => $pdf_filename,
	);

	# set window title
	my $mw = $self->builder->get_object('main-window');
	$mw->set_title( $pdf_filename );

	$self->open_document( $doc );
}

sub open_word_processor_document {
	my ($self, $filename) = @_;
	my $abi = AbiWord::Widget->new;
	$self->builder->get_object('application_vbox')->pack_start( $abi , TRUE, TRUE, 0 );
	my $uri = URI::file->new_abs( $filename );
	$abi->load_file( "$uri" , '' );
}

sub open_document {
	my ($self, $doc) = @_;

	my $pd = Renard::Curie::Component::PageDrawingArea->new(
		document => $doc,
	);

	$self->page_document_component($pd);
	$self->builder->get_object('application-vbox')
		->pack_start( $pd, TRUE, TRUE, 0 );
}


1;
