use strict;
use warnings;
use Test::More;
use lib "xt/lib";
use CLI;
use Path::Tiny ();

my $cpanfile = Path::Tiny->tempfile; $cpanfile->spew(<<'___');
on test => sub {
    recommends 'Process::Status';
    suggests 'App::ChangeShebang';
};

on develop => sub {
    requires 'Parallel::Pipes';
    recommends 'File::pushd';
    suggests 'Try::Tiny';
};
___

subtest 'normal' => sub {
    my $r = cpm_install '--cpanfile', $cpanfile;
    is $r->exit, 0;
    like $r->err, qr/All requirements are satisfied/;
};

subtest 'develop' => sub {
    my $r = cpm_install '--with-develop', '--cpanfile', $cpanfile;
    is $r->exit, 0;
    unlike $r->err, qr/DONE install Process-Status/;
    unlike $r->err, qr/DONE install App-ChangeShebang/;
    like   $r->err, qr/DONE install Parallel-Pipes/;
    unlike $r->err, qr/DONE install File-pushd/;
    unlike $r->err, qr/DONE install Try-Tiny/;
};

subtest 'recommends' => sub {
    my $r = cpm_install '--with-recommends', '--cpanfile', $cpanfile;
    is $r->exit, 0;
    like   $r->err, qr/DONE install Process-Status/;
    unlike $r->err, qr/DONE install App-ChangeShebang/;
    unlike $r->err, qr/DONE install Parallel-Pipes/;
    unlike $r->err, qr/DONE install File-pushd/;
    unlike $r->err, qr/DONE install Try-Tiny/;
};

subtest 'suggests' => sub {
    my $r = cpm_install '--with-suggests', '--cpanfile', $cpanfile;
    is $r->exit, 0;
    unlike $r->err, qr/DONE install Process-Status/;
    like   $r->err, qr/DONE install App-ChangeShebang/;
    unlike $r->err, qr/DONE install Parallel-Pipes/;
    unlike $r->err, qr/DONE install File-pushd/;
    unlike $r->err, qr/DONE install Try-Tiny/;
};

subtest 'all' => sub {
    my $r = cpm_install '--with-develop', '--with-recommends', '--with-suggests', '--cpanfile', $cpanfile;
    is $r->exit, 0;
    like $r->err, qr/DONE install Process-Status/;
    like $r->err, qr/DONE install App-ChangeShebang/;
    like $r->err, qr/DONE install Parallel-Pipes/;
    like $r->err, qr/DONE install File-pushd/;
    like $r->err, qr/DONE install Try-Tiny/;
};

done_testing;
