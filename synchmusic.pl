#! /usr/bin/env perl
#
# File: synchmusic.pl
# Author: eweb
# Copyright eweb, 2012-2012
# Contents:
#
# Date:          Author:  Comments:
# 10th Sep 2012  eweb     #0008 Detect backup volume
#

use strict;

my $drive;
if ( -d "/Volumes/IOMEGA0" ) {
  $drive = "IOMEGA0";
}
elsif ( -d "/Volumes/iomega1" ) {
  $drive = "iomega1";
}

my $src = "/Users/eweb/Music/iTunes";
my $dst = "/Volumes/$drive/iTunes";


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

chdir( "/Volumes/$drive/projects/wacc" );
system( "git fetch --all");
