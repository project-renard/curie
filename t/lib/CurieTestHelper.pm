use Modern::Perl;
package CurieTestHelper;

use Path::Tiny;

use Renard::Curie::Model::Document::CairoImageSurface;
use Cairo;

use Renard::Curie::App;

=func test_data_directory

Returns a L<Path::Class> object that points to the path defined by
the environment variable C<RENARD_TEST_DATA_PATH>.

If the environment variable is not defined, throws an error.

=cut
sub test_data_directory {
	my ($package) = @_;

	if( not defined $ENV{RENARD_TEST_DATA_PATH} ) {
		die "Must set environment variable RENARD_TEST_DATA_PATH to the path for the test-data repository";
	}
	return path( $ENV{RENARD_TEST_DATA_PATH} );
}

=func create_cairo_document

Returns a L<Renard::Curie::Model::Document::CairoImageSurface> which can be
used for testing.

The pages have the colors:

=for :list

* red

* green

* blue

* black

=cut
sub create_cairo_document {
	my ($package) = @_;
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

	my $cairo_doc = Renard::Curie::Model::Document::CairoImageSurface->new(
		image_surfaces => \@surfaces,
	);
}

=func run_app_with_document

  run_app_with_document( $document, $callback )

Set up a L<Renard::Curie::App> application for running tests on a given
document. The main loop of the L<Renard::Curie::App> application is run after
the callback is called, so the callback should set up events to be run once the
main loop has started.

This callback set up can be accomplished by using L<Glib::Timeout>. For
example, to run code 100 ms after the main loop has started, use:

  Glib::Timeout->add(100, sub {
    ...
  });

See the L<Glib documentation|https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html#g-timeout-add>
for more information.

=for :list

* C<$document>:

a document that will be opened by the L<Renard::Curie::App>

* C<$callback>:

a coderef which will be passed in the L<Renard::Curie::App> C<$app> and the
current L<Renard::Curie::Component::PageDrawingArea> C<$page_component> for
the document C<$document>.

   sub {
     my ( $app, $page_component ) = @_;
     ...
   }

=cut
sub run_app_with_document {
	my ($package, $document, $callback) = @_;
	return sub{
		my $app = Renard::Curie::App->new;
		$app->open_document( $document );

		my $page_component = $app->page_document_component;

		$callback->( $app, $page_component );

		$app->run;
	}
}

1;
