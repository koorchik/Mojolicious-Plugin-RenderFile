use Mojo::Base -strict;

use Test::More;

use Mojolicious::Lite;
use Test::Mojo;

use File::Basename qw/dirname/;
use File::Spec::Functions qw/rel2abs/;

my $FILE = rel2abs( dirname(__FILE__) . '/' . 'sample.txt' );

plugin 'RenderFile';

get '/default' => sub {
    my $self = shift;
    $self->render_file( filepath => $FILE );
};

get '/all_attrs' => sub {
    my $self = shift;
    $self->render_file( filepath => $FILE, filename => 'mysample.txt', status => 201 );
};

my $t = Test::Mojo->new;

$t->get_ok('/default')
    ->status_is(200)
    ->content_is('file to download')
    ->content_type_is('application/x-download;name=sample.txt')
    ->header_is( 'Content-Disposition' => 'attachment;filename=sample.txt' );

$t->get_ok('/all_attrs')
    ->status_is(201)
    ->content_is('file to download')
    ->content_type_is('application/x-download;name=mysample.txt')
    ->header_is( 'Content-Disposition' => 'attachment;filename=mysample.txt' );
    

done_testing();