use strict;


my $oldDir = "b:\\TopClassV8.0.0\\builds\\build030";
my $newDir = "b:\\TopClassV8.0.0\\builds\\build032";

my $cmd = "diff --brief --recursive \"$oldDir\" \"$newDir\"";

if ( open( DIFFS, "$cmd 2>&1 |" ) ) {
  my $qmOldDir = quotemeta( $oldDir );
  my $qmNewDir = quotemeta( $newDir );
  while ( <DIFFS> ) {

    chomp;
    my $status;
    my $file;

    if ( m!^Files $qmOldDir/(.+) and $qmNewDir/(.+) differ! ) {
      if ( $1 ne $2 ) {
          $status = "HUH";
          $file = "$1 != $2";
      }
      else {
        my $oldTime = (stat("$oldDir\\$1"))[9];
        my $newTime = (stat("$newDir\\$1"))[9];
        #print "$oldDir\\$1 $oldTime $newDir\\$1 $newTime\n";

        if ( $newTime == $oldTime ) {
          $status = "DIFFER";
          $file = $1;
        }
        elsif ( $newTime < $oldTime ) {
          $status = "OLDER";
          $file = $1;
        }
        elsif ( $newTime > $oldTime ) {
          $status = "NEWER";
          $file = $1;
        }
      }
    }
    elsif ( m!^Only in $qmOldDir/?(.*): (.+)! ) {
      $status = "OLD";
      $file = "$1/$2";
      $file = "$2" if ( $1 eq "" );
    }
    elsif ( m!^Only in $qmNewDir/?(.*): (.+)! ) {
      $status = "NEW";
      $file = "$1/$2";
      $file = "$2" if ( $1 eq "" );
    }
    else {
      $status = "????";
      $file = $_;
    }
    print "$status: $file\n";
  }
  close( DIFFS );
}
else {
  print "failed to execute diff\n";
}


  if ( $DifferencesFound eq "Y" )
    {
      $PrevDiffs = 0;
      $CurrDiffs = 0;
      if ( !open (PREVLOG, ">$OnlyInPrevBuild") )
        {
          print "**** Unable to open the PrevLogFile $OnlyInPrevBuild\n";
          return;
        }
      print PREVLOG "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"  \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n";
      print PREVLOG "<html>\n<head>\n<title>Only/newer in Previous Build</title>\n";
      print PREVLOG "<link href=\"../../build.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
      print PREVLOG "</head>\n";
      print PREVLOG "<body>\n";
      print PREVLOG "<h1>Only/newer in Previous Build</h1>\n";
      print PREVLOG "<table summary=\"Table of files only in or newer in previous build\">\n";
      print PREVLOG "<tr><th class=\"component\" width=\"40%\">File</th><th class=\"component\" width=\"60%\">Status</th></tr>\n";

      if ( !open (CURRLOG, ">$OnlyInCurrBuild") )
        {
          print "**** Unable to open the CurrLogFile $OnlyInCurrBuild\n";
          return;
        }
      print CURRLOG "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"  \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n";
      print CURRLOG "<html>\n<head>\n<title>Only/newer in Current Build</title>\n";
      print CURRLOG "<link href=\"../../build.css\" rel=\"stylesheet\" type=\"text/css\" />\n";
      print CURRLOG "</head>\n";
      print CURRLOG "<body>\n";
      print CURRLOG "<h1>Only/newer in Current Build</h1>\n";
      print CURRLOG "<table summary\"Table of files only in or newer in current build\">\n";
      print CURRLOG "<tr><th class=\"component\" width=\"40%\">File</th><th class=\"component\" width=\"60%\">Status</th></tr>\n";

      open (DIFFLOG, $DiffsFilename);
      while ( $DiffFileLine = <DIFFLOG> )
        {
          if ( $DiffFileLine =~ /build$PrevBuildNoStr/ )
            {
              $PrevDiffs++;
              my ($file, $status, $crc1, $crc2) = $DiffFileLine =~ /(.*)\t(.*)\t(.*)\t(.*)/;
              #print PREVLOG "$DiffFileLine<br />";
              my $statusclass = "tagpending";
              if ( $file =~ /\.dll$/ )
                {
                  $statusclass = "tagfailure";
                }
              elsif ( $file =~ /\.exe$/ )
                {
                  $statusclass = "tagfailure";
                  if ( $status =~ /only in/ )
                    {
                      if ( $file =~ /$MajorReleaseNo$MinorReleaseNo$PointReleaseNo.*b$PrevBuildNoStr/ )
                        {
                          $statusclass = "tagsuccess";
                        }
                    }
                }
              elsif ( $file =~ /\.plb$/ )
                {
                  $statusclass = "tagfailure";
                }
              elsif ( $file =~ /\.jar$/ )
                {
                  $statusclass = "tagfailure";
                }
              elsif ( $file =~ /\.war$/ )
                {
                  $statusclass = "tagfailure";
                }
              print PREVLOG "<tr>";
              print PREVLOG "<td class=\"component\">$file</td>";
              print PREVLOG "<td class=\"$statusclass\">$status</td>";
              print PREVLOG "</tr>\n";
            }

          if ( $DiffFileLine =~ /build$CurrentBuildNoStr/ )
            {
              $CurrDiffs++;
              my ($file, $status, $crc1, $crc2) = $DiffFileLine =~ /(.*)\t(.*)\t(.*)\t(.*)/;
              #print CURRLOG "$DiffFileLine<br />";
              my $statusclass = "tagpending";
              if ( $file =~ /\.dll$/ )
                {
                  $statusclass = "tagsuccess";
                }
              elsif ( $file =~ /\.exe$/ )
                {
                  $statusclass = "tagsuccess";
                }
              elsif ( $file =~ /\.plb$/ )
                {
                  $statusclass = "tagsuccess";
                }
              elsif ( $file =~ /\.jar$/ )
                {
                  $statusclass = "tagsuccess";
                }
              elsif ( $file =~ /\.war$/ )
                {
                  $statusclass = "tagsuccess";
                }
              print CURRLOG "<tr>";
              print CURRLOG "<td class=\"component\">$file</td>";
              print CURRLOG "<td class=\"$statusclass\">$status</td>";
              print CURRLOG "</tr>\n";
            }
        }

      if ( $PrevDiffs > 0 )
        {
          print $BuildLog "<a href=\"OnlyInBuild$PrevBuildNoStr-$Year-$Month-$Day-$Hour$Min.html\">Only/newer in Previous Build</a><br />\n";
        }

      if ( $CurrDiffs > 0 )
        {
          print $BuildLog "<a href=\"OnlyInBuild$CurrentBuildNoStr-$Year-$Month-$Day-$Hour$Min.html\">Only/newer in Current Build</a><br />\n";
        }


      print PREVLOG "</table>\n";
      print PREVLOG "</body>\n";
      print PREVLOG "</html>\n";
      close PREVLOG;

      print CURRLOG "</table>\n";
      print CURRLOG "</body>\n";
      print CURRLOG "</html>\n";
      close CURRLOG;

      print "Processing of diffs file completed\n";
    }
