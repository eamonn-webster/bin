use strict;

if ( open( LIST, "C:/TEMP/z-checkouts.bat" ) ) {
  while ( <LIST> ) {
    if ( /checkout directory version "([^"]+)"/ ) { #"
    }
    elsif ( /checkout version "([^"]+)"/ ) { # "
      print "REM $1\n";
      my $file = $1;
      my $cmd = "cleartool desc -fmt \"%c\" \"$file\"";
      my $needToChange = undef;
      my @comments = ();
      if ( open( COMMENTS, "$cmd |" ) ) {
        while ( <COMMENTS> ) {
          chomp;
          my $c = $_;
          #print "REM $c\n";
          if ( $c eq "" ) {
          }
          elsif ( grep( /^\Q$c\E$/, @comments ) ) {
            $needToChange = 1;
          }
          else {
            @comments = ( @comments, $c );
            #print "@comments\n";
          }
        }
        close(COMMENTS);
      }
      if ( $needToChange ) {
        print "cleartool chevent -replace -c \"\" \"$file\"\n";
        foreach ( @comments ) {
          $_ =~ s!"!\"!g; # "
          print "cleartool chevent -append -c \"$_\" \"$file\"\n";
        }
      }
    }
  }
  close( LIST );
}