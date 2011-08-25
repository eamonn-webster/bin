use strict;


my $in = $ARGV[0];

my $switches = "--style=gnu --indent-switches --pad=all";
#$switches = "";
my $cmd = "astyle $switches < $in";

my @Types = qw/CTCQpiManager void*& CString CLIPFORMAT TCPublisherExplorer HDROP CTCPublisherDoc long UINT int char TCHAR PubUlm PubTest CCmdUI CExportMenu PubModule tcxmlobject CFile PubCourse PubMediaAttribute CFont CDocument DACMgr PubQuestionPool BYTE PubAction DWORD LPARAM LPCTSTR NM_TREEVIEW TV_DISPINFO CImageList PubTrash PubPage PubQuestion CPubAddAction CPubRemAction CPubNotifyAction CPubEnrollAction/;

if ( open( OUT, ">$in.new") )
  {
    if ( open( PRETTY, "$cmd |") )
      {
        my $extra = "";
        my $saveExtra = "";
        while ( <PRETTY> )
          {
            chomp;
            s!\s+$!!;
            s!\) ->!\)->!g;
            s!_T\( ("([^\\"]|\\.)*") \)!_T\(\1\)!g;
            s!_TEXT\( ("([^\\"]|\\.)*") \)!_TEXT\(\1\)!g;
            s!_T\( ('([^\\']|\\.)*') \)!_T\(\1\)!g;
            s!_TEXT\( ('([^\\']|\\.)*') \)!_TEXT\(\1\)!g;
            s!return ;!return;!g;
            s! \[!\[!g;
            s!\[ !\[!g;
            s! \]!\]!g;
            for my $type ( @Types )
              {
                s!$type \* !$type\* !g;
                s!$type \*!$type\* !g;
                s!\( $type\* \)!\($type\*\)!g;
                s!\( $type\*\)!\($type\*\)!g;
                s!\($type\* \)!\($type\*\)!g;
                s!\($type\*\) !\($type\*\)!g;
                s!\( $type \)!\($type\)!g;
                s!\($type\) !\($type\)!g;
              }
            if ( /^{$/ )
              {
                $extra = "  ";
              }
            if ( $_ ne "" )
              {
                print OUT $extra;
              }
            print OUT "$_\n";
            if ( /^}$/ )
              {
                $extra = "";
              }
          }
      }
    close(OUT);
  }


