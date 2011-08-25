use strict;

my $cmd = "git status";

if ( open( GIT, "$cmd |" ) ) {
  while ( <GIT> ) {
    if ( /^(.+): needs merge/ ) {
      my $file = $1;
      $file =~ s!/!\\!g;
      system( "textpad $file" );
    }
  }
}

