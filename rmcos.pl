#!/usr/bin/perl

use strict;

my $verbose;

my @vobs;

my $remove = lc $ARGV[0];

my $cmd = "cleartool lsvob -short";

print "$cmd => " . qx/$cmd/;

if ( open( VOBS, "$cmd 2>&1 |") ) {
  while ( <VOBS> ) {
    print if ( $verbose );
    chomp;
    @vobs = (@vobs, $_);
  }
  close( VOBS );
}
print "vobs: @vobs\n" if ( $verbose );

foreach my $vob ( @vobs ) {
  $cmd = "cleartool describe -long vob:$vob";
  my @views;
  if ( open( DESC, "$cmd 2>&1 |") ) {
    while ( <DESC> ) {
      print if ( $verbose );
      chomp;
      if ( /^\s*([^:]+):(.+) \[uuid (.+)\]/ ) {
        my $host = $1;
        my $path = $2;
        my $uuid = $3;
        @views = (@views, $uuid);
      }
    }
    close( DESC );
    print "$vob views: @views\n" if ( $verbose );
    foreach my $uuid ( @views ) {
      $cmd = "cleartool rmview -force -vob $vob -uuid $uuid";
      print "$cmd\n";
      if ( $remove eq "y" and open( RMVW, "$cmd 2>&1 |") ) {
        while ( <RMVW> ) {
          print if ( $verbose );
        }
        close( RMVW );
      }
    }
  }
}
