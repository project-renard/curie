use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::DocumentCollection;
# ABSTRACT: A collection of documents

use Moo;

use Hash::Ordered;
use Path::Tiny;

use namespace::clean;

has _filename_set => (
	is => 'ro',
	default => method() { Hash::Ordered->new; },
);

method exists( $path ) {
	$self->_filename_set->exists($path);
}

method add_path( $path ) {
	my @added;

	return @added if $self->exists($path);

	if( -d $path ) {
		push @added, $self->add_path( $_ ) for path($path)->children;
	} elsif( -f $path && $path =~ /\.pdf$/i ) {
		$self->_filename_set->push( "$path" => 1 );
		push @added, $path;
	}

	@added;
}

method remove_path( $path ) {
	my @removed;

	if( -d $path ) {
		push @removed, $self->remove_path( $_ ) for path($path)->children;
	} elsif( $self->exists("$path") ) {
		$self->_filename_set->delete( "$path" );
		push @removed, $path;
	}

	@removed;
}

1;
