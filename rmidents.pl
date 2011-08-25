$ctool = "cleartool";

#$branch = "422_branch\\423_branch\\424_branch\\425_branch\\426_branch\\427_branch\\428_branch";
#$branch = "630_branch";
#$branch = "710_branch";
$branch = $ARGV[0];

# find the latest that isn't 0
$cmd = "$ctool find . -version \"version(\\main\\$branch\\LATEST) && !version(\\main\\$branch\\0)\" -print";

print "$cmd\n";
open( VERSIONS, "$cmd 2>&1 |" ) or die;

while ( <VERSIONS> )
  {
    chomp;
    $version = $_;
    #print $version;

    $version =~ /(.*)@@(.*)/;
    $element = $1;
    $verspec = $2;

    # predecessor
    $cmd = "$ctool desc -pred \"$version\"";

    #print "$cmd\n";
    open( PRED, "$cmd 2>&1 |" ) or die;
    while ( <PRED> )
      {
        if ( /predecessor version: (.*)/ )
          {
            $pred = $1;
            #print "[$pred]\n";
          }
      }
    close PRED;

    print "$cmd\n";
    $cmd = "$ctool diff -pred \"$version\"";

    open( DIFFS, "$cmd 2>&1 |" );
    while ( <DIFFS> )
      {
        if ( /Files are identical/ )
          {
            #$cmd = "$ctool";
            $cmd = "$ctool desc -fmt \"%Nl\\n\" \"$version\"";
            print "$cmd\n";
            open( LABELS, "$cmd 2>&1 |" ) or die;
            while ( <LABELS> )
              {
                chomp;
                $labelLine = $_;
                #print $labelLine;

                if (split(/ /, $labelLine))
                  {
                    foreach $label (split(/ /, $labelLine))
                      {
                        print "$label\n";
                        #print "$ctool mklabel -replace $label \"$element\@\@$pred\"\n";
                      }
                    if ( $ARGV[1] eq "-force" )
                      {
                        $userInput = "y";
                      }
                    else
                      {
                        system( "clearvtree \"$element\"" );
                        print "move labels y/n?";
                        $userInput = <STDIN>;
                        chomp $userInput;
                      }

                    if ( $userInput eq "y" )
                      {
                        foreach $label (split(/ /, $labelLine))
                          {
                            #print "$label\n";
                            $cmd = "$ctool mklabel -replace $label \"$element\@\@$pred\"";
                            system( $cmd );
                            #print "$cmd\n";
                          }
                      }
                  }
                else
                  {
                    print "no labels\n";
                    $cmd = "$ctool rmver $ARGV[1] \"$element\@\@$verspec\"";
                    system( $cmd );
                  }
                #move label to predecessor
                #...
              }
            close LABELS;
          }
        else
          {
            last;
          }
      }
    close DIFFS;
  }
close VERSIONS;
