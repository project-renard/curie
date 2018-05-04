#!/usr/bin/env perl
# PODNAME: t-grid.pl
# ABSTRACT: do some messy stutff

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;
use Renard::Block::Format::PDF::Document;
use Renard::Curie::Model::View::Grid::PageActor;
use Path::Tiny;

sub main {
	my $document = Renard::Block::Format::PDF::Document->new(
		filename => path('~/Downloads/Anatomy Shelf Notes copy.pdf'),
	);

	my $actor = Renard::Curie::Model::View::Grid::PageActor->new(
		document => $document,
		page_number => 1,
	);
	use DDP; p $actor;

	require Carp::REPL; Carp::REPL->import('repl'); repl();#DEBUG
}

main;
