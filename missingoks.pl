use strict;

my %reqs;

if ( open(MSGLOG, $ARGV[0]) ) {
  my $nreqs = 0;
  my $noks = 0;
  while ( <MSGLOG> ) {
    chomp;
    my $line = $_;
    if ( $line =~ /^MSG!/ ) {
    }
    elsif ( $line =~ /^REQ / ) {
      $nreqs++;
      my @parts = split(/\t/, $line);
      my $cmd = $parts[6];
      #print "REQ [" . $cmd . "]\n";
      if ( exists $reqs{$cmd} ) {
        my @existing = split(/\t/, $reqs{$cmd} );
        #print "incrementing $cmd\n";
        my $c = $existing[0] + 1;
        $existing[0] = $c;
          my $x = join( "\t", @existing );
        $reqs{$cmd} = $x;
        #print "inced $reqs{$cmd}\n";
      }
      else {
        #print "adding $cmd\n";
        $reqs{$cmd} = "1\t$line";
        #print "added $reqs{$cmd}\n";
      }
    }
    elsif ( $line =~ /^OK/ or $line =~ /^UNK/ or $line =~ /^NAK/ ) {
      $noks++;
      my @parts = split(/\t/, $line);
      my $cmd = $parts[6];
      #print "OK [" . $cmd . "]\n";
      if ( !exists $reqs{$cmd} ) {
        $cmd =~ s/Retrieve-Course/Retrieve-Page/;
        $cmd =~ s/Retrieve-Test/Retrieve-Page/;
        $cmd =~ s/-\[.+//;
      }
      if ( exists $reqs{$cmd} ) {
        my @existing = split(/\t/, $reqs{$cmd} );
        if ( $existing[0] == 1 ) {
          #print "removing $cmd\n";
          delete $reqs{$cmd};
          #print "deled $reqs{$cmd}\n";
        }
        else {
          $existing[0]--;
          #print "deecrementing $cmd\n";
          my $x = join( "\t", @existing );
          $reqs{$cmd} = $x;
          #print "deced $reqs{$cmd}\n";
        }
      }
      else {
        print "unmatched $line\n";
      }
    }
  }
  close(MSGLOG);
  print "reqs: $nreqs oks: $noks\n";
  foreach ( keys(%reqs) ) {
    my $req = $reqs{$_};
    print "$req\n";
  }
}
