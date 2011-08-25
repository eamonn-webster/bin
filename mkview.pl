#!usr/bin/perl
#
# File: mkview.pl
# Author: eweb
# Copyright WBT Systems, 2003-2010
# Contents:
#
# Date:          Author:  Comments:
# 23rd Jan 2007  eweb     don't use auto, specify the args...
# 31st Aug 2007  eweb     #00008 3rd arg n to turn off username prefix
#  7th Sep 2007  eweb     #00008 domain\user is optional
# 14th Sep 2007  eweb     #00008 Determine storage location.
#  3rd Dec 2007  eweb     #00008 mkstgloc wrong.
#  1st Dec 2008  eweb     #00008 Map usernames
#  8th Jan 2009  eweb     #00008 How to set up drive mapping and restart at login
# 22nd Jan 2009  eweb     #00008 Specify msdos mode
# 23rd Feb 2010  eweb     #00008 Missing a space bewteen args
# 31st Mar 2010  eweb     #00008 2nd arg . for no drive
#  8th Apr 2010  eweb     #00008 Create storage location
# 27th May 2010  eweb     #00008 Force the use of existing folder
#  3rd Nov 2010  eweb     #00008 Grant everyone full access to the share
#  4th Nov 2010  eweb     #00008 net share /grant iff Windows 7
#  8th Nov 2010  eweb     #00008 grant access to share
# 11th Nov 2010  eweb     #00008 Don't use unc hpaths
# 30th Nov 2010  eweb     #00008 bhendrick is barry
#

use strict;

my %usernameMap = (
 lmcgettigan => "lisa",
 rgeraschenko => "rger",
 aemelyanov => "deesy",
 bhendrick => "barry",
);

my $verbose;
my $mkstgloc = "y";
my $cleartool = "cleartool";

my $user = lc $ENV{USERNAME};
if ( $usernameMap{$user} ne "" ) {
  $user = lc $usernameMap{$user};
}

my $host = lc $ENV{COMPUTERNAME};
my $domain = $ENV{USERDOMAIN};

my $name = lc $ARGV[0];
my $drive = lc $ARGV[1];
my $prefix = lc $ARGV[2];

my $view = "${user}_${name}";
if ( $prefix eq "n" )
  {
    $view = "${name}";
  }

my $ccdir;
my $ccshare;
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

my $cmd = "$cleartool lsstgloc -host ${host} -view -long";
#my $cmd = "$cleartool lsstgloc -view -long";
if ( open( CMD, "$cmd |" ) )
  {
    my ($slname, $sltype, $slregion, $sluuid, $slgpath, $slhost, $slhpath);
    while ( <CMD> )
      {
        print if ( $verbose );
        if ( /Name: (.*)/ )
          {
            if ( $slname ne "" && $sltype eq "View" )
              {
                last;
              }
            $slname = $1;
          }
        elsif ( /Type: (.*)/ )
          {
            $sltype = $1; #View
          }
        elsif ( /Region: (.*)/ )
          {
            $slregion = $1; #windows
          }
        elsif ( /Storage Location uuid: (.*)/ )
          {
            $sluuid = $1; #1657b59c.5ce14863.97a0.fd:8c:b0:5b:51:7f
          }
        elsif ( /Global path: (.*)/ )
          {
            $slgpath = $1; #\\prism\ccstg_c\views
          }
        elsif ( /Server host: (.*)/ )
          {
            $slhost = $1; #prism
            if ( lc $slhost ne $host )
              {
                print "Storage on $slhost is on a different host!\n" if ( $verbose );
                $slname = "";
                $sltype = "";
              }
          }
        elsif ( /Server host path: (.*)/ )
          {
            $slhpath = $1; #c:\ClearCase_Storage\views
          }
      }
    if ( $slname ne "" && $sltype eq "View" )
      {
        #print "$slname, $sltype, $slregion, $sluuid, $slgpath, $slhost, $slhpath\n";
        if ( $slhpath =~ /(.+)\\views/ )
          {
            $ccdir = $1;
          }
        if ( $slgpath =~ /\\\\$slhost\\([^\\]+)/ )
          {
            $ccshare = $1;
          }
        print "Found view stgloc: $slname, $slgpath, $slhpath\n";
        print "ccdir: $ccdir ccshare: $ccshare\n" if ( $verbose );
      }
  }

if ( $ccdir eq "" or $ccshare eq "" )
  {
    print "Could not determine view storage location, perhaps none defined?\n";
    print "Try:\n";

    $ccdir = "c:\\ClearCase_Storage";
    $ccshare = "ccstg_c";

    $cmd = "mkdir $ccdir\\views";
    print "$cmd\n";
    if ( $mkstgloc eq "y" ) { system( $cmd ); }

    $cmd = "net share $ccshare=$ccdir";
    if ( $Win7 )
      {
        $cmd = "$cmd /grant:wbt\\ccusers,full";
        $cmd = "$cmd /grant:wbt\\ccadmin,full";
      }
    print "$cmd\n";
    if ( $mkstgloc eq "y" ) { system( $cmd ); }
    if ( !$Win7 )
      {
        # TODO grant access to share
        print "REM grant access to share\n";
        $cmd = "setacl.exe -on \"$ccshare\" -ot shr -actn ace -ace \"n:wbt\\ccusers;p:full;s:n;i:so,sc;m:grant;w:dacl\"";
        print "$cmd\n";
        if ( $mkstgloc eq "y" ) { system( $cmd ); }

        $cmd = "setacl.exe -on \"$ccshare\" -ot shr -actn ace -ace \"n:wbt\\ccadmin;p:full;s:n;i:so,sc;m:grant;w:dacl\"";
        print "$cmd\n";
        if ( $mkstgloc eq "y" ) { system( $cmd ); }
      }

    $cmd = "$cleartool mkstgloc -view -force -host ${host}"
         . " -hpath $ccdir\\views"
         . " -gpath \\\\${host}\\${ccshare}\\views"
         . " ${host}_${ccshare}_views"
         . " \\\\${host}\\${ccshare}\\views";
    print "$cmd\n";
    if ( $mkstgloc eq "y" ) { system( $cmd ); }

    if ( $mkstgloc eq "n" ) { exit; }
  }

if ( $name ne "" )
  {
    #Usage: mkview -tag dynamic-view-tag [-tcomment tag-comment] [-tmode text-mode]
    #              [-region network-region] [-cachesize size]
    #              [-shareable_dos | -nshareable_dos]
    #              [-stream stream-selector]
    #              { -stgloc {view-stgloc-name | -auto}
    #              | [-host hostname -hpath host-stg-pname -gpath global-stg-pname]
    #                dynamic-view-storage-pname
    #              }

    if ( ! -d $ccdir )
      {
        die "Storage dir $ccdir doesn't exist\n";
      }
    else
      {
        #print "Storage dir $ccdir exists\n";
      }
    if ( ! -d "\\\\$host\\$ccshare" )
      {
        die "Storage share \\\\$host\\$ccshare doesn't exist\n";
      }
    else
      {
        #print "Storage share \\\\$host\\$ccshare exists\n";
      }

    my $viewpath = "views";
    if ( ! -d "$ccdir\\$viewpath" )
      {
        die "View root $ccdir\\$viewpath doesn't exist\n";
      }
    else
      {
        #print "View root $ccdir\\$viewpath exists\n";
      }

    my $path  = "$ccdir\\$viewpath\\$view.vws";
    my $gpath = "\\\\$host\\$ccshare\\$viewpath\\$view.vws";

    my $cmd = "$cleartool mkview -tag $view -tmode msdos -host $host -hpath $path -gpath $gpath $path";

    print "cmd: $cmd\n";

    system($cmd);

    if ( $drive ne "" && $drive ne "." )
      {
        $cmd = "net use $drive \\\\view\\$view";

        print "cmd: $cmd\n";

        system($cmd);
      }
  }

# what happens when we map the drive...

#7115  63.26958847 cleardlg.exe:3172 SetValue  HKCU\Network\L\RemotePath SUCCESS "\\view\eweb_scratch2"
#7116  63.27015686 cleardlg.exe:3172 SetValue  HKCU\Network\L\UserName SUCCESS ""
#7117  63.27134705 cleardlg.exe:3172 SetValue  HKCU\Network\L\ProviderName SUCCESS "ClearCase Dynamic Views"
#7129  63.27260971 cleardlg.exe:3172 SetValue  HKCU\Network\L\ProviderType SUCCESS 0x160000
#7137  63.27409744 cleardlg.exe:3172 SetValue  HKCU\Network\L\ConnectionType SUCCESS 0x1
#8425  64.25709534 explorer.exe:3440 SetValue  HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\##view#eweb_scratch2\BaseClass SUCCESS "Drive"

#use Win32::OLE;
#$Win32::OLE::Warn = 3;
#
## ------ SCRIPT CONFIGURATION ------
#$strDrive = '<Drive>'; # e.g. N:
#$strPath = '<Path>'; # e.g. \\rtp01\c$\temp
#$strUser = '<User>'; # e.g. AMER\rallen
#$strPassword = '<Password>';
#$boolPersistent = 1; # True = Persistent ; False = Not Persistent
## ------ END CONFIGURATION ---------
#$objNetwork = Win32::OLE->new('WScript.Network');
#$objNetwork->MapNetworkDrive($strDrive, $strPath, $boolPersistent, $strUser, $strPassword);
#print "Successfully mapped drive\n";
