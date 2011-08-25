

open (FILE,"u://topclass//oracle//topclass//languages//strings.dat") or die "can't open file";

while (<FILE>)
{
  /^\"([A-Za-z0-9\-_\*&]*)\"[   ]*([0-9]*)/;

  $strings{$2} = $1;
}
close FILE;

open (FILE,$ARGV[0]) or die "can't open $ARGV[0]\n";
open (OUTFILE,">work/$ARGV[0]") or die "can't open work/$ARGV[0]\n";

while( ($Key, $Value) = each(%strings))
{
  print "$Key $Value\n";
}
while (<FILE>)
{
  while( ($Key, $Value) = each(%strings))
  {
    s/%\$$Key%/%\$$Value%/g;
    s/\(\$$Key\)/\(\$$Value\)/g;
    s/%\$\$$Key%/%\$\$$Value%/g;
  }
  #print $_;
  print OUTFILE $_;
}

close FILE;
close OUTFILE;
