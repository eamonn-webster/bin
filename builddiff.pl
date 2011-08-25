if (($ARGV[1] eq "") || ($ARGV[0] eq ""))
{
  print "$0 <last build directory> <new build directory>\n";
  exit;
}

#$filever = "6.1.1.106"; #TODO this has to be obtained from somewhere, most probably buildno.h

@filever = `filever $ARGV[1]\\windows\\webable\\topclass.dll`;
#print "$filever[0]\n";
@filever[0]=~/[A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* +([0-9\.]*)/;

$tc_filever = $1;


#@diffs = `f:\\stuff\\diff.exe -q -r $ARGV[0] $ARGV[1]`;

open (DIFFS,"diffs");

$oldlistcount=0;
$newlistcount=0;
$incorrectcount=0;
$diffcount=0;
while (<DIFFS>)
#for each $diff (@diffs)
{
  #  $_ = $diff;
  $pattern=$ARGV[0];
  $pattern =~ s/\\/\\\\/g;
  if (/^Files $pattern([A-Za-z&0-9\-_\/\\\.]*) .*differ$/)
  {
    $file = $1;
    if ($file=~/topclass\.dll/) # don't bother checking topclass
    {
      #print "not bothering to check topclass.dll\n";
    }
    else
    {
      if ($file=~/\.dll|\.exe/) # check dlls and exes
      {
        $file=~s/\//\\/g;
        #print "filever $ARGV[1]\\$file\n";
        @newFileVer = `filever $ARGV[1]\\$file`;
        #print "$newFileVer[0]\n";
        $newFileVer[0] =~ /[A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* [A-Za-z0-9\-_]* +([0-9\.]*)/;
        if ($1 ne $tc_filever) #if dll/exe has incorrect build number
        {
          @incorrectlist[$incorrectcount++] = $file;
          #print "$ARGV[1]/$file has an incorrect build number $1 ($ARGV[1]/windows/webable/topclass.dll has $tc_filever)\n";
          #exit;
        }
        else
        {
          @os = `ls -l $ARGV[0]/$file`;
          $os[0]=~/^[-rwx]+[	 ]+[0-9][	 ]+[A-Za-z0-9\-_]+[	 ]+[A-Za-z0-9\-_]+[	 ]*([0-9]*)/;
          $oldsize = $1;

          @ns = `ls -l $ARGV[1]/$file`;
          $ns[0]=~/^[-rwx]+[	 ]+[0-9][	 ]+[A-Za-z0-9\-_]+[	 ]+[A-Za-z0-9\-_]+[	 ]*([0-9]*)/;
          $newsize = $1;
          if ($oldsize == $newsize) # if the dlls are the same size
          {
            @output = `perl bindiff.pl $ARGV[0]$file $ARGV[1]$file`;
            if ($output ne "")
            {
              @difflist[$diffcount++] = $file;
              #print "$ARGV[1]/$file is different\n";
            }
          }
          else
          {
            @difflist[$diffcount++] = $file;
            #print "$ARGV[1]/$file has a different size\n";
          }
        }
      }
      else
      {
        @difflist[$diffcount++] = $file;
        #print $_;
      }
    }
  }
  else
  {
      $oldpattern=$ARGV[0];
      $oldpattern =~ s/\\/\\\\/g;
      $newpattern=$ARGV[1];
      $newpattern =~ s/\\/\\\\/g;
      if (/^Only in $oldpattern: ([A-Za-z&0-9\-_\/\\\.]*)$/)
      {
        @oldList[$oldlistcount++] = $1;
      }
      elsif (/^Only in $newpattern: ([A-Za-z&0-9\-_\/\\\.]*)$/)
      {
        @newList[$newlistcount++] = $1;
      }
  }
}



print "Items removed in this iteration\n";
for($loop =0; $loop < $oldlistcount; $loop++)
{
  print $oldList[$loop]. "\n";
}
print "Items added in this iteration\n";
for($loop =0; $loop < $newlistcount; $loop++)
{
  print $newList[$loop]. "\n";
}
print "Items changed in this iteration\n";
for($loop =0; $loop < $diffcount; $loop++)
{
  print $difflist[$loop]. "\n";
}
print "Items with incorrect build numbers in this iteration\n";
for($loop =0; $loop < $incorrectcount; $loop++)
{
  print $incorrectlist[$loop]. "\n";
}


