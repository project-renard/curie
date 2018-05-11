package Renard::Curie::Schema::Result::ProcessedDocPytextrank;
# ABSTRACT: Table for if the document has been processed by PyTextRank

use Modern::Perl;
use DBIx::Class::Candy
	-autotable => v1,
	-components => [ qw/InflateColumn::Boolean/ ]
	;

table 'processed_doc_pytextrank';

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

unique_column document_id => {
	data_type => 'integer',
	is_nullable => 0,
};

column processed => {
	# Boolean
	data_type => 'int',
	is_boolean => 1,
	is_nullable => 0,
};

belongs_to 'document_id', 'Renard::Curie::Schema::Result::Document';

has_many 'pytextrank_data', 'Renard::Curie::Schema::Result::PytextrankData', 'processed_doc_pytextrank_id';

1;
