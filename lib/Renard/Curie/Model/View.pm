# NOTE: do not use Renard::Incunabula::Common::Setup here due to Glib / Moo subclass conflict
use strict;
use warnings;
package Renard::Curie::Model::View;
# ABSTRACT: A base class for a view

use Moo;

use Glib::Object::Subclass
	'Glib::Object',
	signals => { 'view-changed' => {} },
	;

=head1 SIGNALS

=for :list
* C<view-changed>: called when a view property is changed.

=cut

1;
