use Test::Most;

use Modern::Perl;
use Renard::Curie::App;
use Renard::Curie::Model::CairoImageSurfaceDocument;
use Cairo;

my $colors = [
	[ 1, 0, 0 ],
	[ 0, 1, 0 ],
	[ 0, 0, 1 ],
	[ 0, 0, 0 ],
];

my @surfaces = map {
	my ($width, $height) = (100, 100);
	my $surface = Cairo::ImageSurface->create(
		'rgb24', $width, $height
	);
	my $cr = Cairo::Context->create( $surface );

	my $rgb = $_;
	$cr->set_source_rgb( @$rgb );
	$cr->rectangle(0, 0, $width, $height);
	$cr->fill;

	$surface;
} @$colors;

my $cairo_doc = Renard::Curie::Model::CairoImageSurfaceDocument->new(
	image_surfaces => \@surfaces,
);

sub build_test{
	my ($callback) = @_;
	return sub{
		my $app = Renard::Curie::App->new;
		$app->open_document( $cairo_doc );

		my $page_comp = $app->page_document_component;

		$callback->( $app, $page_comp );

		$app->run;
	}
}

subtest 'Check that moving forward changes the page number' => build_test ( sub {
	my ( $app, $page_comp ) = @_;
	my $forward_button = $page_comp->builder->get_object('button-forward');

	Glib::Timeout->add(100, sub {
		is($page_comp->current_page_number, 1, 'Start on page 1' );

		$forward_button->clicked;
		is($page_comp->current_page_number, 2, 'On page 2 after hitting forward' );

		$forward_button->clicked;
		is($page_comp->current_page_number, 3, 'On page 3 after hitting forward' );

		$forward_button->clicked;
		is($page_comp->current_page_number, 4, 'On page 4 after hitting forward' );

		$app->window->destroy;
	});
});

subtest 'Check that the current button sensitivity is set on the first and last page' => build_test (sub {
	my ( $app, $page_comp ) = @_;

	my $first_button = $page_comp->builder->get_object('button-first');
	my $last_button = $page_comp->builder->get_object('button-last');

	my $forward_button = $page_comp->builder->get_object('button-forward');
	my $back_button = $page_comp->builder->get_object('button-back');

	Glib::Timeout->add(500, sub {
		is($page_comp->current_page_number, 1, 'Start on page 1' );

		$page_comp->set_navigation_buttons_sensitivity;

		ok ! $first_button->is_sensitive  , 'button-first is disabled on first page';
		ok ! $back_button->is_sensitive   , 'button-back is disabled on first page';
		ok   $last_button->is_sensitive   , 'button-last is enabled on first page';
		ok   $forward_button->is_sensitive, 'button-forward is enabled on first page';

		$last_button->clicked;
		is $page_comp->current_page_number, 4, 'On page 4 after hitting button-last';

		$page_comp->set_navigation_buttons_sensitivity;

		ok   $first_button->is_sensitive  , 'button-first is enabled on last page';
		ok   $back_button->is_sensitive   , 'button-back is enabled on last page';
		ok ! $last_button->is_sensitive   , 'button-last is disabled on last page';
		ok ! $forward_button->is_sensitive, 'button-forward is disabled on last page';

		$app->window->destroy;
	});
});

subtest 'Check the number of pages label' => build_test ( sub {
	my ( $app, $page_comp ) = @_;
	my $number_of_pages_label;

	lives_ok {
		$number_of_pages_label = $page_comp->builder->get_object("number-of-pages-label");
	} 'The number of pages label exists';

	Glib::Timeout->add(500, sub {
			is( $number_of_pages_label->get_text() , '4', 'Number of pages should be equal to four.' );
			$app->window->destroy;
		});
});

done_testing;
