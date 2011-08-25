#
# File: tcsetup.pl
# Author: eweb
# Copyright WBT Systems, 2006-2011
# Contents:
#
# Date:          Author:  Comments:
# 28th Sep 2006  eweb     Initial version.
# 25th Jan 2007  eweb     Registry exes.
#  3rd May 2007  eweb     Prior to 7.3.2 need UNC prefix.
# 10th May 2007  eweb     Better handling of default.html
# 16th May 2007  eweb     Adapt for use by esd.
# 12th Jun 2007  eweb     Get it working for Robert.
#                         IUSR_? needs write access to message log.
#                         copy sql server dlls
#                         don't create virtual dirs under wwwroot
# 28th Jun 2007  eweb     Handling cnr.
#                         handle multiple instances of cnr
#                         install redirector
# 29th Jun 2007  eweb     Remove an instance
#                         Instances page, create if necessary
#                         License take later if available.
# 29th Jun 2007  eweb     -A oraclehome and -Q sqlserverhome
#                         -t Y for testing.
#                         copy oracle jdbc driver...
#  2nd Jul 2007  eweb     #00008 Change name of cnrapp.log
#  5th Jul 2007  eweb     #00008 Don't create tcc up front, xcopy /d tcc, filtering from output
#                         #00008 tomcat manager, pass oradb to runora, find runora.pl
# 27th Jul 2007  eweb     #00008 No longer working for dev clearcase.
#  4th Aug 2007  eweb     #00008 Customer prefix e.g. -x diageo
# 23rd Aug 2007  eweb     #00008 Sql Server 2005.
# 24th Aug 2007  eweb     #00008 Missing line breaks.
# 31st Aug 2007  eweb     #00008 Paths prior to 7.3.2, Config v Globals for OraLogin & SqlLogin.
# 16th Oct 2007  eweb     #00008 Don't set up tcc if it isn't there use "-" $tcc.
# 20th Nov 2007  eweb     #00008 Pass $msqlhome to cmd scripts
# 20th Nov 2007  eweb     #00008 Use underscores not percents to create strong password.
# 21st Nov 2007  eweb     #00008 SchemaPass
# 22nd Nov 2007  eweb     #00008 Turn off version -V N, respect MultipleBuilds, setup DSN, IUSR_LOCAL
# 15th Jan 2008  eweb     #00008 Change in view names
#  5th Feb 2008  eweb     #00008 oralogin & sqllogin moved to config in 7.3.0
#  3rd Mar 2008  eweb     #00008 Early tc_setenv.cmd didn't test before setting.
# 14th Aug 2008  eweb     #00008 Non C++ (and java) dev setup.
#                         -U Y for a personal schema name
#                         -E Y to copy exes from builds
#                         prompt for sys and system passwords. (this should be done in runora.pl)
# 11th Sep 2008  eweb     #11071 Filter out harmless not found errors
# 11th Sep 2008  eweb     #11072 Create c:\temp
# 11th Sep 2008  eweb     #11070 Oracle scripts now in oracle folder (not scripts)
# 11th Sep 2008  eweb     #10958 Create reg key before setting acl
#  1st Oct 2008  eweb     #00008 Was passing 'oraData' as data directory
#  6th Oct 2008  eweb     #00008 -D InstallDrive -U [Y/N/prefix]
# 10th Oct 2008  eweb     #00008 D option not done right, drop /tc from module base for 8.0.0
# 23rd Oct 2008  eweb     #00008 Dev set up using esd vob
# 24th Oct 2008  eweb     #00008 Dev set up using esd vob
# 30th Oct 2008  eweb     #00008 check for jk_nt_service.exe
#  6th Nov 2008  eweb     #00008 Append build to user
#  1st Dec 2008  eweb     #00008 Map usernames, tee to capture output, default settings, -J just
#  5th Dec 2008  eweb     #00008 Do without tee
#  5th Dec 2008  eweb     #00008 check for tee and setacl
# 17th Dec 2008  eweb     #00008 Options to control install of tomcat and the redirector
# 23rd Dec 2008  eweb     #00008 CopyFromBuilds, username, tomcat home from service, reports
#  9th Jan 2009  eweb     #00008 Invalid call to regsvr32
#  9th Jan 2009  eweb     #00008 executing adsutil.vbs on nextgen failed?
#  9th Jan 2009  eweb     #00008 incorrect path to tee
#  9th Jan 2009  eweb     #00008 spaces at end of config files
#  9th Jan 2009  eweb     #00008 specify current view -v . (a period)
# 14th Jan 2009  eweb     #00008 -C to specify tomcat_home, lc $Just, update workers2, set anon user and password
# 14th Jan 2009  eweb     #00008 Add c:\bin to path
# 15th Jan 2009  eweb     #00008 Setting anonymous user, password and password sync.
# 22nd Jan 2009  eweb     #00008 Make the attach folder
# 26th Jan 2009  eweb     #00008 unzip overwrite without prompting
#  6th Feb 2009  eweb     #00008 Add build number to schema name for view based setups
#  6th Feb 2009  eweb     #00008 Change oralogin/sqllogin if creating schemas.
#  6th Feb 2009  eweb     #00008 Rewrite cnr_persist.properies if details differ.
#  6th Feb 2009  eweb     #00008 Don't overwrite with blank password.
#  6th Feb 2009  eweb     #00008 Call prepare.pl when copying exes.
#  6th Feb 2009  eweb     #00008 -J exes didn't
#  6th Feb 2009  eweb     #00008 prepare.pl is in the bin folder
#  4th Mar 2009  eweb     #00008 Language handling
#  5th Mar 2009  alex     #00008 add copy command for cr_report.exe into copyexes
#  6th Mar 2009  eweb     #00008 Wasn't copying exes
#  6th Mar 2009  eweb     #00008 Sql Server 2005
#  9th Mar 2009  eweb     #00008 Keep oracle and sql server schema names separate, #00008 escc
# 16th Mar 2009  eweb     #00008 Database name for crystal reports
# 20th Mar 2009  eweb     #00008 Database name for crystal reports name of var instead of value
#  6th Apr 2009  eweb     #00008 Set globals.topclassUrl
#  8th May 2009  eweb     #00008 Error messages
# 28th May 2009  eweb     #00008 Warn unhandled lines in option files
# 17th Sep 2009  eweb     #00008 validate pre-requisites
# 22nd Oct 2009  eweb     #00008 Incorrect testing of CopyFromBuilds
# 19th Nov 2009  eweb     #00008 xcopy continue on error
# 20th Nov 2009  rger     #11725 Extended procedures can't be used on MS SQL 64-bits
# 14th Jan 2010  eweb     #00008 Install under \topclass8 different names for webable and non webable
# 21st Jan 2010  eweb     #00008 -g verbose, logging
# 28th Jan 2010  eweb     #00008 Don't create program files unless needed
# 26th Feb 2010  eweb     #00008 Handle remote sql server & named instance, date dir, dsn and clr dll
#  2nd Mar 2010  eweb     #00008 Setting up cnr to use named instance
# 14th Apr 2010  eweb     #00008 Redirector use out of the box config
# 26th Apr 2010  eweb     #00008 Default sql server data path
#  4th May 2010  eweb     #00008 Corrupting path when adding c:\bin
#  6th May 2010  eweb     #00008 Always stop and restart tomcat and iis
#  6th May 2010  eweb     #00008 Always add context to redirector
# 31st May 2010  eweb     #00008 Second call to DefaultArgs to override command line
#  3rd Jun 2010  eweb     #00008 Register msxml4.dll
#  3rd Jun 2010  eweb     #00008 Option to clean first -X Y
#  4th Jun 2010  eweb     #00008 Set Permissions after copying files.
# 11th Jun 2010  eweb     #00008 Custom builds copying from radon
#  8th Aug 2010  eweb     #00008 Handling default options
#  2nd Sep 2010  eweb     #00008 Sql Server 2008 $mnp vs $MNP
#  3rd Sep 2010  eweb     #00008 Don't die if Sql Server directory doesn't exist if doing oracle.
#  6th Oct 2010  eweb     #00008 Oracle 11g ojdbc6.jar
# 14th Oct 2010  eweb     #00008 IIS 7, 64 bit
# 19th Oct 2010  eweb     #00008 Command args override buildno.h
# 19th Oct 2010  eweb     #00008 Copy redirector if necessary
# 19th Oct 2010  eweb     #00008 Determine IUSR
# 22nd Oct 2010  eweb     #00008 Error determining minor version.
# 27th Oct 2010  eweb     #12671 Option to not store templates in registry
#  3rd Nov 2010  eweb     #00008 Strip spaces in options file
#  8th Nov 2010  eweb     #00008 IUSR under Windows7
#  9th Nov 2010  eweb     #00008 tcc non longer under nowebable
# 17th Nov 2010  eweb     #00008 TopClassURL shouldn't include login
# 25th Nov 2010  eweb     #00008 regsvr32 or regasm
# 30th Nov 2010  eweb     #00008 -o Y/N to stop and start tomcat
# 30th Nov 2010  eweb     #00008 Use Microsoft jdbc driver
# 30th Nov 2010  eweb     #12834 Don't use assemblies
# 14th Jan 2011  eweb     #00008 machine names
# 20th Jan 2011  eweb     #00008 tcc no longer under nonwebable
# 21st Feb 2011  eweb     #00008 Don't index the content of the web folder
# 16th Mar 2011  eweb     #00008 Exe must be copied to localdrive for Windows7
# 16th Mar 2011  eweb     #00008 Don't enable ws plugin
# 29th Mar 2011  eweb     #00008 Set up jasperserver
# 31st Mar 2011  eweb     #00008 cygwin
# 18th Apr 2011  eweb     #00008 Support for version 9
# 18th Apr 2011  eweb     #00008 Don't overwrite dsn
# 21st Apr 2011  eweb     #00008 Option -a Y/N to install jasper
# 15th Jul 2011  eweb     #00008 radon

#
# Perl script to set up an instance of TopClass.
#
# Dependencies:
# perl, I'm currently using ActiveState v5.8.8 build 817
#
# The following can be got from \\hogfather\bin
#
# adsutil.vbs (comes from inetpub\adminscripts
# setacl.exe  sourceforge
# unzip.exe comes with oracle
#
# Then depending on what database(s) you will be using
# osql and/or sqlplus
#


#
# TODO check that wscript and cscript or whatever
# TODO create DSN for Mssql.
# TODO adapt for ESD use multiple named instance instead on builds.
# TODO determine $mssqlHome
# TODO determine $oracleHome
# TODO finish off delete ...
# TODO verify by calling tccheck.pl
# TODO Crystal
# TODO Publisher
# TODO Mobile
#

use strict;
use Cwd;
use File::Basename;
use Getopt::Std;
use ActiveState::Path qw(find_prog);

my $myDir = dirname($0);
my $upDir = dirname($myDir);
#print "$myDir\n";

my $argsdir = "c:\\bin";

my $host = lc $ENV{COMPUTERNAME};
my $TopClassServerKey = "HKLM\\Software\\WBT Systems\\TopClass Enterprise Server";
my $cscript = $ENV{WINDIR} . "\\System32\\CScript.exe";
my $adsutil = "$cscript //NoLogo c:\\Inetpub\\AdminScripts\\adsutil.vbs";
my $appcmd = "c:\\windows\\system32\\inetsrv\\appcmd.exe";
my $mssqlHome2000 = "c:\\Program Files\\Microsoft SQL Server\\MSSQL";
my $mssqlHome2005 = "c:\\Program Files\\Microsoft SQL Server\\MSSQL.1\\MSSQL";
my $mssqlHome2008 = "c:\\Program Files\\Microsoft Sql Server\\MSSQL10.MSSQLSERVER\\MSSQL";
my $mssqlHome;
my $oracleHome = $ENV{ORACLE_HOME};

my $UseTopClassExe = "N";
my $verbose;
my $Major;
my $Minor;
my $Point;
my $mnp;
my $mnpb;
my $MNP;
my $MNPB;
my $Build;
my $View;
my $Database;
my $ccDrive;
my $clearcasedrive = "N";
my $webpath;
my $nonwebpath;
my $scriptsRoot;
my $oraclePath;
my $mssqlPath;
my $mappedwebpath;
my $tcver;
my $tcdir;
my $tcdir2;
my $oradb;
my $sqldb;
my $CopyFromBuilds = "Y";
my $UseVersion = "Y";
my $LicenseDir = "\\\\radon\\projects\\Keys";
my $debugBuild;
my $MultipleBuilds = "Y";
my $tcuser;
my $InstallDrive = "c:";
my $logsdir = "$InstallDrive\\logs";
my $WWWRoot = "$InstallDrive\\inetpub\\wwwroot";
my $ProgramFiles = "$InstallDrive\\Program Files";
my $tcc = "$InstallDrive\\tcc";
my $installTomcat;
my $tomcatService;
my $cleanFirst;
# --------- Apache redirector options -------------------
my $redirVer                = "1";
my $isapiRedirectoRegRoot   = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Apache Software Foundation\\Jakarta Isapi Redirector";
my $isapiRedirectoRegKey    = "";
my $installRedirector       = "";
my $workersFileRegValue     = "";
my $workersFile             = "";
my $workerMountFileRegValue = "";
my $workerMountFile         = "";
#--------------------------------------------------------
my $copyNewer = "Y";
my $command = "install";
my $instances = "default.html";
my $prefix = "tc";
my $testing;
my $suffix;  # added to cnr
my $Builds = "\\\\radon\\builds";
my $oraSchemaName;
my $oraSchemaPass;
my $sqlSchemaName;
my $sqlSchemaPass;
my $sqlver = "2000";
my $saPass = "sa";
my $syspass;
my $systempass;
my $copyExes;
my $esdVob;
my $tempDir = $ENV{TEMP};
my $nonwebroot;
my $localnonwebroot;
my $Just;
my $tomcat_home;
my $CustomBuild;
my $uname = "Y";
my $languages = "english";
my $bit64;
my $templatesInRegistry = "Y";
my $stopStartTomcat = "Y";
my $useMicrosoftDriver;
my $Assemblies;
my $tcc_under_nonwebable;

my $setupJasper = "N";
#js integration
my $jsOrganizationId = "";
my $jsOrganizationName = "";
my $jsWebAppName = "";
my $jsRDBMSUser = "";
my $jsRDBMSPassword = "";
my $tcRDBMSUser = "";
my $tcRDBMSPassword = "";
my $rptsRDBMSUser = "";
my $rptsRDBMSPassword = "";
my $rptsRDBMSSchema = "";
my $rpts = "_rpts";

my $os = $^O;
my $Win7;

if ( $os eq "MSWin32" )
  {{
    eval { require Win32; } or last;
    $os = Win32::GetOSName();
    $os = "WinXP" if ( $os =~ /WinXP/ );
    if ( $os eq "Win7" )
      {
        $Win7 = 1;
      }
  }}

print "os: $os\n" if ( $verbose );

my $iis7 = -e $appcmd;

if ( $ENV{PROCESSOR_ARCHITECTURE} =~ /64/ ) {
  $bit64 = 1;
}
if ( $bit64 ) {
  $TopClassServerKey = "HKLM\\Software\\Wow6432Node\\WBT Systems\\TopClass Enterprise Server";
  $UseTopClassExe = "Y";
}

my %usernameMap = (
 lmcgettigan => "lisa",
 rgeraschenko => "rger",
 aemelyanov => "deesy",
 bhendrick => "barry",
);

my %lang2code = (
  english => "uk",
  french => "fr",
  german => "de",
  dutch => "du",
);

# we can't handle spaces... because xcopy can't

if ( $tempDir =~ / / )
  {
    $tempDir = "c:\\temp";
  }

if ( !-d $tempDir )
  {
    mkdir $tempDir;
  }

sub osify($) {
  my ($path) = @_;
  if ( $^O eq "MSWin32" ) {
    $path =~ s!/!\\!g;
  }
  else {
    $path =~ s!\\!/!g;
  }
  return $path;
}
sub doOracle()
  {
    return $Database eq "oracle" or $Database eq "both";
  }
sub doSqlServer()
  {
    return $Database eq "mssql" or $Database eq "both";
  }

sub Usage()
  {
    print "Usage: perl tcsetup.pl options [install|delete]\n";
    print "-m - major version\n";
    print "-n - minor version\n";
    print "-p - point version\n";
    print "-b - build number (three digits please)\n";
    print "-d - oracle | mssql | both\n";
    print "-O - tnsname \n";
    print "-S - dsn name\n";
    print "-W - full path to webable folder\n";
    print "-N - full path to nonwebable folder\n";
    print "-B - [Y/N] Copy from builds (default: $CopyFromBuilds)\n";
    print "-M - [Y/N] Multiple builds (default: $MultipleBuilds)\n";
    print "-V - [Y/N] Include Version $Major$Minor$Point (default: $UseVersion)\n";
    print "-D - Install Drive (default: $InstallDrive)\n";
    print "-P - Root for nonwebable folder (default: $ProgramFiles)\n";
    print "-R - Root for webable folder (default: $WWWRoot)\n";
    print "-T - where to put tomcat and the jdk (default: $tcc)\n";
    print "-C - tomcat home (default: $tomcat_home)\n";
    print "-A - Oracle Home e.g. c:\\oracle\\ora92 \n";
    print "-Q - Sql Server Home e.g. c:\\Program Files\\Microsoft SQL Server\\MSSQL.1\\MSSQL\n";
    print "-I - path to instances html page, either absolute or relative to WWWRoot\n";
    print "-G - [Y/N] Debug build (development only) (default: N)\n";
    print "-c - clearcase drive (development only)\n";
    print "-v - view (development only)\n";
    print "-w - [Y/N] only copy newer files\n";
    print "-t - [Y/N] testing\n";
    print "-x - customer prefix\n";
    print "-e - [2000/2005] Sql Server version (default: $sqlver)\n";
    print "-s - Sql Server sa password (default: $saPass)\n";
    print "-U - [Y/N/prefix] Use username as schema prefix [N]\n";
    print "-E - [Y/N] Copy executables [N]\n";
    print "-f - [Y/N] Use esd vob [N]\n";
    print "-J - Just display | WebDir | Perms | Default | Reg | Copy | Tomcat | Schemas | Exes | Redirector\n";
    print "-i - [Y/N] install tomcat [$installTomcat]\n";
    print "-j - [Y/N] install redirector [$installRedirector]\n";
    print "-o - [Y/N] Run tomcat as a service [$stopStartTomcat]\n";
    print "-L - languages to install [$languages]\n";
    print "-u - CustomBuild suffix e.g. build104WB\n";
    print "-r - [Y/N] Store templates in the registry (default: Y)\n";
    print "-a - [Y/N] Setup jasperserver (default: $setupJasper)\n";

    print "\ne.g.\n";
    print "\tperl tcsetup.pl -m 8 -n 1 -p 0 -b 038 -d oracle -O tc810\n";
  }

sub SetupLogging()
  {
    my ($Sec, $Min, $Hour, $Day, $Month, $Year, $Wday, $Yday, $IsDst ) = localtime(time);
    $Year  = $Year + 1900;
    $Month = $Month + 1;

    if ( $Month < 10 )
      {
        $Month = "0$Month";
      }
    if ( $Day < 10 )
      {
        $Day = "0$Day";
      }
    if ( $Hour < 10 )
      {
        $Hour = "0$Hour";
      }
    if ( $Min < 10 )
      {
        $Min = "0$Min";
      }

    if ( $ENV{TCSETUP_LOGS} ne "" )
      {
        $logsdir = $ENV{TCSETUP_LOGS};
      }

    if ( ! -d $logsdir )
      {
        mkdir( $logsdir );
      }

    my $path = $ENV{PATH};
    if ( $path !~ /c:\\bin$/i and $path !~ /c:\\bin;/i )
      {
        $ENV{PATH} = $path . ";c:\\bin";
      }
    if ( !find_prog( "tee" ) )
      {
        print "ERROR! tee not found\n";
        print "install cygwin http://www.cygwin.com/setup.exe\n";
        print "or\n";
        print "copy \\\\hogfather\\shared\\wbt-setup\\tee.exe c:\\bin\n";
        print "copy \\\\hogfather\\shared\\wbt-setup\\cyg*.dll c:\\bin\n";
      }
    else
      {
        if ( -d $logsdir )
          {
            my $log = sprintf( "$logsdir\\tcsetup-%04d-%02d-%02d-%02d%02d.txt", $Year, $Month, $Day, $Hour, $Min );

            print "Logging to $log\n";
            $| = 1; # immediate flushing

            #$pager = $ENV{PAGER} || "(less || more)";

            if ( open( LOG, "| tee $log") )
              {
                #open( LOG, ">$log" );
                open( STDERR, ">&LOG" );
                open( STDOUT, ">&LOG" );
                print "$0\n";
              }
            else
              {
                print "Failed to fork tee: $!\n";
                print "install cygwin http://www.cygwin.com/setup.exe\n";
                print "or\n";
                print "copy \\\\hogfather\\shared\\tee.exe c:\\bin\n";
                print "copy \\\\hogfather\\shared\\cyg*.dll c:\\bin\n";
              }
          }
      }
  }

sub FinishLogging()
  {
    print "Finished!\n";
    #close( LOG );
    #close( STDOUT );
    #close( STDERR );
  }

sub trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

sub DefaultArgs($$$)
  {
    my ($prog, $opts, $first) = @_;

    my $argsfile = "$argsdir\\$prog." . lc $ENV{COMPUTERNAME};

    my $env_name = uc "${prog}_ARGS";

    my $args = $ENV{$env_name};

    if ( $args =~ /^\@(.+)/ ) # was a file specified...
      {
        $argsfile = $1;
        print "$env_name specifies a file $argsfile\n";
      }
    elsif ( $args ne "" ) # th options are as given
      {
        print "$env_name specifies options $args\n";
        my @argv = split( / /, $args );
        for ( my $i = 0; $i < $#argv; $i += 2 )
          {
            if ( $argv[$i] =~ /^-([a-zA-Z])$/ )
              {
                my $n = $1;
                my $v = $argv[$i+1];
                print "Setting opts{$n} = $v\n";
                $opts->{$n} = $v;
              }
          }
      }

    if ( $argsfile eq "" )
      {
      }
    elsif ( !-e $argsfile )
      {
        print "Options file $argsfile not found\n";
      }
    elsif ( -e $argsfile )
      {
        print "Processing options in file $argsfile $first\n";
        my $args;
        if ( open( VARS, $argsfile ) )
          {
            while ( <VARS> )
              {
                chomp;
                s/\s*;.+//;
                s/\s*#.+//;
                if ( /^([-+])([a-zA-Z])\s+(.+)$/ )
                  {
                    my $when = $1;
                    my $name = $2;
                    my $value = $3;
                    $value =~ s!\s+$!!;
                    if ( $when eq "+" or $first eq 1 )
                      {
                        #print "Setting opts{$name} = $value\n";
                        $args = "$args -$name $value";
                        $opts->{$name} = $value;
                      }
                    elsif ( $opts->{$name} ne $value )
                      {
                        print "Ignoring $_\n";
                      }
                  }
                elsif ( /^([-+])([a-zA-Z])\s*$/ )
                  {
                    my $when = $1;
                    my $name = $2;
                    if ( $when eq "+" or $first eq 1 )
                      {
                        #print "Setting opts{$name} = \n";
                        $args = "$args -$name";
                        $opts->{$name} = undef();
                      }
                    elsif ( $opts->{$name} ne undef() )
                      {
                        print "Ignoring $_\n";
                      }
                  }
                elsif ( $_ )
                  {
                    print "ERROR: Unrecognised line $_\n";
                  }
              }
            close( VARS );
          }
        #print "Args: [$args]\n";
      }
  }

sub SetupVars()
  {
    my %opts = ( A => undef(),
                 B => undef(),
                 C => undef(),
                 D => undef(),
                 E => undef(),
                 G => undef(),
                 I => undef(),
                 J => undef(),
                 L => undef(),
                 M => undef(),
                 N => undef(),
                 O => undef(),
                 P => undef(),
                 Q => undef(),
                 R => undef(),
                 S => undef(),
                 T => undef(),
                 U => undef(),
                 V => undef(),
                 W => undef(),
                 X => undef(),

                 a => undef(),
                 b => undef(),
                 c => undef(),
                 d => undef(),
                 e => undef(),
                 f => undef(),
                 g => undef(),
                 i => undef(),
                 j => undef(),

                 m => undef(),
                 n => undef(),
                 o => undef(),
                 p => undef(),
                 r => undef(),
                 s => undef(),
                 t => undef(),
                 v => undef(),
                 w => undef(),
                 x => undef(),
                 u => undef(),
               );

    DefaultArgs("tcsetup", \%opts, 1);

    # Was anything other than the defined option entered on the command line?
    if ( !getopts("a:b:c:d:e:f:g:i:j:m:n:o:p:r:s:t:u:v:w:x:A:B:C:D:E:G:I:J:L:M:N:O:P:Q:R:S:T:U:V:X:W:", \%opts ) )
      {
        print STDERR "Unknown args @ARGV\n" if @ARGV > 0;
        Usage();
        exit;
      }

    DefaultArgs("tcsetup", \%opts, 2);

    #lets try and duplicate stdout and stderr to a file...

    #first the file...


    #print "getopts succeeded \n";
    foreach ( keys %opts )
      {
        if ( defined($opts{$_}) )
          {
            #print "-$_ " . $opts{$_} . "\n";
          }
      }
    if ( defined($opts{g}) )
      {
        if ( "Y" eq uc $opts{g} )
          {
            $verbose = 1;
          }
        else
          {
            $verbose = undef;
          }
      }
    $CustomBuild = $opts{u};
    $View  = $opts{v};
    $Database = lc $opts{d};
    $ccDrive  = $opts{c};
    $Major = $opts{m};
    $Minor = $opts{n};
    $Point = $opts{p};
    $Build = $opts{b};
    $Just = lc $opts{J};

    if ( $View eq "." )
      {
        # need to determine the current view and drive
        my $cmd = "cleartool lsview -cview -short";
        chomp( $View = `$cmd` ); #e.g. eweb_800_hogfather

        print "[$cmd] => [$View]\n";
        #print "[$View]\n";
        if ( $View =~ /Error escc: unknown command lsview/ )
          {
            $View = "";
          }
        if ( $View eq $cmd )
          {
            $View = "";
          }
        #print "[$View]\n";
        if ( $ccDrive eq "" )
          {
            my $dir = cwd;
            if ( $dir =~ /^(.:)/ )
              {
                $ccDrive = $1;
              }
          }
      }

    if ( $Major ne "" and $Minor ne "" and $Point ne "" )
      {
      }
    elsif ( $ccDrive )
      {
        my ($m, $n, $p, $b) = GetBuildNumber( $ccDrive );
        $Major = $m if ( $Major eq "" );
        $Minor = $n if ( $Minor eq "" );
        $Point = $p if ( $Point eq "" );
        $Build = $b if ( $Build eq "" );
      }

    print "Using version: $Major.$Minor.$Point.$Build\n";
    $MNP  = "${Major}.${Minor}.${Point}";
    $MNPB = "${Major}.${Minor}.${Point}.${Build}";
    $mnp  = "${Major}${Minor}${Point}";
    $mnpb = "${Major}${Minor}${Point}b${Build}";

    if ( $MNP ge "8.0.0" )
      {
        $sqlver = "2005";
      }
    #print "Remaining args @ARGV\n" if @ARGV > 0;
    if ( @ARGV > 0 && "install" eq lc $ARGV[0] )
      {
        $command = lc $ARGV[0];
      }
    elsif ( @ARGV > 0 && "delete" eq lc $ARGV[0] )
      {
        $command = lc $ARGV[0];
      }
    elsif ( @ARGV > 0 && "freshen" eq lc $ARGV[0] )
      {
        $command = lc $ARGV[0];
      }
    elsif ( @ARGV > 0 )
      {
        $command = lc $ARGV[0];
        print "unknown command: $command\n";
        Usage();
        exit;
      }
    if ( $Major eq "" or $Minor eq "" or $Point eq "" )
      {
        print "Version not specified\n";
        Usage();
        exit;
      }

    if ( defined($opts{X}) )
      {
        $cleanFirst = uc $opts{X};
      }

    $tomcat_home       = $opts{C};
    $installTomcat     = $opts{i};
    $installRedirector = $opts{j};
    if ( defined($opts{o}) )
      {
        $stopStartTomcat = uc $opts{o};
      }
    if ( $redirVer eq "2" )
      {
        $isapiRedirectoRegKey    = "2.0";
        $workersFileRegValue     = "workersFile";
        $workerMountFileRegValue = "";
      }
    else
      {
        $isapiRedirectoRegKey    = "1.0";
        $workersFileRegValue     = "worker_file";
        $workerMountFileRegValue = "worker_mount_file";
      }

    if ( defined($opts{a}) )
      {
        $setupJasper = uc $opts{a};
      }
    if ( defined($opts{r}) )
      {
        $templatesInRegistry = uc $opts{r};
      }
    if ( defined($opts{L}) )
      {
        $languages = $opts{L};
      }
    if ( defined($opts{f}) )
      {
        $esdVob = $opts{f};
      }
    if ( defined($opts{x}) )
      {
        $prefix = $opts{x};
      }
    if ( defined($opts{t}) )
      {
        $testing = uc $opts{t};
      }
    if ( defined($opts{A}) )
      {
        $oracleHome = $opts{A};
        if ( ! -d $oracleHome )
          {
            print "ERROR Specified Oracle Home directory -A $oracleHome doesn't exist\n";
            die unless ( doSqlServer() );
          }
      }
    if ( defined($opts{w}) )
      {
        $copyNewer = uc $opts{w};
      }
    if ( defined($opts{D}) )
      {
        $InstallDrive = $opts{D};
      }
    if ( defined($opts{P}) )
      {
        $ProgramFiles = $opts{P};
      }
    else
      {
        $ProgramFiles = "$InstallDrive\\Program Files";
      }
#    if ( ! -d $ProgramFiles )
#      {
#        print "Specified \"Program Files\" directory -P $ProgramFiles doesn't exist, creating...\n";
#        MkDir( $ProgramFiles );
#      }
#    if ( ! -d $ProgramFiles )
#      {
#        die "ERROR Specified \"Program Files\" directory -P $ProgramFiles doesn't exist\n";
#      }
    if ( defined($opts{R}) )
      {
        $WWWRoot = $opts{R};
      }
    else
      {
        $WWWRoot = "$InstallDrive\\inetpub\\wwwroot";
      }
    if ( ! -d $WWWRoot )
      {
        print "Specified wwwroot directory -R $WWWRoot doesn't exist, creating...\n";
        MkDir( $WWWRoot );
      }
    if ( ! -d $WWWRoot )
      {
        die "ERROR Specified wwwroot directory -R $WWWRoot doesn't exist\n";
      }
    if ( defined($opts{T}) )
      {
        $tcc = $opts{T};
        if ( ! -d $tcc )
          {
            #print "Specified tcc directory -T $tcc doesn't exist, creating...\n";
            #MkDir( $tcc );
          }
        #if ( ! -d $tcc )
        #  {
        #    die "ERROR Specified tcc directory -T $tcc doesn't exist\n";
        #  }
      }
    else
      {
        if ( ${Major} ge 8 )
          {
            $tcc = "$InstallDrive\\TopClass${Major}\\tcc";
          }
        else
          {
            $tcc = "$InstallDrive\\tcc";
          }
      }

    if ( ${Major} ge 8 )
      {
        $tomcatService = "tomcat6";
      }
    else
      {
        $tomcatService = "Tomcat-TCC";
      }

    if ( defined($opts{I}) )
      {
        $instances = $opts{I};
      }

    if ( defined($opts{B}) )
      {
        $CopyFromBuilds = $opts{B};
        if ( $CopyFromBuilds =~ /\\/ )
          {
            $Builds = $CopyFromBuilds;
            $CopyFromBuilds = "Y";
            print "Builds: $Builds\n";
          }
      }

    if ( $View eq "" && $CopyFromBuilds eq "N" )
      {
        # these are the conventions I use for my views...
        if ( $host eq "hogfather" or $host eq "prism" or $host eq "howlin" )
          {
            $View = "eweb_${mnp}_${host}";
          }
      }

    if ( defined($opts{M}) )
      {
        $MultipleBuilds = uc $opts{M};
      }

    if ( $MultipleBuilds eq "Y" )
      {
        if ( $Build eq "" )
          {
            die "Must specify a build number (e.g. -b 044) for Multiple Builds -M Y\n";
          }
      }

    if ( $CopyFromBuilds eq "Y" )
      {
        if ( $Build eq "" )
          {
            die "Must specify a build number (e.g. -b 044) for Copy From Builds -B Y\n";
          }
      }

    if ( defined($opts{V}) )
      {
        $UseVersion = uc $opts{V};
      }

    if ( $UseVersion eq "N" )
      {
        $tcver  = "${prefix}";
      }
    else
      {
        $tcver  = "${prefix}${mnp}";
      }
    $tcdir  = $tcver; # webable
    $tcdir2 = "TopClass $tcver"; # non webable
    $tcuser = $tcver;

    if ( defined($opts{U}) )
      {
        $uname = $opts{U};
      }

    if ( uc $uname eq "Y" )
      {
        my $username = lc $ENV{USERNAME};
        if ( $usernameMap{$username} ne "" )
          {
            $username = $usernameMap{$username};
          }

        $tcuser = "${username}${mnp}";
      }
    elsif ( uc $uname ne "N" )
      {
        my $username = $uname;
        $tcuser = "${username}${mnp}";
      }
    print "tcuser: $tcuser\n";

    if ( $ccDrive ne "" )
      {
        my $saveDir =  cwd;
        chdir( "$ccDrive\\" );
        my $viewdesc = `cleartool lsview -cview`;
        #print "$viewdesc\n";
        if ( $viewdesc =~ /Error escc: unknown command lsview/ )
          {
            $View = "escc";
          }
        elsif ( $viewdesc =~ "cleartool lsview -cview" )
          {
            $View = "";
          }
        elsif ( $viewdesc =~ /\*?\s+(\S+)\s+(\S+)/ )
          {
            #* eweb_800_hogfather   \\hogfather\ccstg_c\views\WEST\eweb\eweb_800_hogfather.vws
            $View = $1;
            print "View: $View\n";
          }
        else
          {
            print "Error cannot determine view\n";
            print "$viewdesc\n";
          }
        chdir( $saveDir );
      }

    if ( $View ne "" )
      {
        if ( $MultipleBuilds ne "N" )
          {
            print "View specified so, setting MultipleBuilds = N\n" if ( $verbose );
            $MultipleBuilds = "N";
          }
        if ( $CopyFromBuilds eq "Y" )
          {
            print "View specified so, setting CopyFromBuilds = N\n" if ( $verbose );
            $CopyFromBuilds = "N";
          }
      }

    if ( $MultipleBuilds eq "Y" )
      {
        $tcdir = "${tcver}b${Build}";
        $tcdir2 = "TopClass ${tcver}b${Build}";
        $tcuser = "${tcuser}b${Build}";
      }

    if ( $View ne "" and $View ne "escc" )
      {
        if ( $esdVob eq "Y" )
          {
            $webpath = "\\\\view\\$View\\esd\\webable";
            $nonwebpath = "\\\\view\\$View\\esd\\nonwebable";
          }
        else
          {
            $webpath = "\\\\view\\$View\\topclass\\oracle\\topclass\\www";
            $nonwebpath = "\\\\view\\$View\\topclass\\oracle\\topclass\\www";
          }
        $clearcasedrive = "Y";
        $scriptsRoot = "\\\\view\\$View";
      }
    elsif ( $CopyFromBuilds eq "N" && ( lc $ENV{COMPUTERNAME} eq "roo" || lc $ENV{COMPUTERNAME} eq "floyd" ) )
      {
        $webpath = "c:\\cpp\\${tcdir}\\topclass\\oracle\\topclass\\www";
        $nonwebpath = "c:\\cpp\\${tcdir}\\topclass\\oracle\\topclass\\www";
        $scriptsRoot = "c:\\cpp\\${tcdir}";
      }
    else
      {
        # will be copying files...
        if ( $MultipleBuilds eq "Y" && $Build eq "" )
          {
            die "ERROR Must specify a build number (-b) for Multiple Builds (-M)\n";
          }

        # need to know source and destination...
        if ( $Major eq 9 )
          {
            $webpath    = "$InstallDrive\\TopClass9\\$tcdir";
            $nonwebpath = "$InstallDrive\\TopClass9\\$tcdir";

            if ( !defined($opts{T}) )
              {
                $tcc = "$InstallDrive\\TopClass9\\tcc";
              }
          }
        if ( $Major eq 8 )
          {
            $webpath = "$InstallDrive\\TopClass8\\$tcdir";
            $nonwebpath = "$InstallDrive\\TopClass8\\$tcdir2";

            if ( !defined($opts{T}) )
              {
                 $tcc = "$InstallDrive\\TopClass8\\tcc";
              }
          }
        else
          {
            if ( ! -d $ProgramFiles )
              {
                print "Specified \"Program Files\" directory -P $ProgramFiles doesn't exist, creating...\n";
                MkDir( $ProgramFiles );
              }
            if ( ! -d $ProgramFiles )
              {
                die "ERROR Specified \"Program Files\" directory -P $ProgramFiles doesn't exist\n";
              }
            $webpath = "$WWWRoot\\$tcdir";
            $nonwebpath = "$ProgramFiles\\$tcdir2";
          }
        if ( defined( $opts{W} ) )
          {
            $webpath = $opts{W};
          }
        if ( defined( $opts{N} ) )
          {
            $nonwebpath = $opts{N};
          }
        $oraclePath = "$nonwebpath\\scripts";
        $mssqlPath = "$nonwebpath\\mssql";
      }

    $nonwebroot = $nonwebpath;
    if ( $Win7 )
      {
        $localnonwebroot = "c:\\topclassexes\\$tcdir";
      }

    if ( $ccDrive ne "" )
      {
        if ( $esdVob eq "Y" )
          {
            $nonwebroot = "$ccDrive\\esd\\nonwebable";
          }
        else
          {
            $nonwebroot = "$ccDrive\\topclass\\oracle\\topclass\\www";
          }
      }

    if ( defined( $opts{G} ) )
      {
        $debugBuild = $opts{G};
      }
    elsif ( lc $ENV{USERNAME} eq "eweb" )
      {
        if ( $clearcasedrive eq "Y" )
          {
            $debugBuild = "Y";
          }
      }

    if ( defined( $opts{E} ) )
      {
        $copyExes = $opts{E};
      }

################ Database servers ################

    $oradb = lc $ENV{COMPUTERNAME};
    $sqldb = lc $ENV{COMPUTERNAME};

    if ( $ENV{COMPUTERNAME} eq "hogfather" )
      {
        $oradb = "hog10gr2";
      }
    if ( $ENV{COMPUTERNAME} eq "prism" )
      {
        $oradb = "prism10gr2";
      }

    if ( defined( $opts{O} ) )
      {
        #$oradb = $opts{O};
        my ($a, $b, $c) = split( /:/, $opts{O} );
        if ( $a ne "" )
          {
            $oradb = $a;
          }
        if ( $b ne "" )
          {
            $syspass = $b;
          }
        if ( $c ne "" )
          {
            $systempass = $c;
          }
      }
    if ( defined( $opts{S} ) )
      {
        $sqldb = $opts{S};
      }
    if ( defined( $opts{e} ) )
      {
        $sqlver = $opts{e};
        if ( $MNP ge "8.0.0" and $sqlver eq "2000" )
          {
            print "ERROR: Sql Server 2000 no longer supported\n";
            $sqlver = "2005";
          }
      }
    if ( defined( $opts{s} ) )
      {
        $saPass = $opts{s};
      }
    if ( $syspass eq "" )
      {
        $syspass = "whopper";
        $systempass = "whopper";
      }
    if ( defined($opts{Q}) )
      {
        $mssqlHome = $opts{Q};

        my $remote = $sqldb;
        $remote =~ s!\\.+!!; # strip off named instance.

        if ( lc $remote eq lc $ENV{COMPUTERNAME} )
          {
            if ( ! -d $mssqlHome )
              {
                print "ERROR Specified Sql Server Home directory -Q $mssqlHome doesn't exist\n";
                die unless ( doOracle() );
              }
          }
        else #if ( lc $sqldb ne lc $ENV{COMPUTERNAME} )
          {
            # TODO validate directory on remote machine.
            my $remoteHome = "\\\\$remote\\$mssqlHome";
            $remoteHome =~ s!:!\$!;
            if ( ! -d $remoteHome )
              {
                print "WARNING Can't verify remote Sql Server Home directory $remoteHome\n";
              }
          }
      }
    else #if ( ? )
      {
        if ( $sqlver eq "2000" )
          {
            $mssqlHome = $mssqlHome2000;
          }
        elsif ( $sqlver eq "2005" )
          {
            $mssqlHome = $mssqlHome2005;
          }
        elsif ( $sqlver eq "2008" )
          {
            $mssqlHome = $mssqlHome2008;
          }
        else
          {
            print "ERROR sqlver (-e) must be either 2008, 2005 or at a push 2000\n";
            die unless ( doOracle() );
          }
      }
    $oraSchemaName = $tcuser;
    $sqlSchemaName = $tcuser;
    # TODO add build...
    if ( $View ne "" )
      {
        $oraSchemaName .= "b${Build}";
        $sqlSchemaName .= "b${Build}";
      }
    $oraSchemaPass = $oraSchemaName;
    if ( $sqlver eq "2005" and $MNPB le "8.0.0.030" )
      {
        $sqlSchemaPass = '_' . $sqlSchemaName . '_';
      }
    else #if ( $sqlver eq "2005" )
      {
        $sqlSchemaPass = $sqlSchemaName;
      }

    #cnr suffix
    if ( $UseVersion eq "N" )
      {
        $suffix = "";
      }
    else
      {
        $suffix = $mnp;
      }

    if ( $prefix ne "tc" )
      {
        $suffix = "$prefix$suffix";
      }
    if ( $MultipleBuilds eq "Y" )
      {
        $suffix = "${suffix}b$Build";
      }
    if ( $installTomcat eq "" )
      {
        # is it installed as a service?
        my $cmd = "reg query ";
        my $imagePath = RegGet( "HKEY_LOCAL_MACHINE\\system\\CurrentControlSet\\services\\$tomcatService", "ImagePath" );
        if ( $imagePath eq "" )
          {
            print "No service called $tomcatService found, so will install use -i N to override\n";
            $installTomcat = "Y";
          }
        elsif ( $imagePath ne "" )
          {
            print "imagePath: $imagePath\n";
            print "A service called $tomcatService found, so will not install use -i Y to override\n";
            $installTomcat = "N";
            if ( $imagePath =~ /^(.+) \/\/RS\/\/(.+)/ )
              {
                my ($exe, $name) = ($1, $2);
                print "exe: $exe name: $name\n";
                if ( $exe =~ /^(.+)\\bin\\[^\\.]+\.exe/ )
                  {
                    $tomcat_home = $1;
                    print "tomcat_home: $tomcat_home\n";
                  }
              }
          }
      }

    $workersFile     = RegGet( "$isapiRedirectoRegRoot\\$isapiRedirectoRegKey", "$workersFileRegValue" );
    $workerMountFile = RegGet( "$isapiRedirectoRegRoot\\$isapiRedirectoRegKey", "$workerMountFileRegValue" );

    if ( $installRedirector eq "" )
      {
        # is the redirector of the specified version installed?
        if ( $workersFile eq "" )
          {
            print "Redirector not found, so will install use -j N to override\n";
            $installRedirector = "Y";
          }
        elsif ( $workersFile ne "" )
          {
            print "Redirector found, so will not install use -j Y to override\n";
            $installRedirector = "N";
          }
      }

    if ( $tomcat_home eq "" )
      {
        $tomcat_home = "$tcc\\tomcat";
      }
    if ( $MNPB gt "8.1.0.012" and $MNPB le "8.1.0.060"  )
      {
        #$Assemblies = 1;
      }
    if ( $MNPB gt "8.1.0.060" )
      {
        $useMicrosoftDriver = 1;
      }

    my $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${Build}${CustomBuild}";
    print "Distrib: $Builds\n";

    # is tcc under nonwebable?
    my $tcc_under_nonwebable;
    if ( -d "$distrib\\windows\\nonwebable\\tcc" )
      {
        print "found [$distrib\\windows\\nonwebable\\tcc]\n";
        $tcc_under_nonwebable = 1;
      }
    elsif ( -d "$distrib\\windows\\tcc" )
      {
        print "found [$distrib\\windows\\tcc]\n";
        $tcc_under_nonwebable = undef;
      }
    print "\$tcc_under_nonwebable = $tcc_under_nonwebable;\n";
  }

sub CreateWebDir()
  {
    CreateIIsDir( $tcdir, $webpath );

    if ( $clearcasedrive eq "Y" )
      {
        my $password;
        my $domain = $ENV{USERDOMAIN};
        my $username = $ENV{USERNAME};
        #system "stty -echo";
        print "Enter password for $domain\\$username: ";
        chomp($password = <STDIN>);
        print "\n";
        #system "stty echo";
        if ( $iis7 )
          {
            # TODO set password etc in iis 7
            setProperty( $tcdir, "UNCUserName", "$domain\\$username" );
            if ( $password ne "" )
              {
                setProperty( $tcdir, "UNCPassword", $password );
                setProperty( $tcdir, "AnonymousUserPass", $password );
              }
            setProperty( $tcdir, "AnonymousUserName", "$domain\\$username" );
            setProperty( $tcdir, "AnonymousPasswordSync", "False" );
          }
        else
          {
            setProperty( $tcdir, "UNCUserName", "$domain\\$username" );
            if ( $password ne "" )
              {
                setProperty( $tcdir, "UNCPassword", $password );
                setProperty( $tcdir, "AnonymousUserPass", $password );
              }
            setProperty( $tcdir, "AnonymousUserName", "$domain\\$username" );
            setProperty( $tcdir, "AnonymousPasswordSync", "False" );
          }
      }
  }

sub CreateIIs7Dir( $$ )
  {
    my ($name, $path) = @_;
    my $cmd = "$appcmd add app /site.name:\"Default Web Site\" /path:/$name /physicalPath:$path";

    runCmd( $cmd );
    $cmd = "$appcmd set config \"Default Web Site/$name\" -section:system.webServer/handlers /accessPolicy:\"Read, Execute, Script\" /commit:apphost";
    runCmd( $cmd );
  }

sub CreateIIsDir( $$ )
  {
    my ($name, $path) = @_;
    if ( $iis7 )
      {
        return CreateIIs7Dir( $name, $path );
      }
    my $cmd;

    my $RootPath = getProperty( "", "Path" );

    #print "RootPath: $RootPath\n";

    my $DirType = "IIsWebVirtualDir";
    my $qmRootPath = quotemeta $RootPath;
    if ( $path =~ /^$qmRootPath/ )
      {
        $DirType = "IIsWebDirectory";
      }

    $cmd = "$adsutil CREATE W3SVC/1/Root/$name $DirType";

    print "adsutil CREATE W3SVC/1/Root/$name $DirType\n";

    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /ErrNumber: -2147024713 \(0x800700B7\)/ )
              {
              }
            elsif ( /Error creating the object: W3SVC\/1\/Root\/$name/ )
              {
              }
            else
              {
                print;
              }
          }
      }

    # "adsutil APPUNLOAD w3svc/1/root/jakarta" to unload the app NOT

    #if setting up against a clearcase drive need to set user and passswod
    #AnonymousUserName               : (STRING) "west\eweb"
    #AnonymousUserPass               : (STRING) "**********"
    #AnonymousPasswordSync           : (BOOLEAN) False

    #Path                            : (STRING) "\\roger\stuff"
    #UNCUserName                     : (STRING) "sss"
    #UNCPassword                     : (STRING) "**********"

    if ( $DirType eq "IIsWebVirtualDir" )
      {
        setProperty( $name, "Path", $path );
      }
    setProperty( $name, "AccessExecute", "True" );
    setProperty( $name, "AppIsolated", 0 );
    setProperty( $name, "AppRoot", "/LM/W3SVC/1/Root/$name" );
    setProperty( $name, "AppFriendlyName", $name );
    setProperty( $name, "ContentIndexed", "False" );
  }

sub CreateFilter( $$$ )
  {
    my ($name, $path, $desc) = @_;
    my $cmd;

    #print "RootPath: $RootPath\n";

    my $ObjType = "IIsFilters";

    $cmd = "$adsutil CREATE W3SVC/1/Filters $ObjType";

    print "adsutil CREATE W3SVC/1/Filters $ObjType\n";

    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /ErrNumber: -2147024713 \(0x800700B7\)/ )
              {
              }
            elsif ( /Error creating the object: W3SVC\/1\/Filters/ )
              {
              }
            else
              {
                print;
              }
          }
      }

    $ObjType = "IIsFilter";

    $cmd = "$adsutil CREATE W3SVC/1/Filters/$name $ObjType";

    print "adsutil CREATE W3SVC/1/Filters/$name $ObjType\n";

    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /ErrNumber: -2147024713 \(0x800700B7\)/ )
              {
              }
            elsif ( /Error creating the object: W3SVC\/1\/Filters\/$name/ )
              {
              }
            else
              {
                print;
              }
          }
      }

    my $order = getFilterProperty( "", "FilterLoadOrder" );
    if ( $order eq "" )
      {
        setFilterProperty( "", "FilterLoadOrder", $name );
      }
    elsif ( $order !~ /$name/ )
      {
        $order = "$name,$order";
        setFilterProperty( "", "FilterLoadOrder", $order );
      }
    setFilterProperty( $name, "FilterPath", $path );
    setFilterProperty( $name, "NotifyOrderHigh", "True" );
    setFilterProperty( $name, "FilterDescription", $desc );
    setFilterProperty( $name, "FilterFlags", 0 );
    setFilterProperty( $name, "FilterState", "0" );
    #setFilterProperty( $name, "Win32Error", "0" );
    #setFilterProperty( $name, "AppIsolated", 0 );
    #setFilterProperty( $name, "AppRoot", "/LM/W3SVC/1/Root/$name" );
    #setFilterProperty( $name, "AppFriendlyName", $name );
  }

sub UpdateDefaultDotHtml()
  {
    my $fullpath;
    if ( $instances =~ /^.:/ )
      {
        $fullpath = $instances;
      }
    else
      {
        $fullpath = "$WWWRoot\\$instances";
      }
    if ( !open( DEFIN, $fullpath ) )
      {
        if ( open( DEFOUT, ">$fullpath" ) )
          {
            print DEFOUT "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
            print DEFOUT "\n";
            print DEFOUT "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n";
            print DEFOUT "<head>\n";
            print DEFOUT "<title>TopClass Instances</title>\n";
            print DEFOUT "<style type=\"text/css\">\n";
            print DEFOUT "body {\n";
            print DEFOUT "  font-family: Tahoma;\n";
            print DEFOUT "}\n";
            print DEFOUT "</style>\n";
            print DEFOUT "</head>\n";
            print DEFOUT "\n";
            print DEFOUT "<body>\n";
            print DEFOUT "<h1>TopClass Instances</h1>\n";
            print DEFOUT "\n";
            print DEFOUT "<table summary=\"Table of instances\" border=\"1\">\n";
            print DEFOUT "<tr valign=\"top\">\n";
            print DEFOUT "<td>\n";
            if ( $CopyFromBuilds eq "N" )
              {
                print DEFOUT "<a href=\"/$tcdir/tce${mnp}iis.dll?retrieve-home\">tce${mnp}iis.dll (home) </a><br/>\n";
                print DEFOUT "<a href=\"/$tcdir/tce${mnp}iis.dll?login-admin-admin-really\">tce${mnp}iis.dll (admin) </a><br/>\n";
                print DEFOUT "<a href=\"/$tcdir/tce${mnp}.dll?login-admin-admin-really\">tce${mnp}.dll (admin) </a><br/>\n";
              }
            else
              {
                print DEFOUT "<a href=\"/$tcdir/topclass.dll?retrieve-home\">${tcdir}</a><br/>\n";
              }
            print DEFOUT "</td>\n";
            print DEFOUT "</tr>\n";
            print DEFOUT "</table>\n";
            print DEFOUT "\n";
            print DEFOUT "</body>\n";
            print DEFOUT "</html>\n";
            close( DEFOUT );
          }
      }
    elsif ( open( DEFIN, $fullpath ) )
      {
        #print "Have opened \"$fullpath\"\n";
        my $changed = 0;
        my $found = 0;
        my $inlaunchTable = 0;
        my $cell;
        my @tableCells;
        if ( open( DEFOUT, ">$fullpath.temp" ) )
          {
            #print "Have opened \"$fullpath.temp\"\n";
            while (<DEFIN>)
              {
                my $line = $_;
                #print;
                if ( $inlaunchTable eq 0 && $line =~ /<table/ )
                  {
                    #print "Found beginning of launch table\n";
                    #print;

                    $inlaunchTable = 1;
                    print DEFOUT $line;
                  }
                elsif ( $inlaunchTable eq 1 && $line =~ /<\/table/ )
                  {
                    #print "Found end of launch table\n";
                    #print;

                    $inlaunchTable = 2;
                    if ( $found eq 0 )
                      {
                        $changed = 1;
                        if ( $CopyFromBuilds eq "N" )
                          {
                            $cell = "<a href=\"/$tcdir/tce${mnp}iis.dll?retrieve-home\">tce${mnp}iis.dll (home) </a><br/>\n"
                                  . "<a href=\"/$tcdir/tce${mnp}iis.dll?login-admin-admin-really\">tce${mnp}iis.dll (admin) </a><br/>\n"
                                  . "<a href=\"/$tcdir/tce${mnp}.dll?login-admin-admin-really\">tce${mnp}.dll (admin) </a><br/>\n";
                          }
                        else
                          {
                            $cell = "<a href=\"/$tcdir/topclass.dll?retrieve-home\">${tcdir}</a><br/>\n";
                          }
                        @tableCells = ( @tableCells, $cell );
                      }

                    my $cells = 0;

                    foreach my $c ( @tableCells )
                      {
                        #print $c;
                        if ( $cells eq 0 )
                          {
                            print DEFOUT "<tr valign=\"top\">\n";
                          }
                        print DEFOUT "<td>\n";
                        print DEFOUT $c;
                        print DEFOUT "</td>\n";
                        $cells++;
                        if ( $cells eq 6 )
                          {
                            print DEFOUT "</tr>\n";
                            $cells = 0;
                          }
                      }
                    if ( $cells ne 0 )
                      {
                        print DEFOUT "</tr>\n";
                      }
                  }

                if ( $inlaunchTable ne 1 )
                  {
                    print DEFOUT $line;
                  }
                else
                  {
                    if ( $line =~ /<table/ )
                      {
                      }
                    elsif ( $line =~ /<tr/ || $line =~ /<\/tr/ )
                      {
                      }
                    elsif ( $line =~ /<td>/ )
                      {
                      }
                    elsif ( $line =~ /<\/td>/ )
                      {
                        @tableCells = ( @tableCells, $cell );
                        $cell = "";
                      }
                    elsif ( $CopyFromBuilds eq "N" )
                      {
                        $cell = $cell . $line;
                        if ( $found eq 0 && $line =~ /<a href="\/($prefix[0-9]{3}(b[0-9]{3})?(cc)?)?\/tc(e|s)([0-9]{3})(iis)?\.(dll|exe)\?/ ) # closing "
                          {
                            if ( $1 eq $tcdir and $5 eq $mnp )
                              {
                                #print "Exact [$1] [$5]\n";
                                $found = 1;
                              }
                            elsif ( $1 gt $tcdir and $5 gt $mnp )
                              {
                                #print "Greater [$1] [$5]\n";
                              }
                            elsif ( $1 lt $tcdir and $5 lt $mnp )
                              {
                                #print "Smaller [$1] [$5]\n";
                                $found = 1;
                                $changed = 1;
                                my $newcell = "<a href=\"/$tcdir/tce${mnp}iis.dll?retrieve-home\">tce${mnp}iis.dll (home) </a><br/>\n"
                                            . "<a href=\"/$tcdir/tce${mnp}iis.dll?login-admin-admin-really\">tce${mnp}iis.dll (admin) </a><br/>\n"
                                            . "<a href=\"/$tcdir/tce${mnp}.dll?login-admin-admin-really\">tce${mnp}.dll (admin) </a><br/>\n";
                                @tableCells = ( @tableCells, $newcell );
                              }
                          }
                      }
                    elsif ( $MultipleBuilds eq "Y" )
                      {
                        $cell = $cell . $line;
                        if ( $found eq 0 && $line =~ /<a href="\/($prefix[0-9]{3}(b[0-9]{3}))\/topclass\.dll\?/ ) # closing "
                          {
                            if ( $1 eq $tcdir )
                              {
                                #print "Exact [$1] [$5]\n";
                                $found = 1;
                              }
                            elsif ( $1 gt $tcdir )
                              {
                                #print "Greater [$1] [$5]\n";
                              }
                            elsif ( $1 lt $tcdir )
                              {
                                #print "Smaller [$1] [$5]\n";
                                $found = 1;
                                $changed = 1;
                                my $newcell = "<a href=\"/$tcdir/topclass.dll?retrieve-home\">${tcdir}</a><br/>\n";
                                @tableCells = ( @tableCells, $newcell );
                              }
                          }
                      }
                    else #if ( $MultipleBuilds eq "Y" )
                      {
                        $cell = $cell . $line;
                        if ( $found eq 0 && $line =~ /<a href="\/($prefix[0-9]{3})\/topclass\.dll\?/ ) # closing "
                          {
                            if ( $1 eq $tcdir )
                              {
                                #print "Exact [$1] [$5]\n";
                                $found = 1;
                              }
                            elsif ( $1 gt $tcdir )
                              {
                                #print "Greater [$1] [$5]\n";
                              }
                            elsif ( $1 lt $tcdir )
                              {
                                #print "Smaller [$1] [$5]\n";
                                $found = 1;
                                $changed = 1;
                                my $newcell = "<a href=\"/$tcdir/topclass.dll?retrieve-home\">${tcdir}</a><br/>\n";
                                @tableCells = ( @tableCells, $newcell );
                              }
                          }
                      }
                  }
              }
            close( DEFOUT );
          }
        else
          {
            print "Failed to open $fullpath.temp";
          }
        close( DEFIN );
        if ( $changed == 1 )
          {
            if ( -e "$fullpath.bak" )
              {
                unlink( "$fullpath.bak" ) or print "ERROR Failed to delete $fullpath.bak\n";
              }
            rename( "$fullpath", "$fullpath.bak" ) or print "ERROR Failed to rename $fullpath $fullpath.bak\n";
            rename( "$fullpath.temp", "$fullpath" ) or print "ERROR Failed to rename $fullpath.temp $fullpath\n";
          }
      }
  }

sub RegAdd( $$$ )
  {
    my ( $key, $name, $value ) = @_;

    my $cmd = "reg add \"$key\" /v \"$name\" /d \"$value\" /f";
    if ( $testing eq "Y" )
      {
        print "$cmd\n";
        return;
      }

    runCmd( $cmd, "The operation completed successfully" );
  }

sub RegGet( $$ )
  {
    my ( $key, $name ) = @_;

    my $cmd = "reg query \"$key\" /v \"$name\"";
    print "$cmd\n";

    my $gotIt = 0;
    if ( open( REG, "$cmd 2>&1 |" ) )
      {
        while ( <REG> )
          {
            print if ( $verbose );
            if ( /\s+$name\s+REG_[A-Z_]+\s+(.+)/i )
              {
                print " => $1\n" if ( $verbose );
                return $1;
              }
          }
      }
    print " => undef\n" if ( $verbose );
    return "";
  }

sub UpdateRegistry()
  {
    #
    # Set up TopClass registry
    #
    my $regVer = "${Major}.${Minor}.${Point}";
    if ( $MultipleBuilds eq "Y" and $Build ne "" )
      {
        $regVer = "${regVer}.${Build}";
      }

    my $exesKey = "$TopClassServerKey\\exes";

    my $unicode = "u";
    if ( $MNP lt "7.3.0" )
      {
        $unicode = "";
      }

    my @Exes =
      (
        "$nonwebroot\\tce${mnp}${unicode}d_dbg.exe",
        "$nonwebroot\\tce${mnp}${unicode}d.exe",
        "$webpath\\tce${mnp}iis.dll",
        "$webpath\\tce${mnp}${unicode}_dbg.dll",
        "$webpath\\tce${mnp}${unicode}.dll",
        "$webpath\\topclass.dll",
        "$nonwebroot\\topclassd.exe",
        "$nonwebroot\\cpi\\cr_report.exe",
      );
    if ( $Win7 )
      {
        @Exes = ( @Exes,
        "$localnonwebroot\\tce${mnp}${unicode}d_dbg.exe",
        "$localnonwebroot\\tce${mnp}${unicode}d.exe",
        );
      }

    if ( $prefix ne "tc" )
      {
        if ( $UseVersion eq "N" )
          {
            $regVer = $prefix;
          }
        else
          {
            $regVer = "${prefix}.${regVer}";
          }
      }

    for my $exe ( @Exes )
      {
        if ( $MNP lt "7.3.2" )
          {
            $exe =~ s/\\\\view/\\UNC\\view/;
          }

        RegAdd( $exesKey, $exe, $regVer );
      }

    # set the port...
    my $regKey = "$TopClassServerKey\\$regVer";

    #WebPath and DatabasePath
    if ( $nonwebroot ne $webpath )
      {
        RegAdd( "$regKey", "DatabasePath", $nonwebroot );
        RegAdd( "$regKey", "WebPath",      $webpath );
      }
    my $subkey;
    if ( $MNP lt "7.3.0" )
      {
        $subkey = "Globals";
      }
    else
      {
        $subkey = "Config";
      }
    if ( $oradb ne "" )
      {
        my $oralogin = "${oraSchemaName}/${oraSchemaPass}\@${oradb}";
        my $regCmd = "reg query \"$regKey\\$subkey\" /v oralogin";
        print "$regCmd\n";
        my $gotIt = 0;
        if ( open( REG, "$regCmd 2>&1 |" ) )
          {
            while ( <REG> )
              {
                if ( /\s+(oralogin)\s+(REG_SZ)\s+(.+)/i )
                  {
                    if ( doOracle() and $3 ne $oralogin )
                      {
                        print "Changing oralogin from $3 to $oralogin\n";
                      }
                    else
                      {
                        $gotIt = 1;
                      }
                  }
              }
          }

        if ( $gotIt == 0 )
          {
            RegAdd( "$regKey\\$subkey", "oralogin", $oralogin );
          }
        # if
        if ( doOracle() )
          {
            RegAdd( "$regKey\\Config", "RDBMS", "1" );
          }
      }

    if ( $sqldb ne "" )
      {
        my $dsn = $sqldb;
        $dsn =~ s!\\!_!; # strip off named instance.

        my $sqllogin = "${sqlSchemaName}/${sqlSchemaPass}\@${dsn}";
        my $regCmd = "reg query \"$regKey\\$subkey\" /v sqllogin";
        print "$regCmd\n";
        my $gotIt = 0;
        if ( open( REG, "$regCmd 2>&1 |" ) )
          {
            while ( <REG> )
              {
                if ( /\s+(sqllogin)\s+(REG_SZ)\s+(.+)/i )
                  {
                    if ( doSqlServer() and $3 ne $sqllogin )
                      {
                        print "Changing sqllogin from $3 to $sqllogin\n";
                      }
                    else
                      {
                        $gotIt = 1;
                      }
                  }
              }
          }
        if ( $gotIt == 0 )
          {
            RegAdd( "$regKey\\$subkey", "sqllogin", $sqllogin );
          }
        unless ( doOracle() )
          {
            RegAdd( "$regKey\\Config", "RDBMS", "2" );
          }
      }
    my $tcbin = "topclass.dll";
    if ( $CopyFromBuilds eq "N" )
      {
        $tcbin = "tce${mnp}iis.dll";
      }

    RegAdd( "$regKey\\Globals", "TopClassURL", "http://$host/$tcdir/$tcbin?" );

    RegAdd( "$regKey\\Globals", "ServerPort", "16${mnp}" );

    RegAdd( "$regKey\\Config", "MiniHttpPort", "17${mnp}" );

    RegAdd( "$regKey\\Trace", "LogRequests", "1" );
    RegAdd( "$regKey\\Trace", "LogTimes", "1" );

    RegAdd( "$regKey\\Security", "AnonStatus", "2" );

    if ( lc $ENV{USERNAME} eq "eweb" && $CopyFromBuilds eq "N" )
      {
        RegAdd( "$regKey\\Security", "Authentication", "COOKIE" );
        RegAdd( "$regKey\\Security", "AutoLogout", "1" );
        RegAdd( "$regKey\\SPI_COOKIE", "PasswordCookie", "cookie_pass" );
        RegAdd( "$regKey\\SPI_COOKIE", "UsernameCookie", "cookie_user" );
        RegAdd( "$regKey\\SPI_COOKIE", "UsePasswords", "1" );
        RegAdd( "$regKey\\SPI_COOKIE", "Redirect", "cookieauth.html" );
      }
    #
    RegAdd( "$regKey\\Switch", "AutoloadTemplates", "1" );
    # prevents storage of templates in the registry...
    if ( $templatesInRegistry eq "N" )
      {
        RegAdd( "$regKey\\Switch", "RegistryTemplates", "0" );
      }

    RegAdd( "$regKey\\Switch", "TemplateDiffs", "1" );
    RegAdd( "$regKey\\Internal", "DBLinks", "1" );
    RegAdd( "$regKey\\Internal", "FormDefEdit", "1" );
    RegAdd( "$regKey\\Internal", "WriteLogAsUtf16", "0" );
    RegAdd( "$regKey\\Internal", "WriteTemplatesAsUtf16", "0" );

    my $pathToCpi = "cpi\\\\";
    if ( lc $ENV{COMPUTERNAME} eq "roo" || lc $ENV{COMPUTERNAME} eq "floyd" )
      {
        $pathToCpi = "..\\\\..\\\\plugins\\\\bin\\\\";
      }
    my $dbg;
    if ( uc $debugBuild eq "Y" )
      {
        $dbg = "_dbg";
      }
    RegAdd( "$regKey\\Plugins", "xml",        "1,0,${pathToCpi}xmlinterface${unicode}${dbg}.dll,1,0,0" );
    RegAdd( "$regKey\\Plugins", "catreg",     "1,0,${pathToCpi}catreg${unicode}${dbg}.dll,1,0,0" );
    RegAdd( "$regKey\\Plugins", "completion", "0,1,${pathToCpi}completion${unicode}${dbg}.dll,1,0,0" );
    RegAdd( "$regKey\\Plugins", "centra",     "0,1,${pathToCpi}centra${unicode}${dbg}.dll,1,0,0" );
    RegAdd( "$regKey\\Plugins", "NETg",       "0,1,${pathToCpi}netg${unicode}${dbg}.dll,1,0,0" );
    RegAdd( "$regKey\\Plugins", "SCORM",      "1,1,${pathToCpi}SCORM${unicode}${dbg}.dll,1,1,0" );
    RegAdd( "$regKey\\Plugins", "AICC",       "1,0,${pathToCpi}AICC${unicode}${dbg}.dll,1,1,0" );
    RegAdd( "$regKey\\Plugins", "SyncServer", "0,1,${pathToCpi}SyncServer${unicode}${dbg}.dll,1,1,4" );
    RegAdd( "$regKey\\Plugins", "ws",         "0,0,${pathToCpi}ws${unicode}${dbg}.dll,1,1,0" );
   #RegAdd( "$regKey\\Plugins", "haha",       "0,0,${pathToCpi}haha${unicode}${dbg}.dll,1,1,0" );
    RegAdd( "$regKey\\Plugins", "reports",    "1,1,${pathToCpi}reports${unicode}${dbg}.dll,1,0,0" );
    RegAdd( "$regKey\\Plugins", "online",     "0,0,${pathToCpi}online${unicode}${dbg}.dll,1,0,0" );

    # point at the correct context
    if ( $MNP lt "8.0.0" )
      {
        RegAdd( "$regKey\\Plugin_catreg", "ModuleBase", "/cnr$suffix/tc" );
      }
    else
      {
        RegAdd( "$regKey\\Plugin_catreg", "ModuleBase", "/cnr$suffix" );
      }
    # As we use the same schemaName for oracle and sql server this will work?

    RegAdd( "$regKey\\Plugin_reports", "DatabaseName", $oraSchemaName );
  }

sub getProperty( $$ )
  {
    my ($dir,  $property) = @_;
    return getIIsProperty( "Root", $dir, $property );
  }

sub getFilterProperty( $$ )
  {
    my ($dir,  $property) = @_;
    return getIIsProperty( "Filters", $dir, $property );
  }

sub getIIsProperty( $$$ )
  {
    my ($root, $dir,  $property) = @_;

    my $value;

    my $args = "GET W3SVC/1/$root/$dir/$property";
    if ( $dir eq "" )
      {
        $args = "GET W3SVC/1/$root/$property";
      }
    my $cmd = "$adsutil $args";
    print "adsutil $args\n";

    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /ErrNumber: (.*) \((.*)\)/ )
              {
                print;
              }
            #elsif ( /Error creating the object: W3SVC\/1\/$root\/$tcdir/ )
            #  {
            #  }
            elsif ( /([^ ]+) +: \((.*)\) "(.*)"/ )
              {
                if ( $1 eq $property and $3 ne $value and ($property =~ /Password/i) )
                  {
                  }
                elsif ( $1 ne $property or $3 ne $value )
                  {
                    #print "$1 ne $property or $3 ne $value\n";
                    #print;
                  }
                $value = $3;
              }
            elsif ( /([^ ]+) +: \((.*)\) (.*)/ )
              {
                if ( $1 eq $property and $3 ne $value and ($property =~ /Password/i) )
                  {
                  }
                elsif ( $1 ne $property or $3 ne $value )
                  {
                    #print "$1 ne $property or $3 ne $value\n";
                    #print;
                  }
                $value = $3;
              }
            else
              {
                #print "else\n";
                #print;
              }
          }
      }
    return $value;
  }

sub setProperty( $$$ )
  {
    my ($dir, $property, $value) = @_;
    setIIsProperty( "Root", $dir, $property, $value );
  }

sub setFilterProperty( $$$ )
  {
    my ($dir, $property, $value) = @_;
    setIIsProperty( "Filters", $dir, $property, $value );
  }

sub setIIsProperty( $$$$ )
  {
    my ($root, $dir, $property, $value) = @_;

    my $args = "SET W3SVC/1/$root/$dir/$property $value";
    if ( $dir eq "" )
      {
        $args = "SET W3SVC/1/$root/$property $value";
      }
    my $cmd = "$adsutil $args";
    print "adsutil $args\n";

    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /ErrNumber: (.*) \((.*)\)/ )
              {
                print;
              }
            #elsif ( /Error creating the object: W3SVC\/1\/$root\/$tcdir/ )
            #  {
            #  }
            elsif ( /([^ ]+) +: \((.*)\) "(.*)"/ )
              {
                if ( $1 eq $property and $3 ne $value and ($property =~ /Password/i) )
                  {
                  }
                elsif ( $1 ne $property or $3 ne $value )
                  {
                    #print "$1 ne $property or $3 ne $value\n";
                    print;
                  }
              }
            elsif ( /([^ ]+) +: \((.*)\) (.*)/ )
              {
                if ( $1 eq $property and $3 ne $value and ($property =~ /Password/i) )
                  {
                  }
                elsif ( $1 ne $property or $3 ne $value )
                  {
                    #print "$1 ne $property or $3 ne $value\n";
                    print;
                  }
              }
            else
              {
                #print "else\n";
                print;
              }
          }
      }
  }

sub runCmd( $% )
  {
    my ( $cmd, @filters ) = @_;

    print "$cmd\n";
    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            my $line = $_;
            if ( $line =~ /^$/ )
              {
              }
            else
              {
                my $matched = 0;
                foreach my $filter ( @filters )
                  {
                    if ( $line =~ /$filter/ )
                      {
                        $matched = 1;
                        last;
                      }
                  }
                if ( $matched eq 0 )
                  {
                    print "$_";
                  }
              }
          }
      }
  }

sub CopyFiles9()
  {
    my $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${Build}${CustomBuild}";
    print "Distrib: $Builds\n";
    if ( $CopyFromBuilds eq "Y" )
      {
        my $xcopy = "xcopy /s /i /y /c";
        if ( $copyNewer eq "Y" )
          {
            $xcopy = "$xcopy /d";
          }

        if ( $tcc ne "" and $tcc ne "-" )
          {
            # only need to copy tcc the first time...
            # lets copy newer each time...
            $xcopy = "xcopy /s /i /y /c /d";

            my $tccdist = "$distrib\\tcc";

            my $cmd = "$xcopy $tccdist \"$tcc\"";
            runCmd( $cmd, quotemeta($distrib) );

            my $pathToWar = "$distrib\\topclass.war";
            if ( -e $pathToWar )
              {
                # remove existing directory so that it will be expanded...
                if ( -d "$tcc\\tomcat\\webapps\\tc$suffix" )
                  {
                    RmDir( "$tcc\\tomcat\\webapps\\tc$suffix" );
                  }
                # and the cache dir
                if ( -d "$tcc\\tomcat\\work\\Catalina\\localhost\\tc$suffix" )
                  {
                    RmDir( "$tcc\\tomcat\\work\\Catalina\\localhost\\tc$suffix" );
                  }

                $cmd = "copy \"$pathToWar\" \"$tcc\\tomcat\\webapps\\tc$suffix.war\"";
                runCmd( $cmd );
              }
          }
      }
  }

sub CopyFiles()
  {
    if ( $MNP ge "9.0.0" )
      {
        CopyFiles9();
        return;
      }
    # want an installation, copy files from radon\builds...
    # for use by esd.
    my $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${Build}${CustomBuild}";
    print "Distrib: $Builds\n";

    my $cmd;
    if ( $CopyFromBuilds eq "Y" )
      {
        if ( open( EXCLUDES, ">$tempDir\\exclude.list" ) )
          {
            # quicker without them
            print EXCLUDES "windows\\webable\\help\n";
            print EXCLUDES "windows\\webable\\chelp\n";
            if ( $tcc_under_nonwebable )
              {
                print EXCLUDES "windows\\nonwebable\\tcc\n";
              }
            print EXCLUDES "icons\\french\n" unless ( $languages =~ /french/ );
            print EXCLUDES "icons\\german\n" unless ( $languages =~ /german/ );
            print EXCLUDES "danish.lang\n" unless ( $languages =~ /danish/ );
            print EXCLUDES "french.lang\n" unless ( $languages =~ /french/ );
            print EXCLUDES "german.lang\n" unless ( $languages =~ /german/ );
            print EXCLUDES "italian.lang\n" unless ( $languages =~ /italian/ );
            print EXCLUDES "japanese.lang\n" unless ( $languages =~ /japanese/ );
            close( EXCLUDES );
          }

        if ( $cleanFirst eq "Y" )
          {
            RmDir( $webpath );
            RmDir( $nonwebpath );
            RmDir( $oraclePath );
            RmDir( $mssqlPath );
          }

        my $xcopy = "xcopy /s /i /y /c";
        if ( $copyNewer eq "Y" )
          {
            $xcopy = "$xcopy /d";
          }

        $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\windows\\webable \"$webpath\"";
        runCmd( $cmd, quotemeta($distrib) );

        $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\windows\\nonwebable \"$nonwebpath\"";
        runCmd( $cmd, quotemeta($distrib) );

        if ( $UseTopClassExe eq "Y" )
          {
            my $dbg;
            if ( uc $debugBuild eq "Y" )
              {
                $dbg = "_dbg";
              }

            my $exe = "tce${mnp}ud$dbg.exe";
            $cmd = "$xcopy $distrib\\Executables\\www\\$exe \"$nonwebpath\"";
            runCmd( $cmd, quotemeta($distrib) );

            $cmd = "move \"$webpath\\topclass.dll\" \"$webpath\\topclass.lld\"";
            runCmd( $cmd, quotemeta($distrib) );

            my $bits;
            if ( $bit64 )
              {
                $bits = "64";
              }
            my $dll = "tce${mnp}iis$bits.dll";
            $cmd = "$xcopy $distrib\\Executables\\www\\$dll \"$webpath\"";
            runCmd( $cmd, quotemeta($distrib) );

            $cmd = "move \"$webpath\\$dll\" \"$webpath\\topclass.dll\"";
            runCmd( $cmd, quotemeta($distrib) );
          }

        if ( -d "$distrib\\scripts" )
          {
            $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\scripts \"$oraclePath\"";
            runCmd( $cmd, quotemeta($distrib) );
          }
        # in 8.0.0 we write the oracle scripts to the oracle directory, the script directory is no longer there.
        elsif ( -d "$distrib\\oracle" )
          {
            $oraclePath = "$nonwebpath\\oracle";
            $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\oracle \"$oraclePath\"";
            runCmd( $cmd, quotemeta($distrib) );
          }

        $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\mssql \"$mssqlPath\"";
        runCmd( $cmd, quotemeta($distrib) );

        $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\mssql\\dll\\wbt*.dll \"$mssqlHome\\Binn\"";
        runCmd( $cmd, quotemeta($distrib) );

        $cmd = "$xcopy /exclude:$tempDir\\exclude.list $distrib\\CrystalReports \"$webpath\\reports\"";
        runCmd( $cmd, quotemeta($distrib) );

        $cmd = "move $webpath\\reports\\cr_report.exe \"$nonwebpath\\cpi\\cr_report.exe\"";
        runCmd( $cmd, quotemeta($distrib) );

        MkDir( "$nonwebpath\\reports" );

        $cmd = "move $webpath\\reports\\cruflwbt.dll \"$nonwebpath\\reports\\cruflwbt.dll\"";
        runCmd( $cmd, quotemeta($distrib) );

        my $regsvr;
        if ( $Assemblies )
          {
            $regsvr = "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727\\regasm";
          }
        else
          {
            $regsvr = "regsvr32 /s";
          }

        $cmd = "$regsvr \"$nonwebpath\\TopClassDB.dll\"";
        runCmd( $cmd, "" );

        $cmd = "$regsvr \"$nonwebpath\\reports\\cruflwbt.dll\"";
        runCmd( $cmd, "" );

        $cmd = "move \"$nonwebpath\\cpi\\xmlstuff\\*.dll\" \"$nonwebpath\\cpi\"";
        runCmd( $cmd, quotemeta($distrib) );

        $cmd = "move \"$nonwebpath\\cpi\\xmlstuff\\nonreg\\*.dll\" \"$nonwebpath\\cpi\"";
        runCmd( $cmd, quotemeta($distrib) );

        $cmd = "regsvr32 /s \"$nonwebpath\\cpi\\msxml4.dll\"";
        runCmd( $cmd, "" );

        if ( $tcc ne "" and $tcc ne "-" )
          {
            # only need to copy tcc the first time...
            # lets copy newer each time...
            $xcopy = "xcopy /s /i /y /c /d";

            my $tccdist;
            if ( $tcc_under_nonwebable )
              {
                $tccdist = "$distrib\\windows\\nonwebable\\tcc";
              }
            else
              {
                $tccdist = "$distrib\\windows\\tcc";
              }
            $cmd = "$xcopy $tccdist \"$tcc\"";
            runCmd( $cmd, quotemeta($distrib) );

            # always copy the war file, but it needs a unique name...
            # TODO copy tcc.war if it exists...
            # cat&regwar

            my $pathToWar = "$tccdist\\catandregwar\\cnr.war";
            if ( ! -e $pathToWar )
              {
                $pathToWar = "$tccdist\\cat&regwar\\cnr.war";
              }
            if ( -e $pathToWar )
              {
                # remove existing directory so that it will be expanded...
                if ( -d "$tcc\\tomcat\\webapps\\cnr$suffix" )
                  {
                    RmDir( "$tcc\\tomcat\\webapps\\cnr$suffix" );
                  }
                # and the cache dir
                if ( -d "$tcc\\tomcat\\work\\Catalina\\localhost\\cnr$suffix" )
                  {
                    RmDir( "$tcc\\tomcat\\work\\Catalina\\localhost\\cnr$suffix" );
                  }

                $cmd = "copy \"$pathToWar\" \"$tcc\\tomcat\\webapps\\cnr$suffix.war\"";
                runCmd( $cmd );
              }

            if ( $setupJasper eq "Y" )
              {
                $pathToWar = "$tccdist\\catandregwar\\jasperserver-pro.war";
                if ( -e $pathToWar )
                  {
                    # remove existing directory so that it will be expanded...
                    if ( -d "$tcc\\tomcat\\webapps\\adhoc$suffix" )
                      {
                        RmDir( "$tcc\\tomcat\\webapps\\adhoc$suffix" );
                      }
                    # and the cache dir
                    if ( -d "$tcc\\tomcat\\work\\Catalina\\localhost\\adhoc " )
                      {
                        RmDir( "$tcc\\tomcat\\work\\Catalina\\localhost\\adhoc$suffix" );
                      }

                    $cmd = "copy \"$pathToWar\" \"$tcc\\tomcat\\webapps\\adhoc$suffix.war\"";
                    runCmd( $cmd );

                    runCmd( "unzip -u -o $tcc\\tomcat\\webapps\\adhoc$suffix.war -d $tcc\\tomcat\\webapps\\adhoc$suffix", "inflating:", "creating:" );

                    SetupRepository();
                  }
              }
          }
      }

    MkDir( "$nonwebpath\\attach" );

    # copy the license.

    my ($Sec, $Min, $Hour, $Day, $Mon, $Year ) = localtime(time);

    $Year  = $Year + 1900;
    my $file1;
    my $file2;
    if ( $Mon <= 6 )
      {
        $file1 = "nt30Jun$Year.txt";
        $file2 = "nt31Dec$Year.txt";
      }
    else
      {
        $file1 = "nt31Dec$Year.txt";
        $file2 = "nt30Jun".($Year+1).".txt";
      }

    if ( -e "$LicenseDir\\$file2" )
      {
        $cmd = "copy \"$LicenseDir\\$file2\" \"$nonwebpath\\topclass.lic\"";
        runCmd( $cmd );
      }
    elsif ( -e "$LicenseDir\\$file1" )
      {
        $cmd = "copy \"$LicenseDir\\$file1\" \"$nonwebpath\\topclass.lic\"";
        runCmd( $cmd );
      }
    else
      {
        print "ERROR no license file found\n";
      }
  }

sub SetupRepository()
  {

    my $cmd = "";

    $jsOrganizationId = $suffix;
    $jsOrganizationName = "TopClass LCMS v $Major.$Minor.$Point build $Build\n";
    $jsWebAppName = "adhoc$suffix";
    $jsRDBMSUser = "adhoc$suffix";
    $jsRDBMSPassword = "adhoc$suffix";
    $tcRDBMSUser = $suffix;
    $tcRDBMSPassword = $suffix;
    $rptsRDBMSUser = "$suffix$rpts";
    $rptsRDBMSPassword = "$suffix$rpts";
    $rptsRDBMSSchema = "$suffix$rpts";

    #TODO #00008 Modify JS repository values below so that they are assigned dynamically to be either Oracle or MSSQL

    if ( open( buildProperties, ">$tcc\\tomcat\\webapps\\adhoc$suffix\\repository\\build.properties" ) )
      {
        print buildProperties "js.organization.id=$jsOrganizationId\n";
        print buildProperties "js.organization.name=$jsOrganizationName\n";
        print buildProperties "js.RDBMS.name=mssql\n";
        print buildProperties "js.webapp.name=$jsWebAppName\n";
        print buildProperties "js.RDBMS.host=bert.wbt.wbtsystems.com\n";
        print buildProperties "js.RDBMS.user=jasper_user\n";
        print buildProperties "js.RDBMS.password=jasper_password\n";
        print buildProperties "tc.RDBMS.user=$tcRDBMSUser\n";
        print buildProperties "tc.RDBMS.password=$tcRDBMSPassword\n";
        print buildProperties "rpts.RDBMS.user=$rptsRDBMSUser\n";
        print buildProperties "rpts.RDBMS.password=$rptsRDBMSPassword\n";
        print buildProperties "rpts.RDBMS.schema=$rptsRDBMSSchema\n";

        close (buildProperties);
      }

    $cmd = "$tcc\\ant\\bin\\ant -f $tcc\\tomcat\\webapps\\adhoc$suffix\\repository\\build.xml js.config.webapp";
    runCmd( $cmd );
    $cmd = "$tcc\\ant\\bin\\ant -f $tcc\\tomcat\\webapps\\adhoc$suffix\\repository\\build.xml repository.transform";
    runCmd( $cmd );
    $cmd = "$tcc\\ant\\bin\\ant -f $tcc\\tomcat\\webapps\\adhoc$suffix\\repository\\build.xml repository.deploy";
    runCmd( $cmd );


    #print buildProperties "js.webapp.name=$jsWebAppName\n";
    #print buildProperties "js.RDBMS.user=$jsRDBMSUser\n";
    #print buildProperties "js.RDBMS.password=$jsRDBMSPassword\n";
  }

sub SetupRedirector()
  {
    # install isapi filter
    my $regKey = "$isapiRedirectoRegRoot\\$isapiRedirectoRegKey";

    if ( $installRedirector eq "Y" )
      {
        # setting up the redirector...
        # but have we copied the files?
        #if ( $copyExes eq "Y" )
          {
            my $dll = "$tcc\\iis\\dll\\isapi_redirect.dll";
            $dll = "$tcc\\iis\\dll\\isapi_redirector2.dll" if ( $redirVer eq "2" );
            if ( not -e $dll )
              {
                my $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${Build}${CustomBuild}";
                $distrib .= "\\windows";
                if ( $tcc_under_nonwebable )
                  {
                    $distrib .= "\\nonwebable";
                  }
                $distrib .= "\\tcc\\iis";
                runCmd( "xcopy /y /i /s /d $distrib\\*.* $tcc\\iis\\" );
              }
          }

        # create jakarta virtual folder
        CreateIIsDir( "jakarta", "$tcc\\iis\\dll" );

        if ( $redirVer eq "0" )
          {
          }
        elsif ( $redirVer eq "2" )
          {
            my $dll = "$tcc\\iis\\dll\\isapi_redirector2.dll";
            $workersFile = "$tcc\\iis\\conf\\workers2.properties";
            if ( -e $dll )
              {
                CreateFilter( "jakarta", $dll, "Jakarta/ISAPI/2.0" );

                # registry settings
                RegAdd( $regKey, "serverRoot", $tomcat_home );
                RegAdd( $regKey, "extensionUri", "/jakarta/isapi_redirector2.dll" );
                RegAdd( $regKey, "workersFile", $workersFile );
                RegAdd( $regKey, "authComplete", "0" );
                RegAdd( $regKey, "threadPool", "5" );
              }
            else
              {
                print "Error: filter $dll not found\n";
              }
          }
        else # if 1.2..
          {
            my $dll = "$tcc\\iis\\dll\\isapi_redirect.dll";

            $workersFile     = "$tcc\\iis\\conf\\workers.properties";
            $workerMountFile = "$tcc\\iis\\conf\\uriworkermap.properties";
            if ( -e $dll )
              {
                CreateFilter( "jakarta", $dll, "Jakarta/ISAPI/1.0" );

                # registry settings
                RegAdd( $regKey, "extension_uri", "/jakarta/isapi_redirect.dll" );
                RegAdd( $regKey, "$workersFileRegValue",     $workersFile );
                RegAdd( $regKey, "$workerMountFileRegValue", $workerMountFile );
                RegAdd( $regKey, "log_file", "$tomcat_home\\logs\\isapi_redirect.log" );
                RegAdd( $regKey, "log_level", "info" );
              }
            else
              {
                print "Error: filter $dll not found\n";
              }
          }
      }

    if ( $redirVer eq "2" )
      {
        # add mapping for webapp
        my $info = "TopClass LMS $Major.$Minor.$Point";
        if ( $MultipleBuilds eq "Y" )
          {
            $info = "${info} build $Build";
          }

        insertIntoFile( $workersFile,
                        "[uri:/cnr$suffix/*]\n" .
                        "info=$info\n" .
                        "debug=0\n",
                        "<EOF>" );
      }
    elsif ( $redirVer eq "1" )
      {
        $workersFile     = "$tcc\\iis\\conf\\workers.properties";
        $workerMountFile = "$tcc\\iis\\conf\\uriworkermap.properties";

        insertIntoFile( $workerMountFile,
                        "/cnr$suffix/*=wlb\n",
                        "<EOF>" );

        if ( $MNPB ge "8.0.0.120" )
          {
            insertIntoFile( $workerMountFile,
                            "/jasperserver-pro/*=wlb\n",
                            "<EOF>" );
          }
      }
  }

sub SetupTomcat()
  {
    if ( $tcc eq "" or $tcc eq "-" )
      {
        return;
      }

    SetupRedirector();

    my $dbhost; #= lc $ENV{COMPUTERNAME};
    my $dbtype; #= 1;
    my $schemaName;
    my $schemaPass;
    my $sqlserver;
    my $sqlinstance;

    if ( !doOracle() )
      {
        $dbhost = $sqldb;
        $dbtype = 2;
        $schemaName = $sqlSchemaName;
        $schemaPass = $sqlSchemaPass;
        ($sqlserver, $sqlinstance) = split( /\\/, $sqldb );
        $dbhost = $sqlserver;
      }
    else
      {
        $dbhost = $oradb;
        $dbtype = 1;
        $schemaName = $oraSchemaName;
        $schemaPass = $oraSchemaPass;
      }
    my $tcbin = "topclass.dll";
    if ( $CopyFromBuilds eq "N" )
      {
        $tcbin = "tce${mnp}iis.dll";
      }

    if ( $MNP ge "9.0.0" )
      {
      }
    elsif ( $MNP lt "9.0.0" )
      {
        # now sort out cnr.
        my $props = "$tomcat_home\\conf\\cnr${suffix}_persist.properties";
        print "Checking for Properties file $props\n";
        my $createProps = 1;
        if ( -e $props )
          {
            $createProps = 0;
            print "Properties file exists $props\n";
            if ( open( PROPS, "$props" ) )
              {
                while ( <PROPS> )
                  {
                    chomp;
                    if ( /RDBMS=(.+)$/ )
                      {
                        if ( $1 ne $dbtype )
                          {
                            print "RDBMS is $1 not $dbtype\n";
                          }
                      }
                    elsif ( /url-oci8-host=(.+)$/ )
                      {
                        if ( $1 ne $dbhost )
                          {
                            print "url-oci8-host is $1 not $dbhost\n";
                            $createProps = 1;
                          }
                      }
                    elsif ( /userid=(.+)$/ )
                      {
                        if ( $1 ne $schemaName )
                          {
                            print "userid is $1 not $schemaName\n";
                            $createProps = 1;
                          }
                      }
                    elsif ( /password=(.+)$/ )
                      {
                        if ( $1 ne $schemaPass )
                          {
                            print "password is $1 not $schemaPass\n";
                            $createProps = 1;
                          }
                      }
                    elsif ( /tc-install-path=http\\:\/\/([^\/]+)\/(.+)$/ )
                      {
                        if ( $1 ne $host )
                          {
                            print "tc-install-path host is $1 not $host\n";
                            $createProps = 1;
                          }
                        if ( $2 ne $tcdir )
                          {
                            print "tc-install-path tcdir is $2 not $tcdir\n";
                            $createProps = 1;
                          }
                      }
                    elsif ( /tc-executable-path=http\\:\/\/([^\/]+)\/(.+)\/([^\/]+)$/ )
                      {
                        if ( $1 ne $host )
                          {
                            print "tc-executable-path host is $1 not $host\n";
                            $createProps = 1;
                          }
                        if ( $2 ne $tcdir )
                          {
                            print "tc-executable-path tcdir is $2 not $tcdir\n";
                            $createProps = 1;
                          }
                        if ( $3 ne $tcbin )
                          {
                            print "tc-executable-path tcbin is $3 not $tcbin\n";
                            $createProps = 1;
                          }
                      }
                  }
                close( PROPS );
              }
            if ( $createProps eq 1 )
              {
                runCmd( "copy /y $props props.bak" );
              }
          }
        else
          {
            print "Properties file does not exist $props\n";
          }
        if ( $createProps eq 1 )
          {
            print "Creating Properties file $props\n";
            if ( open( PROPS, ">$props" ) )
              {
                print "Have opened Properties file $props\n";
                print PROPS "#Persisted database init propertes\n";
                print PROPS "#Written by tcsetup.pl\n";
                print PROPS "synch-sessions=false\n";
                print PROPS "max-connection-checkout=1000\n";
                print PROPS "max-inactive-interval-mins=720\n";
                print PROPS "template-cache-timout-mins=5\n";
                print PROPS "synch-interval-mins=20\n";
                print PROPS "tc-install-path=http\\://$host/$tcdir\n";
                print PROPS "max-connection-count=50\n";
                print PROPS "idle-connection-timeout-seconds=900\n";
                print PROPS "connection-checkout-timeout-seconds=3600\n";
                print PROPS "tc-executable-path=http\\://$host/$tcdir/$tcbin\n";
                print PROPS "RDBMS=$dbtype\n";
                print PROPS "url-oci8-host=$dbhost\n";
                print PROPS "userid=$schemaName\n";
                print PROPS "password=$schemaPass\n";
                if ( $useMicrosoftDriver )
                  {
                    print PROPS "use-microsoft-jdbc=true\n";
                    if ( $sqlinstance ne "" )
                      {
                        print PROPS "com.microsoft.sqlserver.jdbc.SQLServerDriver.serverName=$sqlserver\n";
                        print PROPS "com.microsoft.sqlserver.jdbc.SQLServerDriver.instancename=$sqlinstance\n";
                        print PROPS "com.microsoft.sqlserver.jdbc.SQLServerDriver.database=$schemaName\n";
                      }
                  }
                else
                  {
                    print PROPS "use-microsoft-jdbc=false\n";
                    if ( $sqlinstance ne "" )
                      {
                        print PROPS "com.inet.tds.TdsDriver.instancename=$sqlinstance\n";
                        print PROPS "com.inet.tds.TdsDriver.database=$schemaName\n";
                        print PROPS "com.inet.tds.TdsDriver.host=$sqlserver\n";
                        if ( lc $sqlinstance eq lc "bert_2005" or lc $sqlinstance eq lc "ernie_2005" )
                          {
                            print PROPS "com.inet.tds.TdsDriver.port=1529\n";
                          }
                      }
                  }
                close( PROPS );
              }
            else
              {
                print "Failed to open Properties file $props $!\n";
              }
          }

        #runCmd( "net stop tomcat-tcc" );
        if ( -e "$tomcat_home\\webapps\\cnr$suffix.war" )
          {
            runCmd( "unzip -u -o $tomcat_home\\webapps\\cnr$suffix.war -d $tcc\\tomcat\\webapps\\cnr$suffix", "inflating:", "creating:" );
            if ( $suffix ne "" )
              {
                replaceInFile( "$tomcat_home\\webapps\\cnr$suffix\\WEB-INF\\web.xml", "<param-value>cnr</param-value>", "<param-value>cnr$suffix</param-value>" );
                replaceInFile( "$tomcat_home\\webapps\\cnr$suffix\\WEB-INF\\log.properties", "cnrapp.log", "cnr${suffix}app.log" );
              }
          }
        else
          {
            print "No war to deploy \"$tomcat_home\\webapps\\cnr$suffix.war\"\n";
          }
        #runCmd( "net start tomcat-tcc" );
      }

    if ( doOracle() )
      {
        # version 5
        my $tomcatlib = "$tomcat_home\\shared\\lib";
        if ( !-d $tomcatlib )
          {
            # version 6
            $tomcatlib = "$tomcat_home\\lib";
          }

        MkDir( $tomcatlib );

        if ( $oracleHome eq "" )
          {
            print "ERROR Oracle Home not specified, use -A or set ORACLE_HOME\n";
          }
        elsif ( !-d $oracleHome )
          {
            print "ERROR oracleHome \"$oracleHome\" doesn't exist\n";
          }
        else #if ( $oracleHome ne "" and -d $oracleHome )
          {
            my $driver6 = "$oracleHome\\jdbc\\lib\\ojdbc6.jar";
            my $driver14 = "$oracleHome\\jdbc\\lib\\ojdbc14.jar";
            if ( -e $driver6 )
              {
                runCmd( "xcopy /y /i \"$driver6\" \"$tomcatlib\"" );
              }
            elsif ( -e $driver14 )
              {
                runCmd( "xcopy /y /i \"$driver14\" \"$tomcatlib\"" );
              }
            else
              {
                print "ERROR: no jdbc driver.\n";
              }
          }
      }

    if ( $installTomcat eq "Y" )
      {
        # setting up tomcat to run as a service...
        if ( "c:\\tcc" ne $tcc )
          {
            # wrapper.properties was used by tomcat 5
            if ( -e "$tomcat_home/conf/wrapper.properties" )
              {
                replaceInFile( "$tomcat_home/conf/wrapper.properties", "c:\\tcc", $tcc );
              }
          }
        MkDir( "$tomcat_home\\logs" );

        # add the manager role to the tomcat user?
        replaceInFile( "$tomcat_home/conf/tomcat-users.xml", "role1", "manager" );

        if ( -e "$tcc/tomcatutilities/jktcc.bat" )
          {
            replaceInFile( "$tcc/tomcatutilities/jktcc.bat", "<tccdir>", $tcc );
            if ( -e "$tcc/tomcat/bin/jk_nt_service.exe" )
              {
                runCmd( "$tcc\\tomcatutilities\\jktcc.bat" );
              }
          }
        elsif ( -e "$tomcat_home/bin/service.bat" )
          {

if ( 0 )
  {
    insertIntoFile( "$tomcat_home\\bin\\setclasspath.bat", "set JAVA_OPTS=%JAVA_OPTS% -Djs.license.directory=\"D:\PROGRA~1\JASPER~1.7\"\n", "???" );
    insertIntoFile( "$tomcat_home\\bin\\setclasspath.bat", "set JAVA_OPTS=%JAVA_OPTS% -Xms128m -Xmx512m -XX:PermSize=32m -XX:MaxPermSize=128m -Xss2m\n", "???" );
    insertIntoFile( "$tomcat_home\\bin\\setclasspath.bat", "set JAVA_OPTS=%JAVA_OPTS% -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled\n", "???" );

    insertIntoFile( "$tomcat_home\\bin\\service.bat", "\"%EXECUTABLE%\" //US//%SERVICE_NAME% ++JvmOptions \"-XX:PermSize=32m;-XX:MaxPermSize=128m\" --JvmMs 128 --JvmMx 1536\n", "echo The service '%SERVICE_NAME%' has been installed." );
    insertIntoFile( "$tomcat_home\\bin\\service.bat", "\"%EXECUTABLE%\" //US//%SERVICE_NAME% ++JvmOptions \"-Dcom.sun.management.jmxremote;-Dcom.sun.management.jmxremote.port=8086;-Dcom.sun.management.jmxremote.ssl=false;-Dcom.sun.management.jmxremote.authenticate=false\"\n", "echo The service '%SERVICE_NAME%' has been installed." );
    insertIntoFile( "$tomcat_home\\bin\\service.bat", "\"%EXECUTABLE%\" //US//%SERVICE_NAME% ++JvmOptions \"-Djs.license.directory=D:\PROGRA~1\JASPER~1.7\"\n", "echo The service '%SERVICE_NAME%' has been installed." );
  }
            my $saveDir =  cwd;
            $ENV{JAVA_HOME} = "$tcc\\jdk";
            chdir( "$tomcat_home\\bin" );
            runCmd( "service.bat install tomcat6" );
            chdir( $saveDir );
          }
        else
          {
            print "ERROR: no script to set up service\n";
          }
      }
  }

sub SetEnvVar( $$ )
  {
    my ($name, $value) = @_;
    $ENV{$name} = $value;
    #print $BuildLog "SET $name=$value<br/>\n";
    print "SET $name=$value\n";
  }

sub CreateDatabaseSchemas()
  {
    # Create the database
    if ( doOracle() )
      {
        my $runora = "\\utils\\AutoDevBuild\\runora.pl";
        if ( !-e $runora and -e "$myDir\\runora.pl" )
          {
            $runora = "$myDir\\runora.pl";
          }
        if ( !-e $runora and -e "$upDir\\runora.pl" )
          {
            $runora = "$upDir\\runora.pl";
          }
        if ( !-e $runora and -e "z:$runora" )
          {
            $runora = "z:$runora";
          }
        if ( !-d "$tempDir\\$oraSchemaName" )
          {
            mkdir "$tempDir\\$oraSchemaName";
          }
       #my $cmd = "perl $runora -U $schemaName -P $schemaPass -H host -d \"\" -s stem -x syspass -y systempass -r rootdir -D oradata -k keep -c copy

        my $args = "-U $oraSchemaName -P $oraSchemaPass -H $oradb -r $tempDir\\$oraSchemaName";
        if ( $syspass ne "" )
          {
            $args = "$args -x $syspass -y $systempass";
          }

        if ( $oraclePath ne "" )
          {
            $args = "$args -S \"$oraclePath\"";
          }
        else
          {
            $args = "$args -d \"$scriptsRoot\"";
          }

        my $cmd = "perl $runora $args";

        runCmd( $cmd );
      }
    if ( doSqlServer() )
      {
        # set up the DSN

        my $SysRoot = RegGet( "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "SystemRoot" );

        my $ODBCDriver = "$SysRoot\\System32\\SQLSRV32.dll";

        my $dsn = $sqldb;
        $dsn =~ s!\\!_!; # strip off named instance.

        my $existingServer = RegGet( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Server" );
        if ( $existingServer eq "" )
          {
            RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Description", "DSN for accessing topclass $sqldb"  );
            RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Driver", $ODBCDriver );
            RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "LastUser", $sqlSchemaName );
            RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Server", $sqldb );
            RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\ODBC Data Sources", $dsn, "SQL Server" );
            RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbcinst.ini\\SQL Server", "CPTimeout", "<not pooled>" );
          }
        elsif ( $existingServer ne $sqldb )
          {
            print "Error dsn exists but refers to a different server\n";
          }

        if ( $bit64 )
          {
            my $dsn32 = "${dsn}_32";
            my $existingServer = RegGet( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbc.ini\\$dsn32", "Server" );
            if ( $existingServer eq "" )
              {
                RegAdd( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbc.ini\\$dsn32", "Description", "DSN for accessing topclass $sqldb (32 bit)"  );
                RegAdd( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbc.ini\\$dsn32", "Driver", $ODBCDriver );
                RegAdd( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbc.ini\\$dsn32", "LastUser", $sqlSchemaName );
                RegAdd( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbc.ini\\$dsn32", "Server", $sqldb );
                RegAdd( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbc.ini\\ODBC Data Sources", $dsn32, "SQL Server" );
                RegAdd( "HKLM\\SOFTWARE\\Wow6432Node\\ODBC\\odbcinst.ini\\SQL Server", "CPTimeout", "<not pooled>" );
              }
            elsif ( $existingServer ne $sqldb )
              {
                print "Error dsn exists but refers to a different server\n";
              }
          }
        # install the schema...

        if ( $mssqlPath eq "" )
          {
            $mssqlPath = "$ccDrive\\topclass\\oracle\\topclass\\Scripts\\MSSQL";
          }

        # handle old tc_setenv.cmd
        if ( open( CMD, "$mssqlPath\\tc_setenv.cmd" ) )
          {
            my $changed = 0;
            my @lines;
            while ( <CMD> )
              {
                if ( /^SET TC_VERSION=/i )
                  {
                    $changed = 1;
                    @lines = ( @lines, "if \"\%TC_VERSION\%\"==\"\" " . $_ );
                  }
                elsif ( /^SET BUILD_NO=/i )
                  {
                    $changed = 1;
                    @lines = ( @lines, "if \"\%BUILD_NO\%\"==\"\" " . $_ );
                  }
                elsif ( /^SET MS_SRV_NAME=/i )
                  {
                    $changed = 1;
                    @lines = ( @lines, "if \"\%MS_SRV_NAME\%\"==\"\" " . $_ );
                  }
                elsif ( /^SET TC_DATA=/i )
                  {
                    $changed = 1;
                    @lines = ( @lines, "if \"\%TC_DATA\%\"==\"\" " . $_ );
                  }
                elsif ( /^SET DB_NAME=/i )
                  {
                    $changed = 1;
                    @lines = ( @lines, "if \"\%DB_NAME\%\"==\"\" " . $_ );
                  }
                elsif ( /^SET TC_USER=/i )
                  {
                    $changed = 1;
                    @lines = ( @lines, "if \"\%TC_USER\%\"==\"\" " . $_ );
                  }
                else
                  {
                    @lines = ( @lines, $_ );
                  }
              }
            close( CMD );
            if ( $changed eq 1 )
              {
                rename( "$mssqlPath\\tc_setenv.cmd", "$mssqlPath\\tc_setenv.cmd.bak" );
                if ( open( CMD, ">$mssqlPath\\tc_setenv.cmd" ) )
                  {
                    foreach ( @lines )
                      {
                        print CMD;
                      }
                    close( CMD );
                  }
              }
          }

        if ( $MNPB le "8.0.0.030" )
          {
            my $cmd = "$tempDir\\mssql.bat";
            if ( open( CMD, ">$cmd" ) )
              {
                #print CMD "osql -U sa -P $saPass -Q \"drop database $sqlSchemaName\"";
                print CMD "setlocal\n";
                print CMD "set tc_user=$sqlSchemaName\n";
                print CMD "set db_name=$sqlSchemaName\n";
                print CMD "set MS_SRV_NAME=$sqldb\n";
                print CMD "set SILENT=true\n";
                print CMD "set TC_DATA=$mssqlHome\\data\n";

                print CMD "chdir /d \"$mssqlPath\"\n";
                print CMD "start \"Account\" /wait \"$mssqlPath\\tc_db_account.cmd\" $sqlSchemaPass $saPass\n";
                print CMD "start \"Schema\" \"$mssqlPath\\tc_db_schema.cmd\" $sqlSchemaPass install\n";

                close( CMD );

                runCmd( $cmd );
              }
          }
        else
          {
            my $drop = "sqlcmd -w 255 -b -S $sqldb -U sa -P $saPass -Q \"DROP DATABASE $sqlSchemaName\"";
            runCmd( $drop );

            # TODO option to specify local & remote path for clr.
            #runCmd( "copy /y \"$mssqlPath\\Internal\\ServerProcs\\wbt_clr_procs.dll\" \"$ENV{TEMP}\"" );
            my $local_clr;
            my $remote_clr;
            my $remote = $sqldb;
            $remote =~ s!\\.+!!; # strip off named instance.

            if ( lc $remote eq lc $ENV{COMPUTERNAME} )
              {
                $local_clr = $ENV{TEMP};
                runCmd( "copy /y \"$mssqlPath\\Internal\\ServerProcs\\wbt_clr_procs.dll\" \"$local_clr\"" );
              }
            else
              {
                $remote_clr = "\\\\$remote\\shared";
                runCmd( "copy /y \"$mssqlPath\\Internal\\ServerProcs\\wbt_clr_procs.dll\" \"$remote_clr\"" );
                if ( -e "$remote_clr\\wbt_clr_procs.dll" )
                  {
                    $local_clr = "c:\\shared";
                  }
                else
                  {
                    $remote_clr = "\\\\$remote\\c\$\\temp";
                    runCmd( "copy /y \"$mssqlPath\\Internal\\ServerProcs\\wbt_clr_procs.dll\" \"$remote_clr\"" );
                    if ( -e "$remote_clr\\wbt_clr_procs.dll" )
                      {
                        $local_clr = "c:\\temp";
                      }
                  }
              }
            MkDir( "$logsdir\\mssql" );
            SetEnvVar( "TC_USER", $sqlSchemaName );
            if ( $MNPB le "8.1.0.046" )
              {
                SetEnvVar( "DB_NAME", $sqlSchemaName );
              }
            else
              {
                SetEnvVar( "TC_DB_NAME", $sqlSchemaName );
                SetEnvVar( "TC_SETUP", "$mssqlPath\\Internal\\Setup" );
              }
            SetEnvVar( "MS_SRV_NAME", $sqldb );
            SetEnvVar( "TC_DATA", "$mssqlHome\\data" );
            SetEnvVar( "TSQL_ROOT", "$mssqlPath\\" );
            SetEnvVar( "CLR_DIR", $local_clr );
            SetEnvVar( "SILENT", "true" );
            SetEnvVar( "LOGDIR", "$logsdir\\mssql" );
            SetEnvVar( "SINGLE_PROCESS", 1 );

            my $saveDir =  cwd;
            chdir( $mssqlPath );
            unlink( "$logsdir\\mssql\\db_account_success" );
            unlink( "$logsdir\\mssql\\db_account_failure" );
            unlink( "$logsdir\\mssql\\db_schema_success" );
            unlink( "$logsdir\\mssql\\db_schema_failure" );

            runCmd( "\"$mssqlPath\\tc_setup_db.cmd\" $sqlSchemaPass $saPass" );
            if ( -e "$logsdir\\mssql\\db_account_failure" )
              {
                print "tc_setup_db.cmd failed\n";
              }
            else #if ( -e "$logsdir\\mssql\\db_account_success" )
              {
                runCmd( "\"$mssqlPath\\tc_db_schema.cmd\" $sqlSchemaPass install" );
              }
            chdir( $saveDir );
          }
      }
  }

sub CopyExes()
  {
    if ( $copyExes eq "Y" )
      {
        if ( $Builds eq "" or $Build eq "" or $ccDrive eq "" )
          {
            print "Need Builds (-B $Builds), Build (-b $Build), and ccDrive (-c $ccDrive) to copy executables\n";
          }
        else
          {
            my $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${Build}${CustomBuild}";

            print "Will try $distrib\n" if ( $verbose );

            my $b = $Build;
            # Can't find distribution and build is odd (which it normally will be...) and
            if ( ! -d $distrib and ( $b % 2 ) eq 1 )
              {
                $b--;

                $b = sprintf( "%03d", $b );

                $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${b}${CustomBuild}";
                print "Will try $distrib\n" if ( $verbose );
              }
            if ( -d $distrib )
              {
                print "Copying exes from build directory: $distrib\n";

                runCmd( "xcopy /y /i $distrib\\windows\\webable\\*.dll $nonwebroot\\" );
                runCmd( "xcopy /y /i $distrib\\windows\\webable\\*.jar $nonwebroot\\" );

                if ( $mssqlPath eq "" )
                  {
                    $mssqlPath = "$ccDrive\\topclass\\oracle\\topclass\\Scripts\\MSSQL";
                  }

                runCmd( "xcopy /y /i $distrib\\MSSQL\\Internal\\ServerProcs\\wbt_clr_procs.dll $mssqlPath\\Internal\\ServerProcs\\" );

                runCmd( "xcopy /y /i $distrib\\Executables\\www\\tce*ud.exe $nonwebroot\\" );
                if ( $Win7 )
                  {
                    runCmd( "xcopy /y /i $distrib\\Executables\\www\\tce*ud.exe $localnonwebroot\\" );
                  }
                runCmd( "xcopy /y /i $distrib\\Executables\\www\\tce*iis.dll $nonwebroot\\" );
                runCmd( "xcopy /y /i $distrib\\windows\\nonwebable\\*.dll $nonwebroot\\" );
                runCmd( "xcopy /y /i $distrib\\windows\\nonwebable\\cpi\\*.dll $nonwebroot\\cpi\\" );
                runCmd( "xcopy /y /i $distrib\\windows\\nonwebable\\qpi\\*.dll $nonwebroot\\qpi\\" );
                runCmd( "xcopy /y /i $distrib\\windows\\nonwebable\\spi\\*.dll $nonwebroot\\spi\\" );
                runCmd( "xcopy /y /i $distrib\\CrystalReports\\cr_report.exe $nonwebroot\\cpi\\" );

                my @langs = split(/,/, $languages);
                foreach my $lang ( @langs )
                  {
                    runCmd( "xcopy /y /i $distrib\\windows\\nonwebable\\language\\*$lang.lang $nonwebroot\\language\\" );
                  }
                runCmd( "xcopy /y /i $distrib\\windows\\nonwebable\\language\\*.labels $nonwebroot\\language\\" );
              }
            else
              {
                print "Build directory not found $distrib\n";
              }
            my $langArgs;
            my @langs = split(/,/, $languages);
            foreach my $lang ( @langs )
              {
                my $code = $lang2code{$lang};
                if ( $code )
                  {
                    if ( $langArgs )
                      {
                        $langArgs = "$langArgs;$code";
                      }
                    else
                      {
                        $langArgs = "-L $code";
                      }
                  }
              }

            runCmd( "perl $ccDrive\\utils\\AutoDevbuild\\bin\\prepare.pl -v $ccDrive $langArgs" );
          }
      }
  }

sub getIusr()
  {
    if ( $Win7 )
      {
        return "IUSR";
      }
    my $cmd = "net user";
    my $fh;
    if ( open( $fh, "$cmd |") )
      {
        while ( <$fh> )
          {
            #print;
            if ( /User accounts for \\\\/ )
              {
              }
            elsif ( /^-+$/ )
              {
              }
            elsif ( /The command completed successfully/ )
              {
              }
            elsif ( /\W(IUSR_[A-Z0-9]+)\W/ )
              {
                print "IUSR: $1\n";
                return $1;
              }
          }
      }
    return "";
  }

sub SetPermissions()
  {
    my $user = getIusr();

    if ( $user )
      {
        SetPermissionsAux( $user );
      }
    else
      {
        $user = "IUSR_" . $ENV{COMPUTERNAME};
        SetPermissionsAux( $user );

        # and just in case...
        $user = "IUSR_LOCAL";
        SetPermissionsAux( $user );
      }
  }

sub SetPermissionsAux( $ )
  {
    my ( $user ) = @_;
    if ( $clearcasedrive ne "Y" )
      {
        if ( ! -d $webpath )
          {
            MkDir( $webpath );
          }
        if ( !find_prog( "setacl.exe" ) )
          {
            print "\n******************************\n";
            print "ERROR: setacl.exe not found\n";
            print "copy \\\\hogfather\\shared\\wbt-setup\\setacl.exe c:\\bin\n";
            print "******************************\n\n";
          }
        else
          {
            my $cmd = "setacl.exe -on \"$webpath\" -ot file -actn ace -ace \"n:$user;p:full;s:n;i:so,sc;m:grant;w:dacl\"";
            runCmd( $cmd, "SetACL finished successfully.", "Processing ACL of:" );

            if ( ! -d $nonwebpath )
              {
                MkDir( $nonwebpath );
              }
            $cmd = "setacl.exe -on \"$nonwebpath\" -ot file -actn ace -ace \"n:$user;p:full;s:n;i:so,sc;m:grant;w:dacl\"";
            runCmd( $cmd, "SetACL finished successfully.", "Processing ACL of:" );

            $cmd = "reg add \"$TopClassServerKey\" /f";
            runCmd( $cmd, "The operation completed successfully." );

            $cmd = "setacl.exe -on \"$TopClassServerKey\" -ot reg -actn ace -ace \"n:$user;p:full;s:n;i:so,sc;m:grant;w:dacl\"";
            runCmd( $cmd, "SetACL finished successfully.", "Processing ACL of:" );
          }
      }
  }

sub MkDir($)
  {
    my ($dir) = @_;
    if ( -d $dir )
      {
        #print COPYLOG "MkDir $dir exists\n";
      }
    else
      {
        my $sofar = "";
        foreach ( split( /\\/, $dir ) )
          {
            #print "[$_]\n";
            if ( $sofar eq "" )
              {
                if ( $_ ne "" and $dir =~ /^\\\\/ )
                  {
                    $sofar = "\\\\$_";
                  }
                else
                  {
                    $sofar = $_;
                  }
              }
            else
              {
                $sofar = "$sofar\\$_";
                if ( -d $sofar )
                  {
                    #print COPYLOG "MkDir $sofar exists\n";
                  }
                elsif ( mkdir( $sofar ) )
                  {
                    #print COPYLOG "MkDir $dir\n";
                  }
                else
                  {
                    #LogError( "MkDir $sofar FAILED! $!" );
                    print "MkDir $sofar FAILED! $!";
                    return 0;
                  }
              }
          }
        #print COPYLOG "MkDir $dir\n";
      }
  }

sub insertIntoFile( $$$@ )
  {
    my ($file, $text, $before, @afters) = @_;

    my @lines;
    if ( open( IN, "$file" ) )
      {
        @lines = <IN>;
        close( IN );
      }
    else
      {
        print "Failed to open $file\n";
        return;
      }

    print "$file\n" unless ( $verbose eq "" );

    my $text0;
    if ( $text =~ /^(.+)$/m )
      {
        $text0 = $1;
      }
    else
      {
        $text0 = $text;
      }

    $text0 = quotemeta( $text0 );

    if ( grep( /^$text0$/, @lines ) )
      {
        print "Already has change\n" unless ( $verbose eq "" );
        print "First line [$text0] found\n" unless ( $verbose eq "" );
        return;
      }
    else
      {
        #print "First line [$text0] not found\n" unless ( $verbose eq "" );
      }
    for ( @afters )
      {
        #print "afters: $_\n" unless ( $verbose eq "" );
      }

    @afters = reverse( @afters );
    my $changed = 0;
    if ( open( OUT, ">$file.temp" ) )
      {
        my $after = quotemeta( pop( @afters ) );
        my $qbefore = quotemeta( $before );
        print "looking for [$before] after [$after]\n" unless ( $verbose eq "" );
        my $i = 0;
        for ( @lines )
          {
            $i++;
            if ( $changed eq 1 )
              {
                #print "$i: processing rest of file\n";
              }
            elsif ( $after eq "" && /$qbefore/ )
              {
                print "$i: found before first output text\n" unless ( $verbose eq "" );
                $qbefore = "";
                print OUT $text;
                $changed = 1;
              }
            elsif ( $after ne "" && /$after/ )
              {
                print "$i: found [$after]\n" unless ( $verbose eq "" );
                $after = quotemeta( pop( @afters ) );
                if ( $after ne "" )
                  {
                    print "after now [$after]\n" unless ( $verbose eq "" );
                  }
                else
                  {
                    print "now looking for [$before]\n" unless ( $verbose eq "" );
                  }
              }
            else
              {
                #print "$i: else\n" unless ( $verbose eq "" );
              }
            print OUT;
          }
        if ( $after ne "" )
          {
            print "**** $file: Never found after '$after'\n";
          }
        if ( $qbefore ne "" )
          {
            if ( $before eq "<EOF>" )
              {
                print OUT $text;
                $changed = 1;
                $qbefore = "";
              }
            if ( $qbefore ne "" )
              {
                print "**** $file: Never found before '$before'\n";
              }
          }
        close( OUT );
      }
    else
      {
        print "Failed to open $file.temp\n";
      }
    if ( $changed eq 1 )
      {
        unlink( "$file.bak" );
        if ( !rename( $file, "$file.bak" ) )
          {
            print "ERROR can't rename $file $file.bak\n";
          }
        if ( !rename( "$file.temp", $file ) )
          {
            print "ERROR can't rename $file.temp $file\n";
          }
      }
    else
      {
        print "Unchanged\n" unless ( $verbose eq "" );
      }
  }

sub replaceInFile( $$$ )
  {
    my ($file, $find, $text ) = @_;

    my @lines;
    if ( open( IN, "$file" ) )
      {
        @lines = <IN>;
        close( IN );
      }
    else
      {
        print "Failed to open $file\n";
        return;
      }

    print "$file\n" unless ( $verbose eq "" );

    if ( grep( /$find/, @lines ) )
      {
        print "Found $find in file\n" unless ( $verbose eq "" );
        if ( open( OUT, ">$file.temp" ) )
          {
            for ( @lines )
              {
                if ( /$find/ )
                  {
                    print "Found $find\n" unless ( $verbose eq "" );
                    s/$find/$text/g;
                  }
                print OUT;
              }
            close( OUT );
            unlink( "$file.bak" );
            if ( !rename( $file, "$file.bak" ) )
              {
                print "ERROR can't rename $file $file.bak\n";
              }
            if ( !rename( "$file.temp", $file ) )
              {
                print "ERROR can't rename $file.temp $file\n";
              }
          }
        else
          {
            print "Failed to open $file.temp\n";
          }
      }
    else
      {
        print "Unchanged\n" unless ( $verbose eq "" );
      }
  }

sub RmDir($) {
  my ($dir) = @_;
  $dir = osify($dir);

  if ( ! -d $dir ) {
    print "RmDir $dir does not exist\n";
  }

  my $cmd;
  if ( $^O eq "MSWin32" ) {
    $cmd = "rd /s /q \"$dir\""
  }
  else {
    $cmd = "rm -Rf \"$dir\""
  }

  print "$cmd\n";
  open( CMD, "$cmd 2>&1 |");

  while ( <CMD> ) {
    print $_;
  }
}

sub RemoveTopClass()
  {
    if ( $WWWRoot ne "" && $tcdir ne "" )
      {
        RmDir( "$WWWRoot\\$tcdir" );
      }
    if ( $ProgramFiles ne "" && $tcdir2 ne "" )
      {
        RmDir( "$ProgramFiles\\$tcdir2" );
      }
    runCmd( "net stop tomcat-tcc" );
    if ( $tcc ne "" )
      {
        RmDir( "$tcc" );
      }
    # delete web dir...
    runCmd( "$adsutil DELETE W3SVC/1/Root/$tcdir" );
    # delete filter dir
    runCmd( "$adsutil DELETE W3SVC/1/Root/jakarta" );
    # delete filter
    runCmd( "$adsutil DELETE W3SVC/1/Filters/jakarta" );

    # need to remove jakarta from the order rather than delete order..
    #runCmd( "$adsutil DELETE W3SVC/1/Filters/FilterLoadOrder" );

    my $regVer = "${Major}.${Minor}.${Point}";
    if ( $MultipleBuilds eq "Y" and $Build ne "" )
      {
        $regVer = "${regVer}.${Build}";
      }
    if ( $prefix ne "tc" )
      {
        $regVer = "${prefix}.${regVer}";
      }
    runCmd( "REG DELETE \"$TopClassServerKey\\$regVer\" /f" );

    # need to delete all those exe entries pointing at $regVer

    # drop sql server database
    if ( doSqlServer() )
      {
        runCmd( "osql -U sa -P $saPass -S $sqldb -Q \"drop database $sqlSchemaName\"" );
      }

    if ( doOracle() )
      {
        # drop oracle scehma
        my $dropSchema = "$tempDir\\drop$oraSchemaName.txt";
        if ( open( DROP, ">$dropSchema" ) )
          {
            print DROP "DROP USER $oraSchemaName CASCADE;\n";
            close( DROP );
            runCmd( "sqlplus -L \"sys/$syspass\@$oradb as sysdba\" \@$dropSchema" );
          }
      }
  }


sub GetBuildNumber( $ )
{
  my ($drive) = @_;
  my ($Major, $Minor, $Point, $Build);

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
  return ($Major, $Minor, $Point, $Build);
}

sub displayVars()
{
  print " adsutil :           $adsutil\n";
  print " Build :             $Build\n";
  print " Builds :            $Builds\n";
  print " ccDrive :           $ccDrive\n";
  print " clearcasedrive :    $clearcasedrive\n";
  print " command :           $command\n";
  print " copyExes :          $copyExes\n";
  print " CopyFromBuilds :    $CopyFromBuilds\n";
  print " Database :          $Database\n";
  print " debugBuild :        $debugBuild\n";
  print " esdVob :            $esdVob\n";
  print " host :              $host\n";
  print " InstallDrive :      $InstallDrive\n";
  print " instances :         $instances\n";
  print " LicenseDir :        $LicenseDir\n";
  print " Major :             $Major\n";
  print " mappedwebpath :     $mappedwebpath\n";
  print " Minor :             $Minor\n";
  print " mssqlHome :         $mssqlHome\n";
  print " mssqlHome2000 :     $mssqlHome2000\n";
  print " mssqlHome2005 :     $mssqlHome2005\n";
  print " mssqlHome2008 :     $mssqlHome2008\n";
  print " mssqlPath :         $mssqlPath\n";
  print " MultipleBuilds :    $MultipleBuilds\n";
  print " myDir :             $myDir\n";
  print " nonwebpath :        $nonwebpath\n";
  print " nonwebroot :        $nonwebroot\n";
  print " oracleHome :        $oracleHome\n";
  print " oraclePath :        $oraclePath\n";
  print " oradb :             $oradb\n";
  print " Point :             $Point\n";
  print " prefix :            $prefix\n";
  print " ProgramFiles :      $ProgramFiles\n";
  print " redirVer :          $redirVer\n";
  print " saPass :            $saPass\n";
  print " oraSchemaName :     $oraSchemaName\n";
  print " oraSchemaPass :     $oraSchemaPass\n";
  print " schemaName :        $sqlSchemaName\n";
  print " sqlSchemaPass :     $sqlSchemaPass\n";
  print " scriptsRoot :       $scriptsRoot\n";
  print " sqldb :             $sqldb\n";
  print " sqlver :            $sqlver\n";
  print " suffix :            $suffix\n";
  print " syspass :           $syspass\n";
  print " systempass :        $systempass\n";
  print " tcc :               $tcc\n";
  print " tcdir :             $tcdir\n";
  print " tcdir2 :            $tcdir2\n";
  print " tcuser :            $tcuser\n";
  print " tcver :             $tcver\n";
  print " tempDir :           $tempDir\n";
  print " testing :           $testing\n";
  print " TopClassServerKey : $TopClassServerKey\n";
  print " upDir :             $upDir\n";
  print " UseVersion :        $UseVersion\n";
  print " verbose :           $verbose\n";
  print " View :              $View\n";
  print " webpath :           $webpath\n";
  print " WWWRoot :           $WWWRoot\n";
}
### Main

sub Setup()
{
  SetupVars();

  if ( $Major eq "" or $Minor eq "" or $Point eq "" )
    {
      print STDERR "Version not fully specified\n";
      print STDERR "$0 -m major -n minor -p point -b build -v view -d database -c drive\n";
      if ( $Just ne "" )
        {
          Usage();
          return;
        }
    }


  # validate pre-requisites
  if ( !find_prog( "setacl.exe" ) )
    {
      print "\n*********************************************\nERROR! setacl not found\n";
      print "copy \\\\hogfather\\shared\\wbt-setup\\setacl.exe c:\\bin\n";
      print "\n*********************************************\nERROR! setacl.exe not found\n*********************************************\n";
      return;
    }
  if ( !find_prog( "unzip.exe" ) )
    {
      print "\n*********************************************\nERROR! unzip not found\n";
      print "copy \\\\hogfather\\shared\\wbt-setup\\unzip.exe c:\\bin\n";
      print "\n*********************************************\nERROR: unzip.exe not found\n*********************************************\n";
      return;
    }
  if ( !find_prog( "tee" ) )
    {
      print "\n*********************************************\nERROR! tee not found\n";
      print "install cygwin http://www.cygwin.com/setup.exe\n";
      print "or\n";
      print "copy \\\\hogfather\\shared\\wbt-setup\\tee.exe c:\\bin\n";
      print "copy \\\\hogfather\\shared\\wbt-setup\\cyg*.dll c:\\bin\n";
      print "\n*********************************************\nERROR! tee.exe not found\n*********************************************\n";
    }

  if ( $CopyFromBuilds eq "Y" or $copyExes eq "Y" )
    {
      if ( ! -d $Builds )
      #my @b = glob("$Builds\\*" );
      #if ( scalar( @b ) == 0 )
        {
          print "\n*********************************************\nERROR! Builds not found [$Builds]\n*********************************************\n";
          return;
        }
    }
  if ( $testing eq "Y" )
    {
      return;
    }
  print "Let's begin\n";

  #print STDOUT "Written to STDOUT\n";
  #print STDERR "Written to STDERR\n";

  runCmd( "iisreset" );
  if ( $stopStartTomcat eq "Y" )
    {
      runCmd( "net stop tomcat6" );
      runCmd( "net stop w3svc" );
    }

  if ( $Just ne "" )
    {
      foreach my $just ( split( /,/, $Just ) )
        {
          if ( $just eq "display" )
            {
              displayVars();
            }
          elsif ( $just eq "webdir" )
            {
              CreateWebDir();
            }
          elsif ( $just eq "perms" )
            {
              SetPermissions();
            }
          elsif ( $just eq "default" )
            {
              UpdateDefaultDotHtml();
            }
          elsif ( $just eq "reg" )
            {
              UpdateRegistry();
            }
          elsif ( $just eq "copy" )
            {
              CopyFiles();
            }
          elsif ( $just eq "tomcat" )
            {
              SetupTomcat();
            }
          elsif ( $just eq "schemas" )
            {
              CreateDatabaseSchemas();
            }
          elsif ( $just eq "exes" )
            {
              $copyExes = "Y";
              CopyExes();
            }
          elsif ( $just eq "usage" )
            {
              Usage();
            }
          elsif ( $just eq "delete" )
            {
              RemoveTopClass();
            }
          elsif ( $just eq "redirector" )
            {
              SetupRedirector();
            }
        }
    }
  else
    {
      if ( $MNP ge "9.0.0" )
        {
          CopyFiles();
          SetupTomcat();
          CreateDatabaseSchemas();
        }
      else
        {
          CreateWebDir();
          UpdateDefaultDotHtml();
          UpdateRegistry();
          CopyFiles();
          SetupTomcat();
          CreateDatabaseSchemas();
          CopyExes();
          SetPermissions();
        }
    }
  if ( $stopStartTomcat eq "Y" )
    {
      runCmd( "net start tomcat6" );
    }
  runCmd( "iisreset" );
}

SetupLogging();

Setup();

FinishLogging();
