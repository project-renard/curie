use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::Cacheable;

use Moo::Role;
use Renard::Curie::Types qw(InstanceOf);

use CHI;

has render_cache => (
	is => 'lazy', # _build_render_cache
	isa => InstanceOf['CHI::Driver'],
);

sub _build_render_cache {
	CHI->new( driver => 'RawMemory', global => 0 );
}

requires 'get_rendered_page';
around get_rendered_page => sub {
	my $orig = shift;
	my ($self, %rest) = @_;
	my @args = @_;
	return $self->render_cache->compute(
		\%rest,
		'never',
		sub { $orig->(@args); }
	);
};

1;
