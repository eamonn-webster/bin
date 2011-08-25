#
#  File: prepare.pl
#  Author: eweb
#  Copyright eweb, 1998-2010
#  Contents:
#
# Date:          Author:  Comments:
#  2nd Nov 2005  eweb     Paths from root
# 15th May 2006  eweb     Fail if can't change to directory.
#  5th Sep 2006  eweb     Command line arg to specify Unicode.
#  3rd Nov 2006  eweb     Copy files for cnr.
#  5th Dec 2006  eweb     Handle old names for dat files.
#  1st Mar 2007  eweb     ORACLE_HOME not defined, sendresult.js
# 31st Aug 2007  eweb     #00008 Options to turn bits on/off.
# 17th Jan 2008  eweb     #00008 -L to specify languages
#  4th Mar 2009  eweb     #00008 path to langutils
#  2nd Nov 2009  eweb     #00008 Find langutils
#  6th May 2010  eweb     #00008 Copy SCORM1.2.jar
# 20th May 2010  eweb     #00008 Overwrite scorm jar
#  1st Jul 2010  eweb     #00008 Copy cookieauth.html
# 28th Jul 2010  eweb     #12513 Just copy the .dat files
# 15th Sep 2010  eweb     #00008 Use temp when generating .lang files
#

#mkdir \topclass\oracle\topclass\www\language
#pushd \topclass\oracle\topclass\www\language
#for %%d in (\topclass\oracle\topclass\languages\*.dat) do langutils -u %1 %%d
#for %%d in (\topclass\oracle\topclass\languages\*_uk.dat) do langutils -u %1 -b %%d
#popd

use strict;
use Cwd;
use File::Copy;
use File::Temp qw/tempdir/;

my $Unicode = "Y";
my $Reports = "N";
my $Java    = "N";
my $Langs   = "uk";
my $UseTemp = "Y";
my $verbose;
my $ViewDriveName;

use Getopt::Std;
use ActiveState::Path qw(find_prog);

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

my %opts = ( U => undef(),
             R => undef(),
             J => undef(),
             L => undef(),
             v => undef(),
             V => undef(),
             T => undef(),
             );

# Was anything other than the defined option entered on the command line?
if ( !getopts("U:v:L:R:J:V:T:", \%opts) or @ARGV > 1 )
  {
    print "Options:\n";
    print "-U [$Unicode] Unicode (Y/N)\n";
    print "-v drive\n";
    print "-R [$Reports] Reports (Y/N)\n";
    print "-J [$Java] Java (Y/N)\n";
    print "-L [$Langs] Languages (list e.g. uk;fr;de or 'all')\n";
    print "-T [$UseTemp] use temp (Y/N)\n";
    print "-V verbose\n";
    exit;
  }

if ( defined( $opts{U} ) )
  {
    $Unicode = uc $opts{U};
  }
if ( defined( $opts{R} ) )
  {
    $Reports = uc $opts{R};
  }
if ( defined( $opts{J} ) )
  {
    $Java = uc $opts{J};
  }
if ( defined( $opts{v} ) )
  {
    $ViewDriveName = $opts{v};
  }
else
  {
    my $curDir =  getcwd();
    if ( $curDir =~ /^(.:)/ )
      {
        $ViewDriveName = $1;
      }
  }
if ( defined( $opts{L} ) )
  {
    $Langs = $opts{L};
  }
if ( defined( $opts{T} ) )
  {
    $UseTemp = uc $opts{T};
  }
$verbose = $opts{V};

sub GenLangFiles()
{
  my $SourceDir = osify("$ViewDriveName/topclass/oracle/topclass/languages");
  my $DestDir = osify("$ViewDriveName/topclass/oracle/topclass/www/language");

  if ( -e "$SourceDir/topclass_server_usenglish.dat" and ! -e "$SourceDir/strings.dat" )
    {
      system( "xcopy /i /y /d /f " . osify("$SourceDir/*.dat") . " " . osify( "$DestDir/" ) );
      return;
    }

  if ( !-d $DestDir )
    {
      mkdir( $DestDir );
    }
  my $curDir =  getcwd();
  chdir( $DestDir ) or die "Can't change to $DestDir\n";

  my $tempDest;
  if ( $UseTemp eq "Y" )
    {
      $tempDest = tempdir();
      print "Will use $tempDest\n";
    }

  my $LangUtils = osify("$ViewDriveName/utils/AutoDevBuild/langutils.exe");
  if ( ! -e $LangUtils )
    {
      my $fp = find_prog( "langutils" );
      if ( $fp )
        {
          print "WARN using langutils from path $fp\n";
          $LangUtils = $fp;
        }
      else
        {
          die "Can't find $LangUtils\n";
        }
    }
  if ( $Unicode eq "Y" )
    {
      $LangUtils = $LangUtils . " -u";
    }
  else
    {
      $LangUtils = $LangUtils . " -a";
    }

  if ( opendir( DIR, $SourceDir ) )
    {
      if ( $tempDest )
        {
          chdir( $tempDest ) or die "Can't change to $tempDest\n";
        }
      my $file;
      my $Cmd;
      my $CmdOut;
      $Langs = "all" if ( $Langs eq "" or $Langs eq "*");
      while ( defined( $file = readdir(DIR) ) )
        {
          my $full = osify("$SourceDir/$file");
          if ( $file =~ /langrps\.dat$/ ) {
            #print "$file\n";
          }
          elsif ( $file =~ /_(..)\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            if ( $Langs eq "all" or $Langs =~ /$1/ ) {
              $Cmd = "$LangUtils $full";
              print "Command: $Cmd\n" if ( $verbose );
              $CmdOut = `$Cmd 2>&1`;
              print "$CmdOut";
            }
          }
          # old names strings.de.dat
          elsif ( $file =~ /\.(..)\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            if ( $Langs eq "all" or $Langs =~ /$1/ ) {
              $Cmd = "$LangUtils $full";
              print "Command: $Cmd\n" if ( $verbose );
              $CmdOut = `$Cmd 2>&1`;
              print "$CmdOut";
            }
          }
          elsif ( $file =~ /_(...)\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            if ( $Langs eq "all" or $Langs =~ /$1/ ) {
              $Cmd = "$LangUtils $full";
              print "Command: $Cmd\n" if ( $verbose );
              $CmdOut = `$Cmd 2>&1`;
              print "$CmdOut";
            }
          }
          elsif ( $file =~ /\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            $Cmd = "$LangUtils $full";
            print "Command: $Cmd\n" if ( $verbose );
            $CmdOut = `$Cmd 2>&1`;
            print "$CmdOut";

            # Generate .labels file
            $Cmd = "$LangUtils -b $full";
            print "Command: $Cmd\n" if ( $verbose );
            $CmdOut = `$Cmd 2>&1`;
            print "$CmdOut";
          }
        }
      closedir(DIR);

      if ( $tempDest )
        {
          chdir( $curDir );
          print "Opening $tempDest\n";
          if ( opendir( DIR, $tempDest ) )
            {
              print "have opened $tempDest\n";
              #print "<pre>\n";
              my $count = 0;
              my $file;
              while ( defined( $file = readdir(DIR) ) )
                {
                  my $full = osify("$tempDest/$file");
                  if ( -d $full )
                    {
                    }
                  elsif ( -e $full )
                    {
                      print "move(" . $full . "," . osify("$DestDir/$file") . ")\n" if ( $verbose );
                      if ( move( $full, osify("$DestDir/$file") ) )
                        {
                          $count++;
                        }
                    }
                }
              print "moved $count file(s)\n";
              closedir(DIR);
            }
          else
            {
              print "couldn't open $tempDest\n";
            }
        }
    }
  else
    {
      print "can't open directory $SourceDir\n";
    }

  chdir( $curDir );
}

GenLangFiles();

if ( $Reports eq "Y" && -d "$ViewDriveName\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal" )
  {
    system( "md $ViewDriveName\\topclass\\oracle\\topclass\\www\\reports" );
    system( "md $ViewDriveName\\topclass\\oracle\\topclass\\www\\reports\\oracle" );
    system( "md $ViewDriveName\\topclass\\oracle\\topclass\\www\\reports\\mssql" );
    system( "xcopy /s /y $ViewDriveName\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\ASP\\*         $ViewDriveName\\topclass\\oracle\\topclass\\www\\reports" );
    system( "xcopy /s /y $ViewDriveName\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\ORACLE\\*.rpt  $ViewDriveName\\topclass\\oracle\\topclass\\www\\reports\\oracle" );
    system( "xcopy /s /y $ViewDriveName\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\MSSQL\\*.rpt   $ViewDriveName\\topclass\\oracle\\topclass\\www\\reports\\mssql" );
  }

if ( $Java eq "Y" && -d "$ViewDriveName\\topclass\\java" )
  {
    system( "xcopy /s /y /i $ViewDriveName\\topclass\\java\\common\\lib\\*.jar $ViewDriveName\\topclass\\java\\cnr\\web-inf\\lib" );

    if ( $ENV{TOMCAT_HOME} ne "" and -d $ENV{TOMCAT_HOME} )
      {
        if ( $ENV{ORACLE_HOME} ne "" and -d $ENV{ORACLE_HOME} )
          {
            system( "xcopy /s /y /i %ORACLE_HOME%\\jdbc\\lib\\ojdbc14.jar %TOMCAT_HOME%\\shared\\lib" );
          }
        elsif ( -d "c:\\oracle\\ora10gr2" )
          {
            system( "xcopy /s /y /i c:\\oracle\\ora10gr2\\jdbc\\lib\\ojdbc14.jar %TOMCAT_HOME%\\shared\\lib" );
          }
        elsif ( -d "c:\\oracle\\ora92" )
          {
            system( "xcopy /s /y /i c:\\oracle\\ora92\\jdbc\\lib\\ojdbc14.jar %TOMCAT_HOME%\\shared\\lib" );
          }
      }
    system( "xcopy /s /y /i $ViewDriveName\\topclass\\java\\cnr\\etc\\*.xml        $ViewDriveName\\topclass\\java\\cnr\\web\\WEB-INF" );
    system( "xcopy /s /y /i $ViewDriveName\\topclass\\java\\cnr\\etc\\*.properties $ViewDriveName\\topclass\\java\\cnr\\web\\WEB-INF" );
    system( "xcopy /s /y /i $ViewDriveName\\topclass\\java\\cnr\\etc\\*.tld        $ViewDriveName\\topclass\\java\\cnr\\web\\WEB-INF" );
    system( "xcopy /s /y /i $ViewDriveName\\topclass\\java\\common\\etc\\*.tld     $ViewDriveName\\topclass\\java\\cnr\\web\\WEB-INF" );

}

#system( "xcopy /s /y /i $ViewDriveName\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\sendresult.js $ViewDriveName\\topclass\\oracle\\topclass\\www" );

system( "xcopy /d /y $ViewDriveName\\utils\\SCORMApplet\\SCORM1.2\\SCORM1.2.jar $ViewDriveName\\topclass\\oracle\\topclass\\www\\" );

system( "xcopy /d /y $ViewDriveName\\topclass\\oracle\\topclass\\sources\\spi\\cookie\\cookieauth.html $ViewDriveName\\topclass\\oracle\\topclass\\www\\" );
