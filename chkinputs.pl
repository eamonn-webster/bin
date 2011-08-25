#
# File: chkinputs.pl
# Author: eweb
# Copyright WBT Systems, 1995-2009
# Contents:
#
# Date:          Author:  Comments:
#  2nd Oct 2009  eweb     #00008 input style classes
#
use strict;

if ( @ARGV == 0 ) {
  print "Usage: chkinputs.pl files\n";
}
else {
  while ( <@ARGV> ) {
    my $file = $_;
    #print $file . "\n";
    if ( open( IN, $file ) ) {
      my $lno = 0;
      while ( <IN> ) {
        my $line = $_;
        $lno++;
        if ( /<input([^>]+)\/>/ ) {
          #print $1 . "\n";
          my $attrs = $1;
          my $type;
          my $class;
          if ( $attrs =~ /type='([^']+)'/ ) {
            $type = $1;
          }
          elsif ( $attrs =~ /type="([^"]+)"/ ) { # "
            $type = $1;
          }
          if ( $attrs =~ /class='([^']+)'/ ) {
            $class = $1;
          }
          elsif ( $attrs =~ /class="([^"]+)"/ ) { # "
            $class = $1;
          }
          if ( $type eq "" ) {
            print "$file($lno) Error input tag has no type ($attrs)\n";
          }
          if ( $class eq "" ) {
            print "$file($lno) Error input tag has no class ($attrs)\n";
          }
  #        my @classAttrs = ($attrs =~ / class=/g);
  #        if ( @classAttrs > 1 ) {
  #          print "$file($lno) Error input tag has more than one class\n";
  #          print $line;
  #        }
  #        my @typeAttrs = ($attrs =~ / type=/g);
  #        if ( @typeAttrs > 1 ) {
  #          print "$file($lno) Error input tag has more than one type\n";
  #          print $line;
  #        }
          if ( $type ne "" and $class ne "" ) {
            my @classes = split( / /, $class );
            if ( !grep( /^TC$type$/, @classes ) ) {
              print "$file($lno) Error input tag class ($class) doesn't contain TC$type\n";
            }
          }
        }
        elsif ( /<input([^>]+)>/ ) {
          my $attrs = $1;
          print "$file($lno): Error input tag not closed\n";
          print $1 . "\n";
        }
        elsif ( /<input([^>]+)/ ) { # extends over next line...
          my $attrs = $1;
        }
      }
      close( IN );
    }
  }
}
