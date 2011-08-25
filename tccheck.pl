#******************************************************************************/
#
#  File: tccheck.pl
#  Author: eweb
#  Copyright WBT Systems, 2003-2011
#  Contents:
#
#******************************************************************************/
#
# Date:          Author:  Comments:
#  8th Oct 2006  eweb     Initial version.
# 12th Oct 2006  eweb     Checking (and granting) access
# 12th Oct 2006  eweb     Checking access to Crystal.
# 12th Oct 2006  eweb     Accessing the about page
# 22nd Jun 2007  eweb     Multiple places including root.
#  1st Aug 2007  eweb     setacl doesn't work on clearcase
# 15th Jan 2008  eweb     #00008 Change in view names
# 14th Jan 2011  eweb     #00008 machine names

#
# Perl script to check an instance of TopClass.
#

=begin comment
Issues:

Correctly determiuning who topclass will run as...
Anonymous access, the connected user, the specified user, low/medium isolation
IWAM or IUSR...

If running as a service then we need to ensure that the ports are unique.

cnr?

=end comment

=cut

use strict;

use Getopt::Std;
use Win32::TieRegistry;
use File::Basename;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

my $adsutil = "cscript c:\\Inetpub\\AdminScripts\\adsutil.vbs //NoLogo";
my $Major;
my $Minor;
my $Point;
my $Build;
my $ua;
my $uaTIMEOUT = 18000;

$Registry->Delimiter("/");

my $ContentTypesKey = "HKEY_CLASSES_ROOT/Mime/Database/Content Type";

my $TopClassKey = "HKEY_LOCAL_MACHINE/Software/WBT Systems/TopClass Enterprise Server";

my $CrystalKey = "HKEY_LOCAL_MACHINE/Software/Crystal Decisions";

my $TopClassRoot = $Registry->{"$TopClassKey/"};
my $TopClassExes = $TopClassRoot->{"exes/"};
my @TopClassVersions = $TopClassRoot->SubKeyNames;

my $CrystalRoot = $Registry->{"$CrystalKey/"};

my %opts = ( i => undef(),
             g => undef(),
             p => undef(),
           );

#CheckAccess( "file", "c:\\inetpub\\wwwroot\\elt", "IUSR_HOGFATHER", "full" );
#CheckAccess( "file", "c:\\program files\\topclass server", "IUSR_HOGFATHER", "full" );

# Was anything other than the defined option entered on the command line?
if ( !getopts("i:g:p:", \%opts) or @ARGV > 1 )
  {
    print STDERR "Unknown arg @ARGV\n" if @ARGV > 0;
    #Usage();
    exit;
  }

my $Inst = lc $opts{i};
my $Grant = lc $opts{g};
my $Ping = lc $opts{p};

# get drive substitutions
# hash of subst drives.
my %substs;
if ( open( SUBST, "subst |" ) )
  {
    while ( <SUBST> )
      {
        #print;
        if ( /([a-z]):\\: => (.+)/i )
          {
            $substs{lc $1} = lc $2;
          }
      }
    close( SUBST );
  }

foreach ( keys %substs )
  {
    #print "[$_] [", $substs{$_}, "]\n";
  }

my %config;

sub SetConfig( $$ )
  {
    my ( $prop, $value ) = @_;
    $prop = lc $prop;
    #print "SetConfig($prop,$value)\n";

    my $qvalue = quotemeta( $value );
    if ( $value eq "" )
      {
      }
    elsif ( $config{$prop} eq "" )
      {
        $config{$prop} = $value;
      }
    else
      {
        my @values = split( /\n/, $config{$prop} );
        if ( grep( /^$qvalue$/i, @values ) )
          {
          }
        else
          {
            #print "\@values [@values]\n";
            #print "config{$prop} = [" . $config{$prop} . "] . [$value]\n";
            $config{$prop} = $config{$prop} . "\n" . $value;
          }
      }
  }


sub CheckReportContentTypes()
  {
    $Registry->Delimiter("\\");

    my $ContentTypesKey = "HKEY_CLASSES_ROOT\\Mime\\Database\\Content Type\\";

    my $ContentTypesRoot = $Registry->{$ContentTypesKey};

    my $setting;
    my $extension;

    $setting = $ContentTypesRoot->{"application/pdf\\"};
    #print "[$setting]\n";
    $extension = $setting->{Extension};

    if ( $extension ne ".pdf" )
      {
        print "No entry for \"application/pdf\"\n";
      }

    $setting = $ContentTypesRoot->{"application/vnd.ms-excel\\"};
    #print "$setting\n";
    $extension = $setting->{Extension};

    if ( $extension ne ".xls" )
      {
        print "No entry for \"application/vnd.ms-excel\"\n";
      }

    $setting = $ContentTypesRoot->{"application/msword\\"};
    #print "$setting\n";
    $extension = $setting->{Extension};

    if ( $extension ne ".doc" )
      {
        print "No entry for \"application/msword\"\n";
      }

    $Registry->Delimiter("/");
  }

CheckReportContentTypes();

#print "The following versions of Topclass are installed @TopClassVersions\n";
print "The following versions/instances of Topclass are installed:\n";
foreach my $inst ( $TopClassRoot->SubKeyNames )
  {
    $inst = lc $inst;
    if ( $inst eq "exes" )
      {
        # not an instance.
      }
    elsif ( $Inst ne "" and $inst ne $Inst )
      {
        # only interested in $Inst.
      }
    else
      {
        print "$inst:\n";
        %config = ();
        # Determine webable and non webable
        my $dir;
        $dir = $TopClassRoot->{"$inst//WebPath"};
        if ( $dir =~ /^\\?UNC\\(.*)$/ )
          {
            $dir = "\\" . $1;
          }
        if ( -d $dir )
          {
            SetConfig( "web", $dir );
          }
        else
          {
            SetConfig( "web-not", $dir );
          }
        $dir = $TopClassRoot->{"$inst//DatabasePath"};
        if ( $dir =~ /^\\?UNC\\(.*)$/ )
          {
            $dir = "\\" . $1;
          }
        if ( -d $dir )
          {
            SetConfig( "nonweb", $dir );
          }
        else
          {
            SetConfig( "nonweb-not", $dir );
          }
        # Are there multiple instances or just multiple versions?
        if ( $TopClassExes )
          {
            # iterate over exes to find those that point at this key.
            foreach my $exe ( $TopClassExes->ValueNames )
              {
                $exe = lc $exe;
                if ( lc $TopClassExes->{$exe} eq $inst )
                  {
                    $exe =~ s!^\\\\\?\\UNC\\!\\\\!i;
                    $exe =~ s!^\\\\\?\\!!;
                    my ($name, $path, $suffix) = fileparse($exe,qr/\.[^.]*/);
                    if ( $path eq ".\\" )
                      {
                        $path = "";
                      }
                    $path =~ s/\\$//;
                    #$path =~ s/^\\\\view\\/m:\\/;
                    if ( $path =~ /^([a-z]):(.*)/i )
                      {
                        #print "$path on drive $1\n";
                        if ( $substs{lc $1} )
                          {
                            $path = $substs{lc $1} . $2;
                          }
                      }
                    $path =~ s/^m:\\/\\\\view\\/;
                    $exe = "$path\\$name$suffix";
                    if ( $suffix eq ".exe" )
                      {
                        if ( $name eq "cr_report" )
                          {
                            # where does cr_report.exe live?
                            # we should check that it is present if multiple versions/instances
                          }
                        else
                          {
                            if ( -d $path )
                              {
                                SetConfig( "nonweb", $path );
                              }
                            else
                              {
                                SetConfig( "nonweb-not", $path );
                              }
                          }
                      }
                    if ( $suffix eq ".dll" or $suffix eq ".tc" )
                      {
                        SetConfig( "web", $path );
                      }
                    if ( -e $exe )
                      {
                        my @filestats = stat($exe);
                        my ($n, $p) = fileparse( $exe );
                        #print "size " . @filestats[7] ."\n";
                        if ( @filestats[7] < 100000 ) # smaller than 100k and it's a stub...
                          {
                            SetConfig( "stub-full", $exe );
                            SetConfig( "stub", $n );
                          }
                        elsif ( @filestats[7] > 4000000 ) # larger than 4mb and it's the app...
                          {
                            my $app = ( $suffix eq ".dll" ) ? "dll" : "exe";
                            SetConfig( "$app-full", $exe );
                            SetConfig( $app, $n );
                          }
                        #print "  $exe $where\n";
                      }
                    else
                      {
                        #print "  not $exe\n";
                      }
                  }
              }
          }
        # use default ...
        if ( $config{dll} eq "" and $config{exe} eq "" and $config{stub} eq "" )
          {
            my $exe = $config{web} . "\\topclass.dll";
            my $suffix = ".dll";
            if ( -e $exe )
              {
                my @filestats = stat($exe);
                #print "size " . @filestats[7] ."\n";
                if ( @filestats[7] < 100000 ) # smaller than 100k and it's a stub...
                  {
                    SetConfig( "stub-full", $exe );
                    SetConfig( "stub", "topclass.dll" );
                  }
                elsif ( @filestats[7] > 4000000 ) # larger than 4mb and it's the app...
                  {
                    my $app = ( $suffix eq ".dll" ) ? "dll" : "exe";
                    SetConfig( "$app-full", $exe );
                    SetConfig( $app, "topclass.dll" );
                  }
                #print "  $exe $where\n";
              }
          }
        #where is it in the web site?
        if ( $config{web} )
          {
            my $url = findWeb( $config{web} );
            if ( $url )
              {
                SetConfig( "url", $url );
              }
            if ( $url and $Grant eq "y" )
              {
                # If we know the url then it must exist or be under a existing dir/vdir
                # in which case we need a dir not a vdir.
                IISCreateDirectory( $config{url} );
              }
          }

        # for each instance we need webable and non webable
        # we need the dll or a service and the isapi stub
        # if so we need a port to listen on.
        # we also need a mini http port.
        # we could have a handler .tc handled by ...
        # we need cr_report.exe
        # we need the reports folder...
        # unless it is under the webable...
        # cnr root.
        my $x;
        # how is the stub configured?
        # access required anon or not
        # who does it run as
        # isolation mode of stub
        if ( $config{stub} )
          {
            checkExe( $inst, "stub" );
          }
        # isolation mode of dll
        if ( $config{dll} )
          {
            checkExe( $inst, "dll" );

            # check Crystal...
            # the user needs full access to c:\\Program Files\\Crystal Decisions
            # and "HKEY_LOCAL_MACHINE\\Software\\Crystal Decisions
          }

        if ( $config{dll} and $config{stub} )
          {
            SetConfig( "errors", "Both DLL and stub found" );
          }
        # what else?
        # later we might try pinging it.

        my @keys = sort { $a cmp $b } keys %config;

        foreach ( @keys )
          {
            if ( $config{$_} )
              {
                print "  $_: " . $config{$_} . "\n";
              }
          }

        if ( $Ping eq "y" and $config{url} )
          {
            my $prog;
            if ( $config{stub} )
              {
                $prog = $config{stub};
              }
            elsif ( $config{dll} )
              {
                $prog = $config{dll};
              }
            if ( $prog )
              {
                if ( !$ua )
                  {
                    $ua = new LWP::UserAgent;
                    $ua->timeout($uaTIMEOUT);   # number of seconds before User Agent times out
                  }

                # New in 7.4.2
                #?login-admin-admin-cmd=about%2Dxml
                my $theURL = "http://localhost" . $config{url} . "/" . $prog . "?about";
                print "GET $theURL\n";
                my $request = new HTTP::Request("GET", $theURL);
                $request->header("Content-type" => "text/XML");
                $request->header("Accept" => "text/*");
                my $response = $ua->request($request);
                print $response->status_line . "\n";
                if ( $response->code ne 200 )
                  {
                    print $response->headers_as_string . "\n";
                  }
                else
                  {
                    #my $headers = $response->headers_as_string;
                    my $contentType = $response->header( "Content-type" );
                    if ( $contentType )
                      {
                        if ( lc $contentType eq "text/html" ||
                             lc $contentType eq "text/xml" )
                          {
                            my $content = $response->content();
                            if ( $content =~ /^</ )
                              {
                                print "$content\n";
                              }
                          }
                        elsif ( lc $contentType eq "text/plain" )
                          {
                            print $response->headers_as_string . "\n";
                            my $content = $response->content();
                            #if ( $content =~ /^</ )
                              {
                                print "$content\n";
                              }
                          }
                        else
                          {
                            print $response->headers_as_string . "\n";
                          }
                      }
                    else
                      {
                        print $response->headers_as_string . "\n";
                      }
                  }
              }
          }
      }
  }


sub GetAccess( $$ )
  {
    my ($type, $obj) = @_;

    if ( !$type or !$obj )
      {
        return;
      }
    if ( $type eq "file" )
      {
        if ( !-e $obj and !-d $obj )
          {
            print "File or directory not found $obj\n";
            return;
          }
      }
    if ( $obj =~ /^\\\\view\\/ )
      {
        #print "set acl won't work on clearcase $obj\n";
        return;
      }
    my $cmd = "setacl -ot $type -on \"$obj\" -actn list -lst f:csv;w:d,o;i:y";
    #print "$cmd\n";

    my $access = `$cmd`;
    #print "$access\n";
    if ( $access =~ /SetACL finished with error\(s\):/ )
      {
        print "$cmd\n";
        print "$access\n";
      }
    elsif ( $access =~ /"[^"]*",[0-9]+,"([^"]*)"/ )
      {
        return $1;
      }
    else
      {
        print "$access\n";
      }
  }

sub GrantAccess( $$$$ )
  {
    my ($type, $obj, $user, $what) = @_;
    print "GrantAccess($type,$obj,$user,$what)\n";

    $obj =~ s!/!\\!g;
    if ( !$type or !$obj )
      {
        return;
      }
    if ( $type eq "file" )
      {
        if ( !-e $obj and !-d $obj )
          {
            print "File or directory not found $obj\n";
            return;
          }
      }
    if ( $obj =~ /^\\\\view\\/ )
      {
        #print "set acl won't work on clearcase $obj\n";
        return;
      }
    my $cmd = "setacl -ot $type -on \"$obj\" -actn ace  -ace n:$user;p:$what;m:grant";
    #print "$cmd\n";

    my $access = `$cmd`;
    #print "$access\n";
    if ( $access =~ /SetACL finished with error\(s\):/ )
      {
        print "$cmd\n";
        print "$access\n";
      }
    elsif ( $access =~ /SetACL finished successfully/ and
            $access =~ /Processing ACL of/ )
      {
      }
    else
      {
        print "$access\n";
      }
  }

sub CheckAccess( $$$$$ )
  {
    my ($type, $obj, $user, $what, $grant) = @_;

    $obj =~ s!/!\\!g;

    # check read access to the registry...
    my $access = GetAccess( $type, $obj );
    my @parts = split( /:/, $access );
    my $hasAccess;
    foreach ( @parts )
      {
        my @subparts = split( /,/ );
        if ( $subparts[0] =~ /$user/ )
          {
            if ( $subparts[1] =~ /$what/ )
              {
                $hasAccess = "True";
                last;
              }
            elsif ( $what eq "KEY_READ" && $subparts[1] =~ /full/ )
              {
                $hasAccess = "True";
                last;
              }
            else
              {
                print "$obj @subparts\n";
              }
          }
      }
    if ( !$hasAccess and $grant eq "y" )
      {
        GrantAccess( $type, $obj, $user, $what );
        return CheckAccess( $type, $obj, $user, $what, undef );
      }
    return $hasAccess;
  }

# so that's the different instances...
# what next?
# cross check against IIS?

##@key_names = $key->SubKeyNames
#foreach ( keys %$TopClassRoot )
#  {
#    print "[$_] [", $TopClassRoot->{$_}, "]\n";
#  }
exit;

# determine where topclass is installed.
# determine user(s) the it will run as.
# for each required resource check if accessible.


if ( defined( $opts{m} ) and defined( $opts{n} ) and defined( $opts{p} ) )
  {
    $Major = $opts{m};
    $Minor = $opts{n};
    $Point = $opts{p};
    $Build = $opts{b};
  }
else
  {
    print STDERR "Version not fully specified\n";
    exit;
  }


my $clearcasedrive = "N";
my $webpath;
my $host = lc $ENV{COMPUTERNAME};
if ( $host eq "hogfather" or $host eq "prism" or $host eq "howlin" )
  {
    $webpath = "\\\\view\\eweb_${Major}${Minor}${Point}_${host}\\topclass\\oracle\\topclass\\www";
    $clearcasedrive = "Y";
  }
elsif ( $host eq "roo" or $host eq "floyd" )
  {
    $webpath = "c:\\cpp\\tc${Major}${Minor}${Point}\\topclass\\oracle\\topclass\\www";
  }
else
  {
    $webpath = "c:\\TopClass$Major.$Minor.$Point\\builds\\build$Build\\Windows\\Webable";
  }

my $tcver = "tc$Major$Minor$Point";
my $tcdir = "tc$Major$Minor$Point";

if ( $Build ne "" )
  {
    $tcdir = $tcver . "b" . $Build;
  }

if ( $clearcasedrive eq "Y" )
  {
    if ( $Build ne "" )
      {
        print "Can't specify build for a clearcase drive\n";
        exit;
      }
    $tcdir = $tcdir . "cc";
  }

my $cmd;

$cmd = "$adsutil CREATE W3SVC/1/Root/$tcdir IIsWebVirtualDir";

print "adsutil CREATE W3SVC/1/Root/$tcdir IIsWebVirtualDir\n";

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
        elsif ( /Error creating the object: W3SVC\/1\/Root\/$tcdir/ )
          {
          }
        else
          {
            print;
          }
      }
  }

sub IISSetPropertyAux( $$$ )
  {
    my ($path, $property, $value) = @_;

    my $args = "SET $path/$property $value";
    my $cmd = "$adsutil $args";
    print "adsutil $args\n";

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
            #elsif ( /Error creating the object: $path/ )
            #  {
            #  }
            elsif ( /([^ ]+) +: \((.*)\) "(.*)"/ )
              {
                if ( $1 eq $property and $3 ne $value and ($property =~ /Password/i) )
                  {
                  }
                elsif ( $1 ne $property or $3 ne $value )
                  {
                    print "$1 ne $property or $3 ne $value\n";
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
                    print "$1 ne $property or $3 ne $value\n";
                    print;
                  }
              }
            else
              {
                print "else\n";
                print;
              }
          }
      }
  }

sub IISSetProperty( $$$ )
  {
    my ( $path, $prop, $value ) = @_;
    # Ensure that $path should include a leading /
    if ( ! $path =~ /^\// )
      {
        die "IISSetProperty($path,$prop,$value) path must include leading /\n";
      }
    return IISSetPropertyAux( "/W3SVC/1/Root$path", $prop, $value );
  }

#C:\bin>c:\inetpub\adminscripts\adsutil.vbs get W3SVC/1/Root/Path
#IIsObjectPath: IIS://localhost/W3SVC/1/Root
#Path                            : (STRING) "c:\inetpub\wwwroot"
#
#C:\bin>adsutil ENUM W3SVC/1/Root

sub findWeb( $ )
  {
    #print "findWeb( @_ )\n";
    my ($filedir) = @_;

    my $cmd = "$adsutil ENUMALL W3SVC/1/Root";

    #print "adsutil ENUMALL W3SVC/1/Root\n";

    my $msg;
    my $url;
    my $CurItem = "/"; # might be in the root.
    my $CurType;
    my $CurRoot;
    my $CurIsol;
    my $prvItem;
    my $prvType;
    my $prvRoot;
    my $prvIsol;
    my $cmdout;
    if ( open( cmdout, "$cmd |" ) )
      {
        my @x = <cmdout>;
        foreach ( @x )
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /\[\/W3SVC\/1\/Root(\/.+)\]/ )
              {
                $CurItem = $1;
                $CurType = "";
                $CurRoot = "";
                $CurIsol = "";
              }
            elsif ( /KeyType\s+: \(STRING\) \"([^"]+)\"/ ) #"
              {
                $CurType = $1;
              }
            elsif ( /AppRoot\s+: \(STRING\) \"([^"]+)\"/ ) #"
              {
                $CurRoot = $1;
              }
            elsif ( /AppIsolated\s+: \(INTEGER\) ([0-9]+)/ )
              {
                $CurIsol = $1;
              }
            elsif ( /Path\s+: \(STRING\) \"([^"]+)\"/ ) #"
              {
                #print $_;
                my $path = $1;
                my $qpath = quotemeta( $path );
                if ( $path ne "" and $filedir =~ /^$qpath\\?(.*)/  )
                  {
                    #print $_;
                    my $subpath = $1;
                    $subpath =~ s!\\!/!g;
                    #print "path [$path]\n";
                    if ( $subpath ne "" )
                      {
                        if ( $url ne "" )
                          {
                            if ( $msg eq "" )
                              {
                                $msg = "Multiple matches: $url"
                              }
                            $msg = "$msg, $CurItem/$subpath";
                          }
                        $url = "$CurItem/$subpath";
                      }
                    else
                      {
                        if ( $url ne "" )
                          {
                            if ( $msg eq "" )
                              {
                                $msg = "Multiple matches: $url"
                              }
                            $msg = "$msg, $CurItem";
                          }
                        $url = "$CurItem";
                      }
                    #print "\$prvItem: $prvItem\n";
                    #print "\$prvIsol: $prvIsol \$CurIsol: $CurIsol\n";

                    if ( $prvItem ne "" )
                      {
                        #print "Multiple matches: $prvItem and $CurItem\n";
                        if ( $prvIsol ne $CurIsol )
                          {
                            my $err = "Isolation differs $prvItem ($prvIsol) and $CurItem ($CurIsol)";
                            print "ERROR: $err\n";
                            SetConfig( "errors", $err );
                          }
                        if ( $prvIsol ne "0" )
                          {
                            my $err = "Isolation should be low unless a stub is used";
                            print "ERROR: $err\n";
                            SetConfig( "errors", $err );
                            print "IISSetProperty( $prvItem, \"AppIsolated\", 0 )\n";
                            if ( $Grant eq "y" )
                              {
                                IISSetProperty( $prvItem, "AppIsolated", "0" );
                              }
                          }
                        if ( $CurIsol ne "0" )
                          {
                            my $err = "Isolation should be low unless a stub is used";
                            print "ERROR: $err\n";
                            SetConfig( "errors", $err );
                            print "IISSetProperty( $CurItem, \"AppIsolated\", 0 )\n";
                            if ( $Grant eq "y" )
                              {
                                IISSetProperty( $CurItem, "AppIsolated", "0" );
                              }
                          }
                      }
                    $prvItem = $CurItem;
                    $prvType = $CurType;
                    $prvRoot = $CurRoot;
                    $prvIsol = $CurIsol;

                  }
              }
            else
              {
                #print;
              }
          }
      }
    if ( $msg )
      {
        print "WARNING: $msg\n";
        SetConfig( "warnings", $msg );
      }
    return $url;
  }


sub IISGetPropertyAux( $$$ )
  {
    my ( $path, $prop, $up ) = @_;

    if ( $path eq "" or $prop eq "" )
      {
        print "Invalid call to IISGetPropertyAux($path,$prop,$up)\n";
        return;
      }
    my $cmd = "$adsutil GET $path/$prop";

    #print "adsutil GET $path/$prop\n";

    my $CurItem;
    my $CurType;
    my $cmdout;
    if ( open( $cmdout, "$cmd |" ) )
      {
        my @x = <$cmdout>;
        close ($cmdout);
        foreach ( @x )
          {
            if ( /^$/ )
              {
                #print;
              }
            elsif ( /\[(\/.+)\]/ )
              {
                $CurItem = $1;
                $CurType = "";
              }
            elsif ( /$prop\s+: \([A-Z]+\) \"([^"\n]+)\"/ ) #"
              {
                return $1;
              }
            elsif ( /$prop\s+: \([A-Z]+\) ([^"\n]+)/ ) #"
              {
                return $1;
              }
            elsif ( /IIsObjectPath: IIS:\/\/localhost\/W3SVC/ ||
                    /The path requested could not be found/ ||
                    /ErrNumber: -2147024893 \(0x80070003\)/ ||
                    /Error Trying To GET the Object \(GetObject Failed\): W3SVC/ ||
                    /The parameter "$prop" is not set at this node./ ||
                    /ErrNumber: -2147463162 \(0x80005006\)/ ||
                    /Error Trying To GET the property: \(Get Method Failed\) $prop/ ||
                    /\(This property is probably not allowed at this node\)/
                  )
              {
                if ( $path =~ /^(.+)\/[^\/]+/ && $up ne "N" )
                  {
                    return IISGetPropertyAux( $1, $prop );
                  }
              }
            else
              {
                print;
              }
          }
      }
#IIsObjectPath: IIS://localhost/W3SVC/1/Root/tc724/tce724iis.dll
#The path requested could not be found.
#     C:\bin>c:\inetpub\adminscripts\adsutil.vbs get W3SVC/1/Root/topclass/topclass.dll/AppIsolated
# IIsObjectPath: IIS://localhost/W3SVC/1/Root/topclass/topclass.dll
#The path requested could not be found.
#ErrNumber: -2147024893 (0x80070003)
#Error Trying To GET the Object (GetObject Failed): W3SVC/1/Root/topclass/topclass.dll
}

sub IISCreateDirectory( $ )
  {
    my ($dir) = @_;
    IISCreateDirAux( $dir, "IIsWebDirectory" )
  }

sub IISCreateVirtualDir( $ )
  {
    my ($dir) = @_;
    IISCreateDirAux( $dir, "IIsWebVirtualDir" )
  }

sub IISCreateDirAux( $$ )
  {
    my ($dir, $type) = @_;

    my $cmd = "$adsutil CREATE W3SVC/1/Root$dir $type";

    #print "adsutil CREATE W3SVC/1/Root$dir $type\n";

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
            elsif ( /Error creating the object: / )
              {
              }
            else
              {
                print;
              }
          }
      }
  }

sub IISCreateFile( $ )
  {
    my ($dir) = @_;

    my $cmd = "$adsutil CREATE W3SVC/1/Root$dir IIsWebFile";

    #print "adsutil CREATE W3SVC/1/Root$dir IIsWebFile\n";

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
            elsif ( /Error creating the object: / )
              {
              }
            else
              {
                print;
              }
          }
      }
  }

sub checkExe( $$ )
  {
    my ($inst, $what) = @_;

    my $user;
    my $iusr;
    my $iwam;
    my $n = $config{$what};
    if ( $Grant eq "y" )
      {
        #IISCreateFile( $config{url} . "/" . $n );
      }

    my $isolated = IISGetProperty( $config{url}, "AppIsolated" );
    if ( $isolated eq 0 )
      {
        $isolated = "low";
      }
    elsif ( $isolated eq 1 )
      {
        $isolated = "high";
      }
    elsif ( $isolated eq 2 )
      {
        $isolated = "medium";
      }
    SetConfig( "$what-appisolated", $isolated );

    my $execute = IISGetProperty( $config{url}, "AccessExecute" );
    if ( lc $execute ne "true" and $Grant eq "y" )
      {
        IISSetProperty( $config{url}, "AccessExecute", "True" );
        $execute = IISGetProperty( $config{url}, "AccessExecute" );
      }
    SetConfig( "$what-accessexecute", $execute );
    my $anon = IISGetProperty( $config{url} . "/" . $n, "AuthAnonymous" );
    SetConfig( "$what-authanonymous", $anon );

    $iusr = IISGetProperty( $config{url} . "/" . $n, "AnonymousUserName" );
    SetConfig( "$what-anonymoususername", $iusr );

    $iwam = IISGetPropertyAux( "/W3SVC", "WAMUserName", "N" );
    SetConfig( "$what-wamusername", $iwam );

    # anonymous user only used in low isolation...

    #print "if ( lc $anon eq \"true\" and $isolated eq \"low\" )\n";
    if ( lc $anon eq "true" and $isolated eq "low" )
      {
        #print "iwam will be system\n";
        $user = $iusr;
        $iwam = "SYSTEM";
      }
    else
      {
        $user = $iwam;
      }

    if ( $what eq "stub" )
      {
        checkUserAccess($inst, $what, $user);
      }
    else
      {
        checkUserAccess($inst, $what, $iusr);
        checkUserAccess($inst, $what, $iwam);
      }
  }

sub checkUserAccess( $$$ )
  {
    my ($inst, $what, $user) = @_;

    # need to check the exes.. otherwise won't look in correct place..
    # has the stub got read access to the registry...
    my $access = ( $what eq "stub" ) ? "KEY_READ" : "full";
    my $hasAccess = CheckAccess( "reg", "$TopClassKey/$inst", $user, $access, $Grant );
    if ( $hasAccess )
      {
        SetConfig( "$user-reg-access", $hasAccess );
      }
    else
      {
        SetConfig( "errors", "$user does not appear to have $access access to the registry" );
      }

    if ( $what eq "dll" )
      {
        # check full access to the webable...
        if ( !$config{web} )
          {
            SetConfig( "errors", "Webable folder not specified" );
          }
        elsif ( -d $config{web} )
          {
            my $hasAccess = CheckAccess( "file", $config{web}, $user, "full", $Grant );
            if ( $hasAccess )
              {
                SetConfig( "$user-web-access", $hasAccess );
              }
            else
              {
                SetConfig( "errors", "$user does not appear to have $access access to the webable folder" );
              }
          }
        else
          {
            SetConfig( "errors", "Webable folder not found" );
          }

        # check full access to the non-webable...
        if ( !$config{nonweb} )
          {
            SetConfig( "errors", "Non-webable folder not specified" );
          }
        elsif ( -d $config{nonweb} )
          {
            my $hasAccess = CheckAccess( "file", $config{nonweb}, $user, "full", $Grant );
            if ( $hasAccess )
              {
                SetConfig( "$user-nonweb-access", $hasAccess );
              }
            else
              {
                SetConfig( "errors", "$user does not appear to have $access access to the non-webable folder" );
              }
          }
        else
          {
            SetConfig( "errors", "Non-webable folder not found" );
          }
        if ( $CrystalRoot )
          {
            my $hasAccess = CheckAccess( "reg", "$CrystalKey", $user, "full", $Grant );
            if ( $hasAccess )
              {
                SetConfig( "$user-crystal-reg-access", $hasAccess );
              }
            else
              {
                SetConfig( "errors", "$user does not appear to have $access access to the crystal registry" );
              }
            my $crystalDir = "c:/Program Files/Crystal Decisions";
            if ( !-d $crystalDir )
              {
                SetConfig( "errors", "Crystal directory [$crystalDir] not found" );
              }
            else
              {
                my $hasAccess = CheckAccess( "file", $crystalDir, $user, "full", $Grant );
                if ( $hasAccess )
                  {
                    SetConfig( "$user-crystal-dir-access", $hasAccess );
                  }
                else
                  {
                    SetConfig( "errors", "$user does not appear to have $access access to the crystal directory" );
                  }
              }
          }
        else
          {
            SetConfig( "errors", "Crystal Registry Root [$CrystalKey] not found" );
          }
      }
  }

sub IISGetProperty( $$$ )
  {
    my ( $path, $prop, $up ) = @_;
    # Ensure that $path should include a leading /
    if ( ! $path =~ /^\// )
      {
        die "IISGetProperty($path,$prop) path must include leading /\n";
      }
    return IISGetPropertyAux( "/W3SVC/1/Root$path", $prop, $up )
  }


