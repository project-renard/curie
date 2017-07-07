use Renard::Curie::Setup;
package Renard::Curie::Model::ViewOptions;
# ABSTRACT: A high-level set of options for generating a view

use Moo;
use Renard::Curie::Types qw(InstanceOf);
use Renard::Curie::Model::ViewOptions::Grid;
use Renard::Curie::Model::ViewOptions::Zoom::Percentage;

with qw(MooX::Role::CloneSet);

=attr grid_options

A L<Renard::Curie::Model::ViewOptions::Grid>.

By default, this a grid option with C<< { rows => 1, columns => 1} >>
(i.e., a single page view, non-continuous).

=cut
has grid_options => (
	is => 'ro',
	default => sub {
		Renard::Curie::Model::ViewOptions::Grid->new(
			rows => 1, columns => 1,
		);
	},
	isa => InstanceOf['Renard::Curie::Model::ViewOptions::Grid'],
);

=attr zoom_options

A L<Renard::Curie::Model::ViewOptions::Zoom>.

By default, this is set to a L<Renard::Curie::Model::ViewOptions::Zoom::Percentage>
such that

  Renard::Curie::Model::ViewOptions::Zoom::Percentage->new(
    zoom_level => 1.0,
  );

=cut
has zoom_options => (
	is => 'ro',
	default => sub {
		Renard::Curie::Model::ViewOptions::Zoom::Percentage->new(
			zoom_level => 1.0,
		);
	},
	isa => InstanceOf['Renard::Curie::Model::ViewOptions::Zoom'],
);

1;
