use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::ReviewTable;

use Moo;
use MooX::Lsub;

use Renard::Incunabula::Common::Types qw(InstanceOf);

use Glib::Object::Subclass
	'Gtk3::Bin';

use Glib qw(TRUE FALSE);
use List::UtilsBy qw(nsort_by);

use constant COLUMNS => {
	REVIEW_ORDER      => { index => 0, type => 'Glib::UInt' },
	FILENAME_BASE     => { index => 1, type => 'Glib::String' },
	FILENAME_PAGE     => { index => 2, type => 'Glib::UInt' },
	PHRASE_CLOZE_ID   => { index => 3, type => 'Glib::UInt' },
	PHRASE_CLOZE_TEXT => { index => 4, type => 'Glib::String' },
	DUE_DATE          => { index => 5, type => 'Glib::String' },
	NUM_REVIEWS       => { index => 6, type => 'Glib::UInt' },
	NUM_CONSECUTIVE   => { index => 7, type => 'Glib::UInt' },
	E_FACTOR          => { index => 8, type => 'Glib::Double' },
	BACKGROUND_COLOR  => { index => 9, type => 'Glib::String' },
};

=attr view_manager

The view manager model for this application.

=cut
has view_manager => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::ViewModel::ViewManager'],
	handles => {
		view => current_view =>,
	},
);

lsub tree_view => method() {
	$self->builder->get_object('review-tree');
};

has model => (
	is => 'lazy',
	isa => InstanceOf['Gtk3::TreeStore'],
);

method BUILD(@) {
	$self->add( $self->builder->get_object('review-box'));
	my @columns = (
		{ header => 'Review order',              field => 'REVIEW_ORDER' },
		{ header => 'File',                      field => 'FILENAME_BASE' },
		{ header => 'Page',                      field => 'FILENAME_PAGE' },
		{ header => 'Phrase',                    field => 'PHRASE_CLOZE_TEXT' },
		{ header => 'Due date',                  field => 'DUE_DATE' },
		{ header => '# of review',               field => 'NUM_REVIEWS' },
		{ header => '# of consecutive correct',  field => 'NUM_CONSECUTIVE' },
		{ header => 'e-factor',                  field => 'E_FACTOR' },
	);
	map {
		my $column_idx = $_;
		my $column_info = $columns[$column_idx];
		$self->tree_view->insert_column(
			Gtk3::TreeViewColumn->new_with_attributes(
				$column_info->{header},
				Gtk3::CellRendererText->new,
				text => COLUMNS->{$column_info->{field}}{'index'},
				'cell-background' => COLUMNS->{'BACKGROUND_COLOR'}{'index'},
			),
			$column_idx,
		)
	} 0..@columns-1;

	$self->tree_view->set( 'headers-visible', TRUE );

	$self->tree_view->set_model( $self->model );

	my $iter = $self->model->append(undef);
	$self->model->set( $iter,
		COLUMNS->{'REVIEW_ORDER'}{'index'} => 0,
		COLUMNS->{'FILENAME_BASE'}{'index'} => "abc",
		COLUMNS->{'FILENAME_PAGE'}{'index'} => 22,
		COLUMNS->{'PHRASE_CLOZE_TEXT'}{'index'} => 'something important',
	);

	$iter = $self->model->append(undef);
	$self->model->set( $iter,
		COLUMNS->{'REVIEW_ORDER'}{'index'} => 1,
		COLUMNS->{'FILENAME_BASE'}{'index'} => "def",
		COLUMNS->{'FILENAME_PAGE'}{'index'} => 11,
		COLUMNS->{'PHRASE_CLOZE_TEXT'}{'index'} => 'not important',
	);
}

classmethod FOREIGNBUILDARGS(@) {
	();
}

method _build_model() {
	my $store = Gtk3::TreeStore->new(
		map { $_->{type} }
		nsort_by { $_->{index} }
		values %{ COLUMNS() }
	);
	$store->clear;

	$store;
}


with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
);

1;
