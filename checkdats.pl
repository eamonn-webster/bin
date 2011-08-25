#
#  File: checkdats.pl
#  Author: eweb
#  Copyright eweb, 1998-2006
#  Contents: Check whether .dat files have the correct headers.
#
#  Date:          Author:  Comments:
#

use strict;
use File::Basename;

my %StringSets =
 (
    aiccstrs => "cpi_AICC",
    basicstrings => "spi_basic",
    batchstrs => "cpi_Batch",
    boolstrings => "qpi_Boolean",
    catregstrs => "cpi_CatReg",
    centrapluginstr => "cpi_Centra",
    checkstrings => "qpi_Check",
    competenciesstrs => "cpi_Competencies",
    completionstrs => "cpi_completion",
    cookiestrings => "spi_cookie",
    dragdropstrings => "qpi_draganddrop",
    exportrawstrs => "cpi_exportraw",
    imgstrings => "qpi_ImageMap",
    ldapstrings => "spi_ldap",
    listmstrings => "qpi_ListMatching",
    mcastrings => "qpi_MCA",
    mcostrings => "qpi_MCObjs",
    mfillstrings => "qpi_mfill",
    netgstrs => "cpi_NETg",
    ntuflstrings => "spi_ntufl",
    onlinestrs => "cpi_Online",
    pickonestrings => "qpi_PickOne",
    reportstrs => "cpi_reports",
    scormstrings => "cpi_scorm",
    siteminderstrings => "spi_siteminder",
    strings => "topclass_server",
    syncLDAPstrs => "cpi_syncLDAP",
    syncserverstrs => "cpi_SyncServer",
    syncstrs => "cpi_Sync",
    textstrings => "qpi_Text",
    uploadstrings => "qpi_Upload",
    userstrs => "user",
    xmlifstrs => "cpi_xmlif",
 );

my %Languages =
  (
    uk => "1,uk,ukenglish,UKEnglish,UK English",
    us => "2,us,usenglish,USEnglish,US English",
    fr => "3,fr,french,Français,Français",
    de => "4,de,german,Deutsch,Deutsch",
  );

sub CheckDatFile( $ )
{
  my ($full) = @_;
  my $file = basename($full);
  my $dir  = dirname($full);
  my $ss;
  my $iso;
  if ( $file =~ /^(.*)_(..)\.dat$/ )
    {
      $ss = $1;
      $iso = $2;
    }
  elsif ( $file =~ /^(.*)\.(..)\.dat$/ )
    {
      $ss = $1;
      $iso = $2;
    }
  elsif ( $file =~ /^(.*)_(abc)\.dat$/ )
    {
      $ss = $1;
      $iso = $2;
    }
  elsif ( $file =~ /^(.*)\.dat$/ )
    {
      $ss = $1;
      #$iso = $2;
      $iso = "us";
    }
  #print "iso: $iso ss: $ss\n";
  if ( open( DAT, $full ) )
    {
      my @strs = <DAT>;
      close( DAT );
      #if ( $strs[0] !~ /^;/ )
        {
          my $language = $Languages{$iso};
          my $stringSet = $StringSets{$ss};
          if ( $language and $stringSet )
            {
              if ( open( DAT, ">$full.new" ) )
                {
                  my ( $langno, $langcode, $langid, $langname, $langdisplay ) = split(/,/, $language );

                  my $fn = "${stringSet}_${langid}.lang";
                  print DAT ";Filename=${fn}\n";
                  print DAT ";Comment=${langdisplay}\n";
                  print DAT ";Language=${langname}\n";
                  print DAT ";LanguageNumber=${langno}\n";
                  foreach my $str ( @strs )
                    {
                      if ( $str !~ /^;/ )
                        {
                          print DAT $str;
                        }
                    }
                  close( DAT );
                  unlink( "$full.old" );
                  rename( $full, "$full.old" );
                  rename( "$full.new", $full );
                }
            }
        }
    }
}
sub GenLangFiles($$$)
{
  my ($BinDir, $ViewDriveName, $UnicodeBuild) = @_;

  my $SourceDir = "$ViewDriveName/topclass/oracle/topclass/languages";
  my $DestDir = "$ViewDriveName/topclass/oracle/topclass/www/language";

  if ( !-d $DestDir )
    {
      mkdir( $DestDir );
    }
  #my $curDir =  getcwd();
  #chdir( $DestDir ) or die "Can't change to $DestDir\n";

  #StartDiv( "GenLangFiles", "Generating .lang and .labels" );

  my $LangUtils = "langutils";
  if ( $UnicodeBuild eq "Y" )
    {
      $LangUtils = $LangUtils . " -u";
    }
  $LangUtils =~ s!/!\\!g;              # do slashes

  if ( opendir( DIR, $SourceDir ) )
    {
      #print "<pre>\n";
      my $file;
      my $Cmd;
      my $CmdOut;
      while ( defined( $file = readdir(DIR) ) )
        {
          my $full = "$SourceDir/$file";
          $full =~ s!/!\\!g;              # do slashes
          if ( $file =~ /langrps\.dat$/ ) {
            #print "$file\n";
          }
          elsif ( $file =~ /\.dat$/ ) {
            #print "$file\n";
            CheckDatFile( $full );
          }
        }
      closedir(DIR);
      #print "</pre>\n";
    }
  else
    {
      print "can't open directory $SourceDir\n";
    }

  #EndDiv( "GenLangFiles", 1 );
  #chdir( "$BinDir" );
  #chdir( $curDir );
}

my $Unicode = $ARGV[0];
if ( $Unicode eq "" )
  {
    $Unicode = "Y";
  }
GenLangFiles( "", "", $Unicode );

