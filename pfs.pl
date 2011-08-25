#
# Perl script to back date zero length .sbr files so that they don't cause out of date prompt.
#
# Author: Eamonn Webster
#
# Supplied as is. Feel free to do what you want with it.
#

my @bsc_s; # stat for the single .bsc file.

my $objdir = $ARGV[0];
my $bsc = $ARGV[1];
my $change = lc $ARGV[2];

if ( $bsc eq "" || $bsc eq "." )
  {
    $bsc = "$objdir\\*.bsc";
  }

print "$bsc\n";

#while ( <$bsc> )
while ( glob($bsc) )
  {
    #print $_ . "\n";
    @bsc_s = stat( $_ );
    printf "%12d %8d %-40s\n", $bsc_s[9], $bsc_s[7], $_ if ( "@bsc_s" ne "" );
    last;
  }

if ( "@bsc_s" eq "" )
  {
    print "no .bsc\n";
  }

if ( "@bsc_s" ne "" )
  {
    # loop through the
    my $pattern;
    if ( $bsc =~ /\.bsc$/ )
      {
        $pattern = "$objdir\\*.sbr";
      }
    else
      {
        $pattern = "$objdir\\*.obj";
      }
    print "$pattern\n";
    while ( glob( $pattern ) )
      {
        #print $_ . "\n";
        my @s = stat( $_ );
        #print "$s[8] $s[9] $s[10] $_ @s\n";
        if ( $s[9] > $bsc_s[9] )
          {
            if ( $s[7] eq 0 )
              {
                if ( $change eq "y" )
                  {
                    printf "changing %12d %8d %-40s\n", $s[9], $s[7], $_ ;
                    utime $s[8], $bsc_s[9], ($_) ;
                  }
                else
                  {
                    printf "would change %12d %8d %-40s\n", $s[9], $s[7], $_ ;
                  }
              }
            else
              {
                printf "%12d %8d %-40s\n", $s[9], $s[7], $_ ;
              }
          }
      }
  }


