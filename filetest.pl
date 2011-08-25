
    #if ( !open( PARAM, $ARGV[0] ) )
    #  {
    #    die "Failed to open param file $ARGV[0]";
    #  }
    #if ( !open( OUT, ">$ARGV[1]" ) )
    #  {
    #    die "Failed to open param file $ARGV[1]";
    #  }

  use File::Glob ':globally';
  use File::Glob ':glob';

  my @logs = bsd_glob('message*.txt');
  #@list = bsd_glob('*.[ch]');

    #my @logs = glob(<message*.txt>);
    #print "@logs\n";
    foreach my $f ( @logs )
    {
    if ( open( IN, $f ) )
    {
      while(<IN>)
      {
        if ( /^REQ/ )
          {
          }
        elsif ( /^OK/ )
          {
          }
        elsif ( /^LILO/ )
          {
          }
        elsif ( /^UNK/ )
          {
          }
        elsif ( /^STRT/  || /^STOP/  )
          {
            print;
            #print OUT;
          }
        elsif ( /^CTCH/  || /^FAIL/  || /^ERR/  )
          {
            print;
            #print OUT;
          }
        else
          {
            #print OUT;
          }
      }
      close(IN);
    }
}
      #close(PARAM);
      #close(OUT);
