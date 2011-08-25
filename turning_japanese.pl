
  if ( opendir( DIR, "." ) )
    {
      my $file;
      my $Cmd;
      my $CmdOut;
      while ( defined( $file = readdir(DIR) ) )
        {
          #print "$file\n";
          #if ( $file =~ /(.*)_ja\.dat/ ) {
          if ( $file =~ /(.*)_it\.dat/ ) {
            print "$file\n";
            rename $file, "$file.old";
            if ( open( IN, "$file.old" ) )
              {
                #if ( open( OUT, ">$1_jp.dat" ) )
                if ( open( OUT, ">$file" ) )
                  {
                    #my $native = "\x{e6}\x{97}\x{a5}\x{e6}\x{9c}\x{ac}\x{e8}\x{aa}\x{9e}";
                    #my $native = "\x{e6}\x{97}\x{a5}\x{e6}\x{9c}\x{ac}\x{e8}\x{aa}\x{9e}";
                    while (<IN>)
                      {
                        s/usenglish/italian/;
                        s/USEnglish/Italiano/;
                        s/US English/Italiano/;
                        s/;LanguageNumber=2/;LanguageNumber=7/;
                        print OUT;
                      }
                    close( OUT );
                  }
                close( IN );
              }
          }
        }
      closedir(DIR);
    }
  else
    {
      print BUILDLOG "can't open directory $LangDir\n";
    }
