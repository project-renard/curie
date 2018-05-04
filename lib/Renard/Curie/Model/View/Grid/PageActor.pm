package Renard::Curie::Model::View::Grid::PageActor;
# ABSTRACT: A jacquard actor for a document page

use Mu;

extends qw(Renard::Jacquard::Actor);

has [qw(document page_number)] => (
	is => 'ro',
	required => 1,
);

lazy _rendered_page => method() {
	$self->document->get_rendered_page(
		page_number => $self->page_number,
	);
};

lazy height => method() { $self->_rendered_page->get_height };
lazy width => method() { $self->_rendered_page->get_width };

method render($svg) {
	my $rp = $document->_rendered_page;
}

with qw(Renard::Jacquard::Role::Geometry::Position2D);

1;
