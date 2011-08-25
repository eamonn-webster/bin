#
# File: mrgcmts.pl
# Take comments from work branch..
#

use strict;

my $verbose;

sub oneFileOneBranch($$) {
  my ($file, $branch) = @_;
  # get latest
  # then for each get comments
  if ( $file and $branch ) {
    my @versions;
    my $cmd = "cleartool ls $file\@\@$branch";
    if ( open( VERS, "$cmd |" ) ) {
      while ( <VERS> ) {
        chomp;
        my $qbranch = quotemeta( $branch );
        if ( /\@\@$qbranch\\(.+)$/ ) {
          my $ver = $1;
          if ( $ver =~ /^[0-9]+$/ ) {
            print "VERSION: $ver\n" if ( $verbose );
            @versions = ( @versions, ($ver + 0) );
          }
          elsif ( $ver eq uc $ver ) {
            if ( $ver =~ /TCE?_[0-9]+_BUILD_[0-9]+/ ) {
              print "LABEL: $ver\n" if ( $verbose );
            }
            elsif ( $ver =~ /PUB_[0-9]+_BUILD_[0-9]+/ ) {
              print "LABEL: $ver\n" if ( $verbose );
            }
            else {
              print "LABEL: $ver\n" if ( $verbose );
            }
          }
          elsif ( $ver eq lc $ver ) {
            print "BRANCH: $ver\n" if ( $verbose );
          }
          else {
            print "INVALID: $ver contains uppercase branch or label?\n";
            #$cmd = "cleartool lstype -short lbtype:$ver";
            #my $res = `$cmd`;
            #print "$res\n";
            #$cmd = "cleartool lstype -short brtype:$ver";
            #$res = `$cmd`;
            #print "$res\n";
          }
        }
        else {
          print "UNKNOWN: $_\n";
        }
      }
      close( VERS );
    }
    @versions = sort {$a <=> $b} @versions;
    #print "@versions\n";
    foreach ( @versions ) {
      my $ver = $_;
      $cmd = "cleartool desc -fmt \"%Nc\" $file\@\@$branch\\$ver";
      my $comment = `$cmd`;
      #my $saveComment;
      #if ( $comment =~ /^merg/i ) {
      #  $saveComment = $comment;
      #  $comment = "";
      #}
      if ( $comment eq "" ) {
        my $nowCommented;
        print "$file\@\@$branch\\$ver has no comment\n" if ( $verbose );
        # did we merge to this version?
        $cmd = "cleartool desc -ahlink -all $file\@\@$branch\\$ver";
        if ( open( MERGES, "$cmd |" ) ) {
          while ( <MERGES> ) {
            my $merge = $_;
            if ( /Merge <- (.+)/ ) {
              print "Incoming $1\n" if ( $verbose );
              $cmd = "cleartool desc -fmt \"%Nc\" $1";
              if ( open( CMTS, "$cmd |" ) ) {
                while ( <CMTS> ) {
                  s![\r\n]+$!!;
                  $cmd = "cleartool chevent -c \"$_\" $file\@\@$branch\\$ver\n";
                  print "$cmd\n";
                  system( $cmd );
                  $nowCommented = 1;
                }
                close( CMTS );
              }
            }
            elsif ( /Merge -> (.+)/ ) {
              #print "Outgoing $1\n";
            }
          }
          close( MERGES );
        }
        # can we scrape from source?
        $cmd = "cleartool diff -diff_format -pred -options -b $file\@\@$branch\\$ver";
        if ( $ver ne "0" and open( DIFF, "$cmd |" ) ) {
          while ( <DIFF> ) {
            s![\r\n]+$!!;
            if ( /^(\+|> )(#|--)? +([0-9]+)(st|nd|rd|th) +([A-Z][a-z]+) +([0-9]+) +([^ ]+) +(#[0-9?]+.*)/ ) {
              my $day = $3;
              my $month = $4;
              my $year = $6;
              my $user = $7;
              my $comment = $8;
              #print "$comment\n";
              if ( $comment =~ /(#[^ ]+) ?(.*)/ ) {
                my $bugid = $1;
                my $text = $2;
                #print "$bugid [$text]\n";
                $cmd = "cleartool chevent -c \"$comment\" $file\@\@$branch\\$ver";
                print "$cmd\n";
                system( $cmd );
                $nowCommented = 1;
              }
            }
          }
          close( DIFF );
        }
        print "$file\@\@$branch\\$ver has no comment\n" unless ( $nowCommented );
      }
      elsif ( $comment =~ /#[0-9]+/ ) {
        print "$file\@\@$branch\\$ver has well formed comment $comment\n" if ( $verbose );
      }
      elsif ( $comment =~ /#\?+/ ) {
        print "$file\@\@$branch\\$ver has partially formed comment $comment\n" if ( $verbose );
      }
      else {
        print "$file\@\@$branch\\$ver has badly formed comment $comment\n";
      }
    }
  }
}

sub checkLabels($) {
  my ($vob) = @_;
  # get latest
  # then for each get comments
  my $cmd = "cleartool lstype -kind lbtype -short";
  if ( $vob ) {
    $cmd = "$cmd -invob $vob";
  }
  if ( open( TYPES, "$cmd |" ) ) {
    while ( <TYPES> ) {
      chomp;
      my $type = $_;
      if ( $type =~ /^[0-9]+$/ ) {
        print "INVALID: $type\n";
      }
      elsif ( $type eq uc $type ) {
        if ( $type =~ /TCE?_[0-9]+_BUILD_[0-9]+/ ) {
          print "LABEL: $type\n" if ( $verbose );
        }
        elsif ( $type =~ /PUB_[0-9]+_BUILD_[0-9]+/ ) {
          print "LABEL: $type\n" if ( $verbose );
        }
        else {
          print "LABEL: $type\n" if ( $verbose );
        }
      }
      #elsif ( $type eq lc $type ) {
      # print "BRANCH: $type\n" if ( $verbose );
      #}
      else {
        #print "INVALID: $type\n";
        print "cleartool rename lbtype:$type " . uc $type . "\n";
      }
    }
    close( TYPES );
  }
}

sub checkBranches($) {
  my ($vob) = @_;
  # get latest
  # then for each get comments
  my $cmd = "cleartool lstype -kind brtype -short";
  if ( $vob ) {
    $cmd = "$cmd -invob $vob";
  }
  if ( open( TYPES, "$cmd |" ) ) {
    while ( <TYPES> ) {
      chomp;
      my $type = $_;
      if ( $type =~ /^[0-9]+$/ ) {
        print "INVALID: $type\n";
      }
      elsif ( $type eq lc $type ) {
        print "BRANCH: $type\n" if ( $verbose );
      }
      else {
        #print "INVALID: $type\n";
        print "cleartool rename brtype:$type " . lc $type . "\n";
      }
    }
    close( TYPES );
  }
}


#checkLabels($ARGV[0]);
#checkBranches($ARGV[0]);
oneFileOneBranch($ARGV[0], $ARGV[1]);

