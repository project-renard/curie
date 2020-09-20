#!/usr/bin/env perl
# PODNAME: t-grid.pl
# ABSTRACT: do some messy stutff

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;
use Renard::Incunabula::Common::Setup;
use Renard::Block::Format::PDF::Document;
use Path::Tiny;

use Renard::API::Cairo;
use Renard::API::Gtk3::Helper;
use Glib qw(TRUE FALSE);

use aliased 'Renard::Curie::Component::JacquardCanvas';

use Renard::Curie::Model::View::Scenegraph;

my $document = Renard::Block::Format::PDF::Document->new(
	filename => path('~/Downloads/Anatomy Shelf Notes copy.pdf'),
);

my $factory = Renard::Curie::Model::View::Scenegraph->new(
	document => $document,
);

sub render_to_svg {
	my ($group) = @_;
	my $bounds = $group->bounds;

	my $svg = SVG->new;
	$group->render($svg);

	$svg->{-childs}[0]->setAttribute('height', $bounds->size->height);
	$svg->{-childs}[0]->setAttribute('width', $bounds->size->width);

	return $svg;
}

sub write_out_svg {
	my ($svg) = @_;
	my $svg_file = path('a.svg');
	$svg_file->spew_utf8( $svg->xmlify );

	return $svg_file;
}

sub open_svg_file {
	my ($svg_file) = @_;
	use Browser::Open qw(open_browser);
	open_browser($svg_file);
}

sub do_svg_things {
	my $group = $factory->graph;
	my $svg = render_to_svg($group);
	my $svg_file = write_out_svg($svg);
	open_svg_file($svg_file);
}

sub cb_on_view_changed {
	my ($widget, $data) = @_;

	if( ! exists $data->{status_bar_scroll_context} ) {
		$data->{status_bar_scroll_context} =
			$data->{status_bar}->get_context_id('pages');
	}

	$data->{status_bar}->remove_all($data->{status_bar_scroll_context});

	my @pages = map { $_->{page_number} } @{ $data->{drawing_area}->{views} };
	$data->{status_bar}->push($data->{status_bar_scroll_context}, "Pages: @pages");
}

sub cb_on_text_found {
	my ($widget, $data) = @_;
	$data->{label}->set_text( $data->{drawing_area}->{text}{substr} );
}


sub do_gtk_things {
	my $data = {};

	$data->{scale} = 0.3;
	$data->{scale} //= 1.0;

	$data->{sg} = $factory->graph;

	my $window = Gtk3::Window->new('toplevel');
	$window->signal_connect( destroy => sub { Gtk3::main_quit } );
	$window->set_default_size(800, 600);
	$window->set_position('center');

	my $vbox = Gtk3::Box->new( 'vertical', 0 );
	$window->add( $vbox );

	my $scrolled = Gtk3::ScrolledWindow->new;
	$data->{scroll} = $scrolled;

	my $drawing_area = JacquardCanvas->new(
		sg => $data->{sg},
		scale => $data->{scale},
	);
	$data->{drawing_area} = $drawing_area;
	$scrolled->add($drawing_area);

	my $label = Gtk3::Label->new;
	$data->{label} = $label;
	$label->set_line_wrap(TRUE);
	$label->set_selectable(TRUE);

	my $status_bar = Gtk3::Statusbar->new;
	$data->{status_bar} = $status_bar;

	$vbox->pack_start($scrolled, TRUE, TRUE, 0 );
	$vbox->pack_end($label, FALSE, FALSE, 0);
	$vbox->pack_end($status_bar, FALSE, FALSE, 0);

	$data->{drawing_area}->signal_connect( 'view-changed',
		\&cb_on_view_changed, $data );
	$data->{drawing_area}->signal_connect( 'text-found',
		\&cb_on_text_found, $data );

	$window->show_all;
	Gtk3::main;
}

sub main {
	do_gtk_things;
}

main;
#require Carp::REPL; Carp::REPL->import('repl'); repl();#DEBUG
