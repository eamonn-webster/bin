#
# dodgy-arg-passing.txt
#

# first find all functions that take a W???* as argument.
# find all calls to these functions.

use strict;

my @swizzlerGets;

for ( <*.h> )
  {
    #print $_;
    my $file = $_;
    if ( $file ne "ETcList.h" && open(h, $file) )
      {
        my $incomments = 0;
        my $lineno = 0;
        while ( <h> )
          {
            $lineno++;
            if ( /^\s*\/\// )
              {
                #lineno comment
              }
            elsif ( /^\s*\/\*.*\*\\s*$/ )
              {
                #multi on single
              }
            elsif ( /\/\*.*\*\// )
              {
                #multi on single
              }
            elsif ( /\/\*/ )
              {
                #print "Comment start:($lineno)" . $_;
                $incomments = 1;
              }
            elsif ( /\*\// )
              {
                #print "Comment end:($lineno)" . $_;
                $incomments = 0;
              }
            elsif ( $incomments eq 1 )
              {
                #
              }
            elsif ( /return/ ||
                    /PTROBJ/ )
              {
              }
            #elsif ( /\(.*get([A-Z][a-zA-Z]+)\(\).*\)/ )
            #  {
            #    if ( $1 ne "ID" )
            #      {
            #        s/^ +//g;
            #        print;
            #      }
            #  }
            #elsif ( /W[A-Z][a-zA-Z]+\s*\*\s*get([A-Z][a-zA-Z]+)\(\).*\)/ )
            elsif ( /(W[A-Z][a-zA-Z]+)\s*\*\s+(get[A-Z][a-zA-Z]+)\(/ )
              {
                if ( $1 ne "ID" )
                  {
                    #s/^ +//g;
                    #print "$1 $2\n";
                    my $swizzlerGet = $2;
                    if ( !grep( /^$swizzlerGet$/, @swizzlerGets ) )
                      {
                        print "$file($lineno): $swizzlerGet\n";
                        #print "$swizzlerGet\n";
                        @swizzlerGets = ( @swizzlerGets, $swizzlerGet );
                      }
                  }
              }
            #elsif ( /\(.*W[A-Z][a-zA-Z]+\s*\*.*\)/ )
            #  {
            #    s/^ +//g;
            #    print;
            #  }
          }
        close(h);
      }
  }
for ( <*.cpp> )
  {
    #print $_;
    my $file = $_;
    if ( open(h, $file) )
      {
        my $incomments = 0;
        my $lineno = 0;
        while ( <h> )
          {
            my $line = $_;
            $lineno++;
            if ( /^\s*\/\// )
              {
                #lineno comment
              }
            elsif ( /^\s*\/\*.*\*\\s*$/ )
              {
                #multi on single
              }
            elsif ( /\/\*.*\*\// )
              {
                #multi on single
              }
            elsif ( /\/\*/ )
              {
                #print "Comment start:($lineno)" . $_;
                $incomments = 1;
              }
            elsif ( /\*\// )
              {
                #print "Comment end:($lineno)" . $_;
                $incomments = 0;
              }
            elsif ( $incomments eq 1 )
              {
                #
              }
            elsif ( #/return/ ||
                    /PTROBJ/ ||
                    /PTRSET/ )
              {
              }
            #elsif ( /\(.*get([A-Z][a-zA-Z]+)\(\).*\)/ )
            #  {
            #    if ( $1 ne "ID" )
            #      {
            #        s/^ +//g;
            #        print;
            #      }
            #  }
            #elsif ( /W[A-Z][a-zA-Z]+\s*\*\s*get([A-Z][a-zA-Z]+)\(\).*\)/ )
            elsif ( /\s+([\w\.\->]*)\s*\(.*(get[A-Z][a-zA-Z]+)\(\)(.*)\)/ )
              {
                my $pre = $1;                
                my $func = $2;
                my $rest = $3;
                #print "[$pre] [$func]\n";
                if ( $pre eq "if" )
                  {
                  }
                elsif ( $pre =~ /\.set$/ )
                  {
                  }
                elsif ( $pre eq "OBJ" )
                  {
                  }
                elsif ( $rest =~ /^\s+[=!]=/ )
                  {
                  }
                elsif ( grep( /^$func$/, @swizzlerGets ) )
                  {
                    #print "[$pre] [$func] [$rest]\n";
                    print "$file($lineno)[$pre]: $line";
                    #@swizzlerGets = ( @swizzlerGets, $swizzlerGet );
                  }
              }
            elsif ( /\(.*(get[A-Z][a-zA-Z]+)\(\)(.*)\)/ )
              {
                my $func = $1;
                my $rest = $2;
                if ( $rest =~ /^\s+[=!]=/ )
                  {
                  }
                elsif ( grep( /^$func$/, @swizzlerGets ) )
                  {
                    print "$file($lineno): $line";
                    #@swizzlerGets = ( @swizzlerGets, $swizzlerGet );
                  }
              }
            #elsif ( /\(.*W[A-Z][a-zA-Z]+\s*\*.*\)/ )
            #  {
            #    s/^ +//g;
            #    print;
            #  }
          }
        close(h);
      }
  }
