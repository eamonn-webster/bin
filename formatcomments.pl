use strict;


sub processFile( $ )
  {
    my ($file) = @_;
    if ( $file =~ /\.([^.]+)$/ )
      {
        #print "[$1]\n";
        if ( $1 eq "sql" )
          {
            processSqlFile( $file );
          }
        else
          {
            print "Unhandled file type [$file]\n"
          }
      }
    else
      {
        print "Can't determine file type [$file]\n"
      }
  }

sub processSqlFile( $ )
  {
    my ($file) = @_;
    my $changed = 0;
    if ( open( IN, $file ) )
      {
        if ( open( OUT, ">$file.new" ) )
          {
            my $where = 1; # 0 start, 1 banner, 2 history, 3 body
            while ( <IN> )
              {
                my $in = $_;
                if ( $where lt 3 )
                  {
                    if ( /^--/ || /^\s*$/ )
                      {
                        # still in initial comments
                        if ( /^--[>< =-]*$/ || /^\s*$/  )
                          {
                            print OUT;
                          }
                        elsif ( /--\s+Date:\s+Author:\s+Comments:/ )
                          {
                            $where = 2;
                            my $dac = "-- Date:          Author:  Comments:\n";
                            if ( $in ne $dac )
                              {
                                $changed = 1;
                              }
                            print OUT $dac;
                          }
                        elsif ( $where eq 2 )
                          {
                            my $out;
                            my ($day, $th, $mon, $year, $user, $comments);

                            if ( /^-- +([0-3]?[0-9])(..)* (...) ([0-9]{4}) +([^ ]+) +(.*)$/ )
                              {
                                $day = $1;
                                $th  = $2;
                                $mon = $3;
                                $year = $4;
                                $user = $5;
                                $comments = $6;
                                $day++;
                                $day--;
                                if ( $day eq 1 or $day eq 21 or $day eq 31 )
                                  {
                                    $th = "st";
                                  }
                                elsif ( $day eq 2 or $day eq 22 )
                                  {
                                    $th = "nd";
                                  }
                                elsif ( $day eq 3 or $day eq 23 )
                                  {
                                    $th = "rd";
                                  }
                                else
                                  {
                                    $th = "th";
                                  }
                                $out = sprintf( "-- %2s%s %s %d  %-9s%s\n", $day, $th, $mon, $year, $user, $comments );
                              }
                            # name first...
                            elsif ( /^-- +([^ ]+) +([0-3]?[0-9])(..)* (...) ([0-9]{4}) +(.*)$/ )
                              {
                                $day = $2;
                                $th  = $3;
                                $mon = $4;
                                $year = $5;
                                $user = $1;
                                $comments = $6;
                                $day++;
                                $day--;
                                if ( $day eq 1 or $day eq 21 or $day eq 31 )
                                  {
                                    $th = "st";
                                  }
                                elsif ( $day eq 2 or $day eq 22 )
                                  {
                                    $th = "nd";
                                  }
                                elsif ( $day eq 3 or $day eq 23 )
                                  {
                                    $th = "rd";
                                  }
                                else
                                  {
                                    $th = "th";
                                  }
                                $out = sprintf( "-- %2s%s %s %d  %-9s%s\n", $day, $th, $mon, $year, $user, $comments );
                              }
                            elsif ( /^--               +(.*)$/ )
                              {
                                $comments = $1;
                                $out = sprintf( "--                         %s\n", $comments );
                              }
                            else
                              {
                                #print;
                                $out = $in;
                              }
                            print OUT $out;
                          }
                        else
                          {
                            print OUT;
                          }
                      }
                    else
                      {
                        $where = 3;
                        print OUT;
                      }
                  }
                else
                  {
                    print OUT;
                  }
              }
            close( OUT );
          }
        close( IN );
      }
    if ( $changed eq 0 )
      {
        unlink( "$file.new" );
      }
    else
      {
        unlink( "$file.old" );
        rename( $file, "$file.old" );
        rename( "$file.new", $file  );
      }
  }

processFile( $ARGV[0] );
