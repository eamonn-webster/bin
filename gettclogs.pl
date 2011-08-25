use strict;

my $tcurl = $ARGV[0];
my $conn = $ARGV[1];

my $cmd "curl ${tcurl}?conn-${conn}-viewlog-all";

system( "$cmd > logs.html" );

if ( !open( LOGS, "logs.html" ) ) {
}
else {
  while ( <LOGS> ) {
  }
  close( LOGS )
}
