use strict;
use MP3::Tag;
use Audio::WMA;

while ( <@ARGV> ) {
  print "$_\n";

  # set filename of MP3 track
  my $filename = $_;

  if ( $filename =~ /\.wma$/ ) {

    my $wma  = Audio::WMA->new($filename);

    #my $info = $wma->info();

    #foreach (keys %$info) {
    #  print "$_: $info->{$_}\n";
    #}

    my $tags = $wma->tags();

    my @tags_to_display = qw/ALBUMARTIST AUTHOR TITLE ALBUMTITLE PUBLISHER YEAR PROVIDER PROVIDERSTYLE GENRE TRACKNUMBER COMPOSER LYRICS/;
#MEDIACLASSPRIMARYID: D1607DBC-E323-4BE2-86A1-48A42A28441E
#COPYRIGHT:
#MEDIACLASSSECONDARYID: 00000000-0000-0000-0000-000000000000
# id of cd?
#WMCOLLECTIONGROUPID: C7F1F402-8848-476A-BBFE-BB6C5A1CBA42
#UNIQUEFILEIDENTIFIER: AMGa_id=R    55129;
#VBR: 0
#WMCOLLECTIONID: C7F1F402-8848-476A-BBFE-BB6C5A1CBA42
#ENCODINGTIME: 1.284573249e+017
#PROVIDERRATING: 4
#DESCRIPTION:

    #foreach (keys %$tags) { }
    foreach ( @tags_to_display ) {
      print "$_: $tags->{$_}\n";
    }
    if ( $tags->{TITLE} eq "I Don't Care" ) {
      $tags->{LYRICS} = "I couldn't give a sh*t!";
    }
    $wma->write();
  }
  else {
    # create new MP3-Tag object
    my $mp3 = MP3::Tag->new($filename);

    # get tag information
    $mp3->get_tags();

    #print "$mp3\n";
    #foreach ( keys $mp3 ) {
    #  print "$_\n";
    #}

    # check to see if an ID3v1 tag exists
    # if it does, print track information

    my @info = $mp3->autoinfo();
    print "@info\n";

    my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
    print "($title, $track, $artist, $album, $comment, $year, $genre)\n";

    if (exists $mp3->{ID3v1}) {
      print "Filename: $filename\n";
      print "Artist: " . $mp3->{ID3v1}->artist . "\n";
      print "Title: " . $mp3->{ID3v1}->title . "\n";
      print "Album: " . $mp3->{ID3v1}->album . "\n";
      print "Year: " . $mp3->{ID3v1}->year . "\n";
      print "Genre: " . $mp3->{ID3v1}->genre . "\n";
    }
    elsif (exists $mp3->{ID3v2}) {
      print "Filename: $filename\n";
      print "Artist: " . $mp3->{ID3v2}->artist . "\n";
      print "Title: " . $mp3->{ID3v2}->title . "\n";
      print "Album: " . $mp3->{ID3v2}->album . "\n";
      print "Year: " . $mp3->{ID3v2}->year . "\n";
      print "Genre: " . $mp3->{ID3v2}->genre . "\n";
    }
    else {
      print "No ID3 data\n";
    }
    # clean up
    $mp3->close();
  }

}

=comment

16 I Am the Greatest.wma
max_packet_size: 5976
codec: Windows Media Audio V7 / V8 / V9
bits_per_sample: 16
bitrate: 129223.836129079
play_duration: 3056720000
preroll: 1579
flags_raw: 2
fileid_guid: 1062D336-11E7-4C56-95E8-28BAB3B944BC
sample_rate: 44100
data_packets: 821
channels: 2
flags: HASH(0x1c3dd20)
creation_date_unix: -11644473324
min_packet_size: 5976
filesize: 4912008
playtime_seconds: 304.093
creation_date: 2750547904
send_duration: 3050140000
max_bitrate: 128639
ALBUMTITLE: I Am the Greatest
PUBLISHER: Setanta
YEAR: 1992
PROVIDER: AMG
PROVIDERSTYLE: Rock
RATING:
MEDIACLASSPRIMARYID: D1607DBC-E323-4BE2-86A1-48A42A28441E
GENRE: Alternative
COPYRIGHT:
TRACKNUMBER: 16
MEDIACLASSSECONDARYID: 00000000-0000-0000-0000-000000000000
COMPOSER: A-House
LYRICS: 0
WMCOLLECTIONGROUPID: C7F1F402-8848-476A-BBFE-BB6C5A1CBA42
UNIQUEFILEIDENTIFIER: AMGa_id=R    55129;
VBR: 0
ALBUMARTIST: A House
WMCOLLECTIONID: C7F1F402-8848-476A-BBFE-BB6C5A1CBA42
AUTHOR: A House
MEDIAPRIMARYCLASSID: {D1607DBC-E323-4BE2-86A1-48A42A28441E}
ENCODINGTIME: 1.284573249e+017
TITLE: I Am the Greatest
PROVIDERRATING: 4
DESCRIPTION:
MCDI: 1 0 + 9 6 + 4 2 D 3 + 7 F 0 D + B 4 7 D + E 4 7 C + 1 0 B 7 1 + 1 5 A A 6 + 1 7 C 0 2 + 1 C 0 6 6 + 1 D 7 2 2 + 2 1 D B F + 2 6 3 4 7 + 2 9 5 5 4 + 2 C 0 6 7 + 3 0 6 1 A + 3 3 1 A 5 + 3 8 A B D



=cut
