use Renard::Curie::Setup;
package Renard::Curie::Model::Outline;
# ABSTRACT: Model that represents a document outline

use Moo;
use Renard::Curie::Types qw(
	ArrayRef Dict
	PositiveOrZeroInt Str PageNumber
	InstanceOf );
use Type::Utils qw( declare as where message );

my $Outline = declare
	as ArrayRef[Dict[
			level => PositiveOrZeroInt,
			text => Str,
			page => PageNumber
		]];
my $OutlineLevelCheck = declare
	as $Outline,
	where {
		my @outline = @$_;
		for my $idx (0..@outline-2) {
			my $current_level = $outline[$idx]{level};
			my $next_level = $outline[$idx + 1]{level};
			if(  $current_level < $next_level
				and $current_level + 1 != $next_level ) {
				# This is a malformed outline. It should not
				# be possible to go down multiple levels at
				# a time.
				return 0;
			}
		}
		return 1;
	},
	message {
		$Outline->validate($_)
			or "Outline item data has malformed levels";
	};

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
	isa => $OutlineLevelCheck,
);

=attr tree_store

The L<Gtk3::TreeStore> representation for this outline. It holds tree data of
the heading text and page numbers.

=cut
has tree_store => (
	is => 'lazy', # _build_tree_store
	isa => InstanceOf['Gtk3::TreeStore'],
);


method _build_tree_store {
	# load Gtk3 dynamically if used outside Gtk3 context
	require Gtk3;
	Gtk3->import(qw(-init));

	my $data = Gtk3::TreeStore->new( 'Glib::String', 'Glib::String', );

	my $outline_items = $self->items;
	my $level = 0;
	my $iter = undef;
	my @parents = ();

	for my $item (@$outline_items) {
		no autovivification;

		# If we need to go up to the parent iterators.
		while( @parents && $item->{level} < @parents ) {
			$iter = pop @parents;
		}

		if( $item->{level} > @parents ) {
			# If we need to go one level down to a child.
			# NOTE : This is not a while(...) loop because the
			# outline should only increase one level at a time.
			push @parents, $iter;
			$iter = $data->append($iter);
			$level++;
		} else {
			# We are still at the same level. Just add a new row to
			# that last parent (or undef if we are at the root).
			$iter = $data->append( $parents[-1] // undef );
		}

		$data->set( $iter,
			0 => $item->{text} // '',
			1 => $item->{page} );
	}

	$data;
}

1;
