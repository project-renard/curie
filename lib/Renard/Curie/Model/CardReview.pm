use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::CardReview;

use Moo;
use MooX::HandlesVia;
use Renard::Curie::Model::DocumentCollection;

has schema => (
	is => 'ro',
	required => 1,
);

has _running_review => (
	is => 'rw',
	handles_via => 'Bool',
	handles => {
		toggle_running_review => 'toggle',
		is_running_review => 'get',
	},
	default => method() { 0 },
);

has review_method => (
	is => 'rw',
);

method get_card() {
	my $rand = int(rand() * scalar @{ $self->cards });
	return $self->cards->[$rand];
}

has cards => (
	is => 'rw',
	default => sub { [] },
);

has _document_collection => (
	is => 'ro',
	default => sub { Renard::Curie::Model::DocumentCollection->new },
	handles => [qw(add_path remove_path)],
);

around add_path => fun($orig, $self, @args) {
	my @added = $orig->($self, @args);
	$self->add_cards($_) for @added;
};

around remove_path => fun($orig, $self, @args) {
	my @removed = $orig->($self, @args);
	use DDP; p @removed;
};

method add_cards($path) {
	my $doc = Renard::Curie::Document->new(
		filename => $path
	);

	if( ! $doc->is_ignored($self->schema) ) {
		$doc->process_pytextrank($self->schema);
		push @{ $self->cards }, $doc->get_schema_result($self->schema)->phrase_cloze;
	}
}

method remove_cards( $path ) {
	my $doc = Renard::Curie::Document->new(
		filename => $path
	);
	my $doc_result = $doc->get_schema_result($self->schema);

	$self->cards(
		grep {
			$_->id != $doc_result->id
		} @{ $self->cards }
	);
}

1;
