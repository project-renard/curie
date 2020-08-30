#!/usr/bin/env perl
# PODNAME: t-grid.pl
# ABSTRACT: do some messy stutff

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;
use Renard::Incunabula::Common::Setup;
use feature qw(current_sub);
use Renard::Block::Format::PDF::Document;
use Renard::Curie::Model::View::Grid::PageActor;
use Renard::Jacquard::Layout::Grid;
use Renard::Jacquard::Layout::Box;
use Path::Tiny;
use Renard::Yarn::Types qw(Point Size);

use Renard::API::Cairo;
use Renard::API::Gtk3::Helper;
use Glib qw(TRUE FALSE);

use Devel::Timer;

use constant BOX_LAYOUT => 1;

my $t = Devel::Timer->new();

my $document = Renard::Block::Format::PDF::Document->new(
	filename => path('~/Downloads/Anatomy Shelf Notes copy.pdf'),
);

my $_LayoutGroup = Moo::Role->create_class_with_roles(
	'Renard::Jacquard::Actor' => qw(
	Renard::Jacquard::Role::Geometry::Position2D
	Renard::Jacquard::Role::Geometry::Size2D
	Renard::Jacquard::Role::Render::QnD::SVG::Group
	Renard::Jacquard::Role::Render::QnD::Cairo::Group
	Renard::Jacquard::Role::Render::QnD::Layout
	Renard::Jacquard::Role::Render::QnD::Size::Direct
	Renard::Jacquard::Role::Render::QnD::Bounds::Direct
));

fun create_group( :$start, :$end, :$margin = 10 ) {
	my $group = $_LayoutGroup->new(
		layout => Renard::Jacquard::Layout::Grid->new( rows => 3, columns => 2 ),
	);

	$t->mark("Adding pages $start..$end");
	for my $page_no ($start..$end) {
		my $actor = Renard::Curie::Model::View::Grid::PageActor->new(
			document => $document,
			page_number => $page_no,
		);
		if( BOX_LAYOUT ) {
			my $box = $_LayoutGroup->new(
				layout => Renard::Jacquard::Layout::Box->new( margin => $margin ),
			);
			$box->add_child( $actor );
			$group->add_child( $box );
		} else {
			$group->add_child( $actor );
		}
	}

	$group;
}

sub create_scene_graph {
	my $group = $_LayoutGroup->new(
		layout => Renard::Jacquard::Layout::Grid->new( rows => 2, columns => 2 ),
	);

	$group->add_child( create_group(start => 1, end => 6,   margin => 10) );
	$group->add_child( create_group(start => 7, end => 12,  margin => 50) );
	$group->add_child( create_group(start => 13, end => 18, margin => 100) );
	$group->add_child( create_group(start => 19, end => 24, margin => 150) );

	$group->x->value( 0 );
	$group->y->value( 0 );

	return $group;
}

sub _update_layouts {
	my ($g) = @_;
	__SUB__->($_) for @{ $g->children };
	$g->update_layout if $g->can('update_layout');
}

sub update_layout {
	my ($group) = @_;
	$t->mark('Updating layouts');
	_update_layouts($group);
	say "done";
}

sub render_to_svg {
	my ($group) = @_;
	$t->mark('Computing bounds');
	my $bounds = $group->bounds;

	$t->mark('Rendering to SVG');
	my $svg = SVG->new;
	$group->render($svg);

	$svg->{-childs}[0]->setAttribute('height', $bounds->size->height);
	$svg->{-childs}[0]->setAttribute('width', $bounds->size->width);

	return $svg;
}

sub write_out_svg {
	my ($svg) = @_;
	$t->mark('Writing SVG to file');
	my $svg_file = path('a.svg');
	$svg_file->spew_utf8( $svg->xmlify );

	return $svg_file;
}

sub open_svg_file {
	my ($svg_file) = @_;
	$t->mark('Opening in browser');
	use Browser::Open qw(open_browser);
	open_browser($svg_file);
}

sub do_svg_things {
	my $group = create_scene_graph;
	update_layout($group);
	my $svg = render_to_svg($group);
	my $svg_file = write_out_svg($svg);
	open_svg_file($svg_file);
}

sub cb_on_draw {
	my ($widget, $cr, $data) = @_;

	$cr->save;

	$cr->scale($data->{scale}, $data->{scale});

	$cr->set_source_rgb(0, 0, 0);
	$cr->paint;

	$data->{sg}->render_cairo( $cr );

	$cr->restore;
}

sub cb_on_scroll {
	my ($widget, $data) = @_;

	if( ! exists $data->{status_bar_scroll_context} ) {
		$data->{status_bar_scroll_context} =
			$data->{status_bar}->get_context_id('pages');
	}

	$data->{status_bar}->remove_all($data->{status_bar_scroll_context});

	my ($h, $v) = (
		$data->{scroll}->get_hadjustment,
		$data->{scroll}->get_vadjustment,
	);

	my $vp_origin = Point->coerce([ $h->get_value, $v->get_value ]);
	my $vp_size = Size->coerce([ $h->get_page_size, $v->get_page_size ]);

	my $vp_bounds = Renard::Yarn::Graphene::Rect->new(
		origin => $vp_origin,
		size => $vp_size,
	);

	my @pages;
	my $vp_is_visible = sub {
		my ($g, $g_matrix) = @_;
		my $t_matrix = Renard::Yarn::Graphene::Matrix->new;
		$t_matrix->init_from_2d( 1, 0 , 0 , 1, $g->x->value, $g->y->value );
		my $matrix = $t_matrix x $g_matrix;
		if( $g->isa('Renard::Curie::Model::View::Grid::PageActor') &&
			( $matrix->transform_bounds($g->bounds)->intersection($vp_bounds) )[0]
		) {
			push @pages, $g->page_number;
		}
		__SUB__->($_, $matrix) for @{ $g->children };
	};

	my $matrix = Renard::Yarn::Graphene::Matrix->new;
	$matrix->init_scale($data->{scale}, $data->{scale}, 0);
	$vp_is_visible->($data->{sg}, $matrix);

	#say "Box: $vp_bounds ; Pages: @pages";
	$data->{status_bar}->push($data->{status_bar_scroll_context}, "Pages: @pages");
}

sub do_gtk_things {
	my $data = {};

	$data->{scale} = 0.3;

	$data->{sg} = create_scene_graph;
	update_layout( $data->{sg} );
	my $bounds = $data->{sg}->bounds;

	my $window = Gtk3::Window->new('toplevel');
	$window->signal_connect( destroy => sub { Gtk3::main_quit } );
	$window->set_default_size(800, 600);

	my $vbox = Gtk3::Box->new( 'vertical', 0 );
	$window->add( $vbox );

	my $scrolled = Gtk3::ScrolledWindow->new;
	$data->{scroll} = $scrolled;

	my $drawing_area = Gtk3::DrawingArea->new;
	$drawing_area->set_size_request(
		$data->{scale} * $bounds->size->width,
		$data->{scale} * $bounds->size->height,
	);
	$scrolled->add($drawing_area);

	my $status_bar = Gtk3::Statusbar->new;
	$data->{status_bar} = $status_bar;

	$vbox->pack_start($scrolled, TRUE, TRUE, 0 );
	$vbox->pack_end($status_bar, FALSE, FALSE, 0);

	$drawing_area->signal_connect( draw => \&cb_on_draw, $data );
	for my $adj (qw(get_hadjustment get_vadjustment)) {
		for my $sig (qw(changed value-changed)) {
			$scrolled->$adj->signal_connect(
				$sig => \&cb_on_scroll, $data );
		}
	}

	$window->show_all;
	Gtk3::main;
}

sub main {
	do_gtk_things;
}

main;
$t->mark('END');
#require Carp::REPL; Carp::REPL->import('repl'); repl();#DEBUG
$t->report();
