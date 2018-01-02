use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::ViewOptions::Grid;
# ABSTRACT: A set of options for grids

use Moo;
use MooX::Lsub;
use Renard::Incunabula::Common::Types qw(Maybe PositiveInt);
use Renard::Curie::Error;

# Need to use the ::BuildArgs version since is_continuous_view is a lsub.
with qw(MooX::BuildArgs MooX::Role::CloneSet::BuildArgs);
=for Pod::Coverage
BUILDARGS FINALIZE_BUILDARGS

=cut

=attr rows

  Maybe[PositiveInt]

The number of rows for the grid (i.e., in the vertical direction)
or C<undef> if the number of rows is unspecified (see C<BUILD>).

=attr columns

  Maybe[PositiveInt]

The number of columns for the grid (i.e., in the horizontal direction)
or C<undef> if the number of columns is unspecified (see C<BUILD>).

=cut
has [ qw/rows columns/ ] => (
	is => 'ro',
	required => 1,
	isa => sub {
		( Maybe[PositiveInt] )->check($_[0]) or
			Renard::Curie::Error::ViewOptions::InvalidGridOptions->throw(
				msg => 'Grid extent must be Maybe[PositiveInt]',
			);
	},
);

=attr is_continuous_view

  Bool

A predicate that returns a true value if the view is a continuous view
(see C<BUILD>).

=cut
lsub is_continuous_view => method() {
	defined $self->rows xor
		defined $self->columns;
};

=method BUILD

This class can only be constructed if at least one of C<rows> or C<columns> is
defined. If one is C<undef>, the associated grid view is continuous and the
non-C<undef> attribute is used to compute the C<undef> attribute.

=cut
method BUILD() {
	unless( defined $self->rows or defined $self->columns ) {
		Renard::Curie::Error::ViewOptions::InvalidGridOptions->throw({
			msg => "At least one of the grid extents must be defined",
		});
	}
};

1;
