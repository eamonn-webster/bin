use strict;
use XMLRPC::Lite;
use File::Basename qw(dirname);
use File::Spec;
use HTTP::Cookies;

# Three inputs

# 1) Issues mentioned in checkin comments
# 2) Issues listed in changes.txt
# 3) Seacrh of bunny for issues fixed in build...


my $issuesHtml;
my $changesTxt;
my $xcheckHtml;
my $LogDir;
my $MNP;
my $mnp;

my $PreviousBuild;
my $CurrentBuild;

$MNP = "8.1.0";
$mnp = "810";
$PreviousBuild = "020";
$CurrentBuild = "022";

my $bugzilla = "http://bunny.wbt.wbtsystems.com";
#$bugzilla = "http://prism:81" if ( "prism" eq lc $ENV{COMPUTERNAME} );
$bugzilla = "http://localhost:81/topclass" if ( "floyd" eq lc $ENV{COMPUTERNAME} );

my $CurrentLabel = "TC_${mnp}_BUILD_$CurrentBuild";
my $PreviousLabel = "TC_${mnp}_BUILD_$PreviousBuild";

my $CurrentDisplay = "${MNP} build $CurrentBuild";
my $PreviousDisplay = "${MNP} build $PreviousBuild";

$LogDir = osify( "//wendy/d\$/autodevbuild/buildlogs/TopClassV${MNP}/build$CurrentBuild" );

my $issuesHtml = osify( "$LogDir/IssuesSinceBuild$PreviousBuild.html" );
my $changesTxt = osify( "$LogDir/changes.txt" );
my $xcheckHtml = osify( "c:/temp/xcheck.html" );

my %issueNumbers;
my %issues;
my %changes;
my %bunny;

sub getBugzilla() {

  my $xmlrpc = "$bugzilla/xmlrpc.cgi";
  my $cookie_jar = new HTTP::Cookies(ignore_discard => 1);

  my $proxy = XMLRPC::Lite->proxy( $xmlrpc, 'cookie_jar' => $cookie_jar);

  print "Have opened $xmlrpc\n";

  if ( 1 ) {
    my $soapresult = $proxy->call('Bugzilla.version');
    #_die_on_fault($soapresult);
    my $fault = $soapresult->fault;
    if ( $fault ) {
      print "fault: " . $soapresult->faultcode . ": " . $soapresult->faultstring . "\n";
    }
    else {
      print 'Connected to a Bugzilla of version ' . $soapresult->result()->{version} . ".\n";
    }
  }

  if ( 1 ) {
    my $soapresult = $proxy->call('User.login', { login => 'bob@wbtsystems.com', password => 'bobbob' });
    my $fault = $soapresult->fault;
    if ( $fault ) {
      print "fault: " . $soapresult->faultcode . ": " . $soapresult->faultstring . "\n";
    }
  }

  if ( 0 ) {
    my $soapresult = $proxy->call('Example.hello');
    ##_die_on_fault($soapresult);
    #print "\$soapresult $soapresult\n";
    my $fault = $soapresult->fault;
    if ( $fault ) {
      print "fault: " . $soapresult->faultcode . ": " . $soapresult->faultstring . "\n";
    }
    else {
      #print "\$fault $fault\n";
      my $result = $soapresult->result;
      print "\$result $result\n";
      #my @resultKeys = keys (%$result);
      #print "\$result keys @resultKeys\n";
    }
    #return;
  }

  if ( 0 ) {
    my $label;
    $label = "TC_800_BUILD_130";
    my $soapresult = $proxy->call('Keyword.create', { name => $label, description => "Fixed in $label" });
    ##_die_on_fault($soapresult);
    #print "\$soapresult $soapresult\n";
    my $fault = $soapresult->fault;
    if ( $fault ) {
      print "fault: " . $soapresult->faultcode . ": " . $soapresult->faultstring . "\n";
    }
    else {
      #print "\$fault $fault\n";
      my $result = $soapresult->result;
      #print "\$result $result\n";
      my @resultKeys = keys (%$result);
      #print "\$result keys @resultKeys\n";
      print "\$result id " . $result->{id} . "\n";
    }
    #return;
  }

  if ( 1 ) {
    my $label;
    $label = "TC_810_BUILD_024";
    print "Retrieving bugs for keyword $label\n";
    #my $soapresult = $proxy->call('Bug.search', { limit => $limit, cf_fixed_in_version => $MNP });
    #my $soapresult = $proxy->call('Bug.search', { limit => $limit, keywords => $keyword });
    my $soapresult = $proxy->call('Keyword.bugs', { name => $label });
    my $fault = $soapresult->fault;
    if ( $fault ) {
      print "fault: " . $soapresult->faultcode . ": " . $soapresult->faultstring . "\n";
    }
    else {
      my $result = $soapresult->result;
      print "\$result keywordid " . $result->{id} . "\n";

      my $limit = 1000;
      for ( 0 .. $limit ) { #length ($result->{bugs}) ) {
        my $bug = $result->{bugs}->[$_];
        next unless ( $bug );

        my $bug_id = $bug->{id};
        my $bug_summary = $bug->{summary};
        my $bug_status = $bug->{status};
        print "$bug_id $bug_status $bug_summary\n";

        $issueNumbers{$bug_id} = $bug_id;
        if ( $bunny{$bug_id} ) {
          $bunny{$bug_id} .= "<br/>\n" . $bug_summary;
        }
        else {
          $bunny{$bug_id} = $bug_summary;
        }
      }
    }
  }
}

getBugzilla();



#print XMLRPC::Lite
#      -> proxy('http://betty.userland.com/RPC2')
#      -> call('examples.getStateStruct', {state1 => 12, state2 => 28})
#      -> result;
#exit;

sub osify($) {
  my ($path) = @_;
  if ( $^O eq "MSWin32" ) {
    $path =~ s!/!\\!g;
  }
  else {
    $path =~ s!\\!/!g;
  }
  return $path;
}

if ( 0 and open( IN, $issuesHtml ) ) {
  print "Have opened $issuesHtml\n";
  while ( <IN> ) {
    if ( /<td class='nowidth' valign='top'><a href="[^"]+">#([0-9]+)<\/a>(.+)<\/td>/ ) { # "
      $issueNumbers{$1} = $1;
      if ( $issues{$1} ) {
        $issues{$1} .= "<br/>\n" . $2;
      }
      else {
        $issues{$1} = $2;
      }
    }
    elsif ( /<td class='nowidth' valign='top'><a href="[^"]+">#([0-9]+)<\/a>(.+)/ ) { # "
      unless ( eof(IN) ) {
        $_ .= "\n" . <IN>; # separate with a line break
        redo; # unless eof(IN);
      }
    }
  }
  close( IN );
}
if ( 0 and open( IN, $changesTxt ) ) {
  print "Have opened $changesTxt\n";
  while ( <IN> ) {
    if ( /#([0-9]+) (.+)/ ) {
      $issueNumbers{$1} = $1;
      if ( $changes{$1} ) {
        $changes{$1} .= "<br/>\n" . $2;
      }
      else {
        $changes{$1} = $2;
      }
    }
  }
  close( IN );
}

# reverse sort
my @numbers = sort { $b cmp $a } keys ( %issueNumbers );

if ( open( OUT, ">$xcheckHtml" ) ) {
  print "Have opened $xcheckHtml\n";
  print OUT "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"  \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n";
  print OUT "<html>\n";
  print OUT "<head>\n";
  print OUT "  <title>Cross Check Issues</title>\n";
  print OUT "  <link rel=\"stylesheet\" href=\"../../build.css\" type=\"text/css\" />\n";
  print OUT "</head>\n";
  print OUT "<body>\n";
  print OUT "<div>\n";
  if ( $CurrentLabel eq "LATEST" )
    {
      print OUT "  <h1>Issues mentioned since $PreviousDisplay\n";
    }
  else
    {
      print OUT "  <h1>Issues mentioned between $CurrentDisplay and $PreviousDisplay\n";
    }
# print OUT "  <img src=\"../../yeswecan.jpg\" width=\"195\" height=\"214\" alt=\"yes we can\" />\n";
  print OUT "  </h1>\n";
  print OUT "  <table summary=\"Issues\">\n";
  print OUT "    <tr>\n";
  print OUT "      <th class='header'>Issue</th>\n";
  print OUT "      <th class='header'>Check Ins</th>\n";
  print OUT "      <th class='header'>Changes</th>\n";
  print OUT "      <th class='header'>Bunny</th>\n";
  print OUT "    </tr>\n";
  foreach ( @numbers ) {
#<td class='nowidth' valign='top'>$comment</td>
    print OUT "    <tr>\n";
    print OUT "      <td class='nowidth' valign='top'><a href=\"$bugzilla/show_bug.cgi?id=$_\">#$_</a></td>\n";
    print OUT "      <td class='nowidth' valign='top'>" . $issues{$_} . "</td>\n";
    print OUT "      <td class='nowidth' valign='top'>" . $changes{$_} . "</td>\n";
    print OUT "      <td class='nowidth' valign='top'>" . $bunny{$_} . "</td>\n";
    print OUT "    </tr>\n";
  }

  print OUT "  </table>\n";
  print OUT "</div>\n";
  print OUT "</body>\n";
  print OUT "</html>\n";
  close( OUT );
}

