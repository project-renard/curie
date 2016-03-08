package Renard::Curie::App;

use Modern::Perl;

use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';
use File::Spec;
use File::Basename;

use Moo;

use Renard::Curie::Error;
use Renard::Curie::Model::PDFDocument;
use Renard::Curie::Component::PageDrawingArea;

use constant UI_FILE =>
	File::Spec->catfile(dirname(__FILE__), "curie.glade");

has window => ( is => 'lazy' );
	sub _build_window {
		my ($self) = @_;
		my $window = $self->builder->get_object('main_window');
	}

has builder => ( is => 'lazy', clearer => 1 );
	sub _build_builder {
		Gtk3::Builder->new ();
	}

has page_document_component => ( is => 'rw' );

sub setup_gtk {
	Glib::Object::Introspection->setup(
		basename => 'Gdl',
		version => '3',
		package => 'Gdl', );
}

sub setup_window {
	my ($self) = @_;

	$self->builder->add_from_file( UI_FILE );
	$self->builder->connect_signals;
}


sub main {
	setup_gtk;

	my $pdf_filename = shift @ARGV;

	die "No PDF filename given" unless $pdf_filename;

	my $self = __PACKAGE__->new;
	$self->setup_window;

	$self->open_document( $pdf_filename );

	$self->window->signal_connect(destroy => sub { Gtk3::main_quit });
	$self->window->set_default_size( 800, 600 );
	
	$self->window->show_all;

	Gtk3::main;
}

sub open_document {
	my ($self, $pdf_filename) = @_;

	if( not -f $pdf_filename ) {
		Renard::Curie::Error::IO::FileNotFound
			->throw("PDF filename does not exist: $pdf_filename");
	}

	my $doc = Renard::Curie::Model::PDFDocument->new(
		filename => $pdf_filename,
	);

	# set window title
	my $mw = $self->builder->get_object('main_window');
	$mw->set_title( $pdf_filename );
	
	my $pd = Renard::Curie::Component::PageDrawingArea->new(
		builder => $self->builder,
		document => $doc,
	);

	$self->page_document_component($pd);
	$pd->setup;
}


1;
