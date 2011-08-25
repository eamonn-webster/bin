#
# File: updateVer.pl
# Author: jbt
# Copyright WBT Systems, 2005-2010
# Contents: Updating version numbers where necessary
#
# Date:          Author:  Comments:
# 29th Jan 2007  eweb     use strict
# 29th Jan 2007  eweb     merge of John's and my approaches.
# 29th Jan 2007  eweb     Reset build to 1 not 0.
# 13th Apr 2007  eweb     #00008 Process Makefile.gnu and Neo/Makefile.gnu
# 25th Apr 2008  eweb     #00008 Java version files, ability to set build, error handling
# 28th Apr 2008  eweb     #00008 RegKeyVersion
# 27th Nov 2008  eweb     #00004 Eclipse settings
# 28th Jan 2010  eweb     #00008 param checks, eclipse files
#  1st Apr 2010  eweb     #00008 deploy-name and context-root
#  1st Jul 2010  eweb     #00007 Reformated
#  1st Jul 2010  eweb     #00008 Process cookieauth.html
#

# TODO #00008 file: \topclass\java\cnr\.project
# change
#  <name>cnr742</name>
# to
#  <name>cnr800</name>
# TODO #00008 file: \topclass\java\cnr\..settings\org.eclipse.wst.common.component
# change
#   <wb-module deploy-name="cnr742">
#     <property name="context-root" value="cnr742"/>
# to
#   <wb-module deploy-name="cnr800">
#     <property name="context-root" value="cnr800"/>

use strict;
use Getopt::Std;

use File::Temp qw/ :mktemp  /;
use File::Copy;
use File::Basename;


my $cleartool = "cleartool";
#$cleartool = "escc";

my $usage="Usage: updateVer.pl [-h] -c <Drive Letter> -m <MajorReleaseNo> -n <MinorReleaseNo> -p <PointReleaseNo> -b <buildno>\n"
    . "-h get help on usage (you're reading it)\n"
    . "-c ClearCase drive\n"
    . "-m TopClass Major version number\n"
    . "-n TopClass Minor version number\n"
    . "-p TopClass Point version number\n"
    . "-b TopClass build number\n";

my %opts
  = ( c => undef(),
      m => undef(),
      n => undef(),
      p => undef(),
      b => undef(),
    );

getopts( 'hc:m:n:p:b:', \%opts );

if ( $opts{h} || !defined($opts{c}) || !defined($opts{m}) || !defined($opts{n}) || !defined($opts{p}) ) {
  die "$usage";
}

# find the current version number from buildno.h

my $cur_m = 0;
my $cur_n = 0;
my $cur_p = 0;
my $cur_b = 0;

my $ccdrive = $opts{c};
my $buildno = "$ccdrive/topclass/oracle/topclass/sources/buildno.h";

open BUILDNO, $buildno or die "Can't open $buildno: $!";

while ( <BUILDNO> ) {
  if ( /#define MAJORREVISION (\d+)/){
    $cur_m = $1;
  }
  if ( /#define MINORREVISION (\d+)/){
    $cur_n = $1;
  }
  if ( /#define POINTREVISION (\d+)/){
    $cur_p = $1;
  }
  if ( /#define BUILDNUMBER +(\d+)/){
    $cur_b = $1;
  }
}

close BUILDNO;

print "Updating from V $cur_m.$cur_n.$cur_p.$cur_b OK?";

my $key = getc();

if ( lc $key ne "y" ) {
  die;
}

print "\n";

#I'm lazy

my $new_m = $opts{m};
my $new_n = $opts{n};
my $new_p = $opts{p};
my $new_b = $opts{b};

my $MNP = "$new_m$new_n$new_p";

if ( $MNP !~ /^[0-9][0-9][0-9]$/ ) {
  die "invalid mnp $MNP\n";
}
my $new_dot = "$new_m.$new_n.$new_p";
my $cur_dot = "$cur_m.$cur_n.$cur_p";

my $new_next = "$new_m.$new_n." . ($new_p + 1);
my $cur_next = "$cur_m.$cur_n." . ($cur_p + 1);

my $new_no = $new_m . $new_n . $new_p;
my $cur_no = $cur_m . $cur_n . $cur_p;

if ( $new_b eq "" ) {
  $new_b = "001";
}

my $new_bb = $new_b;
$new_bb++;
$new_bb--;

$new_b = sprintf("%03d", $new_bb);

if ( 1 ) {
  # cookieauth.html
  fileInsertAfter("$ccdrive\\topclass\\oracle\\topclass\\sources\\spi\\cookie\\cookieauth.html",
                  ["<option value=\"topclass.dll\">topclass.dll</option>"], ["<option value=\"tce${MNP}iis.dll\">tce${MNP}iis.dll<\/option>"]);

  # MSSQL installer
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\MSSQLInstaller\\MSSQLInstaller.ipr",
                       ["Version=$cur_dot"], ["Version=$new_dot"]);
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\MSSQLInstaller\\String Tables\\0009-English\\value.shl",
                       ["PRODUCT_VERSION=$cur_dot", "Upgrade=Upgrade to $cur_dot"],
                       ["PRODUCT_VERSION=$new_dot", "Upgrade=Upgrade to $new_dot"]);
  #Oralce installer
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\OracleInstaller\\OracleInstaller.ipr",
                       ["Version=$cur_dot"],
                       ["Version=$new_dot"]);
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\OracleInstaller\\String Tables\\0009-English\\value.shl",
                       ["PRODUCT_VERSION=$cur_dot", "Upgrade=Upgrade to $cur_dot"],
                       ["PRODUCT_VERSION=$new_dot", "Upgrade=Upgrade to $new_dot"]);

  #Publisher installer
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\Publisher\\Publisher.ipr",
                       ["Version=$cur_dot"],
                       ["Version=$new_dot"]);
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\Publisher\\Shell Objects\\Default.shl",
                       ["TopClass Publisher V$cur_dot"],
                       ["TopClass Publisher V$new_dot"]);

  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\Publisher\\String Tables\\0009-English\\value.shl",
                       ["TopClass Publisher $cur_dot"],
                       ["TopClass Publisher $new_dot"]);


  #TopClass installer
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\TopClassServer\\TopClassServer.ipr",
                       ["Version=$cur_dot"],
                       ["Version=$new_dot"]);
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\TopClassServer\\String Tables\\0009-English\\value.shl",
                       ["PRODUCT_VERSION=$cur_dot"],
                       ["PRODUCT_VERSION=$new_dot"]);

  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\TopClassServer\\Script Files\\setup.rul",
                       ["CURRENT_MNP \"$cur_dot\.0\"", "CURRENT_VER \"$cur_dot\.[0-9]+\"", "NEXT_MNP \"$cur_next\.0\""],
                       ["CURRENT_MNP \"$new_dot.0\"",  "CURRENT_VER \"$new_dot.$new_b\"",  "NEXT_MNP \"$new_next.0\""]);

  #Mobile installer
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\TopClassMobile\\TopClassMobile.ipr",
                       ["Version=$cur_dot"],
                       ["Version=$new_dot"]);
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\install\\projects\\TopClassMobile\\String Tables\\0009-English\\value.shl",
                       ["PRODUCT_VERSION=$cur_dot"],
                       ["PRODUCT_VERSION=$new_dot"]);

  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\topclass\\Makefile.gnu",
                       ["VERNUM = $cur_no"],
                       ["VERNUM = $new_no"]);

  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\topclass\\Neo\\Makefile.gnu",
                       ["VERNUM = $cur_no"],
                       ["VERNUM = $new_no"]);
}

processProject("$ccdrive\\topclass\\oracle\\topclass\\cgi.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\CgiClient.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\convdll.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\iPlanet40API.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\isapistub.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\mobile.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\tcstandard.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\topclass.dsp");
processProject("$ccdrive\\topclass\\oracle\\topclass\\mobile.vcproj");
processProject("$ccdrive\\topclass\\oracle\\topclass\\topclass.vcproj");
processProject("$ccdrive\\topclass\\oracle\\topclass\\cgi.vcproj");
processProject("$ccdrive\\topclass\\oracle\\topclass\\isapistub.vcproj");

if ( 1 ) {
  #build no
  fileSearchAndReplace("$ccdrive\\topclass\\oracle\\topclass\\sources\\buildno.h",
                       ["FULLVERSIONNO _TEXT\\(\"". $cur_dot ."\"\\)", "MAINVERSIONNO _TEXT\\(\"". $cur_m .".". $cur_n ."\"\\)", "MAJORREVISION ".$cur_m, "MINORREVISION ".$cur_n, "POINTREVISION ".$cur_p, "THREEDIGITVER _TEXT\\(\"". $cur_no ."\"\\)", "HEXVER        0x0" . $cur_no, "BUILDNO       _TEXT\\(\"Build [0-9]+\"\\)", "BUILDNOSTR    _TEXT\\(\"[0-9]+\"\\)", "BUILDNUMBER   [0-9]+",  "REGKEYVERSION _TEXT(\"[0-9]\.[0-9]\")"],
                       ["FULLVERSIONNO _TEXT(\"". $new_dot ."\")",     "MAINVERSIONNO _TEXT(\"".   $new_m .".". $new_n ."\")",   "MAJORREVISION ".$new_m, "MINORREVISION ".$new_n, "POINTREVISION ".$new_p, "THREEDIGITVER _TEXT(\"".   $new_no ."\")",   "HEXVER        0x0" . $new_no, "BUILDNO       _TEXT\(\"Build $new_b\"\)",   "BUILDNOSTR    _TEXT\(\"$new_b\"\)",   "BUILDNUMBER   $new_bb", "REGKEYVERSION _TEXT(\"$new_m.$new_n\")"]);

  fileSearchAndReplace("$ccdrive\\topclass\\java\\topclass\\src\\com\\wbtsystems\\VersionInfo.java",
                       ["VERSION = \"". $cur_dot ."\"", "MAJOR = \"". $cur_m ."\"", "MINOR = \"".$cur_n ."\"", "POINT = ".$cur_p ."\"", "BUILD = \"[0-9]+\"", "VERSION_STRING = \"TopClass Version $cur_dot Build [0-9]+\""],
                       ["VERSION = \"". $new_dot ."\"", "MAJOR = \"". $new_m ."\"", "MINOR = \"".$new_n ."\"", "POINT = ".$new_p ."\"", "BUILD = \"$new_b\"", "VERSION_STRING = \"TopClass Version $new_dot Build $new_b\""]);

  fileSearchAndReplace("$ccdrive\\topclass\\java\\cnr\\src\\com\\wbtsystems\\cnr\\CNRVersionInfo.java",
                       ["VERSION = \"[0-9]\.[0-9]\.[0-9]\"", "MAJOR = \"[0-9]\"", "MINOR = \"[0-9]\"", "POINT = \"[0-9]\"", "BUILD = \"[0-9]+\"", "VERSION_STRING = \"TopClass LMS Version [0-9]\.[0-9]\.[0-9] Build [0-9]+\""],
                       ["VERSION = \"". $new_dot ."\"", "MAJOR = \"". $new_m ."\"", "MINOR = \"".$new_n ."\"", "POINT = \"".$new_p ."\"", "BUILD = \"$new_b\"", "VERSION_STRING = \"TopClass LMS Version $new_dot Build $new_b\""]);


  # file: \topclass\java\cnr\.project
  # change
  #  <name>cnr742</name>
  # to
  #  <name>cnr800</name>
  fileSearchAndReplace("$ccdrive\\topclass\\java\\cnr\\.project",
                       ["<name>cnr[0-9][0-9][0-9]</name>"],
                       ["<name>cnr$MNP</name>"]);

  # file: \topclass\java\cnr\.settings\org.eclipse.wst.common.component
  # change
  #   <wb-module deploy-name="cnr742">
  #     <property name="context-root" value="cnr742"/>
  # to
  #   <wb-module deploy-name="cnr800">
  #     <property name="context-root" value="cnr800"/>
  fileSearchAndReplace("$ccdrive\\topclass\\java\\cnr\\.settings\\org.eclipse.wst.common.component",
                       ["<wb-module deploy-name=\"cnr[0-9][0-9][0-9]\">", "<property name=\"context-root\" value=\"cnr[0-9][0-9][0-9]\"/>"],
                       ["<wb-module deploy-name=\"cnr$MNP\">",            "<property name=\"context-root\" value=\"cnr$MNP\"/>"]);
}

#W:\topclass\oracle\topclass\sources\spi\cookie\cookieauth.html
#<option value="topclass.dll">topclass.dll</option>


print "\n";

#print "Remember to update $ccdrive\\topclass\\oracle\\install\\projects\\TopClassServer\\Script Files\\setup.rul manually\n";
#print "Remember to update UnsupportedTopClassVersionInstalled in $ccdrive\\topclass\\oracle\\install\\projects\\TopClassServer\\String Tables\\0009-English\\value.shl\n";

sub copyTemp($) {
  my ($file) = @_;

  if ( ! -e $file ) {
    print "Warn: $file it doesn't exist\n";
    return "";
  }
  if ( ! -r $file ) {
    print "Warn: $file it's not readable\n";
    return "";
  }
  if ( ! -s $file ) {
    print "Warn: $file it's empty\n";
    return "";
  }
  if ( ! -f $file ) {
    print "Warn: $file it's not plain\n";
    return "";
  }

  my $tname = mktemp($ENV{TEMP} . "\\tmpfileXXXXX");

  if ( !copy( $file, $tname ) ) {
    print "copy $file => $tname failed: $!\n";
    return "";
  }

  return $tname;
}

sub checkoutFile($) {
  my ($filename) = @_;
  chomp(my $cwd = `cd`);

  my $file = basename($filename);
  my $dir  = dirname($filename);

  chdir( $dir );
  system("$cleartool co -c \"#00001 Updating version to $new_dot\" $file");
  chdir( $cwd );
}

sub processProject( $ ) {
  my ($dsp) = @_;
  if ( -e $dsp ) {
    if ( open( DSPOUT, ">$dsp.new" ) ) {
      my $changed = 0;
      if ( open( DSP, $dsp ) ) {
        while ( <DSP> ) {
          chomp;
          my $line = $_;
          if ( $line =~ /([a-z]+)([0-9]{3})([a-z_A-Z0-9]*)\.([a-z]{3})/ ) {
            my $prefix = $1;
            my $vernum = $2;
            my $suffix = $3;
            my $extens = $4;
            if ( $vernum ne $MNP ) {
              #print "$vernum: $prefix$vernum$suffix\.$extens\n";
              $line =~ s/([a-z]+)([0-9]{3})([a-z_A-Z0-9]*)\.([a-z]{3})/\1$MNP\3\.\4/g;
              $changed = 1;
            }
          }
          print DSPOUT "$line\n";
        }
        close( DSP );
      }
      close( DSPOUT );
      if ( $changed == 0 ) {
        unlink "$dsp.new";
      }
      else {
        checkoutFile( $dsp );
        unlink "$dsp.old";
        rename $dsp, "$dsp.old";
        rename "$dsp.new", $dsp;
        #CheckIn( $dsp, "Updating version to $MNP" );
      }
    }
  }
}

sub fileSearchAndReplace($$$) {
  my ($filename, $search, $replace) = @_;

  my $modified = 0;
  my $tfile = copyTemp($filename);
  if ( $tfile eq "" ) {
    return;
  }
  checkoutFile( $filename );
  if ( !open( TFILE, $tfile ) ) {
    print "Can't open $tfile for reading\n";
  }
  else {
    if ( !open( FILE, ">$filename" ) ) {
      print "Can't open $filename for writing\n";
    }
    else {
      while ( <TFILE> ) {
        for my $i ( 0 .. $#{$search} ) {
          #print "searching for ${$search}[$i]\n";
          if ( /${$search}[$i]/ ) {
            print ">> $_";
            s/${$search}[$i]/${$replace}[$i]/;
            print "<< $_";
            $modified = 1;
          }
        }
        print FILE;
      }
      close FILE;
    }
    close TFILE;
  }
  unlink $tfile;

  if ( $modified eq 0 ) {
    print "WARNING I did not change $filename\n";
  }
}

sub fileInsertAfter() {
  my ($filename, $search, $insert) = @_;

  my $modified = 0;
  my $tfile = copyTemp($filename);
  if ( $tfile eq "" ) {
    return;
  }
  checkoutFile( $filename );
  if ( !open( TFILE, $tfile ) ) {
    print "Can't open $tfile for reading\n";
  }
  else {
    if ( !open( FILE, ">$filename" ) ) {
      print "Can't open $filename for writing\n";
    }
    else {
      while ( <TFILE> ) {
        print FILE;

        for my $i ( 0 .. $#{$search} ) {
          #print "searching for ${$search}[$i]\n";
          if ( /${$search}[$i]/ ) {
            print "Found " . ${$search}[$i] . "\n";
            print "Adding " . ${$insert}[$i] . "\n";
            print FILE ${$insert}[$i] . "\n";
            $modified = 1;
          }
        }
      }
      close FILE;
    }
    close TFILE;
  }
  unlink $tfile;

  if ( $modified eq 0 ) {
    print "WARNING I did not change $filename\n";
  }
}
