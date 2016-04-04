use Modern::Perl;
package Renard::Curie::Component::ProteinViewer;

use Gtk3::WebKit;
use Glib 'TRUE', 'FALSE';
use Moo;
use Path::Tiny;
use URI::file;

our $VIEW_PDB_STRING = <<HTML;
	<h1> Hello </h1>
	<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/require.js/2.2.0/require.js"/>
	<script type="text/javascript" src="https://raw.githubusercontent.com/biasmv/pv/master/bio-pv.min.js"/>
	<div id="id"><div>
	<script>
		console.log('woah');
		document.getElementById('id').innerHTML = "Hey";
		/*require.config({
			paths: {
				pv: '//raw.githubusercontent.com/biasmv/pv/master/bio-pv.min'
			}
		});
		require(["pv"], function (pv) {
			document.getElementById('id').innerHTML = "Hey";
			pdb = "%s";
			structure = pv.io.pdb(pdb);
			console.log('initialized')
			viewer = pv.Viewer(document.getElementById('id'),
					{quality : 'medium', width: 'auto',
					height : 'auto', antialias : true,
					background : '#eee',
					outline : true, style : 'preset' });
			viewer.fitParent();
		})*/;
	</script>
HTML

has widget => ( is => 'lazy' );

sub _build_widget {
	my $wv = Gtk3::WebKit::WebView->new;
	$wv->get_settings->set_property('enable-webgl', TRUE);
	$wv->get_settings->set_property('enable-universal-access-from-file-uris', TRUE);
	return $wv;
}

sub load_molecule_pdb {
	my ($self, $pdb_data) = @_;
	my $load_file = path('./pv/quick.html');
	my $outfile = path('./pv/pdbs/blah.pdb');
	$outfile->spew_utf8( $pdb_data );
	$self->widget->load_uri( URI::file->new_abs( $load_file ) );
	$self->widget->reload();
}

sub download_pdb {
	...
}

sub load_dengue {
	my ($self) = @_;
	my $pdb_data = path('1r6a.pdb')->slurp_utf8;
	$self->load_molecule_pdb( $pdb_data );
}

1;
