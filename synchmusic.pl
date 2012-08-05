#! /usr/bin/env perl

use strict;

my $src = "/Users/eweb/Music/iTunes";
my $dst;
if ( -d "/Volumes/IOMEGA0" ) {
  $dst = "/Volumes/IOMEGA0/iTunes"
}
elsif ( -d "/Volumes/iomega1" ) {
  $dst = "/Volumes/iomega1/iTunes"
}

my $rsyncflags = "rt";
# r recursive
# l preserve symlinks
# p preserve permissions
# t preserve times
# g preserve group
# o preserve owner
# D same as --devices --specials

my $cmd = "rsync -rtvi $src/ $dst";
print "$cmd\n";
system ( $cmd );

chdir( "/Volumes/IOMEGA0/projects/wacc" );
system( "git fetch --all");

chdir( "/Volumes/iomega1/projects/wacc" );
system( "git fetch --all");

