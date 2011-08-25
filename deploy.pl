#******************************************************************************/
#
#  File: deploy.pl
#  Author: eweb
#  Copyright WBT Systems, 2003-2006
#  Contents: Manifest based deployment
#
#******************************************************************************/
#
#   Date:          Author:  Comments:
#   26th Nov 2006  eweb     Initial version.
#

#
# Will need to read a config.xml taht specifies the locations of the directories
#
# 1) Create a manifest
#   - a recursive list of all files, giving name, date, size and crc.
#   - and add fiels to a zip.
# 2) Create a diffs manifest.
#   - like before but this time we check against an existing manifest.
#   - and only add those fiels that have changed...


# will need to be able to exclude files e.g message*.txt


use strict;
use Getopt::Std;
use File::stat;
use Time::gmtime;
use Archive::Zip;

#doDirectory( "webable", "c:\\cpp\\tc742\\topclass\\oracle\\topclass\\www\\" );
#doDirectory( "nonwebable", "c:\\cpp\\tc742\\topclass\\oracle\\topclass\\www\\" );

my $zip; # = Archive::Zip->new();

#   my $member = $zip->addDirectory( 'dirname/' );
#   $member = $zip->addString( 'This is a test', 'stringMember.txt' );
#   $member->desiredCompressionMethod( COMPRESSION_DEFLATED );
#   $member = $zip->addFile( 'xyz.pl', 'AnotherName.pl' );
#   die 'write error' unless $zip->writeToFileNamed( 'someZip.zip' ) == AZ_OK;
#   $zip = Archive::Zip->new();
#   die 'read error' unless $zip->read( 'someZip.zip' ) == AZ_OK;
#   $member = $zip->memberNamed( 'stringMember.txt' );
#   $member->desiredCompressionMethod( COMPRESSION_STORED );
#   die 'write error' unless $zip->writeToFileNamed( 'someOtherZip.zip' ) == AZ_OK;


sub doDirectory( $$ )
  {
    my ( $relpath, $path ) = @_;
    print MANIFEST "<directory name=\"$relpath\">\n";
    my $dirh;
    if ( opendir( $dirh, $path ) )
      {
        my $file;
        while ( defined( $file = readdir($dirh) ) )
          {
            if ( $file eq "." or $file eq ".." )
              {
              }
            elsif ( -d "$path\\$file" )
              {
                doDirectory( "$relpath/$file", "$path\\$file" );
              }
            elsif ( -e "$path\\$file" )
              {
                my $st = stat("$path\\$file");
                my $size = $st->size;
                my $mtime = $st->mtime;
                my $ti = gmtime($mtime);
                my $date = ($ti->year + 1900) . " " . ($ti->mon + 1) . " " . $ti->mday;
                my $time = sprintf( "%02d:%02d:%02d", $ti->hour, $ti->min, $ti->sec );
                my $crc = 0;
                if ( open( F, "$path\\$file" ) )
                  {
                    while ( <F> )
                      {
                        $crc = Archive::Zip::computeCRC32( $_, $crc );
                      }
                    close( F );
                  }
                $crc = sprintf( "%08x", $crc );
                print MANIFEST "<file name=\"$file\" size=\"$size\" date=\"$date\" time=\"$time\" crc=\"$crc\" />\n";
                if ( $zip )
                  {
                    my $member = $zip->addFile( "$path\\$file", "$relpath/$file" );
                  }
              }
          }
        closedir(dirh);
      }
    print MANIFEST "</directory>\n";
  }
sub CreateManifest()
  {
    if ( open( MANIFEST, ">manifest.xml" ) )
      {
        $zip = Archive::Zip->new();
        doDirectory( "webable", "c:\\cpp\\tc742\\topclass\\oracle\\topclass\\www\\" );
        close( MANIFEST );
        if ( $zip )
          {
            $zip->addFile( "manifest.xml" );
            $zip->writeToFileNamed( 'topclass.zip' );
          }
      }
  }

CreateManifest();
system( "type manifest.xml" );
