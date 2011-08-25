#
# File: runms.pl
# Author: eweb
# Copyright WBT Systems, 1995-2011
# Contents:
#
# Date:          Author:  Comments:
# 31st Aug 2010  eweb     #00008 runora for sql server
# 30th Sep 2010  eweb     #00008 Don't drop database in upgrade mode
# 13th Oct 2010  rger     #12511 Ad Hoc reports for MS SQL Server
# 29th Oct 2010  eweb     #00008 Wrong data directory, Need complex password
# 30th Nov 2010  eweb     #00008 bhendrick is barry
#  3rd Feb 2011  bob      #00008 Lower case suffix _rpts
#
use strict;
use Getopt::Std;
use File::Find;
use File::Copy;
use File::Basename;
use Cwd;

my $argsdir = osify("c:/bin");

my $root;         # directory in which we will create a scripts folder and a log folder.
my $logsdir;

my $saPass;

my $tcuser;
my $tcpass;

# TODO #12511 Ad Hoc reports for MS SQL Server: enable by default
my $adhoc = "N";
my $rpts_user;
my $rpts_pwd;

my $mode = "install";
my $ccDrive;

my $major;
my $minor;
my $point;
my $build;
my $verbose;
my $version;

my $testing;
my $Builds = "\\\\neon\\builds";

# rger: Default paths for a default (not Named) instance of SQL server
my $mssqlHome2000 = osify("c:/Program Files/Microsoft SQL Server/MSSQL/DATA");
my $mssqlHome2005 = osify("c:/Program Files/Microsoft SQL Server/MSSQL.1/MSSQL/DATA");
my $mssqlHome2008 = osify("c:/Program Files/Microsoft Sql Server/MSSQL10.MSSQLSERVER/MSSQL/DATA");
my $mssqlHome;

my $sqlver;
my $tempDir;
my $sqldb;
my $mssqlPath;
my $MNPB;
my $MNP;
my $mnp;
my $mnpb;

my %usernameMap =
  (
    lmcgettigan => "lisa",
    rgeraschenko => "rger",
    aemelyanov => "deesy",
    bhendrick => "barry",
  );

print "perl $0 @ARGV\n";

sub mychomp
  {
    if ( @_ )
      {
        for ( @_ )
          {
            s![\r\n]+$!!;
          }
      }
    else
      {
        s![\r\n]+$!!;
      }
  }

sub dosify($)
  {
    my ($path) = @_;
    $path =~ s!/!\\!g;
    return $path;
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

sub DefaultArgs($$$)
  {
    my ($prog, $opts, $first) = @_;

    my $argsfile = osify("$argsdir/$prog." . lc $ENV{COMPUTERNAME});

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
        print "Options file $argsfile not found\n" if ( $first eq 1 );
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
                s/\s*#.+//;
                if ( /^([-+])([a-zA-Z])\s+(.+)$/ )
                  {
                    if ( $1 eq "+" or $first eq 1 )
                      {
                        #print "Setting opts{$2} = $3\n";
                        $args = "$args -$2 $3";
                        $opts->{$2} = $3;
                      }
                    elsif ( $opts->{$2} ne $3 )
                      {
                        print "Ignoring $_\n";
                      }
                  }
                elsif ( /^([-+])([a-zA-Z])$/ )
                  {
                    if ( $1 eq "+" or $first eq 1 )
                      {
                        #print "Setting opts{$2} = \n";
                        $args = "$args -$2";
                        $opts->{$2} = undef();
                      }
                    elsif ( $opts->{$2} ne undef() )
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
            if ( /\s+$name\s+REG_[A-Z]+\s+(.+)/i )
              {
                print " => $1\n" if ( $verbose );
                return $1;
              }
          }
      }
    print " => undef\n" if ( $verbose );
    return "";
  }

sub MkDir($)
  {
    my $dir = osify(shift);
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

    $BuildNoFile = osify($BuildNoFile);
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
            $build = $1;
            #$Build++;
            #$Build--;
          }
        elsif ( /\#define MAJORREVISION +([0-9]+)/ )
          {
            $major = $1;
          }
        elsif ( /\#define MINORREVISION +([0-9]+)/ )
          {
            $minor = $1;
          }
        elsif ( /\#define POINTREVISION +([0-9]+)/ )
          {
            $point = $1;
          }
      }
    close BUILDNO;
    $build = sprintf( "%03d", $build );
  }

sub SetEnvVar( $$ )
  {
    my ($name, $value) = @_;
    $ENV{$name} = $value;
    #print $BuildLog "SET $name=$value<br/>\n";
    print "SET $name=$value\n";
  }

sub Usage()
  {
    print "Usage perl $0 options\n";
    print "-U user [$tcuser]\n";
    print "-V version [$version]\n";
    print "-d drive [$ccDrive]\n";
    print "-M mode (install|upgrade) [$mode]\n";
    print "-P password [$tcpass]\n";
    print "-H host [$sqldb]\n";
    print "-r root [$root]\n";
    print "-x saPass [$saPass]\n";
    print "-v verbose [$verbose]\n";
    print "-X sqlver [$sqlver]\n";
    print "-Q mssqlHome [$mssqlHome]\n";
    print "-T testing [$testing]\n";
    print "-A Install Ad Hoc reports schema [$adhoc]\n";
  }

sub processCommandLine()
  {
    my %opts = ( U => undef(),
                 V => undef(),
                 d => undef(),
                 M => undef(),
                 P => undef(),
                 H => undef(),
                 r => undef(),
                 x => undef(),
                 v => undef(),
                 X => undef(),
                 Q => undef(),
                 T => undef(),
                 A => undef()
               );

    DefaultArgs("runms", \%opts, 1);

    $saPass = "sa";
    $sqldb = lc $ENV{COMPUTERNAME};

    my $unknown;
    # Was anything other than the defined option entered on the command line?
    if ( !getopts("U:V:d:M:P:H:r:x:v:X:Q:T:A:", \%opts) or @ARGV > 0 )
      {
        $unknown = "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
      }

    DefaultArgs("runms", \%opts, 2);

    if ( defined( $opts{U} ) )
      {
        $tcuser    = $opts{U};
        $rpts_user = $tcuser . "_rpts";
      }

    if ( defined( $opts{P} ) )
      {
        $tcpass   = $opts{P};
        $rpts_pwd = $tcpass;
      }

    if ( defined( $opts{A} ) )
      {
        $adhoc = uc $opts{A};
      }

    $testing = uc $opts{T};

    if ( defined( $opts{V} ) )
      {
        $version = $opts{V};
      }

    if ( defined( $opts{d} ) )
      {
        $ccDrive = $opts{d};
      }
    if ( defined( $opts{M} ) )
      {
        $mode = lc $opts{M};
      }

    if ( $version =~ /([0-9])([0-9])([0-9])b([0-9]+)/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
        $build = $4;
      }
    elsif ( $version =~ /([0-9])\.([0-9])\.([0-9])\.([0-9]+)/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
        $build = $4;
      }
    elsif ( $version =~ /([0-9])([0-9])([0-9])/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
      }
    elsif ( $version =~ /([0-9])\.([0-9])\.([0-9])/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
      }
    elsif ( $tcuser =~ /^[a-z_]+([0-9])([0-9])([0-9])b([0-9]+)$/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
        $build = $4;
      }
    elsif ( $tcuser =~ /^[a-z_]+([0-9])([0-9])([0-9])$/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
      }
    elsif ( $tcuser =~ /TC_([0-9])([0-9])([0-9])_BUILD_([0-9]+)/i )
      {
        $major = $1;
        $minor = $2;
        $point = $3;
        $build = $4;
      }
    else
      {
        GetBuildNumber($ccDrive);
        if ( $ccDrive eq "" and  $major ne "" )
          {
            my $dir = cwd;
            if ( $dir =~ /^(.:)/ )
              {
                $ccDrive = $1;
              }
          }
        if ( $major eq "" and $minor eq "" and $point eq "" and $build eq "" )
          {
            print "WARNING: Can't determine version number\n";
          }
        else
          {
            print "Using version: $major.$minor.$point.$build\n";
            $version = "$major.$minor.$point.$build";
          }
      }

    $MNP = "${major}.${minor}.${point}";
    $MNPB = "${major}.${minor}.${point}.${build}";
    $mnp = "${major}${minor}${point}";
    $mnpb = "${major}${minor}${point}b${build}";

    print "\$major.\$minor.\$point is $major.$minor.$point\n" if ( $verbose );

    if ( defined( $opts{H} ) )
      {
        $sqldb = $opts{H};
      }
    if ( defined( $opts{r} ) )
      {
        $root = $opts{r};
      }
    if ( defined( $opts{x} ) )
      {
        $saPass = $opts{x};
      }
    if ( defined( $opts{v} ) )
      {
        $verbose = $opts{v};
      }

    if ( defined($opts{X}) )
      {
        $sqlver = $opts{X};
      }
    else
      {
        $sqlver = "2005";
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
                die "ERROR Specified Sql Server Home directory -Q $mssqlHome doesn't exist\n";
              }
          }
        else #if ( lc $sqldb ne lc $ENV{COMPUTERNAME} )
          {
            # TODO validate directory on remote machine.
            my $remoteHome = osify("//$remote/$mssqlHome");
            $remoteHome =~ s!:!\$!;
            if ( ! -d $remoteHome )
              {
                print "WARNING Can't verify remote Sql Server Home directory $remoteHome\n";
              }
          }
      }
    else #if ( ? )
      {
       # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       # rger: on 2005\2008 systems:
       # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       # SELECT
       #   SUBSTRING( physical_name , 0, ( CHARINDEX( 'master.mdf', physical_name )) - 1)
       # FROM sys.master_files
       # WHERE name = 'master'
       # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
            die "sqlver (-e) must be either 2008, 2005 or at a push 2000\n";
          }
      }

    if ( $tcuser eq "" )
      {
        if ( $major . $minor . $point ne "" )
          {
            my $username = lc $ENV{USERNAME};
            if ( $usernameMap{$username} ne "" )
              {
                $username = $usernameMap{$username};
              }
            $tcuser = lc $username . $major . $minor . $point;
            if ( $build ne "" )
              {
                $tcuser = $tcuser . "b" . $build;
              }
            print "Will use tcuser $tcuser\n";
          }

        $rpts_user = $tcuser . "_rpts";
      }

    if ( $tcpass eq "" )
      {
        $tcpass   = $tcuser;
        $rpts_pwd = $rpts_user;
        if ( $MNPB lt "8.0.0.050" )
          {
            $tcpass =~ s!$mnp!$MNP!g;
            $tcpass =~ s!\.!_!g;
            #$tcpass =~ "_$tcpass_";
          }
      }

    if ( $saPass eq "" )
      {
        $saPass = "sa";
      }

    if ( $root eq "" )
      {
        $root = osify($ENV{TEMP} . "/" . $tcuser);
        # sqlplus doesn't understand cygdrive
        if ( $^O eq "cygwin" )
          {
            $root =~ s!^/cygdrive/(.)/!$1:/!;
          }
      }

    $logsdir = "$root/log";
    $tempDir = "$root/temp";

    if ( $root ne "" )
      {
        mkdir ( $root );
        mkdir ( $logsdir );
        mkdir ( $tempDir );
      }

    # unlikely to happen as we will have set $ccdrive from cwd
    if ( $ccDrive eq "" )
      {
        #print "\$0 $0\n";
        my $ccpath = osify( "/utils/AutoDevBuild/runora.pl" );

        if ( $0 =~ /(.+)\Q$ccpath\E$/ )
          {
            $ccDrive = $1;
            print "Will use clearcase drive $ccDrive\n";
          }
        else
          {
            print "can't determine value for \$ccDrive\n";
          }
      }

    if ( $ARGV[0] eq "?" )
      {
        Usage();
        exit;
      }
    elsif ( $unknown )
      {
        print $unknown;
        Usage();
        exit;
      }

    if ( $root eq "" ) { Usage(); die "\$root (-r) not specified\n"; }
    if ( $logsdir eq "" ) { Usage(); die "\$logsdir not specified\n"; }

    if ( $saPass eq "" ) { Usage(); die "\$saPass (-x) not specified\n"; }

    if ( $tcuser eq "" ) { Usage(); die "\$tcuser (-U) not specified\n"; }
    if ( $tcpass eq "" ) { Usage(); die "\$tcpass (-P) not specified\n"; }
    if ( $sqldb eq "" ) { Usage(); die "\$sqldb (-H) not specified\n"; }

    if ( $ccDrive eq "" ) { Usage(); die "\$ccDrive (-d) not specified\n"; }

    print "Version:    $major.$minor.$point.$build";
    if ( $version ne "" )
      {
        print " ($version)";
      }
    print "\n";

    print "root:       " . osify($root) . "\n";
    print "logsdir:    " . osify($logsdir) . "\n";
    print "ccDrive:    $ccDrive verbose: $verbose\n";
    print "connect:    $tcuser\@$sqldb\n";
  }

#
# installSchema() comes from tcsetup
#
sub installSchema($)
  {
    my ($mode) = @_;
    # set up the DSN

    my $SysRoot = RegGet( "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "SystemRoot" );
    my $ODBCDriver;

    #12644 - Use of Native Client to configure access to SQL2005\SQL2008 instances
    if ( $sqlver eq "2008" )
      {
        $ODBCDriver = "$SysRoot\\System32\\SQLNCLI10.dll";
        if ( !-e $ODBCDriver )
          {
            $ODBCDriver = "$SysRoot\\System32\\SQLNCLI.dll";
          }
        if ( !-e $ODBCDriver )
          {
            $ODBCDriver = "$SysRoot\\System32\\SQLSRV32.dll";
          }
      }
    elsif ( $sqlver eq "2005" )
      {
        $ODBCDriver = "$SysRoot\\System32\\SQLNCLI.dll";
        if ( !-e $ODBCDriver )
          {
            $ODBCDriver = "$SysRoot\\System32\\SQLSRV32.dll";
          }
      }
    elsif ( $sqlver eq "2000" )
      {
        $ODBCDriver = "$SysRoot\\System32\\SQLSRV32.dll";
      }

    if ( !-e $ODBCDriver )
      {
        die "Cannot locate ODBC Driver $ODBCDriver for SQL Server $version;\n Please Install the driver first.\n";
      }

    my $dsn = $sqldb;
    $dsn =~ s!\\!_!; # strip off named instance.
    die "ERROR: No dsn\n" unless ( $dsn );

    RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Description", "DSN for accessing topclass"  );
    RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Driver", $ODBCDriver );
    RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "LastUser", $tcuser );
    RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\$dsn", "Server", $sqldb );
    RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbc.ini\\ODBC Data Sources", $dsn, "SQL Server" );
    RegAdd( "HKLM\\SOFTWARE\\ODBC\\odbcinst.ini\\SQL Server", "CPTimeout", "<not pooled>" );

    # install the schema...

    if ( $mssqlPath eq "" )
      {
        $mssqlPath = osify("$ccDrive/topclass/oracle/topclass/Scripts/MSSQL");
      }

    # handle old tc_setenv.cmd
    if ( open( CMD, osify("$mssqlPath/tc_setenv.cmd") ) )
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
            rename( osify("$mssqlPath/tc_setenv.cmd"), osify("$mssqlPath/tc_setenv.cmd.bak") );
            if ( open( CMD, ">$mssqlPath/tc_setenv.cmd" ) )
              {
                foreach ( @lines )
                  {
                    print CMD;
                  }
                close( CMD );
              }
          }
      }

    if ( $mode eq "install" )
      {
        my $dropCmd;
        if ( $adhoc eq "Y" and $MNPB gt "8.1.0.046" )
          {
             $dropCmd = "sqlcmd -w 255 -b -S $sqldb -U sa -P $saPass -Q \"DROP DATABASE $rpts_user\"";
             runCmd( $dropCmd );
          }

        $dropCmd = "sqlcmd -w 255 -b -S $sqldb -U sa -P $saPass -Q \"DROP DATABASE $tcuser\"";
        runCmd( $dropCmd );
      }
    if ( $MNPB le "8.0.0.030" )
      {
        my $cmd = osify("$tempDir/mssql.bat");
        if ( open( CMD, ">$cmd" ) )
          {
            #print CMD "osql -U sa -P $saPass -Q \"drop database $tcuser\"";
            print CMD "setlocal\n";
            print CMD "set tc_user=$tcuser\n";
            print CMD "set db_name=$tcuser\n";
            print CMD "set MS_SRV_NAME=$sqldb\n";
            print CMD "set SILENT=true\n";
            print CMD "set TC_DATA=$mssqlHome\n";

            print CMD "chdir /d \"$mssqlPath\"\n";
            if ( $mode eq "install" )
              {
                print CMD "start \"Account\" /wait \"$mssqlPath\\tc_db_account.cmd\" $tcpass $saPass\n";
              }
            print CMD "start \"Schema\" \"$mssqlPath\\tc_db_schema.cmd\" $tcpass $mode\n";

            close( CMD );

            runCmd( $cmd );
          }
      }
    else
      {
        # TODO option to specify local & remote path for clr.
        #runCmd( "copy /y \"$mssqlPath\\Internal\\ServerProcs\\wbt_clr_procs.dll\" \"$ENV{TEMP}\"" );
        my $local_clr;
        my $clr_target_dir;
        my $remote = $sqldb;
        $remote =~ s!\\.+!!; # strip off named instance.

        my $clr_src = osify( "$mssqlPath/Internal/ServerProcs/wbt_clr_procs.dll" );

        if ( not -e $clr_src )
          {
            $clr_src = osify( "$Builds\\TopClassV${major}.${minor}.${point}\\builds\\build$build\\MSSQL\\Internal\\ServerProcs\\wbt_clr_procs.dll" );
            if ( not -e $clr_src and $build % 2 )
              {
                my $prevbuild = sprintf( "%03d", ($build-1));
                $clr_src = osify( "$Builds\\TopClassV${major}.${minor}.${point}\\builds\\build$prevbuild\\MSSQL\\Internal\\ServerProcs\\wbt_clr_procs.dll" );
              }
          }

        if ( not -e $clr_src )
          {
            die "Cannot find TopClass CLR DLL wbt_clr_procs.dll at either location.";
          }

        if ( lc $remote eq lc $ENV{COMPUTERNAME} )
          {
            #[rger]:[Can't use $clr_target_dir = $ENV{TEMP} as it's not accessible to MS SQL Server Process;
            $clr_target_dir = osify("C:/shared");
            if ( not -e $clr_target_dir )
              {
                $clr_target_dir = $argsdir;
              }
            runCmd( "copy /y \"$clr_src\" \"$clr_target_dir\"" );

            if ( -e "$clr_target_dir\\wbt_clr_procs.dll" )
              {
                $local_clr = $clr_target_dir;
              }
            else
              {
                die "Can't copy CLR Dll to a local location $clr_target_dir\\ ";
              }
          }
        else
          {
            $clr_target_dir = "\\\\$remote\\shared";
            runCmd( "copy /y \"$clr_src\" \"$clr_target_dir\"" );
            if ( -e "$clr_target_dir\\wbt_clr_procs.dll" )
              {
                $local_clr = "c:\\shared";
              }
            else
              {
                $clr_target_dir = "\\\\$remote\\c\$\\temp";
                runCmd( "copy /y \"$clr_src\" \"$clr_target_dir\"" );
                if ( -e "$clr_target_dir\\wbt_clr_procs.dll" )
                  {
                    $local_clr = "c:\\temp";
                  }
              }

            if ( not -e "$clr_target_dir\\wbt_clr_procs.dll" )
              {
                die "Can't copy CLR Dll to a remote location $clr_target_dir\\ ";
              }
          }

        MkDir( "$logsdir/mssql" );
        SetEnvVar( "TC_USER", $tcuser );

        if ( $MNPB le "8.1.0.046" )
          {
            SetEnvVar( "DB_NAME", $tcuser );
          }
        else # Ad Hoc Reports schema
          {
            SetEnvVar( "TC_DB_NAME", $tcuser );
            SetEnvVar( "REPORTS_USER", "${tcuser}_rpts");
            SetEnvVar( "REPORTS_DB_NAME", "${tcuser}_rpts" );
            SetEnvVar( "TC_SETUP", osify("$mssqlPath/Internal/Setup"));
          }

        SetEnvVar( "MS_SRV_NAME", $sqldb );
        SetEnvVar( "TC_DATA", osify("$mssqlHome") );
        SetEnvVar( "TSQL_ROOT", osify("$mssqlPath/") );
        SetEnvVar( "CLR_DIR", $local_clr );
        SetEnvVar( "SILENT", "true" );
        SetEnvVar( "LOGDIR", osify("$logsdir/mssql") );
        SetEnvVar( "SINGLE_PROCESS", 1 );

        my $saveDir =  cwd;
        chdir( $mssqlPath );

        if ( $MNPB gt "8.1.0.046")
          {
            unlink( "$logsdir/mssql/rpts_account_success" );
            unlink( "$logsdir/mssql/rpts_account_failure" );
            unlink( "$logsdir/mssql/rpts_schema_success" );
            unlink( "$logsdir/mssql/rpts_schema_failure" );
          }

        unlink( "$logsdir/mssql/db_account_success" );
        unlink( "$logsdir/mssql/db_account_failure" );
        unlink( "$logsdir/mssql/db_schema_success" );
        unlink( "$logsdir/mssql/db_schema_failure" );

        if ( $mode eq "install" )
          {
            runCmd( "\"$mssqlPath\\tc_setup_db.cmd\" $tcpass $saPass" );
            if ( -e "$logsdir/mssql/db_account_failure" )
              {
                print "tc_setup_db.cmd failed\n";
              }
            else #if ( -e "$logsdir/mssql/db_account_success" )
              {
                unlink( "$clr_target_dir\\wbt_clr_procs.dll");
                runCmd( "\"$mssqlPath\\tc_db_schema.cmd\" $tcpass $mode" );

                if ( -e "$logsdir/mssql/db_schema_failure" )
                  {
                    print "tc_db_schema.cmd failed\n";
                  }
                else
                  {
                    if ( $adhoc eq "Y" and $MNPB gt "8.1.0.046" )
                      {
                        runCmd( "\"$mssqlPath\\rpts_setup_db.cmd\" $rpts_pwd $saPass" );
                        if ( -e "$logsdir/mssql/rpts_account_failure" )
                          {
                            print "rpts_setup_db.cmd failed\n";
                          }
                        else #if ( -e "$logsdir/mssql/db_account_success" )
                          {
                            runCmd( "\"$mssqlPath\\rpts_db_schema.cmd\" $rpts_pwd $mode" );
                          }
                      }
                  }
              }
          }
        else #if ( -e "$logsdir/mssql/db_account_success" )
          {
            runCmd( "\"$mssqlPath\\tc_db_schema.cmd\" $tcpass $mode" );

            if ( $adhoc eq "Y" and $MNPB gt "8.1.0.046" )
              {
                runCmd( "\"$mssqlPath\\rpts_db_schema.cmd\" $rpts_pwd $mode" );
              }
          }
        chdir( $saveDir );
      }
  }

sub main()
  {
    processCommandLine();
    installSchema($mode);
  }

main();

