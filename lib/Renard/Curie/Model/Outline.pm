use Renard::Curie::Setup;
package Renard::Curie::Model::Outline;
# ABSTRACT: Model that represents a document outline

use Moo;
use Renard::Curie::Types qw(ArrayRef HashRef);

=attr items

An C<ArrayRef[HashRef]> with a simple representation of an outline where each
item of the ArrayRef represents an item in the list of headings displayed in
order.

Each C<HashRef> element is an element of the outline with the structure:

  {
    # The level in the outline that the item is at. Starts at zero (0).
    level => PositiveOrZeroInt,

    # The textual description of the item.
    text  => Str,

    # The page number that the outline item points to.
    page  => PageNumber,
  }

A complete example is:

  [
    {
      level => 0,
      text  => 'Chapter 1',
      page  => 20,
    },
    {
      level => 1,
      text  => 'Section 1.1',
      page  => 25,
    },
    {
      level => 0,
      text  => 'Chapter 2',
      page  => 30,
    },
  ]

which represents the outline

  Chapter 1 .......... 20
    Section 1.1 ...... 25
  Chapter 2 .......... 30

=cut
has items => (
	is => 'rw',
	required => 1,
	isa => ArrayRef[HashRef],
);

# TODO create the Gtk3::TreeStore here?

1;
