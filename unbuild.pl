#
#  File: unbuild.pl
#  Author: eweb
#
# Date:          Author:  Comments:
#  4th Sep 2006  eweb     Changes to undo to do a build again.
#  4th May 2007  eweb     #00008 Remove label from esd vob as well
# 10th Nov 2008  eweb     #00008 Rename rather than remove label, determine args, don't bother with installer files.

#
# What to do if we need to build again.
# a complete rebuild as opposed to nudging a few labels.
#

use strict;
use Getopt::Std;

my @VobList = ("\\topclass", "\\3rdparty", "\\utils", "\\authoring", "\\esd");

my $Drive = "";
my $Major = "";
my $Minor = "";
my $Point = "";
my $Build = "";
my $rmlabel;

my %opts = ( d => undef(),
             b => undef(),
             m => undef(),
             n => undef(),
             p => undef(),
             R => undef(),
           );

  # Was anything other than the defined option entered on the command line?
  if ( !getopts("d:m:n:p:b:R:", \%opts) or @ARGV > 0 )
    {
      die "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
      #Usage();
      #exit;
    }

  if ( defined( $opts{d} ) )
    {
      $Drive = $opts{d};
    }
  GetBuildNumber( $Drive );

  if ( defined( $opts{m} ) )
    {
      $Major = $opts{m};
    }
  if ( defined( $opts{n} ) )
    {
      $Minor = $opts{n};
    }
  if ( defined( $opts{p} ) )
    {
      $Point = $opts{p};
    }
  if ( defined( $opts{b} ) )
    {
      $Build = $opts{b};
    }
  if ( defined( $opts{R} ) )
    {
      $rmlabel = $opts{R} eq "Y";
    }

#die "Must specify drive -d\n" if ( $Drive eq "" );
#die "Must specify major -m\n" if ( $Major eq "" );
#die "Must specify minor -n\n" if ( $Minor eq "" );
#die "Must specify point -p\n" if ( $Point eq "" );
die "Must specify build -b\n" if ( $Build eq "" );

my $cmd;

$cmd = "clearvtree \"$Drive\\topclass\\oracle\\topclass\\sources\\buildno.h\"";
print "$cmd\n";
system( $cmd );

$cmd = "clearvtree \"$Drive\\topclass\\java\\cnr\\src\\com\\wbtsystems\\cnr\\CNRVersionInfo.java\"";
print "$cmd\n";
system( $cmd );

if ( 0 )
  {
    $cmd = "clearvtree \"$Drive\\topclass\\oracle\\install\\projects\\TopClassServer\\Script Files\\setup.rul\"";
    print "$cmd\n";
    system( $cmd );

    $cmd = "cleartool find $Drive\\topclass\\oracle\\install\\projects -name Build.tsb -exec \"clearvtree \\\"%CLEARCASE_PN%\\\"\"";
    print "$cmd\n";
    system( $cmd );
  }

my $label = "TC_" . "$Major$Minor$Point" . "_BUILD_" . "$Build";

for my $vob (@VobList)
  {
    if ( $rmlabel )
      {
        $cmd = "cleartool rmtype -rmall -force lbtype:$label\@$vob";
      }
    else
      {
        $cmd = "cleartool rename lbtype:$label\@$vob ${label}_NOT";
      }
    print "$cmd\n";
    system( $cmd );
  }

sub GetBuildNumber( $ )
{
  my ($drive) = @_;

  my $BuildNoFile = "$drive/topclass/oracle/topclass/sources/buildno.h";
  if ( ! -e $BuildNoFile )
    {
      my $VersionInfoFile = "$drive/topclass/oracle/topclass/sources/versioninfo.h";
      if ( -e $VersionInfoFile )
        {
          $BuildNoFile = $VersionInfoFile;
        }
      else
        {
          my $NeoBuildNoFile = "$drive/topclass/neo/sources/buildno.h";
          if ( -e $NeoBuildNoFile )
            {
              $BuildNoFile = $NeoBuildNoFile;
            }
          else
            {
              my $VersionInfoFile = "$drive/topclass/neo/sources/versioninfo.h";
              if ( -e $VersionInfoFile )
                {
                  $BuildNoFile = $VersionInfoFile;
                }
            }
        }
    }
  print "$BuildNoFile\n";

  if ( !open (BUILDNO, $BuildNoFile) )
    {
      print "**** Cannot open file $BuildNoFile for reading\n";
      return;
    }

  while ( <BUILDNO> )
    {
      if ( /\#define BUILDNUMBER +([0-9]+)/ )
        {
          $Build = $1;
          #$Build++;
          #$Build--;
        }
      elsif ( /\#define MAJORREVISION +([0-9]+)/ )
        {
          $Major = $1;
        }
      elsif ( /\#define MINORREVISION +([0-9]+)/ )
        {
          $Minor = $1;
        }
      elsif ( /\#define POINTREVISION +([0-9]+)/ )
        {
          $Point = $1;
        }
    }
  close BUILDNO;
  #if ( $Build % 2 == 1 )
  #  {
  #    $Build--;
  #  }
  if ( $Build < 0 )
    {
    }
  elsif ( $Build < 10 )
    {
      $Build = "00" . $Build;
    }
  elsif ( $Build < 100 )
    {
      $Build = "0" . $Build;
    }
}

