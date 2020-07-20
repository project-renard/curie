#!/usr/bin/env perl
# PODNAME: t-grid.pl
# ABSTRACT: do some messy stutff

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;
use Renard::Block::Format::PDF::Document;
use Renard::Curie::Model::View::Grid::PageActor;
use Renard::Jacquard::Layout::Grid;
use Path::Tiny;

sub main {
	my $document = Renard::Block::Format::PDF::Document->new(
		filename => path('~/Downloads/Anatomy Shelf Notes copy.pdf'),
	);

	my $_LayoutGroup = Moo::Role->create_class_with_roles(
		'Renard::Jacquard::Actor' => qw(
		Renard::Jacquard::Role::Geometry::Position2D
		Renard::Jacquard::Role::Render::QnD::SVG::Group
		Renard::Jacquard::Role::Render::QnD::Layout::Grid
		Renard::Jacquard::Role::Render::QnD::Bounds::Group
	));
	my $group = $_LayoutGroup->new(
		layout => Renard::Jacquard::Layout::Grid->new( rows => 3, columns => 2 ),
	);

	for my $page_no (1..6) {
		my $actor = Renard::Curie::Model::View::Grid::PageActor->new(
			document => $document,
			page_number => $page_no,
		);
		$group->add_child( $actor );
	}

	$group->x->value( 0 );
	$group->y->value( 0 );
	$group->update_layout;
	my $bounds = $group->bounds;

	my $svg = SVG->new;
	$group->render($svg);

	$svg->{-childs}[0]->setAttribute('height', $bounds->size->height);
	$svg->{-childs}[0]->setAttribute('width', $bounds->size->width);
	my $svg_file = path('a.svg');
	$svg_file->spew_utf8( $svg->xmlify );
	use Browser::Open qw(open_browser);
	open_browser($svg_file);

	#require Carp::REPL; Carp::REPL->import('repl'); repl();#DEBUG
}

main;
