use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::RenderFile',
  VERSION_FROM => 'lib/Mojolicious/Plugin/RenderFile.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '2.88'},
  test         => {TESTS => 't/*.t'}
);
