#******************************************************************************/
#
#  File: cinall.pl
#  Author: eweb
#  Copyright WBT Systems, 2007-2007
#  Contents: Checks in everything currently checked out.
#
#******************************************************************************/
#
#   Date:          Author:  Comments:
#    8th Nov 2007  eweb     Initial version.
#

# Need to handle identicals...

use strict;

my $cleartool1 = "cleartool";
my $cleartool2 = "cleartool";

my $comments = "#????? Work in progress";

my $cmd0 = "$cleartool1 lsco -avobs -cview -short";

if ( open( COS, "$cmd0 |" ) )
  {
    while ( <COS> )
      {
        chomp;
        my $file = $_;
        if ( -d $file )
          {
          }
        elsif ( -e $file )
          {
            #print "$file \n";
            my $cmd1 = "$cleartool1 desc -fmt \"%Nc\" \"$file\"";
            #print "$cmd1\n";
            my $c = `$cmd1`;
            #print "Comments: $c\n";
            if ( $c eq "" )
              {
                $c = $comments;
              }
            CheckIn( $file, $c );
         }
      }
    close( COS );
  }
  

sub CheckIn($$)
  {
    my ($file, $comment) = @_;
    $comment =~ s!"!\\"!g;

    my $cmd = "$cleartool2 ci -c \"$comment\" \"$file\"";
    print "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won't create version with data identical to predecessor./ )
      {
        # hasn't changed so undo the check out.
        $cmd = "$cleartool2 unco -rm $file";
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

sub runCmd( $ )
  {
    my ( $cmd ) = @_;

    print "$cmd\n";
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
                print "$_";
              }
          }
      }
  }
