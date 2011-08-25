#
# File: runora.pl
# Author: eweb
# Copyright WBT Systems, 2006-2011
# Contents:
#
# Date:          Author:  Comments:
# 12th Mar 2006  eweb     Initial attempt.
# 13th Mar 2006  eweb     Creating Oracle Schema.
# 20th Mar 2006  eweb     Recursively process files.
#                         Spool to .txt files.
# 22nd Mar 2006  eweb     Not commenting out defines for tablespaces.
#                         Moved param file processing here from devbuild.pl
#                         -k Y to keep scripts.
#                         output the defines
# 23rd Mar 2006  eweb     $scriptDir defaults to .
#                         -c N not to copy (and to keep).
#                         Determine oradata from existing Data files.
#                         die if things go wrong.
#  4th May 2006  eweb     Handle new way of specifying tclogpath.
# 24th May 2006  eweb     Changed Oracle Instance to UC10R2.
# 15th Jun 2006  eweb     Default Oracle instance based on version.
#                         Usage string pick up -c [Y/N] copy files.
#  5th Sep 2006  eweb     Script path was different before 7.3
#                         Old versions needs a value for regpath
# 10th Oct 2006  eweb     -p param file. Don't insist on a drive.
#  5th Dec 2006  eweb     -v verbose, handle 4.2.8 scripts.
# 11th Jan 2007  eweb     One more way to detect versions, default to latest.
#  1st Feb 2007  eweb     May need to Upgrade the user before creating schema objects.
#  1st Feb 2007  eweb     Old style create tablespace script.
#  9th Feb 2007  eweb     806 doesn't like as sysdba. -V MNP[b123] to specify version.
#  1st Mar 2007  eweb     Display defaults/choices in usage.
#  2nd Mar 2007  eweb     Include check for temp tablespace.
# 29th Mar 2007  eweb     #00008 Log all sql.
# 16th May 2007  eweb     #00008 -S to specify the script dir.
# 14th Sep 2007  eweb     #00008 Fix pre 74 tc_create_usr to work with Oracle 10g.
# 18th Oct 2007  eweb     #00008 Display settings.
# 15th Jan 2008  eweb     #00008 Default for -r root
#  4th Apr 2008  eweb     #00008 tchist tablespace
#  7th Apr 2008  eweb     #00008 default to quark_10
# 11th Apr 2008  eweb     #00008 tchist tablespace
# 24th Apr 2008  eweb     #10921 Oracle Scripts: history index tablespace.
# 25th Apr 2008  eweb     #00001 8.0.0 => 9.0.0
# 25th Apr 2008  eweb     #00008 Unix slashes
# 25th Apr 2008  eweb     #10921 History index tablespace
#  8th May 2008  eweb     #00008 Arbitary prefix when determining version from name
# 16th Sep 2008  eweb     #00008 Changed tablespace prefix on quark to topclass_
# 16th Sep 2008  eweb     #00008 Exclude deprecated files, filter messages
# 16th Sep 2008  eweb     #00008 Deafult drive, version and user
# 22nd Sep 2008  eweb     #00008 Always use default tablespace prefix topclass_
# 23rd Oct 2008  eweb     #00008 Default system password
#  1st Dec 2008  eweb     #00008 Map usernames
#  4th Dec 2008  eweb     #00008 Handle new installer
#  5th Dec 2008  eweb     #00008 New installer, tcpass as arg to tc_install_nt
# 17th Dec 2008  eweb     #00008 Removed noise from logs
# 16th Jan 2009  eweb     #00008 Misleading warning
# 16th Jan 2009  eweb     #00008 die if can't drop user, hide rmdir errors, cleaner output
# 26th Jan 2009  eweb     #00008 Errors in package bodies, check for invalid objects
# 12th Feb 2009  eweb     #00008 Different stem versions prior to 8.0
#  8th May 2009  eweb     #00008 dosify paths
# 20th May 2009  eweb     #00008 install/upgrade mode
# 20th May 2009  eweb     #00008 Use period not plus to concatenate strings
# 25th May 2009  eweb     #00008 Upgrade mode
# 28th May 2009  eweb     #00008 Names of temp files, dosifying
# 12th Jun 2009  eweb     #00008 Digits in defines, Create tablespaces after processing files.
# 26th Jun 2009  eweb     #00008 Always use tcMajorMinorPoint as tnsname
#  4th Sep 2009  eweb     #00008 Always determine oradata, based on setname not first
#  4th Sep 2009  eweb     #00008 Ignore exception if tablespaces okay
#  3rd Mar 2010  eweb     #00008 Slashes
# 15th Mar 2010  rger     #12204 Ad Hoc reports for 8.1.0
#  8th Apr 2010  eweb     #00008 Option to control reporting schema creation -A Y/N
#  8th Apr 2010  eweb     #00008 Only consider directories of permanent tablespaces (not undo)
# 14th Apr 2010  eweb     #00008 Cope with script re-org
# 20th Apr 2010  eweb     #00008 Less noise
#  2nd Jun 2010  eweb     #00008 slashes
# 23rd Jun 2010  eweb     #00008 TSC_GROUP1_DATA and TSC_GROUP2_DATA
# 23rd Jun 2010  eweb     #00008 Attempt to make directory for tablespaces
#  8th Aug 2010  eweb     #00008 Handling default options
#  8th Sep 2010  eweb     #00008 Determine datadir
#  9th Sep 2010  eweb     #00008 Had left in an exit
# 14th Sep 2010  eweb     #00008 If find tableset folder use parent
# 12th Oct 2010  eweb     #00008 Ignore sizing model before 8
# 30th Nov 2010  eweb     #00008 bhendrick is barry
#  3rd Feb 2011  eweb     #00008 Wrong case so no adhoc schema
#  3rd Feb 2011  bob      #00008 Lower case suffix _rpts
#  9th Feb 2011  eweb     #00008 Noise Unrecognised line, Reports user name as password
# 30th Mar 2011  eweb     #00008 mychomp
# 30th Mar 2011  eweb     #00008 cygwin, use scriptsDir if specified
# 30th Mar 2011  eweb     #00008 determining data directory
# 31st Mar 2011  eweb     #00007 Logging
#  4th Apr 2011  eweb     #00008 Corrected chnage of scriptsDir
# 12th May 2011  eweb     #00008 Run from M: drive

# rewrite all .sql files commenting out the Accepts
# the prompts and the clear screens, etc..
#  define everything.
# run processing the output looking for errors.
#
# devbuild.pl will report failure if it finds **** ORA-9999 or **** SP2-9999


use strict;
use Getopt::Std;
use File::Find;
use File::Copy;
use File::Basename;
use Cwd;

my $argsdir = osify("c:/bin");

my $oradata;      # c:\oracle\oradata
my $root;         # directory in which we will create a scripts folder and a log folder.
my $tcpath;
my $tclogpath;
my $sqllog;
my $tempsqldir;

my $syspass;
my $systempass;

my $tcuser;
my $tcpass;
my $tchost;

my $rpts_user;
my $rpts_pwd;

my $mode = "install";
my $stem;
my $setName;
my $sizing_model = "tiny";
my $ccDrive;
my $scriptsDir;

my $copy = "Y";
my $keep = "N";

my $paramFile;

my $major;
my $minor;
my $point;
my $build;
my $verbose;
my $forLater;
my $version;
my $OraVer;
my $historyTableSpace;
my $adhoc = "Y";

my %usernameMap =
(
 lmcgettigan => "lisa",
 rgeraschenko => "rger",
 aemelyanov => "deesy",
 bhendrick => "barry",
);

my $asSysDBA = "as SYSDBA";

print "perl $0 @ARGV\n";

my $scriptDir;

my ($file, $scriptDir) = fileparse($0);

if ( $scriptDir eq "" )
  {
    $scriptDir = ".";
  }
else
  {
    $scriptDir =~ s![\\/]$!!;
  }

sub mychomp
  {
    if (@_) {
      for (@_) { s![\r\n]+$!!; }
    }
    else {
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

my @tablespaces;

sub set_std_tscs_names()
  {
    if ( "$major.$minor.$point" lt "8.0.0" ) #and "large" eq lc $sizing_model )
      {
        @tablespaces = ("data", "xref", "indx", "lobs", "xref_indx", "temp");
      }
    elsif ( "$major.$minor.$point" ge "8.0.0" )
      {
        # the smallest possible deployment: sizing model tiny;
        @tablespaces = ("data", "temp");

        if ( "small" eq lc $sizing_model || "medium" eq lc $sizing_model )
          {
            @tablespaces = (@tablespaces, "indx", "lobs", "xref_indx");
          }

        if ( "large" eq lc $sizing_model )
          {
            $historyTableSpace = "Y";
            @tablespaces = (@tablespaces, "hist", "hist_indx");
          }
      }
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
        print "Options file $argsfile not found\n";
      }
    elsif ( -e $argsfile )
      {
        print "Processing options in file $argsfile $first\n";
        if ( open( VARS, $argsfile ) )
          {
            while ( <VARS> )
              {
                mychomp;
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
    print "args: $args\n";
  }

sub processCommandLine()
  {
    my %opts = ( A => undef(),
                 U => undef(),
                 P => undef(),
                 H => undef(),
                 d => undef(),
                 s => undef(),
                 x => undef(),
                 y => undef(),
                 r => undef(),
                 D => undef(),
                 k => undef(),
                 c => undef(),
                 p => undef(),
                 v => undef(),
                 l => undef(),
                 V => undef(),
                 S => undef(),
                 M => undef(),
                 z => $sizing_model # 'tiny' by default
               );

    DefaultArgs("runora", \%opts, 1);

    # Was anything other than the defined option entered on the command line?
    if ( !getopts("A:U:P:H:d:s:x:y:r:D:k:c:p:v:l:V:S:M:", \%opts) or @ARGV > 0 )
      {
        print STDERR "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
        #Usage();
      }

    DefaultArgs("runora", \%opts, 2);

    if ( defined( $opts{A} ) )
      {
        $adhoc = uc $opts{A};
      }
    if ( defined( $opts{U} ) )
      {
        $tcuser = $opts{U};
        $rpts_user = $tcuser . "_rpts";
      }

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
    if ( defined( $opts{z} ) )
      {
        $sizing_model = $opts{z};
      }

    if ( $version =~ /([0-9])([0-9])([0-9])b([0-9]+)/i )
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
        if ( $ccDrive eq "" )
          {
            my $dir = cwd;
            if ( $dir =~ /^(m:[\/\\][^\/\\]+)[\/\\]?/i )
              {
                $ccDrive = $1;
                print "Setting ccDrive to $ccDrive\n";
              }
            elsif ( $dir =~ /^(.:)/ )
              {
                $ccDrive = $1;
                print "Setting ccDrive to $ccDrive\n";
              }
          }
        GetBuildNumber($ccDrive);
        if ( $ccDrive eq "" and $major ne "" )
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
          }
      }

    $syspass = "whopper";
    $systempass = "whopper";
    $stem = "";

    $tchost = "tc$major$minor$point";
    if ( $major eq 4 )
      {
        $asSysDBA = "";
      }

    print "\$major.\$minor.\$point is $major.$minor.$point\n" if ( $verbose );

    set_std_tscs_names();

    if ( defined( $opts{p} ) )
      {
        $paramFile = $opts{p};
      }
    else
      {
        $paramFile = "$scriptDir/oracle.params";
      }

    if ( open( PARAMS, "$paramFile" ) )
      {
        print "reading params from $paramFile\n";
        while ( <PARAMS> )
          {
            print if ( $verbose );
            mychomp;
            if ( /^syspass=(.*)$/ )
              {
                $syspass = $1;
              }
            elsif ( /^systempass=(.*)$/ )
              {
                $systempass = $1;
              }
            elsif ( /^tchost=(.*)$/ )
              {
                $tchost = $1;
              }
            elsif ( /^oradata=(.*)$/ )
              {
                $oradata = $1;
              }
            elsif ( /^stem=(.*)$/ )
              {
                $stem = $1;
              }
            elsif ( /^\s*$/ )
              {
              }
            else
              {
                print "*** Unknown line in params file [$_]\n";
              }
          }
        close(PARAMS);
      }
    else
      {
        #print "params file $paramFile not found using defaults\n";
      }

    if ( defined( $opts{P} ) )
      {
        $tcpass = $opts{P};
        $rpts_pwd = $tcpass;

      }
    if ( defined( $opts{H} ) )
      {
        $tchost = $opts{H};
      }
    if ( defined( $opts{D} ) )
      {
        $oradata = $opts{D};
      }
    if ( defined( $opts{r} ) )
      {
        $root = $opts{r};
      }
    if ( defined( $opts{s} ) )
      {
        $stem = $opts{s};
      }
    if ( defined( $opts{x} ) )
      {
        $syspass = $opts{x};
      }
    if ( defined( $opts{y} ) )
      {
        $systempass = $opts{y};
      }
    if ( defined( $opts{k} ) )
      {
        $keep = uc $opts{k};
      }
    if ( defined( $opts{c} ) )
      {
        $copy = uc $opts{c};
        if ( $copy ne "Y" )
          {
            $keep = "Y";
          }
      }
    if ( defined( $opts{v} ) )
      {
        $verbose = $opts{v};
      }
    if ( defined( $opts{l} ) )
      {
        $forLater = $opts{l};
        $keep = "Y";
      }
    if ( defined( $opts{S} ) )
      {
        $scriptsDir = $opts{S};
      }

    if ( $stem eq "" )
      {
        #print "\$major.\$minor.\$point: $major.$minor.$point ge 8.0.0\n" if ( "$major.$minor.$point" ge "8.0.0" );
        #print "\$major.\$minor.\$point: $major.$minor.$point lt 8.0.0\n" if ( "$major.$minor.$point" lt "8.0.0" );
        if ( "$major.$minor.$point" ge "8.0.0" )
          {
            $stem = "topclass_";
          }
        else
          {
            $stem = "tc${major}${minor}${point}_";
          }
      }
    else
      {
        #print "\$stem: $stem\n";
      }

    #print "\$stem: $stem\n";

    $setName = $stem;
    $setName =~ s!_$!!;

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
      }
    if ( $rpts_user eq "" )
      {
        $rpts_user = $tcuser . "_rpts";
      }

    if ( $tcpass eq "" )
      {
        $tcpass = $tcuser;
      }

    if ( $syspass eq "" )
      {
        $syspass = "change_on_install";
      }
    if ( $systempass eq "" )
      {
        $systempass = "manager";
      }

    if ( $root eq "" )
      {
        my $tmp = $ENV{TMP};
        if ( $tmp eq "" )
          {
            $tmp = osify("c:/temp");
          }
        $root = osify("$tmp/$tcuser");
        # sqlplus doesn't understand cygdrive
        if ( $^O eq "cygwin" )
          {
            $root =~ s!^/cygdrive/(.)/!$1:/!;
          }
      }

    $tcpath    = "$root/orascripts";
    $tclogpath = "$root/oralog";
    $tempsqldir = "$root/temp";
    $sqllog    = "$tclogpath/sql.log";

    if ( $root ne "" )
      {
        mkdir ( $root );
        mkdir ( $tcpath );
        mkdir ( $tclogpath );
        mkdir ( $tempsqldir );
      }

    if ( open( SQLLOG, ">$sqllog" ) )
      {
        print "Opened " . osify($sqllog) . "\n";
      }
    else
      {
        print "Failed to open " . osify($sqllog) . "\n";
      }

    # unlikely to happen as we will have set $ccdrive from cwd
    #print "\$ccDrive $ccDrive \$scriptsDir $scriptsDir\n";
    if ( $ccDrive eq "" && $scriptsDir eq "" )
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

    my $usage = "perl runora.pl -U user -P pass -H host -d drive -s stem -x syspass -y systempass -r rootdir -D oradata -k keep -c copy";
    $usage = "$usage\nperl runora.pl -U $tcuser -P $tcpass -H $tchost -d $ccDrive -s $stem -x $syspass -y $systempass -r $root -D $oradata -k $keep -c $copy";

    #$oradata is only needed when creating tablespaces
    # and we can pick it from existing tablespaces (data_files)
    #if ( $oradata eq "" ) { die "\$oradata not specified\n"; }
    if ( $root eq "" ) { die "\$root (-r) not specified\n$usage\n"; }
    #if ( $tcpath eq "" ) { die "\$tcpath not specified\n$usage\n"; }
    #if ( $tclogpath eq "" ) { die "\$tclogpath not specified\n$usage\n"; }

    if ( $syspass eq "" ) { die "\$syspass (-x) not specified\n$usage\n"; }
    if ( $systempass eq "" ) { die "\$systempass (-y) not specified\n$usage\n"; }

    if ( $tcuser eq "" ) { die "\$tcuser (-U) not specified\n$usage\n"; }
    if ( $tcpass eq "" ) { die "\$tcpass (-P) not specified\n$usage\n"; }
    if ( $tchost eq "" ) { die "\$tchost (-H) not specified\n$usage\n"; }

    if ( $stem eq "" ) { die "\$stem (-s) not specified\n$usage\n"; }
    if ( $ccDrive eq "" && $scriptsDir eq "" ) { die "neither \$ccDrive (-d) nor \$scriptsDir (-S) specified\n$usage\n"; }

    my $dbhost = determineHost($tchost);

    print "Version:    $major.$minor.$point.$build";
    if ( $version ne "" )
      {
        print " ($version)";
      }
    print "\n";

    print "tcuser:     $tcuser\n";
    print "tchost:     $tchost\n";
    print "dbhost:     $dbhost\n";
    print "tcpath:     " . osify($tcpath) . "\n";
    print "tclogpath:  " . osify($tclogpath) . "\n";
    print "sqllog:     " . osify($sqllog) . "\n";
    print "paramFile:  " . osify($paramFile) . "\n";
    print "root:       " . osify($root) . "\n";
    print "scriptsDir: " . osify($scriptsDir) . "\n";
    print "scriptDir:  " . osify($scriptDir) . "\n";


    print "ccDrive:    $ccDrive\n";
    print "copy:       $copy\n";
    print "forLater:   $forLater\n";
    print "keep:       $keep\n";
    print "verbose:    $verbose\n";
    print "adhoc:      $adhoc\n";
    print "stem:       $stem\n";
    print "oradata:    $oradata\n";
    print "connect:    $tcuser\@$tchost\n";
   #print "usage:      $usage\n";

   #exit;
  }


sub determineHost($)
  {
    my ($tnsname) = @_;
    if ( open( TNS, "tnsping $tnsname |" ) )
      {
        while ( <TNS> )
          {
            if ( /\(HOST = ([^ ).]+)(\.[^ )]+)?\)/ ) {
              print "tnsname $tnsname maps to $1\n";
              return $1;
            }
          }
        close( TNS );
      }
  }

my @defines;
my @accepts;
my @symbols;

sub addDefine( $$ )
  {
    my ($name, $value) = @_;
    #print "found define $name $value\n";
    my $found = 0;
    foreach ( @defines )
      {
        my ($n, $v) = split( "," );
        if ( $n eq $name )
          {
            $found = 1;
            last;
          }
      }
    if ( $found == 0 )
      {
        @defines = ( @defines, "$name,$value" );
      }
  }

sub addAccept( $ )
  {
    my ($name) = @_;
    #print "found accept $name\n";
    my $found = 0;
    foreach ( @accepts )
      {
        if ( $_ eq $name )
          {
            $found = 1;
            last;
          }
      }
    if ( $found == 0 )
      {
        @accepts = ( @accepts, "$name" );
      }
  }

sub processOneSqlFile ($)
  {
    my ($sqlFile) = @_;
    print "processOneSqlFile($sqlFile)\n" if ( $verbose );

    if ( !open( OUTFILE, ">$sqlFile.new" ) )
      {
        print "Couldn't open $sqlFile.new\n";
      }
    else #if ( open( OUTFILE, ">$sqlFile.new" ) )
      {
        my $changed = 0;
        if ( !open( SQLFILE, $sqlFile ) )
          {
            print "Couldn't open $sqlFile\n";
          }
        else #if ( open( SQLFILE, $sqlFile ) )
          {
            if ( $forLater )
              {
                if ( $sqlFile =~ /ts_create\.sql/ ||
                     $sqlFile =~ /tc_create_usr\.sql/ ||
                     $sqlFile =~ /create_user\.sql/ ||
                     $sqlFile =~ /tc_upgrade_usr_713\.sql/ ||
                     $sqlFile =~ /tc_install_nt\.sql/ ||
                     $sqlFile =~ /tc_upgrade_nt\.sql/ )
                  {
                    # how do we write send SQLTEMP to OUTFILE
                    WriteDefines( 1, 1 );
                  }
              }
            while ( <SQLFILE> )
              {
                #print if ( $verbose );
                mychomp;
                #print "[$_]\n";
                if ( /DEFINE\s+tcdata\s+=\s+'.*'/i ||
                     /DEFINE\s+tcxref\s+=\s+'.*'/i ||
                     /DEFINE\s+tcindx\s+=\s+'.*'/i ||
                     /DEFINE\s+tchist\s+=\s+'.*'/i ||
                     /DEFINE\s+tchist_indx\s+=\s+'.*'/i ||
                     /DEFINE\s+tcxref_indx\s+=\s+'.*'/i ||
                     /DEFINE\s+tclobs\s+=\s+'.*'/i )
                  {
                    if ( $major ne 8 )
                      {
                        $changed = 1;
                        print OUTFILE "--$_\n";
                      }
                    else
                      {
                        print OUTFILE "$_\n";
                      }
                  }
                elsif ( /^DEFINE\s+tcpath\s*=\s*.*/i ||
                        /^DEFINE\s+tclogpath\s*=\s*.*/i ||
                        /^DEFINE\s+tclog\s*=\s*.*/i )
                  {
                    $changed = 1;
                    print OUTFILE "--$_\n";
                  }
                elsif ( /^DEFINE\s+([a-zA-Z0-9_]+)\s*=\s*'(.*)'/i &&
                        ($1 eq "tools" or
                         $1 eq "templates" or
                         $1 eq "logging" or
                         $1 eq "config" or
                        #$1 eq "tclog" or
                         $1 eq "tccore" or
                         $1 eq "adhoc" ) )
                  {
                    print OUTFILE "$_\n";
                  }
                elsif ( /^DEFINE\s+Sys_Pwd\s*=/i )
                  {
                    $changed = 1;
                    print OUTFILE "DEFINE sys_pwd = '$syspass'\n";
                  }
                elsif ( /^DEFINE\s+([a-zA-Z0-9_]+)\s*=\s*(.*)/i )
                  {
                    my ($name, $oldvalue) = ($1, $2);
                    if ( $oldvalue =~ /'(.*)'/ )
                      {
                        $oldvalue = $1;
                      }
                    elsif ( $oldvalue =~ /"(.*)"/ )
                      {
                        $oldvalue = $1;
                      }
                    elsif ( $oldvalue =~ /(.*)\s*--/ )
                      {
                        $oldvalue = $1;
                      }
                    $oldvalue =~ s! +$!!;
                    my $newvalue = $oldvalue;
                    $name = lc $name;
                    $newvalue = $tcpath if( $name eq lc "tcpath");
                    $newvalue = $tcuser if ( $name eq lc "TC_USER" );
                    $newvalue = $tcpass if ( $name eq lc "TC_PWD" );
                    $newvalue = 'silent' if ( $name eq lc "INSTALL_MODE" ); # = SILENT
                    $newvalue = $tchost if ( $name eq lc "ORA_TNS_NAME" ); # =BAMBOO_10
                    $newvalue = 'Y' if ( $name eq lc "ORA_LOCAL_HOST" ); # =Y          -- [ Y | N ]
                    $newvalue = $sizing_model if ( $name eq lc "SIZING_MODEL" ); # =MEDIUM       -- [ TINY | SMALL | MEDIUM | LARGE ]
                    $newvalue = $setName if ( $name eq lc "TSC_SET_NAME" ); # =TOPCLASS     --   TOPCLASS
                    $newvalue = "BIGFILE" if ( $name eq lc "USE_BIGFILE" ); # ='BIGFILE'     -- [ '' | BIGFILE ]

                    $newvalue = $tcuser . "_rpts" if ( $name eq lc "rpts_user" );
                    $newvalue = $tcuser . "_rpts" if ( $name eq lc "rpts_pwd" );            #[Use the same password for Ad Hoc Reports user]

                    $newvalue = $oradata if ( $name eq lc "TSC_GROUP1_ROOT" ); # =C:\__&ORA_TNS_NAME
                    $newvalue = $oradata if ( $name eq lc "TSC_GROUP2_ROOT" ); # =&TSC_GROUP1_ROOT

                    $newvalue = "$oradata/$setName/data" if ( $name eq lc "TSC_GROUP1_DATA" ); # =C:\__&ORA_TNS_NAME
                    $newvalue = "$oradata/$setName/data" if ( $name eq lc "TSC_GROUP2_DATA" ); # =&TSC_GROUP1_ROOT

                    #addDefine( $1, $2 );
                    if ( $newvalue ne $oldvalue )
                      {
                        print "changing define $name from $oldvalue to $newvalue\n" if ( $verbose );
                        print "DEFINE $name = '$newvalue'\n";
                        print OUTFILE "DEFINE $name = '$newvalue'\n";
                        $changed = 1;
                      }
                    else
                      {
                        print "found define $name $oldvalue\n" if ( $verbose );
                        print OUTFILE "DEFINE $name = '$newvalue'\n";
                      }
                  }
                elsif ( /^PAUSE/ )
                  {
                    $changed = 1;
                    print OUTFILE "--$_\n";
                  }
                elsif ( /^UNDEF\s+([a-zA-Z0-9_]+)/i )
                  {
                    #print "found undef $1\n";
                    #addDefine( $1 );
                    $changed = 1;
                    print OUTFILE "--$_\n";
                  }
                elsif ( /^ACCEPT\s+([a-zA-Z0-9_]+)\s/ )
                  {
                    print "found accept $1\n" if ( $verbose );
                    #addAccept( $1 );
                    $changed = 1;
                    print OUTFILE "--$_\n";
                  }
                elsif ( /^SPOOL\s+(.+)/ )
                  {
                    my $file = $1;
                    $file =~ s!\.log!.txt!;
                    #print "found spool $file\n";
                    $changed = 1;
                    print OUTFILE "SPOOL $file\n";
                  }
                elsif ( /^connect system\@&tchost/i )
                  {
                    #print "found connect system\n";
                    $changed = 1;
                    print OUTFILE "connect system/&systempass\@&tchost\n";
                  }
                elsif ( /^connect sys\@&tchost/i )
                  {
                    #print "found connect sys\n";
                    $changed = 1;
                    print OUTFILE "connect sys/&syspass\@&tchost $asSysDBA\n";
                  }
                elsif ( /^@(.*)\.plb/ )
                  {
                    #print "found @ .plb $1\n";
                    $changed = 1;
                    print OUTFILE "\@$1.sql\n";
                  }
                elsif ( /^--create tablespace &tc_(.*) datafile 'your pathname\\your datafile name' size 100M/ )
                  {
                    $changed = 1;
                    print OUTFILE "create tablespace &tc$1 datafile '$oradata/&tc$1..dbf' size 100M\n";
                    print OUTFILE "/\n"
                  }
                elsif ( /^clear screen/i )
                  {
                    $changed = 1;
                    print OUTFILE "--$_";
                  }
                else
                  {
                    if ( "$major$minor$point" lt "740" ) #and $OraVer eq "10g" )
                      {
                        if ( /-- create topclass user/ )
                          {
                            print OUTFILE "WHENEVER SQLERROR CONTINUE\n";
                            print OUTFILE "CREATE ROLE tcuserrole\n";
                            print OUTFILE "/\n";
                            print OUTFILE "WHENEVER SQLERROR EXIT SQL.SQLCODE\n";
                            print OUTFILE "PROMPT Grant required privileges to tcuser role.\n";
                            print OUTFILE "PROMPT\n";
                            print OUTFILE "grant CREATE TABLE to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE VIEW  to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE SEQUENCE to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE SESSION to tcuserrole\n/\n";
                            print OUTFILE "grant ALTER  SESSION to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE SYNONYM to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE TRIGGER  to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE PROCEDURE to tcuserrole\n/\n";
                            print OUTFILE "grant CREATE TYPE to tcuserrole\n/\n";
                          }
                        elsif ( /grant select on (.*) to &tcuser/i )
                          {
                            print OUTFILE "PROMPT Grant tcuser role to TopClass user account\n";
                            print OUTFILE "grant tcuserrole to &tcuser\n/\n";
                          }
                      }
                    print OUTFILE "$_\n";
                  }
              }
            close( SQLFILE );
          }
        close( OUTFILE );
        if ( $changed == 1 )
          {
            #print "file $sqlFile has been altered\n";
            unlink( "$sqlFile.old" );
            rename( $sqlFile, "$sqlFile.old" );
            rename( "$sqlFile.new", $sqlFile );
          }
        elsif ( $changed == 0 )
          {
            unlink( "$sqlFile.new" );
          }
      }
  }

sub processSqlFilesInDir($)
  {
    my ($dir) = @_;
    print "processSqlFilesInDir($dir)\n" if ( $verbose );
    my $dirh;
    if ( opendir( $dirh, $dir ) )
      {
        my $file;
        while ( defined( $file = readdir($dirh) ) )
          {
            if ( $file =~ /\.sql$/ )
            #if ( $file =~ /^run_install_audit\.sql$/ )
              {
                #print "processing file: $file\n";
                processOneSqlFile( "$dir/$file" );
              }
            if ( $file eq "." or $file eq ".." )
              {
              }
            elsif ( -d "$dir/$file" )
              {
                #print "processing directory: $file\n";
                processSqlFilesInDir( "$dir/$file" );
              }
          }
        closedir($dirh);
      }


#    print "-- DEFINES\n";
#    foreach ( @defines )
#      {
#        my ($n, $v) = split( "," );
#        print "define $n $v\n";
#      }

#    print "-- ACCEPTS\n";
#    foreach ( @accepts )
#      {
#        print "DEFINE $_ = \"\"\n";
#      }
  }

sub processSqlFiles()
  {
    if ( $copy eq "Y" )
      {
        print "Copying files\n";
        my $cmd;
        if ( $scriptsDir eq "" )
          {
            if ( "$major.$minor" ne "." and "$major.$minor" lt "7.3" )
              {
                $scriptsDir = "$ccDrive/topclass/oracle/topclass/Scripts";
              }
            elsif ( "$major.$minor" ne "." and "$major.$minor" ge "9.0" )
              {
                $scriptsDir = "$ccDrive/topclass/java/topclass/Scripts/ORACLE";
              }
            else
              {
                $scriptsDir = "$ccDrive/topclass/oracle/topclass/Scripts/ORACLE";
              }
          }
        #if ( open( EXC, ">$tcpath/exclude.lst" ) )
        #  {
        #    print EXC "obsolete\n";
        #    print EXC "__DEPRICATED\n";
        #    print EXC "__NOT_FOR_DISTRIBUTION\n";
        #    close( EXC );
        #  }
        #$cmd = "xcopy /E /y /q /EXCLUDE:" . dosify("$tcpath/exclude.lst") . " \"" . dosify("$scriptsDir/*.sql") . "\" " . dosify("$tcpath");

        #print "scriptsDir: $scriptsDir\n";
        find( \&wanted, ( $scriptsDir ) );

        #print "$cmd\n";
        #system( $cmd );
        processSqlFilesInDir( $tcpath );
      }
  }

sub wanted {
  #$File::Find::dir  = /some/path/
  #$_                = foo.ext
  #$File::Find::name = /some/path/foo.ext

  my $file = $_;
  my $path = $File::Find::dir;
  my $full = $File::Find::name;

  #print "path:$path file:$file\n";
  my $src = osify($full);
  my $dst = osify($full);
  my $dstdir = osify($path);

  my $srcRoot = osify($scriptsDir);
  my $dstRoot = osify($tcpath);

  print "src:$src dst:$dst\n" if ( $verbose );

  print "srcRoot:$srcRoot dstRoot:$dstRoot\n" if ( $verbose );
  $srcRoot = quotemeta($srcRoot);
  #$dstRoot = quotemeta($dstRoot);

  $dst =~ s!$srcRoot!$dstRoot!;
  $dstdir =~ s!$srcRoot!$dstRoot!;
  print "src:$src dst:$dst\n" if ( $verbose );

  if ( $full eq "." ) {
    # create empty directories.
    if ( !-d $dstdir ) {
      mkdir( $dstdir );
    }
  }
  elsif ( $full eq ".." ) {
  }
  elsif ( -e $full && $full =~ /\.sql$/ ) {
    if ( !-d $dstdir ) {
      mkdir( $dstdir );
    }
    print "copy($src, $dst)\n" if ( $verbose );
    mycopy($src, $dst);
  }
}

sub mycopy($$) {
  my ($src, $dst) = @_;
  print "copy($src, $dst)\n" if ( $verbose );
  my $lastCarp;
  local $SIG{__WARN__} = sub { $lastCarp = $_[0] };
  return copy( $src, $dst );
}

sub tidyup()
  {
    if ( $keep ne "Y" )
      {
        my $cmd;
        my $out;
        #$cmd = "handle -a orascripts";
        #print "$cmd\n";
        #system( $cmd );
        if ( $^O eq "MSWin32" )
          {
            $cmd = "rd /s /q " . osify("$tcpath");
          }
        else
          {
            $cmd = "rm -r -f " . osify("$tcpath");
          }
        print "$cmd\n";
        $cmd = "$cmd 2>&1";
        my $tries = 0;
        while ( $tries < 4 )
          {
            $out = `$cmd`;
            #print "[$out]\n";
            if ( $out eq "" ) #!~ /The process cannot access the file because it is being used by another process/ )
              {
                last;
              }
            print $out if ( $verbose );
            $tries++;
          }
      }
  }

sub determineDataDir()
  {
    if ( open( SQLTEMP, ">$tcpath/sqltemp.sql" ) )
      {
        print SQLTEMP "set linesize 2000;\n";
        print SQLTEMP "set pagesize 2000;\n";
        print SQLTEMP "select df.tablespace_name, df.file_name from dba_data_files df join dba_tablespaces ts on (df.tablespace_name = ts.tablespace_name) where ts.contents = 'PERMANENT' order by df.file_name;\n";
        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $tcpath/sqltemp.sql $!\n";
      }
    print SQLLOG "\n*** determineDataDir ***\n\n";
    #system( "type $tcpath/sqltemp.sql" );
    my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@$tcpath/sqltemp.sql";

    #print "$cmd\n";

    my @alternatives;
    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /FILE_NAME/ )
              {
              }
            elsif ( $line =~ /----/ )
              {
              }
            elsif ( $line =~ /----/ )
              {
              }
            elsif ( $line =~ /rows selected/ )
              {
              }
            elsif ( $line =~ /ORA-[0-9]+:/ )
              {
                die "**** $line\n";
              }
            elsif ( $line =~ /SP2-[0-9]+:/ )
              {
                die "**** $line\n";
              }
            elsif ( $line =~ /^(\S+)\s+(\S+)\s*$/ )
              {
                my $name = $1;
                my $file = $2;
                if ( uc $name ne "SYSTEM" and uc $name ne "SYSAUX" )
                  {
                    #print "[$name] [$file]\n";
                    if ( $file =~ /(.+)(\\|\/)[^\\\/]+/ )
                      {
                        my $dir = $1;
                        # convert C:\ORACLE\ORADATA\PRISM10GR2\TOPCLASS\DATA
                        #      to C:\ORACLE\ORADATA\PRISM10GR2
                        if ( $dir =~ /\\$setName\\DATA$/i )
                          {
                            # this is th one we want...
                            $dir =~ s!\\$setName\\DATA$!!i;
                            $oradata = $dir;
                          }
                        if ( $oradata eq "" )
                          {
                            #print "Dir: $dir\n";
                            $oradata = $dir;
                          }
                        elsif ( $oradata ne $dir )
                          {
                            if ( $dir =~ /$setName\\DATA/i && $oradata !~ /$setName\\DATA/i )
                              {
                                my $qdir = quotemeta( $oradata );
                                if ( grep( /^$oradata$/, @alternatives ) == 0 )
                                  {
                                    @alternatives = ( @alternatives, $oradata );
                                  }
                                #print " =>: $dir\n";
                                $oradata = $dir;
                              }
                            else
                              {
                                my $qdir = quotemeta( $dir );
                                if ( grep( /^$qdir$/, @alternatives ) == 0 )
                                  {
                                    @alternatives = ( @alternatives, $dir );
                                    #print " or: $dir\n";
                                  }
                              }
                          }
                      }
                  }
                #@tablespacesInSchema = ( $1, @tablespacesInSchema );
              }
            elsif ( $line )
              {
                print "$line\n";
              }
            #print "$line\n";
          }
        close( SQLOUT );
        print "dir: $oradata\n";
        if ( @alternatives )
          {
            foreach ( @alternatives )
              {
                if ( $oradata =~ m!^\Q$_\E! )
                  {
                    print "Oops! $oradata is a sub dir of $_\n";
                    print "Will use $_\n";
                    $oradata = $_;
                  }
                elsif ( $_ =~ m!^\Q$oradata\E! )
                  {
                    print "$_ is a sub dir of $oradata\n" if ( $verbose );
                  }
                else
                  {
                    print " or: $_\n";
                  }
              }
          }
      }
    else
      {
        die "Failed to open $cmd $!\n";
      }
  }


sub listTablespaces()
  {
    if ( open( SQLTEMP, ">$tcpath/sqltemp.sql" ) )
      {
        print SQLTEMP "set linesize 2000;\n";
        print SQLTEMP "set pagesize 2000;\n";
        print SQLTEMP "select tablespace_name from dba_tablespaces;\n";
        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $tcpath/sqltemp.sql $!\n";
      }
    print SQLLOG "\n*** listTablespaces ***\n\n";
    system( "type $tcpath/sqltemp.sql" ) if ( $verbose );
    my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@$tcpath/sqltemp.sql";

    print "$cmd\n" if ( $verbose );

    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        my @tablespacesInSchema = ();
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /TABLESPACE_NAME/ )
              {
              }
            elsif ( $line =~ /^\s*$/ )
              {
              }
            elsif ( $line =~ /----/ )
              {
              }
            elsif ( $line =~ /rows selected/ )
              {
              }
            elsif ( $line =~ /^([A-Z_0-9]+)$/ )
              {
                print "found tablespace [$1]\n" if ( $verbose );
                @tablespacesInSchema = ( $1, @tablespacesInSchema );
              }
            elsif ( $line =~ /ORA-[0-9]+:/ )
              {
                die "**** $line\n";
              }
            elsif ( $line =~ /SP2-[0-9]+:/ )
              {
                die "**** $line\n";
              }
            else
              {
                print "**** [$line]\n";
              }
            #print "$line\n";
          }
        close( SQLOUT );
        my $allfound = 1;
        print "\n*** checking tablespaces ***\n\n" if ( $verbose );

        foreach my $ts0 ( @tablespaces )
          {
            print "Check $ts0\n" if ( $verbose );
            $ts0 = uc "$stem$ts0";

            print "looking for $ts0\n" if ( $verbose );

            my $found = 0;
            foreach my $ts1 ( @tablespacesInSchema )
              {
                $ts1 = uc $ts1;
                if ( $ts0 eq $ts1 )
                  {
                    $found = 1;
                    last;
                  }
              }
            if ( $found == 0 )
              {
                print "Didn't find $ts0\n";
                $allfound = 0;
                last;
              }
          }
        if ( $allfound == 0 or $oradata eq "" )
          {
            determineDataDir();
            if ( $allfound == 0 )
              {
                return 1;
              }
          }
      }
    else
      {
        print "Cannot get list of tablespaces\n";
        if ( $oradata eq "" )
          {
            print "Can't generate create tablespace script oradata not specified.\n";
            print "e.g. -D c:/oracle/oradata\n";
          }
        else
          {
            return 1;
          }
      }
  }

sub WriteDefine( $$$$ )
  {
    my ($name, $value, $log, $hide) = @_;
    print SQLTEMP "DEFINE $name = '$value'\n";
    if ( $log == 1 )
      {
        if ( $hide == 1 )
          {
            print "DEFINE $name = '***'\n";
          }
        else
          {
            print "DEFINE $name = '$value'\n";
          }
      }
  }

sub WriteDefines( $$ )
  {
    my ($files, $log) = @_;

    print SQLTEMP "set linesize 2000;\n";
    print SQLTEMP "set pagesize 2000;\n";
    WriteDefine( "syspass", $syspass, $log, 1 );
    WriteDefine( "systempass", $systempass, $log, 1 );
    WriteDefine( "tcpath", osify($tcpath), $log, 0 );
    WriteDefine( "tclogpath", osify($tclogpath), $log, 0 );
    WriteDefine( "tclog", osify($tclogpath), $log, 0 );
    WriteDefine( "tcuser", $tcuser, $log, 0 );
    WriteDefine( "tcpass", $tcpass, $log, 1 );
    WriteDefine( "tchost", $tchost, $log, 0 );
    WriteDefine( "UserType", "SQL", $log, 0 );
    if ( $major ne 8 )
      {
        WriteDefine( "PLB_SQL_FILETYPE", "SQL", $log, 0 );
        WriteDefine( "tctemp", uc $stem . "temp", $log, 0 );
        WriteDefine( "tcdata", uc $stem . "data", $log, 0 );
        WriteDefine( "tcxref", uc $stem . "xref", $log, 0 );
        WriteDefine( "tcindx", uc $stem . "indx", $log, 0 );
        WriteDefine( "tclobs", uc $stem . "lobs", $log, 0 );
        WriteDefine( "tcxref_indx", uc "$stem" . "xref_indx", $log, 0 );
        if ( $historyTableSpace eq "Y" )
          {
            WriteDefine( "tchist", uc $stem . "hist", $log, 0 );
            WriteDefine( "tchist_indx", uc $stem . "hist_indx", $log, 0 );
          }
        WriteDefine( "regpath", "regpath", $log, 0 );

        if ( $files == 1 )
          {
            WriteDefine( "tctemp_file", osify("$oradata/${stem}temp.dbf"), $log, 0 );
            WriteDefine( "tcdata_file", osify("$oradata/${stem}data.dbf"), $log, 0 );
            WriteDefine( "tcxref_file", osify("$oradata/${stem}xref.dbf"), $log, 0 );
            WriteDefine( "tcindx_file", osify("$oradata/${stem}indx.dbf"), $log, 0 );
            WriteDefine( "tclobs_file", osify("$oradata/${stem}lobs.dbf"), $log, 0 );
            WriteDefine( "tcxref_indx_file", osify("$oradata/${stem}xref_indx.dbf"), $log, 0 );
            if ( $historyTableSpace eq "Y" )
              {
                WriteDefine( "tchist_file", osify("$oradata/${stem}hist.dbf"), $log, 0 );
                WriteDefine( "tchist_indx_file", osify("$oradata/${stem}hist_indx.dbf"), $log, 0 );
              }
          }
      }
  }

sub createTableSpaces()
  {
    print "-- Creating TableSpaces --\n";

    my $tscreate;
    if ( "$major.$minor.$point" ge "8.0.0" )
      {
        if ( ! -d "$oradata/$setName/DATA" )
          {
            if ( ! -d "$oradata/$setName" )
              {
                mkdir( "$oradata/$setName" );
              }
            mkdir( "$oradata/$setName/DATA" );
          }
        $tscreate = "$tcpath/create_std_tscs.sql"
      }
    else
      {
        $tscreate = "$tcpath/ts_create.sql"
      }

    if ( ! -e $tscreate )
      {
        print "ERROR can't find " . osify($tscreate) . "\n";
        return;
      }

    my $sqltemp = "$tempsqldir/sqltemp.sql";

    if ( open( SQLTEMP, ">$sqltemp" ) )
      {
        WriteDefines( 1, 0 );

        print SQLTEMP "\@$tscreate $syspass\n";

        print SQLTEMP "\n";

        print SQLTEMP "\nexit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $sqltemp $!\n";
      }

    print SQLLOG "\n*** createTableSpaces ($tscreate) ***\n\n";
    #system( "type " . osify($sqltemp) );
    my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@" . osify($sqltemp);

    #print "$cmd\n";

    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            #mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ )
              {
              }
            elsif ( $line =~ /CREATE TABLESPACE .* DATAFILE '.+'/ ||
                 /^\*/ ||
                 /ERROR at line 1:/ ||
                 /Creating TopClass .* tablespace/  ||
                 /Tablespace created./
               )
              {
              }
            elsif ( $line =~ /ORA-01543: tablespace '(.+)' already exists/ )
              {
              }
            # we raise an exception if the Standard have been defined...
            elsif ( $line =~ /ORA-20101: Standard tablespaces have already been defined/ ||
                    $line =~ /ORA-06512/ )
              {
              }
            else
              {
                print $line;
              }
          }
      }
    else
      {
        die "Failed to open $cmd $!\n";
      }
  }

sub dropUser( $ )
  {
    my ($Usr) = @_;

    print "-- Dropping User $Usr --\n";
    if ( open( SQLTEMP, ">$tcpath/sqltemp.sql" ) )
      {
        print SQLTEMP "DROP USER $Usr CASCADE;\n";
        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $tcpath/sqltemp.sql $!\n";
      }

    print SQLLOG "\n*** dropUser $Usr ***\n\n";
    #system( "type $tcpath/sqltemp.sql" );
    my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@$tcpath/sqltemp.sql";

    print "$cmd\n" if ( $verbose );

    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        while ( <SQLOUT> )
          {
            #print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ )
              {
              }
            elsif ( $line =~ /^\s*[A-Z0-9_]+\s*$/ )
              {
              }
            elsif ( $line =~ /^[0-9]+ rows selected\./ )
              {
              }
            elsif ( $line =~ /^ORA-01940/ )
              {
                die "**** $line\n";
              }
            else
              {
                print "$line\n";
              }
          }
      }
    else
      {
        die "Failed to open $cmd $!\n";
      }
  }

sub createUser()
  {
    if ( $major ge 8 )
      {
        dropUser( $tcuser );
      }
    print "-- Creating User $tcuser --\n";
    my $sqltemp = osify("$tempsqldir/tempCreateUser.sql");
    if ( open( SQLTEMP, ">$sqltemp" ) )
      {
        WriteDefines( 0, 1 );

        if ( -e "$tcpath/tc_create_usr.sql" )
          {
            print SQLTEMP "\@" . osify("$tcpath/tc_create_usr.sql") . "\n";
          }
        elsif ( -e "$tcpath/create_user.sql" )
          {
            print SQLTEMP "\@" . osify("$tcpath/create_user.sql") . " $syspass\n";
          }
        else
          {
            print "ERROR: can't find tc_create_usr or create_user\n";
            close( SQLTEMP );
            return;
          }

        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $sqltemp $!\n";
      }

    print SQLLOG "\n*** createUser (tc_create_usr.sql) ***\n\n";
    #system( "type $tcpath/sqltemp.sql" );
    my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@$sqltemp";

    print "$cmd\n" if ( $verbose );

    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ )
              {
              }
            elsif ( $line =~ /^\s*[A-Z0-9_]+\s*$/ )
              {
              }
            elsif ( $line =~ /^[0-9]+ rows selected\./ )
              {
              }
            elsif ( $line =~ /^User dropped\./ ||
                    $line =~ /^User created\./ )
              {
                print "$line\n";
              }
            elsif ( $line =~ /^Grant succeeded\./ ||
                    $line =~ /^Commit complete\./ )
              {
              }
            elsif ( $line =~ /Create tcuser role/ ||
                    $line =~ /\(If an error occurs because the role already exists, this may safely be ignored\)/ ||
                    $line =~ /CREATE ROLE tcuserrole/ ||
                    $line =~ /Drop topclass user account if it already exists/ ||
                    $line =~ /.+   [0-9]+: grant tcuserrole to .+/ ||
                    $line =~ /^Grant .+ to .+$/ )
              {
              }
            elsif ( $line =~ /drop user $tcuser cascade/ ||
                    $line =~ /\s+\*/ ||
                    $line =~ /ERROR at line 1:/ ||
                    $line =~ /ORA-01918: user '(.*)' does not exist/ )
              {
              }
            elsif ( $line =~ /^(.*)\s+[0-9]+:\sdrop user (.*) cascade/ ||
                    $line =~ /^(.*)\s+[0-9]+:\screate user (.*) identified by (.*)/ ||
                    $line =~ /^(.*)\s+[0-9]+:\s(.*) tablespace (.*)/ ||
                    $line =~ /^(.*)\s+[0-9]+:\sgrant select on (.*) to (.*)/ ||
                    $line =~ /^(.*)\s+[0-9]+:\sgrant connect, resource to (.*)/ ||
                    $line =~ /^(.*)\s+[0-9]+:\sgrant query rewrite to (.*)/ ||
                    $line =~ /^(.*)\s+[0-9]+:\sgrant execute on (.*) to (.*)/ )
              {
              }
            elsif ( $line =~ /^Connecting as SYS\.\.\./ ||
                    $line =~ /^Connected./ ||
                    $line =~ /^'Prepare to enter info needed to create new TopClass database account\.'/ ||
                    $line =~ /^'Granting dbms_alert rights to TopClass account\. Please wait\.\.\.'/ )
              {
              }
            elsif ( $line =~ /^Connect (.*)/ ||
                    $line =~ /^Now connected to account (.*) at (.*)/ ||
                    $line =~ /^To exit this script and Sql\*Plus, enter EXIT at the prompt\./ )
              {
              }
            elsif ( $line =~ /If an error occurs because the role already exists, this my safely be ignored/ ||
                    $line =~ /If an error occurs because the account does not exist, this may safely be ignored/ ||
                    $line =~ /ORA-01921: role name 'TCUSERROLE' conflicts with another user or role name/ )
              {
              }
            elsif ( $line =~ /Copyright.+Oracle.+All rights reserved/ ||
                    $line =~ /Used parameter files:/ ||
                    $line =~ /sqlnet.ora/ ||
                    $line =~ /Used TNSNAMES adapter to resolve the alias/ )
              {
              }
            elsif ( $line =~ /The tablespaces that are matching to the Set Name/ )
              {
              }
            elsif ( $line =~ /^'--.*--'$/ ||
                    $line =~ /^\s*--/ ||
                    $line =~ /^\*+$/ ||
                    $line =~ /^\./ ||
                    $line =~ /\* Connecting as SYS\.\.\./
                  )
              {
              }
            elsif ( $line =~ /^ORA-([0-9]+): (.*)$/ )
              {
                if ( $1 eq "10615" ) #**** ORA-10615: Invalid tablespace type for temporary tablespace
                  {
                    die "**** $line\n";
                  }
                if ( $1 eq "01017" ) #**** ORA-01017: invalid username/password; logon denied
                  {
                    die "**** $line\n";
                  }
                print "**** $line\n";
              }
            elsif ( $line =~ /^SP2-([0-9]+): (.*)$/ )
              {
                if ( $1 eq "0640" ) #**** SP2-0640: Not connected
                  {
                    die "**** $line\n";
                  }
                print "**** $line\n";
              }
            else
              {
                print "$line\n";
              }
          }
      }
    else
      {
        die "Failed to open $cmd $!\n";
      }
  }

sub upgradeUser()
  {
    if ( $major == 7 and $minor == 1 && $point > 2 )
      {
        my $sqltemp = osify("$tempsqldir/tempUpgradeUser.sql");
        if ( open( SQLTEMP, ">$sqltemp" ) )
          {
            WriteDefines( 0, 1 );

            print SQLTEMP "\@" . osify( "$tcpath/tc_upgrade_usr_713" ) . "\n";

            print SQLTEMP "exit;\n";
            close( SQLTEMP );
          }
        else
          {
            die "Failed to open $sqltemp $!\n";
          }

        print SQLLOG "\n*** upgradeUser (tc_upgrade_usr_713.sql) ***\n\n";
        #system( "type $tcpath/sqltemp.sql" );
        my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@$sqltemp";

        print "$cmd\n" if ( $verbose );

        if ( open( SQLOUT, "$cmd 2>&1 |" ) )
          {
            while ( <SQLOUT> )
              {
                print if ( $verbose );
                print SQLLOG;
                mychomp;
                my $line = $_;
                if ( $line =~ /^\s*$/ )
                  {
                  }
                elsif ( $line =~ /^\s*[A-Z0-9_]+\s*$/ )
                  {
                  }
                elsif ( $line =~ /^[0-9]+ rows selected\./ )
                  {
                  }
                elsif ( $line =~ /^User dropped\./ ||
                        $line =~ /^User created\./ )
                  {
                    print "$line\n";
                  }
                elsif ( $line =~ /^Grant succeeded\./ ||
                        $line =~ /^Commit complete\./ )
                  {
                  }
                elsif ( $line =~ /drop user $tcuser cascade/ ||
                        $line =~ /\s+\*/ ||
                        $line =~ /ERROR at line 1:/ ||
                        $line =~ /ORA-01918: user '(.*)' does not exist/ )
                  {
                  }
                elsif ( $line =~ /^(.*)\s+[0-9]+:\sdrop user (.*) cascade/ ||
                        $line =~ /^(.*)\s+[0-9]+:\screate user (.*) identified by (.*)/ ||
                        $line =~ /^(.*)\s+[0-9]+:\s(.*) tablespace (.*)/ ||
                        $line =~ /^(.*)\s+[0-9]+:\sgrant select on (.*) to (.*)/ ||
                        $line =~ /^(.*)\s+[0-9]+:\sgrant connect, resource to (.*)/ ||
                        $line =~ /^(.*)\s+[0-9]+:\sgrant query rewrite to (.*)/ ||
                        $line =~ /^(.*)\s+[0-9]+:\sgrant execute on (.*) to (.*)/ )
                  {
                  }
                elsif ( $line =~ /^Connecting as SYS\.\.\./ ||
                        $line =~ /^Connected./ ||
                        $line =~ /^'Prepare to enter info needed to create new TopClass database account\.'/ ||
                        $line =~ /^'Granting dbms_alert rights to TopClass account\. Please wait\.\.\.'/ )
                  {
                  }
                elsif ( $line =~ /^Connect (.*)/ ||
                        $line =~ /^Now connected to account (.*) at (.*)/ ||
                        $line =~ /^To exit this script and Sql\*Plus, enter EXIT at the prompt\./ )
                  {
                  }
                elsif ( $line =~ /If an error occurs because the role already exists, this my safely be ignored/ ||
                        $line =~ /If an error occurs because the account does not exist, this may safely be ignored/ ||
                        $line =~ /ORA-01921: role name 'TCUSERROLE' conflicts with another user or role name/ )
                  {
                  }
                elsif ( $line =~ /^ORA-([0-9]+): (.*)$/ )
                  {
                    if ( $1 eq "10615" ) #**** ORA-10615: Invalid tablespace type for temporary tablespace
                      {
                        die "**** $line\n";
                      }
                    if ( $1 eq "01017" ) #**** ORA-01017: invalid username/password; logon denied
                      {
                        die "**** $line\n";
                      }
                    print "**** $line\n";
                  }
                elsif ( $line =~ /^SP2-([0-9]+): (.*)$/ )
                  {
                    if ( $1 eq "0640" ) #**** SP2-0640: Not connected
                      {
                        die "**** $line\n";
                      }
                    print "**** $line\n";
                  }
                else
                  {
                    print "$line\n";
                  }
              }
          }
        else
          {
            die "Failed to open $cmd $!\n";
          }
      }
  }

sub installSchema($)
  {
    my ($mode) = @_;
    print "-- installSchema($mode) --\n";
    my $sqltemp = osify("$tempsqldir/temp${mode}schema.sql");
    if ( open( SQLTEMP, ">$sqltemp" ) )
      {
        WriteDefines( 0, 1 );

        print SQLTEMP "\@" . osify("$tcpath/tc_${mode}_nt") . " $tcpass\n";

        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $sqltemp $!\n";
      }

    print SQLLOG "\n*** installSchema (tc_${mode}_nt.sql) ***\n\n";
    #system( "type $tcpath/sql${mode}schema.sql" );
    my $cmd = "sqlplus -L -S \"sys/$syspass\@$tchost $asSysDBA\" \@$sqltemp";

    print "$cmd\n" if ( $verbose );

    #system( $cmd );

    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        my $hideLines = 0;
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ ) # empty lines or lines of spaces
              {
              }
            elsif ( $line =~ /^([\s*]*)$/ )
              {
              }
            elsif ( $line =~ /^ORA-([0-9]+): (.*)$/ )
              {
                if ( $1 eq "10615" ) #**** ORA-10615: Invalid tablespace type for temporary tablespace
                  {
                    die "**** $line\n";
                  }
                if ( $1 eq "01017" ) #**** ORA-01017: invalid username/password; logon denied
                  {
                    die "**** $line\n";
                  }
                print "**** $line\n";
              }
            elsif ( $line =~ /^SP2-([0-9]+): (.*)$/ )
              {
                if ( $1 eq "0640" ) #**** SP2-0640: Not connected
                  {
                    die "**** $line\n";
                  }
                print "**** $line\n";
              }
            elsif ( $line =~ /Warning: Package Body created with compilation errors/ ||
                    $line =~ /Errors for PACKAGE BODY/ )
              {
                print "**** ERROR: $line\n";
              }
            elsif ( $line =~ /Copyright.+Oracle.+All rights reserved/ ||
                    $line =~ /Used parameter files:/ ||
                    $line =~ /sqlnet.ora/ ||
                    $line =~ /Used TNSNAMES adapter to resolve the alias/ )
              {
              }
            # Standard oracle responses
            elsif ( $line =~ /^PL\/SQL procedure successfully completed./ ||
                    $line =~ /^Table created\./ ||
                    $line =~ /^Table altered\./ ||
                    $line =~ /^Index created\./ ||
                    $line =~ /^View created\./ ||
                    $line =~ /^Function created\./ ||
                    $line =~ /^Procedure created\./ ||
                    $line =~ /^Trigger created\./ ||
                    $line =~ /^Trigger alter\./ ||
                    $line =~ /^Sequence created\./ ||
                    $line =~ /^No errors\./ ||
                    $line =~ /^Package created\./ ||
                    $line =~ /^Package body created\./ ||
                    $line =~ /^Trigger altered\./ )
              {
              }
            elsif ( $line =~ /^Index (.*) on table (.*) created\./ )
              {
              }
            elsif ( $line =~ /^Function-based index (.*) on table (.*) created\./ )
              {
              }
            elsif ( $line =~ /^Creating primary key (.*) on table (.*)\./ )
              {
              }
            elsif ( $line =~ /^Creating alternate key (.*) on table (.*)\./ )
              {
              }
            elsif ( $line =~ /^1 row created\./ )
              {
              }
            elsif ( $line =~ /^[0-9]+ rows created\./ )
              {
              }
            elsif ( $line =~ /^[0-9]+ rows deleted\./ )
              {
              }
            elsif ( $line =~ /^[0-9]+ rows selected\./ )
              {
                # end of config table
                $hideLines = 0;
              }
            elsif ( $line =~ /^Commit complete\./ )
              {
              }
            elsif ( $line =~ /^Creating Procedure (.+)/ )
              {
              }
            elsif ( $line =~ /^Creating Function (.+)/ )
              {
              }
            elsif ( $line =~ /^Regenerating/ )
              {
              }
            elsif ( $line =~ /^Regeneration/ )
              {
              }
            elsif ( $line =~ /^Creating/ )
              {
              }
            elsif ( $line =~ /^Creation/ )
              {
              }
            elsif ( $line =~ /^Installing/ )
              {
              }
            elsif ( $line =~ /^Installation/ )
              {
              }
            elsif ( $line =~ /^Setting DB configuration/ )
              {
              }
            elsif ( $line =~ /^\./ )
              {
              }
            elsif ( $line =~ /^\|/ )
              {
              }
            elsif ( $line =~ /^'.*'$/ )
              {
              }
            elsif ( $line =~ /^\s*--/ )
              {
              }
            elsif ( $line =~ /^Checking Configuration Settings/ )
              {
                # start of config table
                $hideLines = 1;
              }
            elsif ( $line =~ /The tablespaces that are matching to the Set Name/ )
              {
              }
            elsif ( $line =~ /^TABLESPACE_NAME/ )
              {
                # start of config table
                $hideLines = 1;
              }
            elsif ( $line =~ /^Details of Oracle instance:/ )
              {
                # start of config table
                $hideLines = 1;
              }
            elsif ( $line =~ /^Checking "query_rewrite" settings:/ )
              {
                # start of config table
                $hideLines = 1;
              }
            elsif ( $line =~ /^\(Re-check your connection details before trying again\.\)/ ||
                    $line =~ /^\*---------------------------------------------------------\*/ ||
                    $line =~ /^\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/ ||
                    $line =~ /^________________________________________________________________________/ ||
                    $line =~ /^Adding Audit Components\./ ||
                    $line =~ /^Applying 7\.1\.3 History Indexes/ ||
                    $line =~ /^before proceeding any further\./ ||
                    $line =~ /^Check that TopClass database user account has been upgraded to at least v6\.0\.2/ ||
                    $line =~ /^Checking number of objects created/ ||
                    $line =~ /^Checking the schema for invalid objects\.\.\./ ||
                    $line =~ /^Checking whether you have successfully connected/ ||
                    $line =~ /^Connected./ ||
                    $line =~ /^Connecting as TopClass user (.*)/ ||
                    $line =~ /^Create TopClass config table\./ ||
                    $line =~ /^DropTableIfExists did not find a table called "WTEXTSTOPWORDS"\. No table dropped\./ ||
                    $line =~ /^Executing a development install\./ ||
                    $line =~ /^Executing first check to resolve previous "Upgrade Tools" warnings/ ||
                    $line =~ /^Executing TopClass Install Checks \.\.\./ ||
                    $line =~ /^For Release version install, press RETURN to continue \.\.\./ ||
                    $line =~ /^If you have successfully logged on press RETURN to proceed\./ ||
                    $line =~ /^'INSTALL --> Signature Options are initialized'/ ||
                    $line =~ /^Is LMS also installed\?\s+= [YN]/ ||
                    $line =~ /^no rows selected/ ||
                    $line =~ /^Otherwise enter CTRL-C to exit to the sql command line/ ||
                    $line =~ /^Path to TopClass db script files = (.*)/ ||
                    $line =~ /^Path to TopClass TccExtra directory\s+= (.*)/ ||
                    $line =~ /^Path to TopClass Util-Scripts directory\s+= (.*)/ ||
                    $line =~ /^Principal steps of .*install have now been completed\./ ||
                    $line =~ /^Proceeding to checks\./ ||
                    $line =~ /^Proceeding to installing TopClass v7 Reporting components\./ ||
                    $line =~ /^Starting script tc_upgrade_tools\./ ||
                    $line =~ /^Table analyzed\./ ||
                    $line =~ /^Testing CheckGrantedPrivs\.\.\./ ||
                    $line =~ /^This version of TopClass database is not compatible with TC_check_counts/ ||
                    $line =~ /^To exit this script and SQL\*Plus, enter EXIT at the prompt\./ ||
                    $line =~ /^to the account on the database server./ ||
                    $line =~ /^TopClass schema install logged to directory = (.*)/ ||
                    $line =~ /^TopClass version detected = (.*)/ ||
                    $line =~ /^\(Installing latest version of ConnectionUser\)\./ ||
                    $line =~ /^Script tc_upgrade_tools has completed\. Exiting to main script\./ ||
                    $line =~ /^inserting operations into W.*OpType\.\.\./ ||
                    $line =~ /^'Installing R2BS package/ || # '
                    $line =~ /^\(re\)build .+ Hierarchy/ ||
                    $line =~ /^User (.*) has connected successfully\./ ||
                    $line =~ /^DropTableIfExists did not find a table/ )
              {
                #print "**** $line\n";
              }
            else
              {
                if ( $hideLines == 0 )
                  {
                    print "$line\n";
                  }
              }
          }
      }
    else
      {
        die "Failed to open $cmd $!\n";
      }
  }
sub checkSchema()
  {
    print "-- Checking Schema --\n";
    if ( open( SQLTEMP, ">$tcpath/sqltemp.sql" ) )
      {
        print SQLTEMP "SELECT 'INVALID OBJECT: ' || object_type || ' ' || object_name FROM user_objects WHERE status <> 'VALID';\n";

        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }
    else
      {
        die "Failed to open $tcpath/sqltemp.sql $!\n";
      }

    print SQLLOG "\n*** checkSchema ***\n\n";
    #system( "type $tcpath/sqltemp.sql" );
    my $cmd = "sqlplus -L -S \"$tcuser/$tcpass\@$tchost\" \@$tcpath/sqltemp.sql";

    print "$cmd\n" if ( $verbose );

    #system( $cmd );

    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        my $hideLines = 0;
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ ) # empty lines or lines of spaces
              {
              }
            elsif ( $line =~ /INVALID OBJECT/ )
              {
                print "**** ERROR: $line\n";
              }
            else
              {
                #print "???? $line\n";
              }
          }
      }
    else
      {
        die "Failed to open $cmd $!\n";
      }
  }

sub installAdHocSchema()
  {
    dropUser( $rpts_user );

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Create empty reporting schema
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    my $sqltemp = osify("$tempsqldir/tempCreateAdHocUser.sql");
    if ( open( SQLTEMP, ">$sqltemp" ) )
      {
        WriteDefines( 0, 0 );
        my $rpts_user_create = osify("$tcpath/rpts_user_create.sql");

        if ( -e $rpts_user_create )
          {
            print SQLTEMP "\@'$rpts_user_create'\n";
          }
        else
          {
            print "ERROR: can't find '$rpts_user_create'\n";
            close( SQLTEMP );
            return;
          }

        print SQLTEMP "exit;\n";
        close( SQLTEMP );
      }

    my $cmd = "sqlplus /nolog \@$sqltemp";
    print "$cmd\n";
    #system( $cmd );
    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ ||     # just space
                 $line =~ /^\./ ||       # starts with a dot
                 $line =~ /^\s*-- File:/ ||       # files
                 $line =~ /^\s*-- MSG:/ ||       # messages
                 $line =~ /^[-\* =]+$/ ) # spaces and punctuation
              {
              }
            else
              {
                print "$line\n";
              }
          }
      }

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Install the reporting schema objects:
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $sqltemp = osify("$tempsqldir/tempAdHocSchemaInstall.sql");
    if ( open( SQLTEMP, ">$sqltemp" ) )
      {
        WriteDefines( 0, 0 );
        my $rpts_schema_install = osify("$tcpath/rpts_schema_install.sql");
        if ( -e $rpts_schema_install )
          {
            print SQLTEMP "\@'$rpts_schema_install'\n";
          }
        else
          {
            print "ERROR: can't find '$rpts_schema_install'\n";
            close( SQLTEMP );
            return;
          }

        print SQLTEMP "exit\n";
        close( SQLTEMP );
      }

    $cmd = "sqlplus /nolog \@$sqltemp";
    print "$cmd\n";
    #system( $cmd );
    if ( open( SQLOUT, "$cmd 2>&1 |" ) )
      {
        while ( <SQLOUT> )
          {
            print if ( $verbose );
            print SQLLOG;
            mychomp;
            my $line = $_;
            if ( $line =~ /^\s*$/ ||     # just space
                 $line =~ /^\./ ||       # starts with a dot
                 $line =~ /^\s*-- File:/ ||       # files
                 $line =~ /^\s*-- MSG:/ ||       # messages
                 $line =~ /^[-\* =]+$/ ) # spaces and punctuation
              {
              }
            else
              {
                print "$line\n";
              }
          }
      }
  }

sub main()
  {
    #print "Processing command line\n";
    processCommandLine();

    #print "tablespaces\n";
    my $needToCreate = listTablespaces();

    #print "Processing sql files\n";
    processSqlFiles();

    chdir( $tcpath );

    if ( $needToCreate eq 1 )
      {
        if ( !-d "$oradata/$setName/data" )
          {
            mkdir("$oradata/$setName/data");
          }
        createTableSpaces();
      }

    if ( $mode eq "install" )
      {
        #print "Creating schema\n";
        createUser();

        upgradeUser();
      }

    #print "Installing schema\n";
    installSchema($mode);

    checkSchema();

    if ( $adhoc eq "Y" and "$major.$minor" ne "." and "$major.$minor" ge "8.1" )
      {
        installAdHocSchema();
      }

    #print "tidy up\n";
    tidyup();
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

main();
