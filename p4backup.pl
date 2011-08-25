#******************************************************************************
#
#  File: p4backup.pl
#  Author: eweb
#  Copyright eweb, 2007
#  Contents: Script to backup perforce.
#
#******************************************************************************
#
# Date:          Author:  Comments:
#  3rd Jul 2007  eweb     Created.
#

use strict;

my $cmd;
my $error;

# start by verifying stuff.
# computes new md5 hashes
# -q quiet unless errors.

$cmd = "p4 verify -q //...";

print "$cmd\n";
if ( open( CMD, "$cmd 2>&1 |" ) )
  {
    while ( <CMD> )
      {
        print;
        $error = 1;
      }
    close( CMD );
  }

if ( $error eq 1 )
  {
    die "ERROR: error verifying\n";
  }

# create the checkpoint
# creates a new checkpoint file and truncates the journal

$cmd = "p4d -jc";

my $number;
my $checkpoint;
my $journal;

print "$cmd\n";
if ( open( CMD, "$cmd 2>&1 |" ) )
  {
    while ( <CMD> )
      {
        if ( /Checkpointing to checkpoint.([0-9]+)\.\.\./ )
          {
            $checkpoint = "checkpoint.$1";
            $number = $1;
            print;
          }
        elsif ( /Saving journal to journal.([0-9]+)\.\.\./ )
          {
            $journal = "journal.$1";
            print;
          }
        elsif ( /Rotating journal to journal.([0-9]+)\.\.\./ )
          {
            $journal = "journal.$1";
            print;
          }
        elsif ( /Truncating journal\.\.\./ )
          {
            print;
          }
        else
          {
            $error = 1;
            print "ERROR ";
            print;
          }
      }
    close( CMD );
  }

if ( $error eq 1 )
  {
    die "ERROR: Error checkpointing\n";
  }

chdir( "c:/Program Files/Perforce" );

$cmd = "zip23 -r -o backup.$number.zip $checkpoint $journal depot";

print "$cmd\n";
if ( open( CMD, "$cmd 2>&1 |" ) )
  {
    while ( <CMD> )
      {
        if ( /adding:/ )
          {
            print;
          }
        else
          {
            print "ERROR ";
            print;
            $error = 1;
          }
      }
    close( CMD );
  }

if ( $error eq 1 )
  {
    die "ERROR: zip errors\n";
  }

mkdir( "e:\\p4" );

$cmd = "copy backup.$number.zip e:\\p4\\";

print "$cmd\n";
if ( open( CMD, "$cmd 2>&1 |" ) )
  {
    while ( <CMD> )
      {
        if ( / 1 file\(s\) copied./ )
          {
            print;
          }
        else
          {
            $error = 1;
            print "ERROR ";
            print;
          }
      }
    close( CMD );
  }
if ( $error eq 1 )
  {
    die "ERROR: copy errors\n";
  }


