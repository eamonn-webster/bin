#
# File:     translate.pl
# Auhtor:   JohnBoy
# Copyright WBT Systems, 1995-2002
# Contents: Some perl code that does some things will TopClass
# language resources or something like that
#

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common qw(POST);
use HTTP::Response;
use HTML::LinkExtor;
use LWP::Simple ;
use HTTP::Cookies;
use FileHandle;



#$url = "http://translator.dictionary.com/text.html";
$url = "http://babelfish.altavista.com/tr";
$ua = new LWP::UserAgent;
$ua->agent("Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)");
$r = "";
$Cooky = HTTP::Cookies->new;

if ( $ARGV[0] eq "" ){
  print "Who allowed you to run this script?\n";
  print "Usage: trans <pants>\n";
  print "DO NOT specify .dat\n";
  print "Produces foreign muck\n";
}

$INPUT = $ARGV[0] . ".dat";
#$GERMAN = ">" . $ARGV[0] . "_de.dat";
#$FRENCH = ">" . $ARGV[0] . "_fr.dat";
#$CHINESE = ">" . $ARGV[0] . "_zh.dat.translated";
$RUSSIAN = ">" . $ARGV[0] . "_ru.dat.translated";

open INPUT or die "Cannot open $INPUT\n";
#open GERMAN or die "Cannot open $GERMAN for writing\n";
#open FRENCH or die "Cannot open $FRENCH for writing\n";
#open CHINESE or die "Cannot open $CHINESE for writing\n";
open RUSSIAN or die "Cannot open $RUSSIAN for writing\n";


STDOUT->autoflush(1);
#CHINESE->autoflush(1);
RUSSIAN->autoflush(1);

init();
while ( <INPUT> ){
  next if ( /^$/ );

  if ( /\"([^\"]*)\"\W+([0-9]*)\W+\"([^\"]*)\"/ ){
    $funcname = $1;
    $strnumber = $2;
    $strvalue = $3;

    print "#";

    if ( $strvalue eq "" )
      {
        #print GERMAN "\"$funcname\" $strnumber \"\"\n";
        #print FRENCH "\"$funcname\" $strnumber \"\"\n";
        #print CHINESE "\"$funcname\" $strnumber \"\"\n";
        print RUSSIAN "\"$funcname\" $strnumber \"\"\n";
      }
    else
      {
        #$french = translate($strvalue, "en_fr");
        #$german = translate($strvalue, "en_ge");
        #$chinese = translate($strvalue, "en_zh");
        $russian = translate($strvalue, "en_ru");
        #print GERMAN "\"$funcname\" $strnumber \"$german\"\n";
        #print FRENCH "\"$funcname\" $strnumber \"$french\"\n";
        #print CHINESE "\"$funcname\" $strnumber \"$chinese\"\n";
        print RUSSIAN "\"$funcname\" $strnumber \"$russian\"\n";
     }
  }
}

close INPUT;
close OUTPUT;

sub init(){
  my $request = new HTTP::Request("GET", $url);
  my $response = $ua->request($request);
  $Cooky->extract_cookies($response);
  my $content = $response->content();

  if ($content =~ /<INPUT TYPE=\"hidden\" NAME=\"r\" VALUE=\"([^\"]*)\">/ ){
   print "r is $1\n";
   $r = $1;
  }

}

sub translate(){

  %postargs = (
    r => $r,
    text   => $_[0],
    lp  => $_[1],
    submit => "Translate"
  );

  my $request = POST $url, [%postargs];
  $Cooky->add_cookie_header($request);
  my $response = $ua->request($request);
  $Cooky->extract_cookies($response);
  my $content = $response->content();

#  return $content;

  my $trans = "XNONE";


  while ($content =~ /<td bgcolor=white class=s><div style=padding:10px;>(.*?)<\/div><\/td>/mg){
    #print "$_[0] ==> $1";
    $trans = $1;
  }
  return $trans;
}
