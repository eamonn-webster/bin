use strict;
use Getopt::Std;

my $config = "debug";
my $suffix = "_dbg";
my $execute = 1;

my %opts = ( r => undef(),
             x => undef(),
             t => undef(),
             p => undef(),
           );

if ( !getopts("rxtp", \%opts) or @ARGV > 1 ) {
}

my $topclass = $opts{t};
my $publisher = $opts{p};

if ( !$topclass and !$publisher ) {
  $topclass = 1;
}

if ( defined( $opts{r} ) ) {
    $config = "release";
    $suffix = "";
  }

if ( defined( $opts{x} ) ) {
    $execute = undef;
  }

sub run($) {
  my ($cmd) = @_;
  print "$cmd\n";
  if ( $execute ) {
    system( $cmd );
  }
}

if ( $topclass ) {
  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\oHtmlParser\\$config", "\\topclass\\oracle\\topclass\\oHtmlParser\\$config\\oHtmlParser.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\alerts\\$config", "\\topclass\\oracle\\topclass\\alerts\\$config\\alerts.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\player\\$config", "\\topclass\\oracle\\topclass\\player\\$config\\PlayerDlg.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\Neo\\$config\\ent\\exe", "\\topclass\\oracle\\topclass\\Neo\\$config\\ent\\exe\\Neo.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\Neo\\$config\\ent\\dll", "\\topclass\\oracle\\topclass\\Neo\\$config\\ent\\dll\\Neo.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\Neo\\$config\\std\\exe", "\\topclass\\oracle\\topclass\\Neo\\$config\\std\\exe\\Neo.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\$config\\ent\\exe", "\\topclass\\oracle\\topclass\\www\\tce800ud$suffix.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\ent\\dll", "\\topclass\\oracle\\topclass\\www\\tce800u$suffix.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\plugins\\$config\\aicc", "\\topclass\\oracle\\plugins\\$config\\aicc\\AICC.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\Centra", "\\topclass\\oracle\\plugins\\$config\\Centra\\CentraPlugin.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\NETg", "\\topclass\\oracle\\plugins\\$config\\NETg\\NETg.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\SCORM", "\\topclass\\oracle\\plugins\\$config\\SCORM\\SCORM.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\Sync", "\\topclass\\oracle\\plugins\\$config\\Sync\\Sync.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\SyncServer", "\\topclass\\oracle\\plugins\\$config\\SyncServer\\SyncServer.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\batch", "\\topclass\\oracle\\plugins\\$config\\batch\\batch.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\catreg", "\\topclass\\oracle\\plugins\\$config\\catreg\\catreg.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\completion", "\\topclass\\oracle\\plugins\\$config\\completion\\completion.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\exportraw", "\\topclass\\oracle\\plugins\\$config\\exportraw\\exportraw.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\haha", "\\topclass\\oracle\\plugins\\$config\\haha\\haha.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\online", "\\topclass\\oracle\\plugins\\$config\\online\\online.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\reports", "\\topclass\\oracle\\plugins\\$config\\reports\\reports.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\syncLDAP", "\\topclass\\oracle\\plugins\\$config\\syncLDAP\\syncLDAP.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\ws", "\\topclass\\oracle\\plugins\\$config\\ws\\ws.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\xmlinterface", "\\topclass\\oracle\\plugins\\$config\\xmlinterface\\XMLInterface.bsc", "y" );
  pfs( "\\topclass\\oracle\\plugins\\$config\\xmltest", "\\topclass\\oracle\\plugins\\$config\\xmltest\\xmltest.bsc", "y" );


  # pfs \topclass\oracle\topclass\Neo\$config\ent\exe \topclass\oracle\topclass\Neo\$config\ent\exe\Neo.bsc y

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\release\\isapi", "\\topclass\\oracle\\topclass\\www\\isapistub.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\$config\\dragdrop", "\\topclass\\oracle\\topclass\\www\\qpi\\dragdrop.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\pickone", "\\topclass\\oracle\\topclass\\www\\qpi\\pickone.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\boolqpi", "\\topclass\\oracle\\topclass\\www\\qpi\\boolqpi.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\mca", "\\topclass\\oracle\\topclass\\www\\qpi\\mca.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\mco", "\\topclass\\oracle\\topclass\\www\\qpi\\mco.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\text", "\\topclass\\oracle\\topclass\\www\\qpi\\text.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\mfill", "\\topclass\\oracle\\topclass\\www\\qpi\\mfill.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\listm", "\\topclass\\oracle\\topclass\\www\\qpi\\listm.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\boolWithReasonQPI", "\\topclass\\oracle\\topclass\\www\\qpi\\boolWithReasonQPI.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\img", "\\topclass\\oracle\\topclass\\www\\qpi\\img.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\upload", "\\topclass\\oracle\\topclass\\www\\qpi\\upload.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\check", "\\topclass\\oracle\\topclass\\www\\qpi\\check.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\varitext", "\\topclass\\oracle\\topclass\\www\\qpi\\varitext.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\variimage", "\\topclass\\oracle\\topclass\\www\\qpi\\variimage.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\scormq", "\\topclass\\oracle\\topclass\\www\\qpi\\scormq.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\$config\\ntufl", "\\topclass\\oracle\\topclass\\www\\spi\\ntufl.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\basic", "\\topclass\\oracle\\topclass\\www\\spi\\basic.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\cookie", "\\topclass\\oracle\\topclass\\www\\spi\\cookie.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\ldap", "\\topclass\\oracle\\topclass\\www\\spi\\ldap.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\oraclesso", "\\topclass\\oracle\\topclass\\www\\spi\\oraclesso.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\sapsso", "\\topclass\\oracle\\topclass\\www\\spi\\sapsso.bsc", "y" );
  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\$config\\tcodbc", "\\topclass\\oracle\\topclass\\www\\tcodbc.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\tcoci", "\\topclass\\oracle\\topclass\\www\\tcoci.bsc", "y" );

  print "\n";
  pfs( "\\topclass\\oracle\\topclass\\$config\\pound", "\\topclass\\oracle\\topclass\\www\\pound.bsc", "y" );
  pfs( "\\topclass\\oracle\\topclass\\$config\\mobile", "\\topclass\\oracle\\topclass\\www\\mobile.bsc", "y" );
}
if ( $publisher ) {
  print "\n";
  pfs( "\\authoring\\utilities\\tcbase64\\tcbase64mod\\$config", "\\authoring\\utilities\\tcbase64\\tcbase64mod\\$config\\tcbase64mod.bsc", "y" );
  pfs( "\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\$config", "\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\$config\\tcpowerpointdoccommod.bsc", "y" );
  pfs( "\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\$config", "\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\$config\\TCServerDacMod.bsc", "y" );
  pfs( "\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\$config", "\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\$config\\tcworddoccommod.bsc", "y" );
  pfs( "\\authoring\\utilities\\htmlclean\\$config", "\\authoring\\utilities\\htmlclean\\$config\\htmlclean.bsc", "y" );
  pfs( "\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\$config", "\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\$config\\tcSCORMdoccom.bsc", "y" );
  pfs( "\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\$config", "\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORM12Import\\$config\\tcSCORM12Import.bsc", "y" );
  pfs( "\\authoring\\utilities\\tchtmlgenerate\\$config", "\\authoring\\utilities\\tchtmlgenerate\\$config\\tchtmlgenerate.bsc", "y" );
  pfs( "\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\$config", "\\authoring\\utilities\\SCORM\\scorm1.2\\tcSCORMExport\\$config\\tcSCORMExport.bsc", "y" );
  pfs( "\\authoring\\utilities\\AICC\\tcAICCdoccom\\$config", "\\authoring\\utilities\\AICC\\tcAICCdoccom\\$config\\tcAICCdoccom.bsc", "y" );
  pfs( "\\authoring\\utilities\\AICC\\TcAICCExport\\$config", "\\authoring\\utilities\\AICC\\TcAICCExport\\$config\\TcAICCExport.bsc", "y" );
  pfs( "\\authoring\\utilities\\tclangreader\\$config", "\\authoring\\utilities\\tclangreader\\$config\\tclangreader.bsc", "y" );
  pfs( "\\authoring\\utilities\\tccomverter\\$config", "\\authoring\\utilities\\tccomverter\\$config\\tccomverter.bsc", "y" );
  pfs( "\\authoring\\utilities\\tcqpimgr\\$config", "\\authoring\\utilities\\tcqpimgr\\$config\\tcqpimgr.bsc", "y" );
  pfs( "\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\$config", "\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\$config\\TCPlugDacMod.bsc", "y" );
  pfs( "\\authoring\\assistant\\tcmetadatamod\\$config", "\\authoring\\assistant\\tcmetadatamod\\$config\\metadllmod.bsc", "y" );
  pfs( "\\authoring\\TCPublisher\\$config", "\\authoring\\TCPublisher\\$config\\SSCE5332U.bsc", "y" );
  pfs( "\\authoring\\utilities\\Scorm2Plug\\$config", "\\authoring\\utilities\\Scorm2Plug\\$config\\Scorm2Plug.bsc", "y" );
}

sub pfs($$$) {
  #print "\n\npfs\n";
  my @bsc_s; # stat for the single .bsc file.

  my ($objdir, $bsc, $change) = @_;

  if ( $bsc eq "" || $bsc eq "." ) {
    $bsc = "$objdir\\*.bsc";
  }

  print "$bsc\n";

  my $bsc9;
  if ( -e $bsc ) {
    @bsc_s = stat( $bsc );
    $bsc9 = $bsc_s[9];
    printf "%12d %8d %-40s\n", $bsc_s[9], $bsc_s[7], $bsc if ( "@bsc_s" ne "" );
  }
  else {
    while ( glob($bsc) ) {
      #print $_ . "\n";
      @bsc_s = stat( $_ );
      $bsc9 = $bsc_s[9];
      printf "%12d %8d %-40s\n", $bsc_s[9], $bsc_s[7], $_ if ( "@bsc_s" ne "" );
      last;
    }
  }

  if ( $bsc9 ne "" ) {
    # loop through the
    my $pattern;
    if ( $bsc =~ /\.bsc$/ ) {
      $pattern = "$objdir\\*.sbr";
    }
    else {
      $pattern = "$objdir\\*.obj";
    }
    print "$pattern\n";
    while ( glob( $pattern ) ) {
      #print $_ . "\n";
      my @s = stat( $_ );
      #print "$s[8] $s[9] $s[10] $_ @s\n";
      if ( $s[9] > $bsc9 ) {
        if ( $s[7] eq 0 ) {
          if ( $change eq "y" ) {
            printf "changing %12d %8d %-40s\n", $s[9], $s[7], $_ ;
            utime $s[8], $bsc9, ($_) ;
          }
          else {
            printf "would change %12d %8d %-40s\n", $s[9], $s[7], $_ ;
          }
        }
        else {
          printf "%12d %8d %-40s\n", $s[9], $s[7], $_ ;
        }
      }
    }
  }
}

