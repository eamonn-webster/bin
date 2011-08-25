
while (<ARGV>)
  {

    if ( /#/ )
      {
      }
    elsif ( /\/\// )
      {
      }
    else
      {
        if ( /(\"([^\"\\]|\\.)*\")/ )
          {
            my $str = $1;
            if ( $str eq "" )
              {
              }
            elsif ( $str =~ /[a-z]/ )
              {
                print "$str\n";
              }
          }
      }
    #print;
  }


