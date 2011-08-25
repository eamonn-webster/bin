#******************************************************************************
#
#  File: upvers.pl
#  Author: eweb
#  Copyright WBT Systems, 2005-2006
#  Contents: Updating version numbers in .dsp
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 27th Mar 2006  eweb     Major minor & point.

use strict;

# do we search for an exact match and increment or do we take a more generic approach?

#cgi.dsp           tc(e|s)$M$N$Pcgi[_dbg]\.exe
#isapistub.dsp     tc(e|s)$M$N$Piis[_dbg]\.dll
#CgiClient.dsp     tc(e|s)$M$N$Pcgi[_dbg]\.exe
#iPlanet40API.dsp  tc(e|s)$M$N$PiP[_dbg]\.dll
#mobile.dsp        tcm$M$N$Pu[_dbg]\.exe
#topclass.dsp      tce$M$N$Pu[d][_dbg]\.(exe|dll)
#convdll.dsp       conv$M$N$Pu[_dbg]\.dll
#tcstandard.dsp    tcs$M$N$Pu[d][_dbg]\.(exe|dll)

my $drive = $ARGV[0];
my $MNP = $ARGV[1];

my $VerifiedClearcase = "N";
my $UseClearcase = "Y";
my $cctool = "cleartool";

sub verifyClearcase()
  {
    if ( $VerifiedClearcase eq "N" and $UseClearcase eq "Y" )
      {
        $cctool = "cleartool";
        my $desc = `$cctool desc -fmt \"[%m]\" "\\topclass"`;
        if ( $desc eq "[**null meta type**]" )
          {
            print "Not a clearcase drive\n";
            $cctool = "";
            $UseClearcase = "N";
          }
        elsif ( $desc eq "[directory version]" )
          {
            print "Is a clearcase drive\n";
            $UseClearcase = "Y";
          }
        elsif ( $desc eq "" )
          {
            print "Looks like we don't have cleartool\n";
            $cctool = "";
            $UseClearcase = "N";
          }
        $VerifiedClearcase = "Y";
      }
  }

sub CheckIn($$)
  {
    my ($file, $comment) = @_;

    my $cmd = "$cctool ci -c \"$comment\" $file";
    print "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won't create version with data identical to predecessor./ )
      {
        # hasn't changed so undo the check out.
        $cmd = "$cctool unco -rm $file";
        $results = $results . "\n" . $cmd . "\n" . `$cmd 2>&1`;
      }
    elsif ( $results =~ /Error: Not an element:/ )
      {
        # Not an element
      }
    elsif ( $results =~ /Error:/ )
      {
        # Not an element
      }
    else
      {
        # Not an element
      }
    print "$results\n";
  }

sub CheckOut($$)
  {
    my ($file, $comment) = @_;

    my $cmd = "$cctool co -c \"$comment\" $file";

    print "$cmd\n";

    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: Element "(.+)" is already checked out to view "(.+)"/ )
      {
      }
    elsif ( $results =~ /Error: Not a vob object:/ )
      {
        # Not an element
      }
    elsif ( $results =~ /Error: / )
      {
      }

    print "$results\n";
  }

sub processOneDsp( $ )
  {
    my ($dsp) = @_;
    if ( -e $dsp )
      {
        if ( open( DSPOUT, ">$dsp.new" ) )
          {
            my $changed = 0;
            if ( open( DSP, $dsp ) )
              {
                while ( <DSP> )
                  {
                    chomp;
                    my $line = $_;
                    if ( $line =~ /([a-z]+)([0-9]{3})([a-z_A-Z0-9]*)\.([a-z]{3})/ )
                      {
                        my $prefix = $1;
                        my $vernum = $2;
                        my $suffix = $3;
                        my $extens = $4;
                        if ( $vernum ne $MNP )
                          {
                            print "$vernum: $prefix$vernum$suffix\.$extens\n";
                            $line =~ s/([a-z]+)([0-9]{3})([a-z_A-Z0-9]*)\.([a-z]{3})/\1$MNP\3\.\4/g;
                            $changed = 1;
                          }
                      }
                    print DSPOUT "$line\n";
                  }
                close( DSP );
              }
            close( DSPOUT );
            if ( $changed == 0 )
              {
                unlink "$dsp.new";
              }
            else
              {
                CheckOut( $dsp, "Updating version to $MNP" );
                unlink "$dsp.old";
                rename $dsp, "$dsp.old";
                rename "$dsp.new", $dsp;
                CheckIn( $dsp, "Updating version to $MNP" );
              }
          }
      }
  }

if ( -d "$drive\\topclass\\oracle\\topclass" )
  {
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\cgi.dsp" );  #           tc(e|s)$M$N$Pcgi[_dbg]\.exe
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\isapistub.dsp" );  #     tc(e|s)$M$N$Piis[_dbg]\.dll
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\CgiClient.dsp" );  #     tc(e|s)$M$N$Pcgi[_dbg]\.exe
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\iPlanet40API.dsp" );  #  tc(e|s)$M$N$PiP[_dbg]\.dll
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\mobile.dsp" );  #        tcm$M$N$Pu[_dbg]\.exe
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\topclass.dsp" );  #      tce$M$N$Pu[d][_dbg]\.(exe|dll)
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\convdll.dsp" );  #       conv$M$N$Pu[_dbg]\.dll
    processOneDsp( "$drive\\topclass\\oracle\\topclass\\tcstandard.dsp" );  #    tcs$M$N$Pu[d][_dbg]\.(exe|dll)
  }
if ( -d "$drive\\topclass\\neo" )
  {
    processOneDsp( "$drive\\topclass\\neo\\cgi.dsp" );  #           tc(e|s)$M$N$Pcgi[_dbg]\.exe
    processOneDsp( "$drive\\topclass\\neo\\isapistub.dsp" );  #     tc(e|s)$M$N$Piis[_dbg]\.dll
    processOneDsp( "$drive\\topclass\\neo\\CgiClient.dsp" );  #     tc(e|s)$M$N$Pcgi[_dbg]\.exe
    processOneDsp( "$drive\\topclass\\neo\\topclass.dsp" );  #      tce$M$N$Pu[d][_dbg]\.(exe|dll)
    processOneDsp( "$drive\\topclass\\neo\\convdll.dsp" );  #       conv$M$N$Pu[_dbg]\.dll
  }
