#
#  File: transfercomments.pl
#  Author: eweb
#  Copyright WBT Systems, 2003-2010
#  Contents: transfers comments across a merge.
#
# Date:          Author:  Comments:
# 14th Sep 2007  eweb     #00008 Handle existing comments.
# 15th Sep 2008  eweb     #00008 Better handling of directories
# 28th Jul 2010  eweb     #00008 Tidier output
# 19th Aug 2010  eweb     #00008 Was broken for multi line comments
#

use strict;

my $toView = $ARGV[0]; # view in which the file is currently checked out.

my $file   = $ARGV[1];

my $verbose;

if ( $toView ne "" ) {
    chdir( $toView );
}

if ( $file ne "" ) {
    print "file $file\n";
    transferComment( $file );
}
else {
    my $cmd = "cleartool lsco -cview -avobs -short";

    print "cmd: $cmd\n";
    if ( open( COUTS, "$cmd 2>&1 |" ) ) {
        while ( <COUTS> ) {
            chomp;
            transferComment( $_ );
        }
        close( COUTS );
    }
}

sub chevent($$$) {
    my ($checkout, $comment, $replace) = @_;
    my $cmd = "cleartool chevent $replace -c \"$comment\" \"$checkout\"";
    print "$cmd\n" if ( $verbose or 1 );
    if ( open( CHEV, "$cmd 2>&1 |" ) ) {
        while ( <CHEV> ) {
            chomp;
            if ( /Modified event of version/ ) {
                print "$_\n" if ( $verbose );
            }
            elsif ( /Modified event of directory version/ ) {
                print "$_\n" if ( $verbose );
            }
            else {
                print "$_\n"; # if ( $verbose );
            }
        }
        close( CHEV );
    }
}

sub transferComment($) {
    my ($checkout) = @_;
    if ( $checkout ne "\\topclass\\oracle\\install\\distribution\\nonwebable\\dat\\formdefs" ) {
      #return;
    }
    print "$checkout\n";

    my $cmd = "cleartool describe -fmt \"[%Nc]\" \"$checkout\"";
    print "cmd: $cmd\n" if ( $verbose );
    my $existing_comment;
    my $desc = `$cmd`;
    if ( $desc =~ /\[(.*)\]/s ) {
        $existing_comment = $1;
    }
    if ( $existing_comment ) {
        print "existing_comment: [$existing_comment]\n" if ( $verbose );
    }
    my $replace = "";
    if ( -d $checkout ) {
        if ( $existing_comment =~ /^#/ ) {
        }
        elsif ( $existing_comment ne "" ) {
            $existing_comment = "";
            $replace = "-replace ";
        }
    }

    #print "\$existing_comment [$existing_comment]\n";

    if ( $existing_comment eq "" ) {
        # list the hyperlinks
        $cmd = "cleartool describe -ahl -all \"$checkout\"";
        print "$cmd\n" if ( $verbose );
        if ( open( LINKS, "$cmd 2>&1 |" ) ) {
#  Hyperlinks:
#    Merge <- \topclass\oracle\topclass\Scripts\ORACLE\up741to742@@\main\eweb_742_work_3\1
            while ( <LINKS> ) {
                chomp;
                if ( /Hyperlinks:/ ) {
                }
                elsif ( /Merge <- (.+)\@\@(.+)/ ) {
                    print "merged from $1\@\@$2\n" if ( $verbose );
                    $cmd = "cleartool describe -fmt \"[%Nc]\" \"$1\@\@$2\"";
                    print "cmd: $cmd\n" if ( $verbose );
                    my $desc = `$cmd`;
                    print "$desc\n";
                    if ( $desc =~ /\[(.*)\]/s ) {
                        my $comment = $1;
                        my @lines = split( /[\n\r]+/, $comment );
                        #print "\@lines: @lines\n";
                        foreach ( @lines ) {
                            my $l = $_;
                            if ( $l eq "" ) {
                            }
                            else {
                                if ( $replace ne "" ) {
                                    print "\$replace:$replace\n";
                                    chevent($checkout, "", $replace);
                                    $replace = "";
                                }
                                chevent($checkout, $l, $replace);
                            }
                        }
                    }
                }
            }
            close( LINKS );
        }
    }
}
