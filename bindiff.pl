#@version = `filever tcoci104.dll`;

@oldFileCmd = `filever $ARGV[0]`;
foreach $line (@oldFileCmd)
{
  $line =~/[A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* +([0-9\.]*)/;
  #print "old : $1\n";
  @oldfilever = split/\./,$1;
  #$1=~/\.([0-9]*)$/;
  #$oldfilever=$1;
}

@newFileCmd = `filever $ARGV[1]`;
foreach $line (@newFileCmd)
{
  $line =~/[A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* +([0-9\.]*)/;
  #print "new : $1\n";
  @newfilever = split/\./,$1;
  #$1=~/\.([0-9]*)$/;
  #$newfilever=$1;
}



#print "old hex = $oldverhex\n";
#print "new hex = $newverhex\n";
@oldDLLInfo = `dumpbin /headers $ARGV[0]`;

foreach $line (@oldDLLInfo)
{
  if ($line=~/ *([A-Fa-f0-9]*) time date stamp/)
  {
    $oldDLLdate=$1;
  }
}


@newDLLInfo = `dumpbin /headers $ARGV[1]`;

foreach $line (@newDLLInfo)
{
  if ($line=~/ *([A-Fa-f0-9]*) time date stamp/)
  {
    $newDLLdate=$1;
  }
}

@FC_cmd = `c:/WINNT/SYSTEM32/fc /b $ARGV[0] $ARGV[1]`;
$count = 0;
foreach $line (@FC_cmd)
{
  $line =~/[A-Fa-f0-9]*: ([A-Fa-f0-9][A-Fa-f0-9]) ([A-Fa-f0-9][A-Fa-f0-9])/;
  if (($1 ne "") && ($2 ne ""))
  {
    $old[$count] = $1;
    $new[$count] = $2;
    $count++;
  }
}


#searching for dates 
$hit=0;
$ndcount=0;
for ($loop = 0; $loop < $count; $loop++)
{
  if ($hit > 0)
  {
    $oldsearch=$old[$loop].$oldhexbits;
    $newsearch=$new[$loop].$newhexbits;
  }
  else
  {
    $oldsearch=$old[$loop];
    $newsearch=$new[$loop];
  }
  if ($oldDLLdate=~/$oldsearch/ && $newDLLdate=~/$newsearch/)
  {
    # both hex values appear in their respective 
    $oldhexbits = $oldsearch;
    $newhexbits = $newsearch;
    $hit++;
  }
  else
  {
    #failed to find the pattern thus far. print out the patterns components
    for($x = $hit; $x >= 0; $x--)
    {
      $index_str = '$loop - $x';
      $index = eval($index_str);
      @oldNonDates[$ndcount] = $old[$index];
      @newNonDates[$ndcount] = $new[$index];
      $ndcount++;
    }
    $oldhexbits="";
    $newhexbits="";
    $hit=0;
  }
  if ($hit == 3)
  {
    # a perfect match
    $oldhexbits="";
    $newhexbits="";
    $hit=0;

  }
}

#for ($loop = 0 ; $loop < $ndcount; $loop ++)
#{
  #print "$oldNonDates[$loop] :: $newNonDates[$loop]\n";
  #}
  #exit 0 ;
# have to assertain how much of the 

# removed any date component. now remove anything that matches the hex version value.
# TODO should probably compare against the entire version information.
$bitsToCheck=0;
if ($oldfilever[0] != $newfilever[0])
{
  @oldVersionBits[$bitsToCheck]= $oldfilever[0];
  @newVersionBits[$bitsToCheck]= $newfilever[0];
  $bitsToCheck++;
}
if ($oldfilever[1] != $newfilever[1])
{
  @oldVersionBits[$bitsToCheck]= $oldfilever[1];
  @newVersionBits[$bitsToCheck]= $newfilever[1];
  $bitsToCheck++;
}
if ($oldfilever[2] != $newfilever[2])
{
  @oldVersionBits[$bitsToCheck]= $oldfilever[2];
  @newVersionBits[$bitsToCheck]= $newfilever[2];
  $bitsToCheck++;
}
if ($oldfilever[3] != $newfilever[3])
{
  @oldVersionBits[$bitsToCheck]= $oldfilever[3];
  @newVersionBits[$bitsToCheck]= $newfilever[3];
  $bitsToCheck++;
}
$nvCount = 0;
$hits = 0;
for ($loop = 0; $loop < $ndcount; $loop ++)
{
  $oldverhex = sprintf "%lx",$oldVersionBits[$hits];
  $newverhex = sprintf "%lx",$newVersionBits[$hits];
  if ((@oldNonDates[$loop] != $oldverhex) && (@newNonDates[$loop] != $newverhex))
  {
    # we found some of the version, but its not what we're looking for.
    for ($x = $hits; $x >= 0; $x--)
    {
      $index = eval('$loop - $x');
      $oldvalue = hex($oldNonDates[$index]);
      $newvalue = hex($newNonDates[$index]);
      @oldNonVersions[$nvcount] = sprintf "%c", $oldvalue;
      @newNonVersions[$nvcount] = sprintf "%c", $newvalue;
      #print "* $oldNonDates[$loop] :: $newNonDates[$loop]\n";
      $nvcount++;
    }
  }
  else
  {
    $hits++;
    if ($hits == $bitsToCheck)
    {
      # we've found the all the differences in the version.
      $hits = 0;
    }
  }
}

# finally, remove all bytes that match the text version at the same point in both strings.
# take the array, make it into one string, and search on the whole thing.
#
foreach $element (@oldfilever)
{
  $wholeoldfilever = $wholeoldfilever.$element;
}
foreach $element (@newfilever)
{
  $wholenewfilever = $wholenewfilever.$element;
}

$found = 0;
$finalcount=0;
for ($x = 0; $x < $nvcount; $x ++)
{
  @oldverarray = split//,$wholeoldfilever;
  @newverarray = split//,$wholenewfilever;
  for ($loop = 0; $loop < length($wholeoldfilever); $loop ++)
  {
    #print "comparing $oldverarray[$loop] and $oldNonVersions[$x]\n  and $newverarray[$loop] and $newNonVersions[$x]\n";
    if (($oldverarray[$loop] == $oldNonVersions[$x]) && ($newverarray[$loop] == $newNonVersions[$x]))
    {
      $found = 1;
    }
  }
  if ($found != 1)
  {
    $oldhex = sprintf "%lx",ord($oldNonVersions[$x]);
    $newhex = sprintf "%lx",ord($newNonVersions[$x]);
    #print "$oldNonVersions[$x] [$oldhex] : $newNonVersions[$x] [$newhex]\n";
    @oldfinalarray[$finalcount] = $oldNonVersions[$x];
    @newfinalarray[$finalcount] = $newNonVersions[$x];
    $finalcount++;
  }
  $found = 0;
}

if ($finalcount > 0)
{
  print "binary files are different\n";
}
