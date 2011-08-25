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



$url = "http://translator.dictionary.com/text.html";
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
$GERMAN = ">" . $ARGV[0] . ".de.dat";
$FRENCH = ">" . $ARGV[0] . ".fr.dat";

open INPUT or die "Cannot open $INPUT\n";
open GERMAN or die "Cannot open $GERMAN for writing\n";
open FRENCH or die "Cannot open $FRENCH for writing\n";



init();
while ( <INPUT> ){
  next if ( /^$/ );

  if ( /\"([^\"]*)\"\W+([0-9]*)\W+\"([^\"]*)\"/ ){
    $funcname = $1;
    $strnumber = $2;
    $strvalue = $3;

    print "#";
    $french = translate($strvalue, "en_fr");
    $german = translate($strvalue, "en_ge");
    print GERMAN "\"$funcname\" $strnumber \"$german\"\n";
    print FRENCH "\"$funcname\" $strnumber \"$french\"\n";

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
 
  my $trans = "XNONE";

  while ($content =~ /<!-- resultListStart -->\n<P>(.*?)<\/P>\n<!-- resultListEnd -->/mg){
    #print "$_[0] ==> $1";
    $trans = $1;
  }
  return $trans;
}
