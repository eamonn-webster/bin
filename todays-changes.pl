use strict;


my $dest = "\\\\tsclient\\y" > c:\temp\xxx.bat
my $user = lc $ENV{USERNAME};

my $cmd = "cleartool find  -avobs -visible -version \"created_since(yesterday) && created_by($user) && !eltype(directory)\" -print";

if ( open( CHANGES, "$cmd |" ) ) {
  while ( <CHANGES> ) {
    chomp;
    $cmd = "copy /y $1 $dest$2";
  }
}