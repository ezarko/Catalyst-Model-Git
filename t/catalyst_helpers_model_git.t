#!perl -w
use strict;
use warnings;
use Test::More;
use Cwd;
use File::Path;
use File::Spec::Functions;
use FindBin ();

BEGIN {
    eval 'use Catalyst 5';
    plan(skip_all =>
        'Catalyst 5 not installed') if $@;

    eval 'use Test::File 1.10';
    plan(skip_all =>
        'Test::File 1.10 not installed') if $@;

    eval 'use Test::File::Contents 0.02';
    plan(skip_all =>
        'Test::File::Contents 0.02 not installed') if $@;

    plan tests => 3;

    use_ok('Catalyst::Helper');
};

my $helper = Catalyst::Helper->new({short => 1});
my $app = 'TestApp';


## create the test app
{
    chdir('t');
    rmtree($app);

    $helper->mk_app($app);
    $FindBin::Bin = catdir(cwd, $app, 'lib');
};


## create the default model
{
    my $module = catfile($app, 'lib', $app, 'M', 'Git.pm');
    $helper->mk_component($app, 'model', 'Git', 'Git', 'testrepo');
    file_exists_ok($module);
    file_contents_like($module, qr/'testrepo'/);
};
