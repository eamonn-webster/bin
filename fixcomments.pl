#
# File: fixcomments.pl
# Author: eweb
# Copyright WBT Systems, 1995-2009
# Contents:
#
# Date:          Author:  Comments:
# 28th Jul 2009  eweb     #00008 Checkins with invalid comments
#
use strict;

my $changes = $ARGV[0];
my $verbose = $ARGV[1];

my %messages;

my ($name, $type, $date, $user, $version, $pred, $comment );

if ( open( CHANGES, $changes ) ) {

  while ( <CHANGES> ) {
    #print if ( $verbose );
    if ( /^NAME: (.+)/ ) {
      writeOutEntry();
      $name = $1;
    }
    elsif ( /^DATE: (.+)/ ) {
      $date = $1;
    }
    elsif ( /^TYPE: (.+)/ ) {
      $type = $1;
    }
    elsif ( /^USER: (.+)/ ) {
      $user = $1;
    }
    elsif ( /^VERSION: (.+)/ ) {
      $version = $1;
    }
    elsif ( /^PREDECESSOR: (.+)/ ) {
      $pred = $1;
    }
    elsif ( /^COMMENT: ?(.+)/ ) {
      $comment = $1;
    }
    elsif ( /^$/ ) {
    }
    else {
      $comment .= $_;
    }
  }
  writeOutEntry();
  close( CHANGES )
}
else {
  die "Failed to open $changes $!\n";
}

sub writeOutEntry() {
  if ( $name ) {
    print "$name, $comment\n" if ( $verbose );
    if ( $comment =~ /#[0-9]{4,5}/ ) {
    }
    else {
      $messages{$user} .= "cleartool chevent -insert -c \"\" \"$name\@\@$version\"\n";
    }
  }
  $name = undef();
}

foreach ( keys %messages ) {
  print "mail to $_\n";
  print "The following check-ins have empty or invalid comments\n";
  print "A valid comment should start with a issue number\n\n";
  print $messages{$_};
}
