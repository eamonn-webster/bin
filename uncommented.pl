use strict;

my $fromView;   # view from which the file was merged.
my $toView;     # view in which the file is currently checked out.

#$fromView = $ARGV[0];
$toView   = $ARGV[0];

if ( $toView ne "" )
  {
    chdir( $toView );
  }

my $cmd = "cleartool lsco -cview -avobs -short";

print "cmd: $cmd\n";
if ( open( COUTS, "$cmd 2>&1 |" ) )
  {
    while ( <COUTS> )
      {
        chomp;
        my $checkout = $_;
        #print "$checkout\n";
        #$cmd = "cleartool describe \"$fromView$checkout\"";
        #system( $cmd );
        # list the hyperlinks
        $cmd = "cleartool describe -ahl -all \"$toView$checkout\"";
        $cmd = "cleartool describe -ahl -all \"$checkout\"";
        $cmd = "cleartool describe -fmt \"[%c]\" \"$checkout\"";
        #print "$cmd\n";
        my $comments = `$cmd`;
        if ( $comments eq "[]" )
          {
            print "$checkout\n";
          }
      }
    close( COUTS );
  }
