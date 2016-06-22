use Renard::Curie::Setup;
package Renard::Curie::App;

use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';

use Moo 2.001001;

use Renard::Curie::Helper;
use Renard::Curie::Model::Document::PDF;
use Renard::Curie::Component::PageDrawingArea;
use Renard::Curie::Component::MenuBar;
use Renard::Curie::Component::FileChooser;

use Renard::Curie::Types qw(InstanceOf Path Str DocumentModel);
use Function::Parameters;

has window => ( is => 'lazy' );
	method _build_window :ReturnType(InstanceOf['Gtk3::Window']) {
		my $window = $self->builder->get_object('main-window');
	}

has page_document_component => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Component::PageDrawingArea'],
	predicate => 1, # has_page_document_component
	clearer => 1 # clear_page_document_compnent
);
has menu_bar => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Component::MenuBar'],
);

classmethod setup_gtk() {
	# stub out the GDL loading for now. Docking is not yet used.
	##Glib::Object::Introspection->setup(
		##basename => 'Gdl',
		##version => '3',
		##package => 'Gdl', );
}

method setup_window() {
	my $menu = Renard::Curie::Component::MenuBar->new( app => $self );
	$self->menu_bar( $menu );
	$self->builder->get_object('application-vbox')
		->pack_start( $menu, FALSE, TRUE, 0 );
}

method run() {
	$self->window->show_all;
	Gtk3::main;
}

method BUILD {
	$self->setup_gtk;

	$self->setup_window;

	$self->window->signal_connect( destroy => fun ($event, $self) {
		$self->on_application_quit_cb($event);
	}, $self );
	$self->window->set_default_size( 800, 600 );
}

method process_arguments() {
	my $pdf_filename = shift @ARGV;

	if( $pdf_filename ) {
		$self->open_pdf_document( $pdf_filename );
	}
}

fun main() {
	my $self = __PACKAGE__->new;
	$self->process_arguments;
	$self->run;
}

method open_pdf_document( (Path->coercibles) $pdf_filename ) {
	$pdf_filename = Path->coerce( $pdf_filename );
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

method open_document( (DocumentModel) $doc ) {
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
method on_open_file_dialog_cb( $event ) {
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

method on_application_quit_cb( $event ) {
	Gtk3::main_quit;
}
# }}}

with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
