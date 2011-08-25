#!/usr/bin/perl
#
# File: incbuildno.pl
# Author: eweb
# Copyright WBT Systems, 2005-2010
# Contents: Incrementing buildno.h
#
# Date:          Author:  Comments:
# 17th Feb 2006  eweb
# 27th Mar 2006  eweb     Major minor & point.
# 15th Jun 2006  eweb     Display current version.
# 26th Sep 2006  eweb     Handle single digit builds.
#  2nd Jul 2007  eweb     #00008 use versioninfo.h if no buildno.h
#  9th Mar 2009  eweb     #00008 Other files containing version/buid numbers
# 16th Apr 2009  eweb     #00008 Attempt to handle other files that contain build bumber
# 14th Jan 2010  eweb     #00008 Increment build number in VersionInfo.java
# 21st Jan 2010  eweb     #00008 Java version info
# 18th Mar 2010  eweb     #00008 slashes
# 18th Mar 2010  eweb     #00008 Spaces
#  1st Apr 2010  eweb     #00008 Work on M: drive
#  1st Jun 2010  eweb     #00008 CNRVersionInfo.java refers to TopClass LMS

use strict;
use Cwd;

#print "os: " . $^O ."\n";

my $UnicodeBuild = "Y";
my $Debug = "N";

my ($Sec, $Min, $Hour, $Day, $Month, $Year ) = gmtime(time);
$Year = $Year + 1900;
my $Drive = $ARGV[0];
my $build = $ARGV[1];
my $Major = $ARGV[2];
my $Minor = $ARGV[3];
my $Point = $ARGV[4];

if ( $Drive eq "" ) {
  my $cwd = getcwd();
  if ( $cwd =~ /^(.):/ ) {
    if ( lc $1 eq "m" ) {
      if ( $cwd =~ /^(.:[\/\\][^\/\\]+)/ ) {
        $Drive = "$1";
      }
      else {
        print "Can't handle $cwd\n";
      }
    }
    else {
      $Drive = "$1:";
    }
  }
  else {
    $Drive = ".";
  }
}

sub osify($)
{
  my ($path) = @_;
  if ( $^O eq "MSWin32" )
    {
      $path =~ s!/!\\!g;
    }
  else
    {
      $path =~ s!\\!/!g;
    }
  return $path;
}

sub IncreaseBuildNumber($$$)
{
  my ($dir, $buildnoh, $buildno) = @_;
  my $PatternFound = 0;
  my $BuildLine;
  my $OutputLine = "";
  my $i = 0;
  my $CurrentMajor;
  my $CurrentMinor;
  my $CurrentPoint;
  my $CurrentBuild;

  my $file = osify("$dir/$buildnoh");

  if ( !chdir($dir) )
    {
      $Debug eq "N" or print "**** Cannot change to $dir\n";
      return;
    }
  #system("$Ctool checkout -c \"Incrementing build number\" $file");

  $file = osify($file);

  if ( !open (BUILDNO, $file) )
    {
      $Debug eq "N" or print "**** Cannot open file $file for reading\n";
      return;
    }
  my @Lines = reverse<BUILDNO>;
  close BUILDNO;

  for ($i = $#Lines; $i != -1; $i-- )
    {
      $BuildLine = $Lines[$i];
      if ( $BuildLine =~ /#define BUILDNUMBER\s+([0-9]+)/ )
        {
          $Debug eq "N" or print "found BUILDNUMBER\n";
          $PatternFound = 1;
          $CurrentBuild = $1;

          # Check to see if the Current build number is odd or even, if odd (ie the last build was an internal build,
          # we need to add 1 to the build number. If even (ie the last build was a release-type build) then we need
          # to add 2 to the build number. (Internal - odd, Release - Even)

          if ( $buildno ne "" )
            {
              print "$file: Current Build number is $CurrentBuild\n";
            }

          if ( $CurrentBuild == $buildno )
            {
              #print "$file: $CurrentBuild == $buildno\n";
              return;
            }
          elsif ( $CurrentBuild > $buildno )
            {
              #print "$file: $CurrentBuild > $buildno\n";
              #return;
            }
          else                                # If no '.' is found the current build number is even
            {
              #print "$file: $CurrentBuild < $buildno\n";
            }

          $CurrentBuild = sprintf( "%03d", $CurrentBuild );

          if ( $buildno ne "" )
            {
              my $Newline = "#define BUILDNUMBER   " . $buildno . "\n";
              $Lines[$i] = $Newline;

              my $buildstr = sprintf( "%03d", $buildno );

              if ( $UnicodeBuild eq "Y" )
                {
                  $Newline = "#define BUILDNOSTR    _TEXT(\"" . $buildstr . "\")\n";
                }
              else
                {
                  $Newline = "#define BUILDNOSTR    \"" . $buildstr . "\"\n";
                }

              $Lines[$i+1] = $Newline;
              if ( $UnicodeBuild eq "Y" )
                {
                  $Newline = "#define BUILDNO       _TEXT(\"Build " . $buildstr . "\")\n";
                }
              else
                {
                  $Newline = "#define BUILDNO       \"Build " . $buildstr . "\"\n";
                }

              $Lines[$i+2] = $Newline;
            }
        }
      elsif ( $BuildLine =~ /  Copyright WBT Systems, [0-9]+-([0-9]+)/ )
        {
          $Debug eq "N" or print "found Copyright\n";
          my $fileyear = $1;
          if ( $fileyear ne $Year )
            {
              $Lines[$i] = "  Copyright WBT Systems, 1995-$Year\n";
            }
        }
      elsif ( $BuildLine =~ /define THISYEAR/ )
        {
          $Debug eq "N" or print "found THISYEAR\n";
          $BuildLine =~ /"([0-9]+)"/;
          my $fileyear = $1;
          if ( $fileyear ne $Year )
            {
              if ( $UnicodeBuild eq "Y" )
                {
                  $Lines[$i] = "#define THISYEAR _TEXT(\"$Year\")\n";
                }
              else
                {
                  $Lines[$i] = "#define THISYEAR \"$Year\"\n";
                }
            }
        }
      #define FULLVERSIONNO _TEXT("7.4.0")
      elsif ( $BuildLine =~ /define FULLVERSIONNO/ )
        {
          $Debug eq "N" or print "found FULLVERSIONNO\n";
          $BuildLine =~ /"([0-9]\.[0-9]\.[0-9])"/;
          my $got = $1;
          my ( $major, $minor, $point ) = $BuildLine =~ /"([0-9])\.([0-9])\.([0-9])"/;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "FULLVERSIONNO mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "FULLVERSIONNO mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $CurrentPoint eq "" )
            {
              $CurrentPoint = $point;
            }
          elsif ( $CurrentPoint ne $point )
            {
              print "FULLVERSIONNO mismatch on point $CurrentPoint ne $point\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major.$Minor.$Point" )
            {
              #print "$got ne $Major.$Minor.$Point\n";
              if ( $UnicodeBuild eq "Y" )
                {
                  $Lines[$i] = "#define FULLVERSIONNO _TEXT(\"$Major.$Minor.$Point\")\n";
                }
              else
                {
                  $Lines[$i] = "#define FULLVERSIONNO \"$Major.$Minor.$Point\"\n";
                }
            }
        }
      #define MAINVERSIONNO _TEXT("7.4")
      elsif ( $BuildLine =~ /define MAINVERSIONNO/ )
        {
          $Debug eq "N" or print "found MAINVERSIONNO\n";
          $BuildLine =~ /"([0-9]\.[0-9])"/;
          my $got = $1;
          my ( $major, $minor ) = $BuildLine =~ /"([0-9])\.([0-9])"/;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "MAINVERSIONNO mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "MAINVERSIONNO mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major.$Minor" )
            {
              #print "$got ne $Major.$Minor\n";
              if ( $UnicodeBuild eq "Y" )
                {
                  $Lines[$i] = "#define MAINVERSIONNO _TEXT(\"$Major.$Minor\")\n";
                }
              else
                {
                  $Lines[$i] = "#define MAINVERSIONNO \"$Major.$Minor\"\n";
                }
            }
        }
      #define THREEDIGITVER _TEXT("740")
      elsif ( $BuildLine =~ /define THREEDIGITVER/ )
        {
          $Debug eq "N" or print "found THREEDIGITVER\n";
          $BuildLine =~ /"([0-9]{3})"/;
          my $got = $1;
          my ( $major, $minor, $point ) = $BuildLine =~ /"([0-9])([0-9])([0-9])"/;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "THREEDIGITVER mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "THREEDIGITVER mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $CurrentPoint eq "" )
            {
              $CurrentPoint = $point;
            }
          elsif ( $CurrentPoint ne $point )
            {
              print "THREEDIGITVER mismatch on point $CurrentPoint ne $point\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major$Minor$Point" )
            {
              #print "$got ne $Major$Minor$Point\n";
              if ( $UnicodeBuild eq "Y" )
                {
                  $Lines[$i] = "#define THREEDIGITVER _TEXT(\"$Major$Minor$Point\")\n";
                }
              else
                {
                  $Lines[$i] = "#define THREEDIGITVER \"$Major$Minor$Point\"\n";
                }
            }
        }
      #define REGKEYVERSION _TEXT("7.0")
      elsif ( $BuildLine =~ /define REGKEYVERSION/ )
        {
          $Debug eq "N" or print "found REGKEYVERSION\n";
          $BuildLine =~ /"([0-9]\.[0-9])"/;
          my ( $major, $minor ) = $BuildLine =~ /"([0-9])\.([0-9])"/;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "REGKEYVERSION mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $CurrentMinor eq "" )
            {
              #$CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              #print "mismatch on minor $CurrentMinor ne $minor\n";
            }
          my $got = $1;
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major.0" )
            {
              #print "$got ne $Major.0\n";
              if ( $UnicodeBuild eq "Y" )
                {
                  $Lines[$i] = "#define REGKEYVERSION _TEXT(\"$Major.0\")\n";
                }
              else
                {
                  $Lines[$i] = "#define REGKEYVERSION \"$Major.0\"\n";
                }
            }
        }
      #define HEXVER        0x0740
      elsif ( $BuildLine =~ /define HEXVER/ )
        {
          $Debug eq "N" or print "found HEXVER\n";
          $BuildLine =~ /0x0([0-9]{3})/;
          my $got = $1;
          my ( $major, $minor, $point ) = $BuildLine =~ /0x0([0-9])([0-9])([0-9])/;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "HEXVER mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "HEXVER mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $CurrentPoint eq "" )
            {
              $CurrentPoint = $point;
            }
          elsif ( $CurrentPoint ne $point )
            {
              print "HEXVER mismatch on point $CurrentPoint ne $point\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major$Minor$Point" )
            {
              #print "$got ne $Major$Minor$Point\n";
              $Lines[$i] = "#define HEXVER        0x0$Major$Minor$Point\n";
            }
        }
      #define MAJORREVISION 7
      elsif ( $BuildLine =~ /define MAJORREVISION / )
        {
          $Debug eq "N" or print "found MAJORREVISION\n";
          $BuildLine =~ /([0-9])/;
          my $got = $1;
          my $major = $got;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "MAJORREVISION mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major" )
            {
              #print "$got ne $Major\n";
              $Lines[$i] = "#define MAJORREVISION $Major\n";
            }
        }
      #define MINORREVISION 4
      elsif ( $BuildLine =~ /define MINORREVISION / )
        {
          $Debug eq "N" or print "found MINORREVISION\n";
          $BuildLine =~ /([0-9])/;
          my $got = $1;
          my $minor = $got;
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "MINORREVISION mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Minor" )
            {
              #print "$got ne $Minor\n";
              $Lines[$i] = "#define MINORREVISION $Minor\n";
            }
        }
      #define POINTREVISION 0
      elsif ( $BuildLine =~ /define POINTREVISION/ )
        {
          $Debug eq "N" or print "found POINTREVISION\n";
          $BuildLine =~ /([0-9])/;
          my $got = $1;
          my $point = $got;
          if ( $CurrentPoint eq "" )
            {
              $CurrentPoint = $point;
            }
          elsif ( $CurrentPoint ne $point )
            {
              print "POINTREVISION mismatch on point $CurrentPoint ne $point\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Point" )
            {
              #print "$got ne $Point\n";
              $Lines[$i] = "#define POINTREVISION $Point\n";
            }
        }
    }

  # If we can't find the pattern to replace then we need to uncheckout the buildno.h file
  if ( $PatternFound ne 1 )
    {
      print "**** Could not determine current build number from buildno.h - build number unaltered\n";
      #system("$Ctool uncheckout -rm $file");
    }
  elsif ( $buildno eq "" )
    {
      print "$file : $CurrentMajor.$CurrentMinor.$CurrentPoint.$CurrentBuild\n";
    }
  else
    {
      open (BUILDNO, ">$file");
      for ($i = $#Lines; $i != -1; $i-- )
        {
          $OutputLine = $Lines[$i];
          print BUILDNO $OutputLine;
        }
      close BUILDNO;

      #system("$Ctool checkin -nc $file");
      print "$file : build number changed from $CurrentBuild to $buildno.\n";
    }
}

sub IncreaseBuildNumberJava($$$)
{
  my ($dir, $buildnoh, $buildno) = @_;
  #print "IncreaseBuildNumberJava($dir, $buildnoh, $buildno)\n";
  my $PatternFound = 0;
  my $BuildLine;
  my $OutputLine = "";
  my $i = 0;
  my $CurrentMajor;
  my $CurrentMinor;
  my $CurrentPoint;
  my $CurrentBuild;

  my $file = osify("$dir/$buildnoh");

  if ( !chdir("$dir") )
    {
      $Debug eq "N" or print "**** Cannot change to $dir\n";
      return;
    }
  #system("$Ctool checkout -c \"Incrementing build number\" $file");

  $file = osify($file);

  if ( !open (BUILDNO, $file) )
    {
      print "**** Cannot open file $file for reading\n";
      return;
    }
  my @Lines = <BUILDNO>;
  close BUILDNO;

  for ($i = 0; $i <= $#Lines; $i++ )
    {
      $BuildLine = $Lines[$i];
      if ( $BuildLine =~ /(\s*)private static final String BUILD = "([0-9]+)"/ )
        {
          my $sp = $1;
          $Debug eq "N" or print "found BUILD\n";
          $PatternFound = 1;
          $CurrentBuild = $2;

          if ( $buildno ne "" )
            {
              print "$file: Current Build number is $CurrentBuild\n";
            }

          if ( $CurrentBuild == $buildno )
            {
              #print "$file: $CurrentBuild == $buildno\n";
              return;
            }
          elsif ( $CurrentBuild > $buildno )
            {
              #print "$file: $CurrentBuild > $buildno\n";
              #return;
            }
          else                                # If no '.' is found the current build number is even
            {
              #print "$file: $CurrentBuild < $buildno\n";
            }

          if ( $buildno ne "" )
            {
              my $buildstr = sprintf( "%03d", $buildno );
              my $Newline = $sp . "private static final String BUILD = \"$buildstr\";\n";
              $Lines[$i] = $Newline;
              $CurrentBuild = $buildstr;
            }
        }
      elsif ( $BuildLine =~ /(\s*)Copyright WBT Systems, ([0-9]+)-([0-9]+)/ )
        {
          $Debug eq "N" or print "found Copyright\n";
          my $sp = $1;
          my $startyear = $2;
          my $fileyear = $3;
          if ( $fileyear ne $Year )
            {
              $Lines[$i] = $sp . "Copyright WBT Systems, $startyear-$Year\n";
            }
        }
      #private static final String MAJOR = "9";
      elsif ( $BuildLine =~ /(\s*)private static final String MAJOR = "([0-9])"/ )
        {
          $Debug eq "N" or print "found MAJOR\n";
          my $sp = $1;
          my $got = $2;
          my $major = $got;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "MAJORREVISION mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Major" )
            {
              #print "$got ne $Major\n";
              $Lines[$i] = $sp . "private static final String MAJOR = \"$Major\";\n";
            }
        }
      #private static final String MINOR = "0";
      elsif ( $BuildLine =~ /(\s*)private static final String MINOR = "([0-9])"/ )
        {
          $Debug eq "N" or print "found MINOR\n";
          my $sp = $1;
          my $got = $2;
          my $minor = $got;
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "MINOR mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Minor" )
            {
              #print "$got ne $Major\n";
              $Lines[$i] = $sp . "private static final String MINOR = \"$Minor\";\n";
            }
        }
      #private static final String POINT = "0";
      elsif ( $BuildLine =~ /(\s*)private static final String POINT = "([0-9])"/ )
        {
          $Debug eq "N" or print "found POINT\n";
          my $sp = $1;
          my $got = $2;
          my $point = $got;
          if ( $CurrentPoint eq "" )
            {
              $CurrentPoint = $point;
            }
          elsif ( $CurrentPoint ne $point )
            {
              print "POINT mismatch on point $CurrentPoint ne $point\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and $got ne "$Point" )
            {
              #print "$got ne $Point\n";
              $Lines[$i] = $sp . "private static final String POINT = \"$Point\";\n";
            }
        }
      elsif ( $BuildLine =~ /(\s*)private static final String VERSION = / )
        {
          my $sp = $1;
          $Debug eq "N" or print "found VERSION\n";
          $BuildLine =~ /([0-9])\.([0-9])\.([0-9])/;
          my ($major, $minor, $point) = ($1, $2, $3);
          my $updateLine = 0;
          if ( $CurrentMajor eq "" )
            {
              $CurrentMajor = $major;
            }
          elsif ( $CurrentMajor ne $major )
            {
              print "VERSION mismatch on major $CurrentMajor ne $major\n";
            }
          if ( $CurrentMinor eq "" )
            {
              $CurrentMinor = $minor;
            }
          elsif ( $CurrentMinor ne $minor )
            {
              print "VERSION mismatch on minor $CurrentMinor ne $minor\n";
            }
          if ( $CurrentPoint eq "" )
            {
              $CurrentPoint = $point;
            }
          elsif ( $CurrentPoint ne $point )
            {
              print "VERSION mismatch on point $CurrentPoint ne $point\n";
            }
          if ( $Major ne "" and $Minor ne "" and $Point ne "" and "$Major.$Minor.$Point" ne "$major.$minor.$point" )
            {
              $Lines[$i] = $sp . "private static final String VERSION = \"$Major.$Minor.$Point\";\n";
            }
        }
    }


  #print "$CurrentMajor $CurrentMinor $CurrentPoint $CurrentBuild\n";
#exit;

  for ($i = 0; $i <= $#Lines; $i++ )
    {
      $BuildLine = $Lines[$i];
      if ( $BuildLine =~ /(\s*)private static final String VERSION_STRING =/ )
        {
          my $app = "TopClass";
          $app = "$app LMS" if ( $buildnoh eq "CNRVersionInfo.java" );
          $Lines[$i] = $1. "private static final String VERSION_STRING = \"$app Version $CurrentMajor.$CurrentMinor.$CurrentPoint Build $CurrentBuild\";\n";
        }
      elsif ( $BuildLine =~ /(\s*)private static final String VERSION = / )
        {
          $Lines[$i] = $1 . "private static final String VERSION = \"$CurrentMajor.$CurrentMinor.$CurrentPoint\";\n";
        }
    }

  # If we can't find the pattern to replace then we need to uncheckout the buildno.h file
  if ( $PatternFound ne 1 )
    {
      print "**** Could not determine current build number from $file - build number unaltered\n";
      #system("$Ctool uncheckout -rm $file");
    }
  elsif ( $buildno eq "" )
    {
      print "$file : $CurrentMajor.$CurrentMinor.$CurrentPoint.$CurrentBuild\n";
    }
  else
    {
      open (BUILDNO, ">$file");
      for ($i = 0; $i <= $#Lines; $i++ )
        {
          print BUILDNO $Lines[$i];
        }
      close BUILDNO;

      #system("$Ctool checkin -nc $file");
      print "$file : build number changed from $CurrentBuild to $buildno.\n";
    }
}

if ( $build eq "" )
  {
    #die "No build number specified\n";
  }
elsif ( ( $build + 1 ) - 1 ne $build )
  {
    die "Build number [$build] not a number\n";
  }

if ( -e "$Drive/topclass/oracle/topclass/sources/buildno.h" )
  {
    IncreaseBuildNumber( "$Drive/topclass/oracle/topclass/sources", "buildno.h", $build );
    IncreaseBuildNumber( "$Drive/topclass/oracle/plugins/sources", "buildno.h", $build );
    IncreaseBuildNumber( "$Drive/topclass/oracle/topclass/keygen/sources", "buildno.h", $build );
    IncreaseBuildNumber( "$Drive/utils/lfa", "buildno.h", $build );
    if ( -e "$Drive/topclass/java/topclass/src/com/wbtsystems/VersionInfo.java" )
      {
        IncreaseBuildNumberJava( "$Drive/topclass/java/topclass/src/com/wbtsystems", "VersionInfo.java", $build );
      }
    elsif ( -e "$Drive/topclass/java/cnr/src/com/wbtsystems/cnr/CNRVersionInfo.java" )
      {
        IncreaseBuildNumberJava( "$Drive/topclass/java/cnr/src/com/wbtsystems/cnr", "CNRVersionInfo.java", $build );
      }
  }
elsif ( -e "$Drive/topclass/oracle/topclass/sources/versioninfo.h" )
  {
    IncreaseBuildNumber( "$Drive/topclass/oracle/topclass/sources", "versioninfo.h", $build );
  }


#display( "$Drive\\topclass\\oracle\\topclass\\sources\\buildno.h" );
#display( "$Drive\\topclass\\oracle\\plugins\\sources\\buildno.h" );
#display( "$Drive\\topclass\\oracle\\topclass\\keygen\\sources\\buildno.h" );
#display( "$Drive\\utils\\lfa\\buildno.h" );
#
#display( "$Drive\\topclass\\java\\cnr\\src\\com\\wbtsystems\\cnr\\CNRVersionInfo.java" );
#display( "$Drive\\topclass\\oracle\\install\\projects\\TopClassServer\\Script Files\\setup.rul" );
#display( "$Drive\\topclass\\oracle\\install\\projects\\Build.tsb" );
#
#display( "$Drive\\topclass\\oracle\\topclass\\Scripts\\mssql\\tc_setenv.cmd" );
#display( "$Drive\\topclass\\oracle\\topclass\\Scripts\\mssql\\Upgrade\\tc7xx_upgrade.cmd" );
#display( "$Drive\\utils\\SCORMApplet\\SCORM1.2\\API.java" );
#
#sub display($)
#  {
#    my ($file) = @_;
#    my $cmd = "cmd /c dir /s /b \"$file\"";
#    #print "$cmd\n";
#    system( $cmd );
#  }


#textpad y:\topclass\java\cnr\src\com\wbtsystems\cnr\CNRVersionInfo.java
#textpad "y:\topclass\oracle\install\projects\TopClassServer\Script Files\setup.rul"
#textpad "y:\topclass\oracle\install\projects\TopClassServer\Text Substitutions\Build.tsb"
#textpad y:\topclass\oracle\plugins\sources\buildno.h
#textpad y:\topclass\oracle\topclass\keygen\sources\buildno.h
#textpad y:\topclass\oracle\topclass\Scripts\mssql\tc_setenv.cmd
#textpad y:\topclass\oracle\topclass\Scripts\mssql\Upgrade\tc7xx_upgrade.cmd
#textpad y:\topclass\oracle\topclass\sources\buildno.h
#textpad y:\utils\lfa\buildno.h
#textpad y:\utils\SCORMApplet\SCORM1.2\API.java

sub xxx($) {
  my ($file) = @_;
  if ( -e $file ) {
    print "textpad \"$file\"\n";
  }
}

if ( 0) {
  xxx( "\\topclass\\java\\cnr\\src\\com\\wbtsystems\\cnr\\CNRVersionInfo.java" );
  xxx( "\\topclass\\oracle\\install\\projects\\TopClassServer\\Script Files\\setup.rul" );
  xxx( "\\topclass\\oracle\\install\\projects\\TopClassServer\\Text Substitutions\\Build.tsb" );
  xxx( "\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\tc_setenv.cmd" );
  xxx( "\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\Upgrade\\tc7xx_upgrade.cmd" );
  xxx( "\\topclass\\oracle\\topclass\\sources\\buildno.h" );
  #xxx( "\\utils\\AutoDevBuild\\langutils.exe" );
  xxx( "\\utils\\SCORMApplet\\SCORM1.2\\API.java" );
}

sub ModifyTSBFile ($$) {
  my ($Ctool, $Project) = @_;

  my $InstallersRoot = "\\topclass\\oracle\\install\\projects";
  my $ViewDriveName = "";

  #@TSBsUpdated = ( @TSBsUpdated, $Project );

  #my $BuildDir = InstallerDir( $Project ) . "\\";

  my $TSBPathAndFilename = "$InstallersRoot\\$Project\\Text Substitutions\\Build.tsb";
  if ( $Project eq "Publisher" && ! -d "$InstallersRoot\\$Project" )
    {
      $TSBPathAndFilename = "$ViewDriveName\\authoring\\suite\\installer${Major}0\Publisher ${Major}.0";
    }
  #my $ReplacementLine    = "value=$BuildDir\n";

  print "\nModifying The Installshield Build.tsb file for $Project\n";
  #print $BuildLog "\n<h3>Modifying The Installshield Build.tsb file for $Project<\/h3>\n";

  #print $BuildLog "TSBPathAndFilename is $TSBPathAndFilename<br />\n";
  #print $BuildLog "BuildDir is $BuildDir<br />\n";

  my $buildStatus = 1;
  my $SearchPattern = "\\[<BUILD>\\]";

  # Open the Build.tsb file and put contents into a line array.
  if ( !open (TSBFILE, $TSBPathAndFilename ) )
    {
      print "**** Cannot open file $TSBPathAndFilename for reading\n";
      $buildStatus = 0;
      return $buildStatus;
    }

  my @TSBLines = <TSBFILE>;
  close TSBFILE;

  my $fileChanged    = 0;                    # Did we change the file initialise to FALSE
  my $PatternFound   = 0;                    # Initialise pattern search variable to FALSE
  my $i              = 0;

  for ($i = 0; $i <= $#TSBLines; $i++ )         # For each of the lines read freom the file into the array
    {
      if ( $TSBLines[$i] =~ /$SearchPattern/ ) # Look for the BUILD search string
        {
          $PatternFound = 1;                   # Found it, set pattern search variable to TRUE
          my $ReplacementLine = $TSBLines[$i+1];

          my $MNP = "$Major.$Minor.$Point";
          my $buildstr = sprintf( "%03d", $build );

          $ReplacementLine =~ s![0-9]\.[0-9]\.[0-9]!$MNP!;
          $ReplacementLine =~ s!build[0-9][0-9][0-9]!build$buildstr!;
          if ( $TSBLines[$i+1] ne $ReplacementLine )
            {
              $fileChanged = 1; # yes we did
              my $a = $TSBLines[$i+1];
              my $b = $ReplacementLine;
              chomp $a;
              chomp $b;
              print "changing from [$a] to [$b]\n";
              #print $BuildLog "changing from [$a] to [$b]<br />\n";
              $TSBLines[$i + 1] = $ReplacementLine; # Replace the current line with the new location.
            }
        }
    }

  if ( $PatternFound ne 1 )                  # If we didn't find the
    {
      #print $BuildLog "Could not determine current build directory in $TSBPathAndFilename<br />\n";
      print "Could not determine current build directory in $TSBPathAndFilename\n";
      $buildStatus = 0;
    }
  elsif ( $fileChanged ne 1 )
    {
      #print $BuildLog "Build.tsb file unchanged.<br /><br />\n";
      print "Build.tsb file unchanged.\n";
    }
  else
    {
      ## A change is required...

      #CheckoutFile($Ctool, $TSBPathAndFilename) unless ( $justKidding eq "Y" );

      if ( open (TSBFILE, ">$TSBPathAndFilename") )    # Open the Build.tsb file for output (overwrite existing content)
        {
          for ($i = 0; $i <= $#TSBLines; $i++ )         # For each of the lines read freom the file into the array
            {
              print TSBFILE $TSBLines[$i];           # Write the current array line to the file.
            }
          close TSBFILE;

          #CheckinFile($Ctool, $TSBPathAndFilename, $fileChanged);

          #print $BuildLog "Build.tsb file modified successfully.<br /><br />\n";
          print "Build.tsb file modified successfully.\n";
        }
      else
        {
          #print $BuildLog "Failed to open $TSBPathAndFilename for output<br />\n";
          print "Failed to open $TSBPathAndFilename for output\n";
          $buildStatus = 0;
        }
    }

  return $buildStatus;
}

#ModifyTSBFile( "", "MSSQLInstaller" );
#ModifyTSBFile( "", "OracleInstaller" );
#ModifyTSBFile( "", "Publisher" );
#ModifyTSBFile( "", "TopClassMobile" );
#ModifyTSBFile( "", "TopClassServer" );
