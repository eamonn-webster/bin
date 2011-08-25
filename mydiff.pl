#!/usr/bin/perl

use strict;

my $dir1 = $ARGV[0];
my $dir2 = $ARGV[1];

$dir1 .= "/" unless ( $dir1 =~ m!/$! );
$dir2 .= "/" unless ( $dir2 =~ m!/$! );

my $cmd = "diff -q -r -s $dir1 $dir2";
if ( open( DIFF, "$cmd |" ) ) {
  while ( <DIFF> ) {
    if ( /Only in \Q$dir1\E(.*): (.+)/ ) {
      my $f = $2;
      $f = "$1/$2" unless ( $1 eq "" );
      print "$f\tonly in $dir1\t-\t-\n";
    }
    elsif ( /Only in \Q$dir2\E(.*): (.+)/ ) {
      my $f = $2;
      $f = "$1/$2" unless ( $1 eq "" );
      print "$f\tonly in $dir2\t-\t-\n";
    }
    elsif ( /Files \Q$dir1\E(.+) and \Q$dir2\E(.+) are identical/ ) {
      #print "identical$1\n";
    }
    elsif ( /Files \Q$dir1\E(.+) and \Q$dir2\E(.+) differ/ ) {
      #print "In both $1\n";
      if ( $1 ne $2 ) {
        print "======================\n$_";
      }
      else {
        my $time1 = (stat("$dir1/$1"))[9];
        my $time2 = (stat("$dir2/$1"))[9];
        #print "$time1 $time2\n";
        if ( $time1 gt $time2 ) {
          #print "$dir1 is more recent\n";
          print "$1\tdifferent ($dir1 is more recent)\t-\t-\n";
        }
        elsif ( $time1 lt $time2 ) {
          #print "$dir2 is more recent\n";
          print "$1\tdifferent ($dir2 is more recent)\t-\t-\n";
        }
        elsif ( $time1 eq $time2 ) {
          #print "The same\n";
        }
        else {
          #print "======================\n$time1 $time2\n";
        }
      }
    }
    else {
      #print "======================\n$_";
    }
  }
  close( DIFF );
}

