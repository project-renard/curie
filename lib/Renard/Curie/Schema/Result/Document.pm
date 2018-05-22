package Renard::Curie::Schema::Result::Document;

use Modern::Perl;
use Path::Tiny;
use DBIx::Class::Candy
	-autotable => v1;

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

column md5sum => {
	data_type => 'varchar',
	size => 32,
	is_nullable => 0,
};

column path => {
	data_type => 'text',
};

inflate_column path => {
	inflate => sub {
		my ($raw_value_from_db, $result_object) = @_;
		Path::Tiny::path($raw_value_from_db);
	},
	deflate => sub {
		my ($inflated_value_from_user, $result_object) = @_;
		$inflated_value_from_user->stringify;
	},
};

has_many 'phrase_cloze' => 'Renard::Curie::Schema::Result::PhraseCloze', 'document_id';

might_have 'processed_doc_pytextrank' => 'Renard::Curie::Schema::Result::ProcessedDocPytextrank', 'document_id';
might_have 'ignored' => 'Renard::Curie::Schema::Result::IgnoredDoc', 'document_id';

1;
