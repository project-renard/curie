use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::CardReview;

use Moo::Role;
use MooX::Lsub;

use Renard::Curie::Model::CardReview;

use namespace::clean;

requires 'schema';

lsub card_review => method() {
	Renard::Curie::Model::CardReview->new(
		schema => $self->schema,
	);
};

has current_card => (
	is => 'rw',
);

method next_card() {
	$self->current_card(
		$self->card_review->get_card
	);

	$self->current_phrase_schema_result(
		$self->current_card
	);
}

method set_method( $method ) {
	die "unknown review method" unless $method =~ /^(srs|random|sequential)$/;
	$self->card_review->review_method($method);
}

method start() {

}

1;
