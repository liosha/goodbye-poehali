#!/usr/bin/perl -w

use strict;

use GD;
use List::Util 'first';


my @yellow = (
    [ 0xFF, 0xFF, 0x00 ],
    [ 0xF8, 0xF8, 0x08 ],
);


print "\n  ---|   'poehali' logo remover   (c) 2010  liosha, xliosha\@gmail.com\n\n";

unless ( @ARGV ) {
    print "Usage:\n\n  no_poehali.pl <file.gif>\n";
    exit;
}

my $file = shift @ARGV;
my $dir = '_cleared';
mkdir $dir  unless -d $dir;


my @nb = (
    [-1, 0],    [ 1, 0],    [ 0,-1],    [ 0, 1],
    [-1,-1],    [ 1,-1],    [ 1, 1],    [ 1,-1],
    [-2, 0],    [ 2, 0],    [ 0,-2],    [ 0, 2],
);


print "$file\n";
print "Loading...            ";
my $im = new GD::Image( $file );
my ($width,$height) = $im->getBounds();
print "$width x $height image\n";

print "Processing...\n";

COLOR:
for my $yellow ( @yellow ) {
    my $yindex = $im->colorResolve( @$yellow );
    printf "Color #%02X%02X%02X %-6s  ", @$yellow, "($yindex):";
    unless ( defined $yindex ) {
        print "no such color\n";
        next COLOR;
    }

    my @changes = ();
    
    for my $y ( $height*0.1-200 .. $height*0.1+100, $height*0.95-200 .. $height*0.95+100, ) {
        next if $y <  0;
        next if $y >= $height;
        for my $x ( 0 .. $width-1 ) {
            my $pix = $im->getPixel( $x, $y );
            if ( $pix == $yindex ) {
                my $newpix;
                first {  ( $newpix = $im->getPixel( $x+$_->[0], $y+$_->[1] ) ) != $pix  } @nb;
                push @changes, [ $x, $y, $newpix ]  unless $pix == $newpix;
            }
        }
    }

    printf "%d pixels", scalar @changes;

    if ( @changes > 5000 ) {
        print " - ok\n";
        for my $change ( @changes ) {
            $im->setPixel( @$change );
        }
        last COLOR;
    }
    else {
        print " - too few\n";
    }
}

$file =~ s{(.*[/\\])?([^/\\]+)$}{$2};

print "Writing result...     ";
open OUT, '>', "$dir/$file";
binmode OUT;
print OUT $im->gif();
close OUT;
print "Ok\n";


print "All done!\n";


