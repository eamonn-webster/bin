#
# File: minjs.pl
# Author: eweb
# Copyright WBT Systems, 1995-2010
# Contents:
#
# Date:          Author:  Comments:
# 26th Jul 2010  eweb     #00008 Script to minimise javascript files
# 27th Jul 2010  eweb     #00008 Output as abc-min.js
#
use strict;
use Getopt::Std;

my %opts = ( d => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("d:", \%opts) or @ARGV > 1 ) {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
}

my $yuicompressor = "c:/java/yuicompressor-2.4.2/build";

if ( defined( $opts{d} ) ) {
    $yuicompressor = $opts{d};
}

#my $pattern = $ARGV[0];
#$pattern = "*.js" unless ( $pattern );

sub run($) {
  my ($cmd) = @_;
  print "cmd: $cmd\n";
  system( $cmd );
}

#mkdir ( "min" );

#print "Searching $pattern\n";
foreach ( <*.js> ) {
  if ( /-min\.js$/ ) {
  }
  elsif ( /^(.+)\.js$/ ) {
    my $name = $1;
    run( "java -jar \"$yuicompressor/yuicompressor-2.4.2.jar\" -o $name-min.js $name.js" );
  }
}

#chdir( "min" );

#run( "zip ../minimised-js.zip *.js" );

