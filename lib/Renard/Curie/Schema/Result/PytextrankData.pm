package Renard::Curie::Schema::Result::PytextrankData;
# ABSTRACT: Table for PyTextRank data for a given document

use Modern::Perl;
use DBIx::Class::Candy
	;

table 'pytextrank_data';

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

column processed_doc_pytextrank_id => {
	data_type => 'integer',
	is_nullable => 0,
};

column count => {
	data_type => 'integer',
	is_nullable => 0,
};

column pos => {
	data_type => 'text',
	is_nullable => 0,
};

column rank => {
	data_type => 'real',
	is_nullable => 0,
};

column text => {
	data_type => 'text',
	is_nullable => 0,
};

has_many 'pytextrank_cloze', 'Renard::Curie::Schema::Result::PytextrankCloze', 'pytextrank_data_id';

belongs_to 'processed_doc_pytextrank_id', 'Renard::Curie::Schema::Result::ProcessedDocPytextrank';

1;
