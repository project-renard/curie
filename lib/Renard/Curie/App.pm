use Modern::Perl;
package Renard::Curie::App;

use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';
use File::Spec;
use File::Basename;

use Moo;

use Renard::Curie::Error;
use Renard::Curie::Helper;
use Renard::Curie::Model::Document::PDF;
use Renard::Curie::Component::PageDrawingArea;
use Renard::Curie::Component::MenuBar;
use Renard::Curie::Component::FileChooser;

has window => ( is => 'lazy' );
	sub _build_window {
		my ($self) = @_;
		my $window = $self->builder->get_object('main-window');
	}

has page_document_component => ( is => 'rw', predicate => 1, clearer => 1 );
has menu_bar => ( is => 'rw' );

sub setup_gtk {
	# stub out the GDL loading for now. Docking is not yet used.
	##Glib::Object::Introspection->setup(
		##basename => 'Gdl',
		##version => '3',
		##package => 'Gdl', );
}

sub setup_window {
	my ($self) = @_;

	my $menu = Renard::Curie::Component::MenuBar->new( app => $self );
	$self->menu_bar( $menu );
	$self->builder->get_object('application-vbox')
		->pack_start( $menu, FALSE, TRUE, 0 );
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

	$self->window->signal_connect( destroy => sub {
		my ($event, $self) = @_;
		$self->on_application_quit_cb($event);
	}, $self );
	$self->window->set_default_size( 800, 600 );
}

sub process_arguments {
	my ($self) = @_;
	my $pdf_filename = shift @ARGV;
	if( $pdf_filename ) {
		$self->open_pdf_document( $pdf_filename );
	}
}

sub main {
	my $self = __PACKAGE__->new;
	$self->process_arguments;
	$self->run;
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
	$self->window->set_title( $pdf_filename );

	$self->open_document( $doc );
}

sub open_document {
	my ($self, $doc) = @_;

	if( $self->has_page_document_component ) {
		$self->builder->get_object('application-vbox')
			->remove( $self->page_document_component );
		$self->clear_page_document_component;
	}
	my $pd = Renard::Curie::Component::PageDrawingArea->new(
		document => $doc,
	);
	$self->page_document_component($pd);
	$self->builder->get_object('application-vbox')
		->pack_start( $pd, TRUE, TRUE, 0 );
	$pd->show_all;
}

# Callbacks {{{
sub on_open_file_dialog_cb {
	my ($self, $event) = @_;

	my $file_chooser = Renard::Curie::Component::FileChooser->new( app => $self );
	my $dialog = $file_chooser->get_open_file_dialog_with_filters;

	my $result = $dialog->run;

	if ( $result eq 'accept' ) {
		my $filename = $dialog->get_filename;
		$dialog->destroy;
		$self->open_pdf_document($filename);
	} else {
		$dialog->destroy;
	}
}

sub on_application_quit_cb {
	my ($self, $event) = @_;
	Gtk3::main_quit;
}
# }}}

with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
