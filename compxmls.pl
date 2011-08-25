use strict;

my $sourcesDir = $ARGV[0];
if ( $sourcesDir ) {
  chdir( $sourcesDir );
}

#include "kDefaultLwObjXml.inc"

#include "kDefaultShoppingCartXml.inc"

#include "kDefaultHistoryXml.inc"

my @files = qw/LwObj ShoppingCart History CloneSpecs/;
foreach ( @files ) {
    my $stem = $_;
    my $file = "$stem.xml";
    my $output = "kDefault${stem}Xml.inc";
    if ( !-e $output ) {
      print "$file to $output\n";

      my $cmd = "perl xmltostring.pl $file $output";
      print "$cmd\n";
      system( $cmd );
    }
}

