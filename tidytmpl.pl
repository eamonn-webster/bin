#
#  File: tidyhtml.pl
#  Author: eweb
#
# Date:          Author:  Comments:
# 12th Oct 2006  eweb     Tidy html tags in templates.
# 17th Oct 2006  eweb     Comments and no eoln @ eof.
#

use strict;

my $in = $ARGV[0];

sub formatAttrs( $ )
  {
    my ($attrs) = @_;
    $attrs =~ s!scope="COL"!scope="col"!gi;
    $attrs =~ s!method="POST"!method="post"!gi;
    $attrs =~ s!/>! />!gi;
    $attrs =~ s!  />! />!gi;
    $attrs =~ s!< />!<>!gi;
    print OUT $attrs;


#    while ( $attrs ne "" )
#      {
#        if ( $attrs =~ /(\s*)([^ =]+)(="[^"]*")(.*)/ ) #"
#          {
#            print OUT $1 . (lc $2) . $3;
#            $attrs = $4;
#          }
#        elsif ( $attrs =~ /(\s*)([^ =]+)(='[^']*')(.*)/ ) #'
#          {
#            print OUT $1 . (lc $2) . $3;
#            $attrs = $4;
#          }
#        elsif ( $attrs =~ /(\s*)([^ =]+)(=[^ ]*)(.*)/ ) #'
#          {
#            print OUT $1 . (lc $2) . $3;
#            $attrs = $4;
#          }
#        elsif ( $attrs =~ /(\s*)([^ =]+)(.*)/ ) #'
#          {
#            print OUT $1 . (lc $2);
#            $attrs = $4;
#          }
#        else
#          {
#            print OUT $attrs;
#            $attrs = undef;
#          }
#      }
  }

if ( open( OUT, ">../new/$in") )
  {
    if ( open( PRETTY, "$in") )
      {
        my $tag;
        my $comment;
        while ( <PRETTY> )
          {
            my $line = $_;
            my $eoln = "";
            if ( /\n$/ )
              {
                $eoln = "\n";
              }
            $line =~ s!/+>!/>!g;
            while ( $line ne "" )
              {
                # are we still in a comment?
                if ( $comment )
                  {
                    if ( $line =~ /(.*)(-->)?(.*)/ )
                      {
                        print OUT $1;
                        if ( $2 )
                          {
                            print OUT $2;
                            $comment = undef;
                          }
                        $line = $3;
                      }
                  }
                # are we still in a tag?
                elsif ( $tag ne "" )
                  {
                    if ( $line =~ /(.*)(\/*>?)(.*)/ )
                      {
                        # $1 are attributes
                        my $attrs = $1;
                        # $2 the end slash
                        my $endSlash = $2;
                        # $3 the end of the tag
                        my $endTag = $3;
                        # $4 what comes after the tag
                        my $postTag = $4;

                        formatAttrs( $attrs );

                        if ( $endTag )
                          {                            
                            if ( $endSlash )
                              {
                                print OUT "/";
                              }
                            elsif ( " img input br hr " =~ / $tag /i )
                              {
                                #print "Found end of $tag\n";
                                if ( $postTag =~ /<\/$tag/ )
                                  {
                                    #print "has close tag\n";
                                  }
                                else
                                  {
                                    #print "closing the tag\n";
                                    print OUT "/";
                                  }
                              }
                            print OUT $endTag;
                            $tag = undef;
                          }
                        $line = $postTag;
                      }
                    else 
                      {
                        print "How could this happen?\n";
                      }
                  }
                else 
                  {
                    if ( $line =~ /([^<]*)<!--(.*)(-->)?(.*)/ )
                      {
                        # $1 before the comment
                        # <!--
                        # $2 the comment
                        # $3 --> or undef
                        # $4 after the comment

                        print OUT $1;
                        print OUT "<!--" . $2;
                        if ( $3 )
                          {                            
                            print OUT $3;
                            $comment = undef;
                          }
                        else
                          {
                            $comment = 1;
                          }
                        $line = $4;
                      }
                    elsif ( $line =~ /([^<]*)<(\/?[A-Za-z0-9]+)(.*)(\/*>)?(.*)/ )
                      {
                        # $1 before the tag
                        # <
                        # $2 the tag
                        # $3 the attributes
                        # $4 close slash
                        # $5 end of tag
                        # $6 after the tag
                        
                        my $preTag = $1;
                        $tag = $2;
                        my $attrs = $3;
                        my $endSlash = $4;
                        my $endTag = $5;
                        my $postTag = $6;

                        print OUT $preTag;
                        if ( " messageBody /messageBody iCalendar /iCalendar " =~ / $tag / )
                          {
                            print OUT "<" . $tag;
                          }
                        else
                          {
                            print OUT "<" . lc $tag;
                          }
                        # the attributes...
                        
                        formatAttrs( $attrs );
                        
                        if ( $endTag )
                          {                            
                            if ( $endSlash )
                              {
                                print OUT "/";
                              }
                            elsif ( " img input br hr " =~ / $tag /i )
                              {
                                #print "Found end of $tag\n";
                                if ( $postTag =~ /<\/$tag/ )
                                  {
                                    #print "has close tag\n";
                                  }
                                else
                                  {
                                    #print "closing the tag\n";
                                    print OUT "/";
                                  }
                              }
                            print OUT $endTag;
                            $tag = undef;
                          }
                        $line = $postTag;
                        # w
                      }
                    elsif ( $line =~ /(.*)/ )
                      {
                        print OUT $1;
                        $line = undef;
                      }
                  }
              }
            print OUT $eoln;
            #s!<(/?[A-Za-z]+)!<\L\1\E!g;

            #s!<([A-Za-z]+)(.*) ([A-Za-z]+=)!<\L\1\E\2 \L\3\E!g;
            #print OUT "$_\n";
          }
      }
    close(OUT);
  }


