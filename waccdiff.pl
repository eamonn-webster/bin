use strict;

compareFiles( $ARGV[0], $ARGV[1] );

sub scantrans( $$ )
  {
    my ( $line, $format ) = @_;
    my @parts;
    my $i = 0;
    if ( $line =~ /^(T)(.*)/ )
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^([0-9] [0-9]+ [0-9]+ [0-9]+)\s*(.*)/ )
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^("[^\"]+")\s*(.*)/ ) #part
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^(-?[0-9]+)\s*(.*)/ ) # code
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^(-?[0-9]+ [0-3])\s*(.*)/ ) # amount
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^(-?[0-9]+ [0-3])\s*(.*)/ ) # balance
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^(-?[0-9]+ [0-3])\s*(.*)/ ) # equiv
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^(-?[0-9]+ [0-3])\s*(.*)/ ) # rate
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $format gt 5 )
      {
        if ( $line =~ /^(-?[0-9]+ [0-3])\s*(.*)/ ) # ledbal
          {
            $parts[$i++] = $1;
            $line = $2;
          }
      }    
    else
      {
        $parts[$i++] = 0;
        $parts[$i++] = 0;
      }
    if ( $line =~ /^(-?[0-9]+)\s*(.*)/ ) # link id
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    if ( $line =~ /^(-?[0-9]+)\s*(.*)/ ) # ref num
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    #print "before type: $line\n";
    if ( $line =~ /^(-?[0-9]+)\s*(.*)/ ) # type
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    #print "before time: $line\n";
    if ( $line =~ /^(-?[0-9]+ -?[0-9]+)\s*(.*)/ ) # time
      {
        $parts[$i++] = $1;
        $line = $2;
      }
    #print "before receipted: $line\n";
    if ( $format ge 3 )
      {
        if ( $line =~ /^([0-9]+)\s*(.*)/ ) # receipted
          {
            $parts[$i++] = $1;
            $line = $2;
          }
        else
          {
            $parts[$i++] = 0;
          }
      }    
    #print "before data: $line\n";
    if ( $format ge 4 )
      {
        if ( $line =~ /^("[^\"]*")\s*(.*)/ ) # data
          {
            $parts[$i++] = $1;
            $line = $2;
          }
        else
          {
            $parts[$i++] = '""';
          }
      }    
    #print "before posted: $line\n";
    if ( $format ge 3 )
      {
        if ( $line =~ /^([0-9] [0-9]+ [0-9]+ [0-9]+)\s*(.*)/ ) # posted
          {
            $parts[$i++] = $1;
            $line = $2;
          }
        else
          {
            $parts[$i++] = "0 0 0 0";
          }
      }    
    return @parts;
  }
  
sub compareFiles( $$ )
  {
    my ($filea, $fileb) = @_;

    if ( $filea =~ /\.([^.]+)$/ )
      {
        if ( lc($1) eq "cbk" ) 
          {
          }
        elsif ( lc($1) eq "bbb") 
          {
          }
        elsif ( lc($1) eq "dry") 
          {
          }
        elsif ( lc($1) eq "shl" )
          {
          }
        else
          {
            die "Unhandled type $1\n";
          }
      }
    my @linesa;
    my @linesb;
    if ( open( HA, $filea ) )
      {
        @linesa = <HA>;
        if ( open( HB, $fileb ) )
          {
            @linesb = <HB>;
            close( HB );
          }
        close( HA );
      }


    my $formata = 0;
    my $formatb = 0;
    my $a = 0;
    my $b = 0;
    while ( $a <= $#linesa )
      {
        my $linea = $linesa[$a];
        my $lineb = $linesb[$b];
        while ( substr($linea,0,1) ne substr($lineb,0,1) )
          {
            # should we adjust lineb?
            # is line a the same as the preceeding line
            if ( $a > $#linesa )
              {
                last;
              }
            elsif ( $b > $#linesb )
              {
                last;
              }
            elsif ( $a gt 0 and substr($linesa[$a-1],0,1) eq substr($linea,0,1) )
              {
                print "different type a hasn't changed\n";
                print "a: $linea";
                #print "b: $lineb";
                $a++;
                $linea = $linesa[$a];
              }
            elsif ( $b gt 0 and substr($linesb[$b-1],0,1) eq substr($lineb,0,1) )
              {
                print "different type b hasn't changed\n";
                #print "a: $linea";
                print "b: $lineb";
                $b++;
                $lineb = $linesb[$b];
              }
            else
              {
                print "different types\n";
                print "testing substr($linesa[$a-1],0,1) eq substr($linea,0,1)\n";
                print "testing substr($linesb[$b-1],0,1) eq substr($lineb,0,1)\n";
                last;
              }
          }
        if ( $linea =~ /^I ([0-9]+)/ )
          {
            $formata = $1;
          }
        if ( $lineb =~ /^I ([0-9]+)/ )
          {
            $formatb = $1;
          }      
        if ( $formata lt 6 )
          {
            $linea =~ s/\$/\"/g;
          }
        if ( $formatb lt 6 )
          {
            $lineb =~ s/\$/\"/g;
          }
        my @partsa;
        my @partsb;
        if ( $linea =~ /^L/ )
          {
            #print "linea: $linea";
            @partsa = ($linea =~ /(.)"([^\"]+)" (-?[0-9]+) ([0-1]) (-?[0-9]+ [0-3]) ([0-9]+)\s*([0-1]*)/ );
            #print "partsa: @partsa\n";
          }
        if ( $lineb =~ /^L/ )
          {
            #print "lineb: $lineb";
            @partsb = ($lineb =~ /(.)"([^\"]+)" (-?[0-9]+) ([0-1]) (-?[0-9]+ [0-3]) ([0-9]+)\s*([0-1]*)/ );
            #print "partsb: @partsb\n";
          }
        if ( $partsa[0] eq "L" and $partsa[0] eq $partsb[0] )
          {
            if ( $formata lt 6 )
              {
                $partsb[6] = $partsa[6];
              }
            if ( $formatb lt 6 )
              {
                $partsa[6] = $partsb[6];
              }
            $linea = "@partsa\n";
            $lineb = "@partsb\n";
          }
    #T1 14 1 2002 "Milk" 21 -57 3 1531 1 0 0 0 0 0 0 0 -1 -1 0 "" 0 0 0 0
        if ( $linea =~ /^T/ )
          {
            #print "linea  : $linea";
            @partsa = scantrans($linea, $formata);
            #print "partsa: @partsa\n";
          }
        if ( $lineb =~ /^T/ )
          {
            #print "lineb  : $lineb";
            @partsb = scantrans($lineb, $formatb);
            #print "partsb: @partsb\n";
          }
        if ( $partsa[0] eq "T" and $partsa[0] eq $partsb[0] )
          {
            if ( $formata lt 6 )
              {
                $partsb[5] = $partsa[5];
              }
            if ( $formatb lt 6 )
              {
                $partsa[5] = $partsb[5];
              }
            $linea = "@partsa\n";
            $lineb = "@partsb\n";
          }
        if ( $linea eq $lineb )
          {
          }
        elsif ( $linea =~ /^;/ and $lineb =~ /^;/ )
          {
          }
        elsif ( $linea =~ /^I/ and $lineb =~ /^I/ )
          {
          }
        elsif ( $linea =~ /^T/ and $lineb =~ /^T/ )
          {
          }
        else
          {
            print "a: $linea";
            print "b: $lineb";
          }
        $a++;
        $b++;
      }
  }
  
