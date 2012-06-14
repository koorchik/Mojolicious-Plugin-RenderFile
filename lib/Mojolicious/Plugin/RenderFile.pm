package Mojolicious::Plugin::RenderFile;
use Mojo::Base 'Mojolicious::Plugin';

use strict;
use warnings;
use File::Basename;

our $VERSION = '0.02';

sub register {
    my ( $self, $app ) = @_;

    $app->helper('render_file' => sub {
        my $c     = shift;
        my %args     = @_;
        my $filepath = $args{filepath};

        unless ( -f $filepath && -r $filepath ) {
            $c->app->log->error("Cannot read file [$filepath]. error [$!]");
            return;
        }

        my $filename = $args{filename} || fileparse($filepath);
        my $status   = $args{status}   || 200;

        my $headers = Mojo::Headers->new();
        $headers->add( 'Content-Type',        'application/x-download;name=' . $filename );
        $headers->add( 'Content-Disposition', 'attachment;filename=' . $filename );

	# Asset
	my $asset = Mojo::Asset::File->new( path => $filepath );

	# Range
	# Partially based on Mojolicious::Static
	my $size = (stat $filepath)[7];
	if (my $range = $c->req->headers->range) {

	  my $start = 0;
	  my $end = $size - 1 >= 0 ? $size - 1 : 0;

	  # Check range
	  if ($range =~ m/^bytes=(\d+)-(\d+)?/ && $1 <= $end) {
	    $start = $1;
	    $end = $2 if defined $2 && $2 <= $end;

	    $status = 206;
	    $headers->add('Content-Length' => $end - $start + 1);
	    $headers->add('Content-Range' => "bytes $start-$end/$size");
	  }

	  # Not satisfiable
	  else {
	    return $c->rendered(416);
	  };

	  # Set range for asset
	  $asset->start_range($start)->end_range($end);
	}

	else {
	  $headers->add('Content-Length' => $size);
	};

        $c->res->content->headers($headers);

        # Stream content directly from file
        $c->res->content->asset($asset);
        return $c->rendered($status);
    });
}

1;


=head1 NAME

Mojolicious::Plugin::RenderFile - "render_file" helper for Mojolicious  

=head1 SYNOPSIS

    # Mojolicious
    $self->plugin('RenderFile');

    # Mojolicious::Lite
    plugin 'RenderFile';
    
    # In controller
    $self->render_file(filepath => '/tmp/files/file.pdf'); # file name will "file.pdf"
     
    # Provide any file name
    $self->render_file(filepath => '/tmp/files/file.pdf',  'filename' => 'report.pdf');

=head1 DESCRIPTION

L<Mojolicious::Plugin::RenderFile> is a L<Mojolicious> plugin that adds "render_file" helper. It does not read file in memory and just streaming it to client. 

=head1 HELPERS

=head2 C<render_file>

    $self->render_file(filepath => '/tmp/files/file.pdf',  'filename' => 'report.pdf');

With this helper you can easily provide files for download. By default content-type is "application/x-download". Therefore, a browser will ask where to save file.

Register plugin in L<Mojolicious> application.

=head1 AUTHOR

Viktor Turskyi <koorchik@cpan.org>

=head1 BUGS

Please report any bugs or feature requests to Github L<https://github.com/koorchik/Mojolicious-Plugin-RenderFile>

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut