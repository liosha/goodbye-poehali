
use strict;

use GD;
use List::Util 'first';

print STDERR "\n  ---|   'poehali' logo remover   (c) 2010  liosha, xliosha\@gmail.com\n\n";

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


print STDERR "$file\n";
print STDERR "Loading...            ";
my $im = new GD::Image( $file );
my ($width,$height) = $im->getBounds();
print STDERR "$width x $height image\n";


my $yindex = $im->colorResolve( 0xFF,0xFF,0x00 );
die unless defined $yindex;
print STDERR "Yellow is $yindex\n";

print STDERR "Processing...         ";

my @changes;
for my $y ( $height*0.1-140 .. $height*0.1+60, $height*0.95-140 .. $height*0.95+60, ) {
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

for my $change ( @changes ) {
    $im->setPixel( @$change );
}

printf STDERR "%d pixels changed\n", scalar @changes;

$file =~ s{(.*[/\\])?([^/\\]+)$}{\2};

print STDERR "Writing result...     ";
open OUT, '>', "$dir/$file";
binmode OUT;
print OUT $im->gif();
close OUT;
print STDERR "Ok\n";


print STDERR "All done!\n";


