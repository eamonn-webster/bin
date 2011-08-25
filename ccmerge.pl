#!usr/bin/perl
#
# File: ccmerge.pl
# Author: eweb
# Copyright eweb, 1998-2011
# Contents:
#
# Date:          Author:  Comments:
# 19th Feb 2006  eweb     Arguments to specify version and branch number
# 27th Nov 2008  eweb     #00008 Determine version and branch number
#  6th May 2010  eweb     #00008 Main is 8.1.0
# 30th Nov 2010  eweb     #00008 List of vobs
# 14th Jan 2011  eweb     #00008 machine names
# 18th Mar 2011  eweb     #00008 810 branched at build 090
# 29th Mar 2011  eweb     #00008 3 variants of main view

# TODO #00008 not all vobs mounted
# TODO #00008 naming convention for main branch

use strict;

print "perl $0 @ARGV\n";

my $ver = $ARGV[0];
my $brn = $ARGV[1];

my $main_ver = "900";
# version of /topclass/oracle/topclass/sources/buildno.pl@@\main\LATEST

my $user = lc $ENV{USERNAME};
my $host = lc $ENV{COMPUTERNAME};

#print "\$ver $ver \$brn $brn\n";
if ( $ver eq "" or $brn eq "" ) {
  #print "Need to determine $ver and $brn\n";
  if ( open( CS, "cleartool catcs |" ) ) {
    while ( <CS> ) {
      #print;
      chomp;
      # remove comments...
      s!#.+!!g;

      if ( /-mkbranch (.+)/ ) {
        my $b = $1;
        if ( $b ne lc $b ) {
          print "ERROR: branch names should be all lower case\n";
        }
        #print "Branch is $b\n";
        if ( $b =~ /([a-z]+)_([0-9]+)_work_([a-z0-9]+)/ ) {
          print "user: $1 version: $2 branch: $3\n";
          if ( $1 eq $user ) {
            $ver = $2;
            $brn = $3;
            last;
          }
        }
      }
    }
    close( CS );
  }
}

my $main_branch = "main";
my $work_branch = "${user}_${ver}_work_${brn}";

my $main_view = "${user}_$host";
# or perhaps my $main_view = "${host}_main";
my $work_view = "${user}_${ver}_${host}";

# all except the version on main.. the version on main...

# three choices for the main view
# 1) ${host}_main      prism_main
# 2) ${host}_${ver}    prism_900
# 3) ${user}_${host}   eweb_prism

if ( $ver ne $main_ver ) {
  $main_view = "${host}_${ver}";
  $main_branch = "${ver}_branch";
}
else {
  $main_view = "${host}_main";
  my $x = `cleartool lsview -short $main_view`;
  chomp( $x );
  #print "$x\n";
  if ( $x eq $main_view ) {
  }
  else {
    $main_view = "${host}_${ver}";
    $x = `cleartool lsview -short $main_view`;
    chomp( $x );
    #print "$x\n";
    if ( $x eq $main_view ) {
    }
    else {
      $main_view = "${user}_${host}";
    }
  }
  $main_branch = "main";
}

my $vobs = "\\topclass \\authoring \\utils \\3rdparty";

run( "start clearmrgman.exe /toview $work_view /branch $main_branch /namelist $vobs" );
run( "start clearmrgman.exe /toview $main_view /branch $work_branch /namelist $vobs" );

sub run($) {
  my ($cmd) = @_;
  print "$cmd\n";
  system( $cmd );
}
