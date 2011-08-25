#
#  File: updateexe.pl
#  Author: eweb
#  Contents: Update an exe iff the version number is greater
#
# Date:          Author:  Comments:
# 12th Apr 2007  eweb     Created.
#

use strict;

sub CopyFile( $$ )
  {
    my ( $source, $dest ) = @_;
    my $cmd = "copy $source $dest";
    print "$cmd\n";
    system( $cmd );
  }

my $source = $ARGV[0];
my $dest = $ARGV[1];

if ( -e $source and ! -e $dest )
  {
    CopyFile( $source, $dest );
  }
elsif ( -e $source and -e $dest )
  {
    my $sourceFileVer = `filever $source`;
    my $destFileVer = `filever $dest`;

    $sourceFileVer =~ /[A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* +([0-9\.]* )/;

    my $sourceVer = $1;

    $destFileVer =~ /[A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* +([0-9\.]* )/;

    my $destVer = $1;

    #print "$source $sourceVer\n";
    #print "$dest $destVer\n";
    if ( $sourceVer eq $destVer )
      {
      }
    elsif ( $sourceVer gt $destVer )
      {
        CopyFile( $source, $dest );
      }
    elsif ( $sourceVer lt $destVer )
      {
        #CopyFile( $source, $dest );
      }
  }

