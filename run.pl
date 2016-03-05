#!/usr/bin/env perl

package App::Curie;

use v5.016;

use Capture::Tiny qw(capture_stdout);
use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';

use Moo;

use constant UI_FILE => "curie.glade";

has [qw{ pdf_filename }] => ( is => 'rw', trigger => 1 );

has pdf_current_page => ( is => 'rw', trigger => 1 );

has [qw(pdf_first_page pdf_last_page)] => ( is => 'rw' );
has [qw(pdf_current_page_width pdf_current_page_height)] => ( is => 'rw' );

has [qw(drawing_area)] => ( is => 'rw' );

has window => ( is => 'lazy' );
	sub _build_window {
		my ($self) = @_;
		my $window = $self->builder->get_object('main_window');
	}

has builder => ( is => 'lazy', clearer => 1 );
	sub _build_builder {
		Gtk3::Builder->new ();
	}

sub gval ($$) { Glib::Object::Introspection::GValueWrapper->new('Glib::'.ucfirst($_[0]) => $_[1]) } # GValue wrapper shortcut
sub genum { Glib::Object::Introspection->convert_sv_to_enum($_[0], $_[1]) }

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

	$self->setup_button_events;
	$self->setup_text_entry_events;
	$self->setup_drawing_area_example;

	$self->setup_window_title;
}

sub setup_window_title {
	my ($self) = @_;
	my $mw = $self->builder->get_object('main_window');
	$mw->set_title( $self->pdf_filename ) if defined $self->pdf_filename;
}

sub mudraw_get_image_surface_of_pdf_page_as_png {
	my ($pdf_filename, $pdf_page_no) = @_;

	my $png_filename = 'test.png';
	system("mudraw",
		qw( -F png ),
		qw( -o), $png_filename,
		$pdf_filename,
		$pdf_page_no,
	);

	my $img = Cairo::ImageSurface->create_from_png( $png_filename );
}

sub get_pdfinfo_for_filename {
	my ($pdf_filename) = @_;

	my ($stdout, $exit) = capture_stdout {
		system("pdfinfo", $pdf_filename);
	};

	my %info = $stdout =~ /
			(?<key> [^:]*? )
			:\s*
			(?<value> .* )
			\n
		/xmg;

	return \%info;
}

sub _trigger_pdf_filename {
	my ($self) = @_;

	my $info = get_pdfinfo_for_filename( $self->pdf_filename );

	$self->pdf_first_page(1);
	$self->pdf_last_page( $info->{Pages} );

	$self->pdf_current_page( 1 );
}

sub _trigger_pdf_current_page {
	my ($self) = @_;
	$self->refresh_drawing_area;

}

sub setup_button_events {
	my ($self) = @_;

	$self->builder->get_object('button-first')->signal_connect(
		clicked => \&set_current_page_to_first, $self );
	$self->builder->get_object('button-last')->signal_connect(
		clicked => \&set_current_page_to_last, $self );

	$self->builder->get_object('button-forward')->signal_connect(
		clicked => \&set_current_page_forward, $self );
	$self->builder->get_object('button-back')->signal_connect(
		clicked => \&set_current_page_back, $self );
}

sub setup_text_entry_events {
	my ($self) = @_;

	$self->builder->get_object('page-number-entry')->signal_connect(
		activate => \&set_current_page_number, $self );
}

sub set_current_page_number {
	my ($entry, $self) = @_;

	my $text = $entry -> get_text;
	if ($text =~ /^[0-9]+$/ and $text <= $self->pdf_last_page
		 and $text >= $self->pdf_first_page){
		$self->pdf_current_page( $text );
	}
}

sub set_current_page_forward {
	my ($button, $self) = @_;
	if( $self->pdf_current_page <= $self->pdf_last_page ) {
		$self->pdf_current_page( $self->pdf_current_page + 1 );
	}
}

sub set_current_page_back {
	my ($button, $self) = @_;
	if( $self->pdf_current_page >= $self->pdf_first_page ) {
		$self->pdf_current_page( $self->pdf_current_page - 1 );
	}
}

sub set_current_page_to_first {
	my ($button, $self) = @_;
	$self->pdf_current_page( $self->pdf_first_page );
}

sub set_current_page_to_last {
	my ($button, $self) = @_;
	$self->pdf_current_page( $self->pdf_last_page );
}

sub refresh_drawing_area {
	my ($self) = @_;
	return unless $self->drawing_area;

	$self->drawing_area->queue_draw;

	$self->builder->get_object('page-number-entry')
		->set_text($self->pdf_current_page);

}

sub on_draw_pdf_page {
	my ($self, $img) = @_;

	$self->pdf_current_page_width( $img->get_width );
	$self->pdf_current_page_height( $img->get_height );

	$self->drawing_area->set_size_request(
		$self->pdf_current_page_width,
		$self->pdf_current_page_height );
}

sub setup_drawing_area_example {
	my ($self) = @_;

	my $vbox = $self->builder->get_object('application_vbox');

	my $drawing_area = Gtk3::DrawingArea->new();
	$self->drawing_area( $drawing_area );
	$drawing_area->signal_connect( draw => sub {
		my ($widget, $cr) = @_;

		my $img = mudraw_get_image_surface_of_pdf_page_as_png(
			$self->pdf_filename,
			$self->pdf_current_page,
		);
		$cr->set_source_surface($img, 0, 0);
		$cr->paint;

		$self->on_draw_pdf_page( $img );

		return TRUE;
	}, $self);

	my $scrolled_window = Gtk3::ScrolledWindow->new();
	$scrolled_window->set_hexpand(TRUE);
	$scrolled_window->set_vexpand(TRUE);

	$scrolled_window->add($drawing_area);
	$scrolled_window->set_policy( 'automatic', 'automatic');
	
	$vbox->pack_start( $scrolled_window, TRUE, TRUE, 0);
}

sub main {
	setup_gtk;

	my $pdf_filename = shift @ARGV;

	die "No PDF filename given" unless $pdf_filename;

	die "PDF filename does not exist: $pdf_filename" unless -f $pdf_filename;


	my $self = __PACKAGE__->new(
		pdf_filename => $pdf_filename,
	);
	$self->setup_window;

	$self->window->signal_connect(destroy => sub { Gtk3::main_quit });
	$self->window->set_default_size( 800, 600 );

	
	$self->window->show_all;


	Gtk3::main;
}

main;
