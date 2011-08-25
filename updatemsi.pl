#
# File: updatemsi.pl
# Author: bob
# Copyright WBT Systems, 1995-2011
# Contents:
#
# Date:          Author:  Comments:
# 10th Nov 2009  bob      #00008 perl script to update .msifact
# 27th Jan 2011  bob      #00008 Set product name, version and description
#

use strict;

my $drive = lc $ARGV[0];
my $major = $ARGV[1];
my $minor = $ARGV[2];
my $point = $ARGV[3];
my $build = $ARGV[4];

my $msifact = "$drive\\Installer_Files\\topclass8_installer.msifact";

#$msifact = "$drive\\temp\\TC800b090.msifact";

if ( !open( IN, $msifact ) ) {
  print "Error couldn't open $msifact $!\n";
}
else {
  if ( !open( OUT, ">$msifact.new" ) ) {
    print "Error couldn't open $msifact.new $!\n";
    close( IN );
  }
  else {
    my $changed = 1;

    while ( <IN> ) {
      s!.:\\Installer_Files\\build([0-9]+)!$drive\\Installer_Files\\build${build}!g;
      s!TC[0-9][0-9][0-9]b[0-9][0-9][0-9]!TC${major}${minor}${point}b${build}!g;
      s!TCDB[0-9][0-9][0-9]Oracleb[0-9][0-9][0-9]!TCDB${major}${minor}${point}Oracleb${build}!g;
      s!TCDB[0-9][0-9][0-9]MSSQLb[0-9][0-9][0-9]!TCDB${major}${minor}${point}MSSQLb${build}!g;
      s!<ProductName>TopClass [0-9].[0-9]</ProductName>!<ProductName>TopClass ${major}.${minor}</ProductName>!g;
      s!<ProductVersion>[0-9].[0-9].[0-9]</ProductVersion>!<ProductVersion>${major}.${minor}.${point}</ProductVersion>!g;
      s!Description="TopClass [0-9].[0-9]"!Description="TopClass ${major}.${minor}"!g;
      print OUT;
    }
    close( IN );
    close( OUT );
    if ( $changed ne 0 ) {
      unlink( "$msifact.old" );
      rename( $msifact, "$msifact.old" );
      rename( "$msifact.new", $msifact );
    }
    else {
      unlink( "$msifact.new" );
    }
  }
}
