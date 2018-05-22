use Renard::Incunabula::Common::Setup;
package Renard::Curie::Process::PyTextRank;
# ABSTRACT: Process a document using PyTextRank

use Moo;
use MooX::Lsub;
use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Incunabula::Document::Types qw(DocumentModel);
use Renard::Curie::Document;

use Regexp::Assemble;

has schema => (
	is => 'ro',
	required => 1,
	#isa => InstanceOf['Renard::Curie::Schema'],
);

has document => (
	is => 'ro',
	required => 1,
	isa => DocumentModel,
);

lsub document_result => method() {
	my $doc = $self->document->get_schema_result( $self->schema );
};

method is_already_processed() {
	$self->document->is_processed_pytextrank( $self->schema );
}

method process() {
	if( ! $self->is_already_processed ) {
		$self->schema->txn_do(sub {
			my $processed = $self->document_result
				->create_related('processed_doc_pytextrank', { processed => 0 } );


			$self->_add_pytextrank_data($processed);
			$self->_add_pytextrank_phrase_cloze;

			$processed->processed(1);
			$processed->update;
		});
	}
}

method _add_pytextrank_data($processed) {
	my $pytextrank_data = $self->document->pytextrank;
	for my $phrase (@$pytextrank_data) {
		delete $phrase->{ids};
		$phrase->{text} =~ s/\s+/ /g;
		$processed->create_related('pytextrank_data', $phrase );
	}
}

method _add_pytextrank_phrase_cloze() {
	my $pytextrank_data = $self->document_result
		->processed_doc_pytextrank->pytextrank_data;

	my @page_text = map {
		$self->document->get_textual_page( $_ );
	} $self->document->first_page_number..$self->document->last_page_number;

	my $ra = Regexp::Assemble->new->track(1);
	$ra->flags('is'); # case insensitive, single string

	my $re_to_id = {};
	while( my $data = $pytextrank_data->next ) {
		my $re = quotemeta($data->text);
		$re = join "", @{ $ra->lexstr( $re ) };
		$re_to_id->{$re} = $data->id;

		$ra->add($re);
	}

	my $page_num = 1;
	for my $page (@page_text) {
		my @matches;
		my $str = $page->str;
		my $re = $ra->re;
		while( $str =~ /$re/g ) {
			my $match_data;
			$match_data->{re} = $ra->source($^R);
			$match_data->{id} = $re_to_id->{$match_data->{re}};
			$match_data->{offsets} = [ $-[0], $+[0] ];
			$match_data->{phrase} = $pytextrank_data->find($match_data->{id});
			$match_data->{page} = $page_num;

			$match_data->{substr} = substr
				$str,
				$match_data->{offsets}[0],
				$match_data->{offsets}[1]-$match_data->{offsets}[0];

			push @matches, $match_data;

		}

		$page_num++;

		for my $match_data (@matches) {
			my $phrase = $self->schema->resultset('PhraseCloze')->update_or_create({
				document_id => $self->document_result->id,
				page => $match_data->{page},
				text => $match_data->{phrase}->text,
				offset_start => $match_data->{offsets}[0],
				offset_end   => $match_data->{offsets}[1],
			});
			$phrase->create_related('pytextrank_cloze', {
				pytextrank_data_id => $match_data->{phrase}->id,
			});
		}
	}
}

1;
