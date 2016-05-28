use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Modern::Perl;
use Renard::Curie::Component::FileChooser;

subtest 'Check that the open file dialog with filters is created' => sub {
	require Renard::Curie::App;
	my $app = Renard::Curie::App->new;
	my $file_chooser = Renard::Curie::Component::FileChooser->new( app => $app );

	my $dialog = $file_chooser->get_open_file_dialog_with_filters;

	is $dialog->get_title, 'Open File', 'Dialog has the right title';

	my $filters = $dialog->list_filters;
	my @filters_names = map { $_->get_name } @$filters;

	cmp_deeply(\@filters_names, bag('All files', 'PDF files'),
		'Has expected filters' );
};
