#
# File: tmpltostring.pl
# Author: nickm
# Copyright WBT Systems, 2002-2010
# Contents:
#
# Date:          Author:  Comments:
# 11th Dec 2002  eweb     Output line breaks.
# 19th Feb 2003  eweb     Need to escape backslashes
# 18th Sep 2003  eweb     Unicode.
# 24th Sep 2008  eweb     #11092 handle files greater than 32k
# 11th Nov 2008  eweb     #11092 better handle files greater than 32k
#  4th Feb 2009  eweb     #00008 Handle zero length and missing files
# 27th Aug 2010  eweb     #00008 Wrong name for parts
# 15th Sep 2010  eweb     #00008 Handling eoln
#

my $type = "Template";
my $ext = "tmpl";

open (OUTFILE,">$ARGV[1]") or die "ERROR: can't open $ARGV[1]\n";
open (FILE,$ARGV[0]) or print "ERROR: can't open $ARGV[0]\n";
$ARGV[0] =~ /([A-Za-z0-9\-_]*).$ext/;

my $name = $1;

my $filesize = (stat($ARGV[0]))[7];
#print "size $filesize\n";

if ( $filesize > 30000 )
  {
    print "Info: $ARGV[0] too large will be split\n";
    my $part = 1;
    my $size = 0;
    print OUTFILE "const TCHAR* kDefault${name}${type}$part = \n";
    while(<FILE>)
      {
        my $linelength = length($_) + 1; # allow for \r
        if ( $size + $linelength > 30000 )
          {
            print OUTFILE ";\n";
            $part++;
            $size = 0;
            print OUTFILE "const TCHAR* kDefault${name}${type}$part = \n";
          }
        $size += $linelength;
        s/\\/\\\\/g;
        s/\"/\\\"/g; #"
        s/\r//;
        s/\n/\\r\\n/;
        print OUTFILE "_TEXT(\"$_\")\n";
      }
    print OUTFILE ";\n";

    print OUTFILE "const String kDefault${name}${type}( kDefault${name}${type}1";
    for ( my $i = 2; $i <= $part; $i++ )
      {
        print OUTFILE ", kDefault${name}${type}${i}";
      }
    print OUTFILE " );\n";
    close FILE;
  }
elsif ( $filesize == 0 )
  {
    print OUTFILE "const TCHAR* kDefault${name}${type} = _TEXT(\"\");\n";
    close FILE;
  }
else
  {
    print OUTFILE "const TCHAR* kDefault${name}${type} = \n";
    while(<FILE>)
      {
        s/\\/\\\\/g;
        s/\"/\\\"/g; #"
        s/\r//;
        s/\n/\\r\\n/;
        print OUTFILE "_TEXT(\"$_\")\n";
      }
    print OUTFILE ";\n";
    close FILE;
  }
close OUTFILE;


