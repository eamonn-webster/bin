#
# File: esdbuild.pl
# Author: eweb
# Copyright WBT Systems, 1995-2008
#

# Date:          Author:  Comments:
# 26th Oct 2005  eweb     Execute in place.
# 31st Mar 2006  eweb     Don't lint.
# 30th Jun 2006  eweb     Don't lint on frodo.
#  6th Jun 2007  eweb     Do lint on frodo.
# 28th Jun 2007  eweb     Frodo to create sql server schema on hogfather
#  5th Feb 2008  eweb     #00008 Building 8.0.0
#  6th Feb 2008  eweb     #00008 reset classpath, don't set builddrive
# 18th Feb 2008  eweb     #00008 Don't lint on frodo.

#
# Call devbuild with the appropriate parameters for an esd build
#
#

use strict;
my $ccDrive = $ARGV[0];
my $Major = "";
my $Minor = "";
my $Point = "";
my $Build = "";

my $localDrive = "c:";
my $Installers = "N";
my $CopyFiles  = "Y";
my $UseClearcase = "Y";
my $DoLint = "N";
#my $SendTo = "$ENV{USERNAME}\@wbtsystems.com";
#my $SendTo = "\"\"";
my $DebugBuild = "R";
my $DoCpp = "N";
my $DoPublisher = "N";
my $DoVB = "N";
my $DoStrings = "N";
my $DoJava = "Y";
my $DoSqlServer = "Y";
my $ExtraArgs = "";
my $CleanView = "Y";


if ( $ccDrive eq "" or ! -d "$ccDrive\\" )
  {
    die "Clearcase drive $ccDrive doesn't exist\n";
  }

#Options : -i increment the build number in buildno.h file
#        : -q [Y] quick build configurations in dosanddonts.txt
#        : -b the build number for this build.
#        : -c compare this build against the previous build for missing files etc.
#        : -m major release version no.
#        : -n minor release version no.
#        : -p point release version no.
#        : -j build java
#
#        : -t testing
#        : -C [Y] build c++? (Y/N)
#        : -P [Y] build Publisher? (Y/N)
#        : -I [Y] build Installers? (Y/N)
#        : -F [Y] copy files? (Y/N)
#        : -T [production@wbtsystems.com] who to mail
#        : -B [H:] builds drive e.g. net use for \\elm\builds
#        : -H [hogfather] Host name for URL
#        : -S [AutoBuild] webable directory on host for URL
#        : -Q [N] Roman's SQl Server script
#        : -U [Y] Use clearcase
#        : -D [DosAndDonts.txt] DosAndDonts file
#        : -L [N] Lint topclass...
#        : -K [Y] Spell Check
#        : -G [N] Debug Build


sub GetBuildNumber()
{
  my $BuildNoFile = "$ccDrive/topclass/oracle/topclass/sources/buildno.h";

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
          # ensure it is a number...
          $Build++;
          $Build--;
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
}

GetBuildNumber();

# increament to the next
if ( $Build > 0 )
  {
    if ( $Build % 2 == 0 ) # currently even ?
      {
        die "Build number is currently even! Aborting...\n";
      }
    $Build++;
  }

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

my $DoLint = "Y";

if ( lc $ENV{COMPUTERNAME} eq "frodo" )
  {
    $DoLint = "N";
  }

my $EsdCopy = "";
my $MsSqlHost = "";

if ( lc $ENV{COMPUTERNAME} eq "frodo" )
  {
    $EsdCopy = "-E Y";
    $MsSqlHost = "-W hogfather";
  }

my $MNP = "$Major.$Minor.$Point";

if ( $Major ge 9 )
  {
    $Installers = "N";
    $CopyFiles  = "Y";
    $DoLint = "N";
    $DoCpp = "N";
    $DoPublisher = "N";
    $DoVB = "N";
    $DoStrings = "N";
    $DoJava = "Y";
    $DoSqlServer = "N";
  }

if ( lc $ENV{COMPUTERNAME} ne "frodo" )
  {
    $CleanView = "N";
  }

if ( $MNP ge "9.0.0" )
  {
    $ENV{JAVA_HOME} = "c:\\java\\jdk1.6.0_03";
    $ENV{TOMCAT_HOME} = "c:\\java\\apache-tomcat-6.0.14";
    $ENV{ANT_HOME} = "c:\\java\\apache-ant-1.7.0";
  }
elsif ( $MNP ge "8.0.0" )
  {
    $ENV{JAVA_HOME} = "c:\\java\\jdk1.5.0_10";
    $ENV{TOMCAT_HOME} = "c:\\java\\apache-tomcat-5.0.28";
    $ENV{ANT_HOME} = "c:\\java\\apache-ant-1.6.5";
  }
else
  {
    $ENV{JAVA_HOME} = "c:\\java\\j2sdk1.4.2_13";
   #$ENV{TOMCAT_HOME} = "c:\\java\\apache-tomcat-4.1.19";
    $ENV{TOMCAT_HOME} = "c:\\java\\apache-tomcat-5.0.28";
    $ENV{ANT_HOME} = "c:\\java\\jakarta-ant-1.5";
  }

$ENV{CATALINA_HOME} = $ENV{TOMCAT_HOME};

$ENV{JAVACMD} = "$ENV{JAVA_HOME}\\bin\\java";

$ENV{CLASSPATH} = "";

#my $cmd = "perl $ccDrive\\utils\\autodevbuild\\devbuild.pl
#-i -c -j -m $Major -n $Minor -p $Point -b $Build
#-L $DoLint -Q Y -G R -X Y $EsdCopy $MsSqlHost -d @ARGV";

my $cmd = "perl $ccDrive\\utils\\autodevbuild\\devbuild.pl";
   $cmd = "$cmd -d $ccDrive -m $Major -n $Minor -p $Point -b $Build";
   $cmd = "$cmd -c -i";
  #$cmd = "$cmd -T $SendTo";
  #$cmd = "$cmd -B $localDrive\\autodevbuild";
   $cmd = "$cmd -I $Installers -F $CopyFiles -U $UseClearcase";
   $cmd = "$cmd -L $DoLint -G $DebugBuild -C $DoCpp -P $DoPublisher";
#if ( $Major > 7 || ( $Major == 7 && $Minor >= 4 ) || ( $Major == 7 && $Minor >= 3 && $Point >= 3 ) || $Major < 4 )
  {
    $cmd = "$cmd -A $DoStrings";
  }
#if ( $Major > 7 || ( $Major == 7 && $Minor >= 3 ) || $Major < 4 )
  {
    $cmd = "$cmd -V $DoVB";
    $cmd = "$cmd -Q $DoSqlServer";
    $cmd = "$cmd -K N";
  }
if ( $DoJava eq "Y" )
  {
    $cmd = "$cmd -j";
  }
if ( $ExtraArgs )
  {
    $cmd = "$cmd $ExtraArgs";
  }
if ( $CleanView eq "Y" )
  {
    $cmd = "$cmd -X Y";
  }

print "$cmd\n";
system( $cmd );
