use Modern::Perl;
package Renard::Curie::App;

use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';
use File::Spec;
use File::Basename;
use Path::Tiny;

use Moo;

use Renard::Curie::Error;
use Renard::Curie::Helper;
use Renard::Curie::Model::PDFDocument;
use Renard::Curie::Component::PageDrawingArea;

use Renard::Curie::Component::ProteinViewer;

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
	my $pdf_filename = shift @ARGV;
	if( $pdf_filename ) {
		$self->open_pdf_document( $pdf_filename );
	} else {
		warn "No PDF filename given";
	}
}

sub main {
	my $self = __PACKAGE__->new;
	$self->process_arguments;
	$self->setup_protein_viewer;
	$self->run;
}

sub open_pdf_document {
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

	$self->open_document( $doc );
}

sub open_document {
	my ($self, $doc) = @_;

	my $pd = Renard::Curie::Component::PageDrawingArea->new(
		builder => $self->builder,
		document => $doc,
	);

	$self->page_document_component($pd);
	$pd->setup;
}

sub setup_protein_viewer {
	use Gtk3::SimpleList;
	my ($self) = @_;
	my $pv_win = Gtk3::Window->new('toplevel');
	$pv_win->set_default_size(640, 480);

	my $box = Gtk3::Box->new( 'horizontal', 0 );

	my $list = Gtk3::ListBox->new( );
	my $slist = Gtk3::SimpleList->new (
                    'Protein name'    => 'text',
                    'PDBD ID'    => 'text',
		    );

	@{$slist->{data}} = (
		[ 'STRUCTURE OF A B-DNA DODECAMER. CONFORMATION AND DYNAMICS', '1BNA', ],
		[ 'THE STEREOCHEMISTRY OF THE PROTEIN MYOGLOBIN', '1MBN' ],
		[ "STRUCTURE OF THE DENGUE VIRUS 2'O METHYLTRANSFERASE", '1r6a' ],
		[ 'CRYSTAL STRUCTURE OF YEAST PHENYLALANINE T-RNA', '6TNA', ],
	);

	my $pv = Renard::Curie::Component::ProteinViewer->new;
	$box->pack_start( $slist, TRUE, TRUE, 0 );
	$box->pack_end( $pv->widget, TRUE, TRUE, 0 );

      $slist->signal_connect (row_activated => sub {
              my ($sl, $path, $column) = @_;
              my $row_ref = $sl->get_row_data_from_path ($path);
	      my $pdb_id = $row_ref->[1];
	      my $pdb_data = path('pv', 'pdbs', "${pdb_id}.pdb")->slurp_utf8;
	      $pv->load_molecule_pdb($pdb_data);
	      use DDP; p $row_ref;
          });

	$pv_win->add( $box );
	$pv_win->show_all;
}


1;
