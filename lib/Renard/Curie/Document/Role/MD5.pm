use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document::Role::MD5;
# ABSTRACT: Computes the MD5 sum of a document file

use Moo::Role;

use Digest::MD5;
use Path::Tiny;

method md5sum_hex() {
	my $md5 = Digest::MD5->new;
	# TODO figure out why the coercion of C<< $self->filename >> is not working
	$md5->addfile( path($self->filename)->openr_raw );

	$md5->hexdigest;
}

1;
