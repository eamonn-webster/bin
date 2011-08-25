use strict;

my $cmd = "cleartool find -all -element \"eltype(compressed_file) or eltype(file)\" -print";

if ( open( OUT, "$cmd |" ) )
  {
    while ( <OUT> )
      {
        chomp;
        if ( /\.gif\@\@$/ )
          {
            #print "$_\n";
          }
        elsif ( /\.jpg\@\@$/ )
          {
            #print "$_\n";
          }
        else
          {
            print "$_\n";
          }
      }
    close( OUT );
  }


