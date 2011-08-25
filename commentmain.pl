#
# File: commentmain.pl
# Author: eweb
# Copyright WBT Systems, 1995-2009
# Contents:
#
# Date:          Author:  Comments:
# 15th Apr 2009  eweb     #00008 Copy comments to main
#
use strict;

# for each version on main (or some other branch)
# if a merge link then transfer comments...

#my $branch = "main";

sub run($)
  {
    my ($cmd) = @_;
    print "$cmd\n";
    system( $cmd );
  }
sub transferComment($)
  {
    my ($file) = @_;
    #print "$file\n";

    my $cmd = "cleartool describe -fmt \"[%Nc]\" \"$file\"";
    #print "cmd: $cmd\n";
    my $existing_comment;
    my $desc = `$cmd`;
    if ( $desc =~ /\[(.*)\]/s )
      {
        $existing_comment = $1;
      }
    #print "existing_comment: [$existing_comment]\n" if $existing_comment;
    my $replace = "";
    if ( -d $file )
      {
        if ( $existing_comment =~ /^#/ )
          {
          }
        else
          {
            $existing_comment = "";
            $replace = "-replace ";
          }
      }

    if ( $existing_comment eq "" )
      {
        # list the hyperlinks
        $cmd = "cleartool describe -ahl -all \"$file\"";
        #print "$cmd\n";
        if ( open( LINKS, "$cmd 2>&1 |" ) )
          {
#  Hyperlinks:
#    Merge <- \topclass\oracle\topclass\Scripts\ORACLE\up741to742@@\main\eweb_742_work_3\1
            while ( <LINKS> )
              {
                chomp;
                if ( /Hyperlinks:/ )
                  {
                  }
                elsif ( /Merge <- (.+)\@\@(.+)/ )
                  {
                    print "merged from $1\@\@$2\n";
                    $cmd = "cleartool describe -fmt \"[%Nc]\" \"$1\@\@$2\"";
                    #print "cmd: $cmd\n";
                    my $desc = `$cmd`;
                    if ( $desc ne "[]" )
                      {
                        #print "$desc\n";
                        if ( $desc =~ /\[\s*(.*)\s*\]/s )
                          {
                            my $comment = $1;
                            $comment =~ s!\r!\n!gs;
                            $comment =~ s!\s*\n\s*!\n!gs;
                            $comment =~ s!^\s+!!gs;
                            $comment =~ s!\s+$!!gs;
                            my @comments = split( /\n+/, $comment );
                            #print "@comments\n";
                            foreach ( @comments ) {
                              #print "[$_]";
                              $cmd = "cleartool chevent $replace -c \"$_\" \"$file\"";
                              run( $cmd );
                              $replace = "";
                            }
                            #print "\n";
                            #$comment =~ s!\n!\\n!gs;
                          }
                      }
                  }
              }
            close( LINKS );
          }
      }
  }

my $branch = $ARGV[0]; # view in which the file is currently checked out.
my $file   = $ARGV[1];

$branch = "main" unless $branch;

    #my $cmd = "cleartool lsco -cview -avobs -short";
    my $cmd = "cleartool lshist -short -branch $branch \"$file\"";
    print "cmd: $cmd\n";
    if ( open( COUTS, "$cmd 2>&1 |" ) )
      {
        while ( <COUTS> )
          {
            chomp;
            transferComment( $_ );
          }
        close( COUTS );
      }

