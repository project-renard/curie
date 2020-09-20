use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas::Role::MousePageTooltip;
# ABSTRACT: Role for tooltip on hover

use Role::Tiny;
use Glib qw(TRUE FALSE);

	after do_pointer_data => sub {
		my ($self, $event_point, $pointer_data, $text_data ) = @_;

		my @intersects = @{ $pointer_data->{intersects} };
		my @pages = @{ $pointer_data->{pages} };
		my $point = $pointer_data->{point};

		if( @pages) {
			$self->set_tooltip_text("@pages");
		} else {
			$self->set_has_tooltip(FALSE);
		}

		return TRUE;
	};


1;
