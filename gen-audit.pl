##;
###  File: gen-audit.lsp
###  Author: eweb
###  Copyright WBT Systems, 1998-2008
###  Contents:
###     Generation of tables, procedures and triggers for Audit

#;
#  Date:          Author:  Comments:
#  16th Jan 2008  eweb     #00009 First attempt at generating audit.
#  25th Jan 2008  eweb     #10721 Paths and file names
#;

#;
#  TODO Type column (e.g. WGoal_Type)
#  TODO Link tables
#  TODO Extras WLogin and WOption
#  TODO Exclude base columns from some sub classes e.g. WCourse.WAccess
#;

use strict;
use XML::Simple;
use Data::Dumper;


=task

what to do?
read in a definition of a table
spit out
1) a create table script
2) a create/replace trigger script
3) a create/replace audit procedure script.

need to decide on format of input, xml.

<table name="WUser">
  <column name="WUser_ID" type="number" />
  <column name="WUserName" type="string" />
</table>

=cut


my %default_size = (
  id => 10,
  number => 10,
 #date => undef,
  char => 1,
  string => 255,
);

my %sized_type = (
  id => "%s(%d)",
  number => "%s(%d)",
  date => "%s",
  char => "%s(%d)",
  string => "%s(%d)",
);

my %sql_type = (
  id => "NUMBER",
  number => "NUMBER",
  date => "DATE",
  char => "CHAR",
  string => "VARCHAR2",
);

sub sql_type_sized($$) {
  my ($type, $size) = @_;
  #print "sql_type_sized @_\n";
  return sprintf( $sized_type{$type}, $sql_type{$type}, $size );
}

sub table_column ($$$$$) {
  my ($comma, $name, $type, $size, $not_null) = @_;

  #print "table_column @_\n";
  if ( !$size ) {
    $size = $default_size{$type};
  }
  my $sizedtype = sql_type_sized($type,$size);


  if ( $not_null eq "true" or $not_null eq 1 ) {
    $not_null = "NOT ";
  }
  else {
    $not_null = "";
  }

  printf( OUT " %s%-27s %-31s %sNULL\n", ($comma ? "," : " "), $name, $sizedtype, $not_null );
}


my %options = ( KeyAttr => () );

my $c = &XMLin("audit.xml", %options );

#my %config = $c;

print Dumper($c);

my $table = $c->{name};

if ( open( OUT, ">${table}_hist.sql" ) ) {
  aud_table($c);
  close OUT;
}
if ( open( OUT, ">aud_${table}.sql" ) ) {
  aud_trigger($c);
  close OUT;
}

if ( open( OUT, ">aud_${table}_proc.sql" ) ) {
  aud_proc($c);
  close OUT;
}

sub aud_table($) {
  my ($c) = @_;
  my $table = $c->{name};
  my @columns = @{$c->{column}};
  #print "table: $table\n";
  print OUT " -- Table: ${table}_hist\n";

  print OUT "CREATE TABLE ${table}_hist (\n";

  table_column( 0, "WAuditSeq", "number", 0, 1);
  table_column( 1, "WAuditDateTime", "date", 0, 1);
  table_column( 1, "WAuditedAction", "char", 1, 1);
  table_column( 1, "WAuditUser_ID", "number", 10, 1);

  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};

    #print "col: " . $colname . "\t";
    #print " " . $details{type} . " " . $details{size} ."\n";
    table_column( 1, $colname, $details{type}, $details{size}, $details{notnull} );
  }
  print OUT ")\n";
  print OUT "/\n";
}

sub aud_trigger($) {
  my ($c) = @_;
  my $table = $c->{name};
  my @columns = @{$c->{column}};
  print OUT "CREATE OR REPLACE TRIGGER aud_$table
BEFORE INSERT OR
       UPDATE OF ";
  my $comma = "";
  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};
    print OUT "$comma $colname";
    $comma = ",";
  }
  print OUT " OR
       DELETE
ON     ${table}
FOR EACH ROW
DECLARE

  lAuditedAction  CHAR(1) ;\n";

#    (dolist (s (cclass-audit-slots class))
#      (when (slot-audit-modify-value s class :var)
#        (funcall (slot-audit-modify-value s class :var) s class strm)))

  print OUT "BEGIN\n";

  print OUT "  IF (INSERTING) THEN

    lAuditedAction := 'I' ;\n\n";

#    (dolist (s (cclass-audit-slots class))
#      (when (slot-audit-modify-value s class :insert)
#        (funcall (slot-audit-modify-value s class :insert) s class strm)))

  print OUT "    aud_${table}_proc
    (
      lAuditedAction\n";

  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};
    print OUT "     ,:new.$colname\n";
  }
  print OUT "    );

  ELSIF
    (
      UPDATING
      AND
      (\n";

  my $or = "  ";
  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};
    my $type = $details{type};

    if ( $type eq "number" ) {
     #print OUT "        $or :new.$colname <> :old.$colname\n";
      print OUT "        $or NVL(:new.$colname, 0) <> NVL(:old.$colname, 0)\n";
    }
    elsif ( $type eq "id" ) {
     #print OUT "        $or :new.$colname <> :old.$colname\n";
      print OUT "        $or NVL(:new.$colname, 0) <> NVL(:old.$colname, 0)\n";
    }
    elsif ( $type eq "date" ) {
      print OUT "        $or NVL(:new.$colname, SYSDATE) <> NVL(:old.$colname, SYSDATE)\n";
    }
    elsif ( $type eq "string" ) {
      print OUT "        $or NVL(:new.$colname, '''') <> NVL(:old.$colname, '''')\n";
    }
    else {
      print "Error: Unknown coulmn type $type\n";
    }
    $or = "OR";
  }
  print OUT "      )
    )
  THEN

    lAuditedAction := 'U' ;\n\n";

#    (dolist (s (cclass-audit-slots class))
#      (when (slot-audit-modify-value s class :update)
#        (funcall (slot-audit-modify-value s class :update) s class strm)))

  print OUT "    aud_${table}_proc
    (
      lAuditedAction\n";

  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};
    print OUT "     ,:new.$colname\n";
  }
  print OUT "    );

  ELSIF (DELETING) THEN

    lAuditedAction := 'D' ;

    aud_${table}_proc
    (
      lAuditedAction\n";

  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};
    print OUT "     ,:old.$colname\n";
  }
  print OUT "    );

  END IF;

END ;
/
SHOW ERRORS\n";


}

sub aud_proc($) {
  my ($c) = @_;
  my $table = $c->{name};
  my @columns = @{$c->{column}};
  print OUT "CREATE OR REPLACE PROCEDURE aud_${table}_proc
  (\n";

#      (if (cclass-audit-return-seqno class)
#        print OUT "    aAuditSeq                   IN OUT NUMBER
#   ,aAuditedAction              IN CHAR\n")
        printf OUT "    a%-30s IN CHAR\n", "AuditedAction";

  foreach ( @columns ) {
    my %details = %{$_};
    my $name = substr($details{column_name},1);
    my $coltype = $sql_type{$details{type}};
    printf OUT "   ,a%-30s IN $coltype\n", $name;
  }
        print OUT "  )\n";
        print OUT "  AS
    lAuditUser_ID NUMBER := -1;
  BEGIN
    lAuditUser_ID := GetConnectionUser;\n\n";

#        (when (cclass-audit-return-seqno class)
#        print OUT "    SELECT Aud_Seq.nextval
#    INTO aAuditSeq
#    FROM tc_onerow;\n\n" ))

        print OUT "    INSERT INTO ${table}_hist
    (
      WAuditSeq
     ,WAuditDateTime
     ,WAuditedAction
     ,WAuditUser_ID\n";

  foreach ( @columns ) {
    my %details = %{$_};
    my $colname = $details{column_name};
    print OUT "     ,$colname\n";
  }
  print OUT "    )
    VALUES
    (
      Aud_Seq.nextval
     ,SYSDATE
     ,aAuditedAction
     ,lAuditUser_ID\n"; # (if (cclass-audit-return-seqno class) "aAuditSeq" "Aud_Seq.nextval") )

  foreach ( @columns ) {
    my %details = %{$_};
    my $name = substr($details{column_name},1);
    print OUT "     ,a$name\n";
  }
  print OUT "    );

  END;\n\n";
}


=lisp

(defvar *extra-audit-classes* nil)

(defun audit-classes ()
  (append *classes* *extra-audit-classes*))

(defun audit-script-dir ()
  (cond ((eq *rdbms* :oracle)
         (script-dir))
        (t # mssql
          (let ((dir (format nil "~amssql/internal/audit/" *gendir*)))
            (ensure-dir dir)
            dir))))

(defun exclude-slot-from-audit (slot class)
  (cond ((obsoletep slot) t)
        ((and (string= (cclass-name class) "WPage") (string= (slot-name slot) "Type")) t)
        ((and (string= (cclass-name class) "WCourse") (string= (slot-name slot) "Type")) t)
        ((and (string= (cclass-name class) "WCourse") (string= (slot-name slot) "Access")) t)
        ((and (string= (cclass-name class) "WExercise") (string= (slot-name slot) "Access")) t)
        (t nil)))

(defun cclass-audit-slots (class)
  (append
        (if (cclass-audit-no-id class) nil
          (list (make-slot :tag "ID" :audit t :type :long :id t :name (format nil "~a_ID" (subseq (cclass-name class) 1)))))
        (append
          (if (cclass-single-table class)
             (list (make-slot :tag "_typ" :audit t :type :CNeoString :size 32 :name (format nil "~a_Type" (subseq (cclass-name class) 1)))))
        (remove-if #'(lambda (s)
                       (exclude-slot-from-audit s class))
                   (remove-if-not #'slot-audit (all-slots-in-cclass class) )))))

(defun generate-audit-package ( &optional (what :full) )
  (format t "# Generating Audit Package\n")
  (let* ((stem "Audit")
         (fstem (if (eq *rdbms* :oracle) (script-stem stem what) (string-downcase stem)) )
         (fname (format nil "~a.sql" fstem))
         (fpath (format nil "~a~a" (audit-script-dir) fname)))
    (format t "#~a\n" fpath)
    (with-open-file (strm fpath :direction :output :if-exists :supersede)
      (oracle-file-banner (intern (string-upcase fstem)) :audit what strm (string-downcase fname))

      (when (eq *rdbms* :oracle)
        (if (eq what :proto)
            print OUT "CREATE OR REPLACE PACKAGE oAudit\nAS\n")
          print OUT "CREATE OR REPLACE PACKAGE BODY oAudit\nAS\n\n")))

        (dolist (class (audit-classes))
        (unless (exclude-class-from-schema class)
          (when (cclass-audit class)
            (gen-audit-proc class what strm)
            (gen-audit-link-procs class what strm)
            )))

      (when (eq *rdbms* :oracle)
        print OUT "END oAudit;\n/\nSHOW ERRORS\n"))
      (unless (eq what :proto)
        (update-config strm "oAudit"))
      )))


(defmacro with-procedure-check (name &rest body)
  `(cond ((eq *rdbms* :mssql)
          (gen-mssql-drop strm "PROCEDURE" ,name)
          ,@body
          print OUT "GO\n")
          (gen-mssql-CHECK strm "PROCEDURE" ,name))
         (t
          ,@body
         ))
)

(defmacro with-table-check (name &rest body)
  `(cond ((eq *rdbms* :mssql)
          (gen-mssql-drop strm "TABLE" ,name)
          ,@body
          print OUT "GO\n")
          (gen-mssql-CHECK strm "TABLE" ,name))
         (t
          ,@body
         ))
)

(defun cclass-audit-return-seqno (class)
  (cond ((null (cclass-audit class)) nil)
        ((listp (cclass-audit class)) (find :return-seqno (cclass-audit class)))
        (t nil))
)

(defun cclass-audit-custom-trigger (class)
  (cond ((null (cclass-audit class)) nil)
        ((listp (cclass-audit class)) (find :custom-trigger (cclass-audit class)))
        (t nil))
)

(defun cclass-audit-no-id (class)
  (cond ((null (cclass-audit class)) nil)
        ((listp (cclass-audit class)) (find :no-id (cclass-audit class)))
        (t nil))
)

(defun slot-audit-not-null (slot)
  (cond ((null (slot-audit slot)) nil)
        ((listp (slot-audit slot)) (find :not-null (slot-audit slot)))
        (t nil))
)


(defun gen-audit-proc (class what strm)
  (case what
    (:proto
      print OUT "  PROCEDURE aud_~a
  (\n" (cclass-name class))
      (if (cclass-audit-return-seqno class)
        print OUT "    aAuditSeq                   IN OUT NUMBER
   ,aAuditedAction              IN CHAR\n")
        print OUT "    aAuditedAction              IN CHAR\n"))
        (dolist (s (cclass-audit-slots class))
          (when (slot-audit s)
            (cond ((eq (slot-type s) :ENeoXDBSwizzler)
                   print OUT "     ,a~a_ID IN ~a\n" (slot-name s) (if (eq *rdbms* :oracle) "NUMBER" "INTEGER") )
                  )
                  ((eq (slot-type s) :ENeoPartMgr)
                  )
                  ((eq (slot-type s) :EPeriod)
                   print OUT "     ,a~a_Start IN ~a\n" (slot-name s) (sql-date-type))
                   print OUT "     ,a~a_End IN ~a\n" (slot-name s) (sql-date-type))
                  )
                  (t
                   print OUT "     ,a~a IN ~a\n" (slot-name s) (oracle-type-no-dim s))
                  ))
          )
        )
      print OUT "  );\n\n")
    )
    (:full
      (with-procedure-check (format nil "aud_~a" (cclass-name class))
        print OUT "  PROCEDURE aud_~a
  (\n" (cclass-name class))
      (if (cclass-audit-return-seqno class)
        print OUT "    aAuditSeq                   IN OUT NUMBER
   ,aAuditedAction              IN CHAR\n")
        print OUT "    aAuditedAction              IN CHAR\n"))

        (dolist (s (cclass-audit-slots class))
          (when (slot-audit s)
            (cond ((eq (slot-type s) :ENeoXDBSwizzler)
                   print OUT "     ,a~a_ID IN ~a\n" (slot-name s) (if (eq *rdbms* :oracle) "NUMBER" "INTEGER") )
                  )
                  ((eq (slot-type s) :ENeoPartMgr)
                  )
                  ((eq (slot-type s) :EPeriod)
                   print OUT "     ,a~a_Start IN ~a\n" (slot-name s) (sql-date-type))
                   print OUT "     ,a~a_End IN ~a\n" (slot-name s) (sql-date-type))
                  )
                  (t
                   print OUT "     ,a~a IN ~a\n" (slot-name s) (oracle-type-no-dim s))
                  ))
          )
        )
        print OUT "  )\n")
        print OUT "  IS
    lAuditUser_ID NUMBER := -1;
  BEGIN
    lAuditUser_ID := GetConnectionUser;\n\n")

        (when (cclass-audit-return-seqno class)
        print OUT "    SELECT Aud_Seq.nextval
    INTO aAuditSeq
    FROM tc_onerow;\n\n" ))

        print OUT "    INSERT INTO ~a_hist
    (
      WAuditSeq
     ,WAuditDateTime
     ,WAuditedAction
     ,WAuditUser_ID\n" (cclass-name class))
        (dolist (s (cclass-audit-slots class))
          (when (slot-audit s)
            (cond ((eq (slot-type s) :ENeoXDBSwizzler)
                   print OUT "     ,W~a_ID\n" (slot-name s) )
                  )
                  ((eq (slot-type s) :ENeoPartMgr)
                  )
                  ((eq (slot-type s) :EPeriod)
                   print OUT "     ,W~a_Start\n" (slot-name s) )
                   print OUT "     ,W~a_End\n" (slot-name s) )
                  )
                  (t
                   print OUT "     ,W~a\n" (slot-name s) )
                  ))
          )
        )
        print OUT "    )
    VALUES
    (
      ~a
     ,Sysdate
     ,aAuditedAction
     ,lAuditUser_ID\n" (if (cclass-audit-return-seqno class) "aAuditSeq" "Aud_Seq.nextval") )
        (dolist (s (cclass-audit-slots class))
          (when (slot-audit s)
            (cond ((eq (slot-type s) :ENeoXDBSwizzler)
                   print OUT "     ,a~a_ID\n" (slot-name s) )
                  )
                  ((eq (slot-type s) :ENeoPartMgr)
                  )
                  ((eq (slot-type s) :EPeriod)
                   print OUT "     ,a~a_Start\n" (slot-name s) )
                   print OUT "     ,a~a_End\n" (slot-name s) )
                  )
                  (t
                   print OUT "     ,a~a\n" (slot-name s))
                  ))
          )
        )
        print OUT "    );

  END;\n\n")
  )))
)

(defun gen-audit-link-procs (class what strm)
  (dolist (slot (cclass-audit-slots class))
    (when (eq (slot-type slot) :ENeoPartMgr)
      (gen-audit-link-proc slot class what strm)
    )))

(defun gen-audit-link-proc (slot class what strm)
  (case what
    (:proto
      print OUT "  PROCEDURE aud_~a_~a
  (\n" (cclass-name class) (slot-name slot) )
      print OUT "    aAuditedAction              IN CHAR\n")
      print OUT "     ,a~a_ID IN ~a\n" (subseq (cclass-name class) 1) (if (eq *rdbms* :oracle) "NUMBER" "INTEGER") )
      print OUT "     ,a~a_ID IN ~a\n" (subseq (slot-othertype slot) 1) (if (eq *rdbms* :oracle) "NUMBER" "INTEGER") )
      print OUT "  );\n\n")
    )
    (:full
      (with-procedure-check (format nil "aud_~a_~a" (cclass-name class) (slot-name slot))
        print OUT "  PROCEDURE aud_~a_~a
  (\n" (cclass-name class) (slot-name slot) )
        print OUT "    aAuditedAction              IN CHAR\n")

      print OUT "     ,a~a_ID IN ~a\n" (subseq (cclass-name class) 1) (if (eq *rdbms* :oracle) "NUMBER" "INTEGER") )
      print OUT "     ,a~a_ID IN ~a\n" (subseq (slot-othertype slot) 1) (if (eq *rdbms* :oracle) "NUMBER" "INTEGER") )
        print OUT "  )\n")
        print OUT "  IS
    lAuditUser_ID NUMBER := -1;
  BEGIN
    lAuditUser_ID := GetConnectionUser;\n\n")

        print OUT "    INSERT INTO ~a_~a_hist
    (
      WAuditSeq
     ,WAuditDateTime
     ,WAuditedAction
     ,WAuditUser_ID\n" (cclass-name class) (slot-name slot))
        print OUT "     ,W~a_ID\n" (subseq (cclass-name class) 1) )
        print OUT "     ,W~a_ID\n" (subseq (slot-othertype slot) 1) )
        print OUT "    )
    VALUES
    (
      ~a
     ,Sysdate
     ,aAuditedAction
     ,lAuditUser_ID\n" (if (cclass-audit-return-seqno class) "aAuditSeq" "Aud_Seq.nextval") )
      print OUT "     ,a~a_ID\n" (subseq (cclass-name class) 1) )
      print OUT "     ,a~a_ID\n" (subseq (slot-othertype slot) 1) )
        print OUT "    );

  END;\n\n")
  )))
)

(defun gen-audit-link-tables (class strm)
  (dolist (s (cclass-audit-slots class))
    (when (eq (slot-type s) :ENeoPartMgr)
        print OUT "--================================================================================
-- Table: ~a_~a_hist
--================================================================================
--\n" (cclass-name class) (slot-name s))
        print OUT "--drop--DROP TABLE ~a_~a_hist
--drop--/\n\n" (cclass-name class) (slot-name s))

        print OUT "CREATE TABLE ~a_~a_hist
(
  WAuditSeq                   NUMBER(10)                      NOT NULL
 ,WAuditDateTime              DATE                            NOT NULL
 ,WAuditedAction              CHAR(1)                         NOT NULL
 ,WAuditUser_ID               NUMBER(10)                      NOT NULL\n"  (cclass-name class) (slot-name s))

        print OUT " ,~a_ID                   NUMBER(10)                      NOT NULL\n" (cclass-name class) )
        print OUT " ,~a_ID               NUMBER(10)                      NOT NULL\n" (slot-othertype s) )

        print OUT ")
TABLESPACE &tcdata
/\n")

        print OUT "ALTER TABLE ~a_~a_hist
ADD CONSTRAINT PK_~a_~a_hist PRIMARY KEY (wAuditSeq) USING INDEX TABLESPACE &tcindx
/\n" (cclass-name class) (slot-name s) (cclass-name class) (slot-name s))
    )))

(defun gen-table-column (strm comma name type &optional not-null)
  print OUT " ~a~27a ~31a ~aNULL\n" (if comma "," "") name type (if not-null "NOT " "") )
)

(defun gen-audit-table (class strm)
      (with-table-check (format nil "~a_hist" (cclass-name class))

        print OUT "--================================================================================
-- Table: ~a_hist
--================================================================================
--\n" (cclass-name class))

        print OUT "--drop--DROP TABLE ~a_hist
--drop--/\n\n" (cclass-name class))

        print OUT "CREATE TABLE ~a_hist
(\n" (cclass-name class))
        (gen-table-column strm nil "WAuditSeq" "NUMBER(10)" t)
        (gen-table-column strm t "WAuditDateTime" "DATE" t)
        (gen-table-column strm t "WAuditedAction" "CHAR(1)" t)
        (gen-table-column strm t "WAuditUser_ID" "NUMBER(10)" t)
        (dolist (s (cclass-audit-slots class))
          (when (slot-audit s)
            (cond ((slot-ID s)
                   (gen-table-column strm t (format nil "W~a" (slot-name s)) (oracle-type s) t)
                  )
                  ((eq (slot-type s) :ENeoXDBSwizzler)
                   (gen-table-column strm t (format nil "W~a_ID" (slot-name s)) (oracle-type s) (slot-audit-not-null s))
                  )
                  ((eq (slot-type s) :ENeoPartMgr)
                  )
                  ((eq (slot-type s) :EPeriod)
                   (gen-table-column strm t (format nil "W~a_Start" (slot-name s)) (sql-date-type) (slot-audit-not-null s))
                   (gen-table-column strm t (format nil "W~a_End" (slot-name s)) (sql-date-type) (slot-audit-not-null s))
                  )
                  (t
                   (gen-table-column strm t (format nil "W~a" (slot-name s)) (oracle-type s) (slot-audit-not-null s))
                  ))
          )
        )
        print OUT ")
TABLESPACE &tcdata
/

ALTER TABLE ~a_hist
ADD CONSTRAINT PK_~a_hist PRIMARY KEY (wAuditSeq) USING INDEX TABLESPACE &tcindx
/\n" (cclass-name class) (cclass-name class)))
)

(defun generate-audit-tables ()
  (format t "# Generating Audit Tables\n")
  (let* ((fstem (if (eq *rdbms* :oracle) "tc_audit_tables" "audit_tables"))
         #(fstem (script-stem stem what))
         (fname (format nil "~a.sql" fstem))
         (fpath (format nil "~a~a" (audit-script-dir) fname)))
    (format t "#~a\n" fpath)
    (with-open-file (strm fpath :direction :output :if-exists :supersede)
      (oracle-file-banner (intern (string-upcase fstem)) :audit-tables :full strm (string-downcase fname))

      (dolist (class (audit-classes))
        (unless (exclude-class-from-schema class)
          (when (cclass-audit class)
            (gen-audit-table class strm)
            (gen-audit-link-tables class strm)
            )))

      (update-config strm "Audit_Tables")
      )))

(defun gen-audit-trigger-oracle (class strm)
  print OUT "CREATE OR REPLACE TRIGGER aud_~a
BEFORE INSERT OR
       UPDATE OF " (cclass-name class) )
    (dolist (s (cclass-audit-slots class))
      (when (slot-audit s)
        (cond ((slot-ID s)
               (format strm"W~a" (slot-name s))
              )
              ((eq (slot-type s) :ENeoPartMgr)
              )
              ((eq (slot-type s) :ENeoXDBSwizzler)
               (format strm", W~a_ID" (slot-name s))
              )
              ((eq (slot-type s) :EPeriod)
               print OUT ", W~a_Start" (slot-name s))
               print OUT ", W~a_End" (slot-name s))
              )
              (t
               print OUT ", W~a" (slot-name s))
              ))))
  print OUT " OR
       DELETE
ON     ~a
FOR EACH ROW
DECLARE

  lAuditedAction  CHAR(1) ;\n" (cclass-name class))

    (dolist (s (cclass-audit-slots class))
      (when (slot-audit-modify-value s class :var)
        (funcall (slot-audit-modify-value s class :var) s class strm)))

  print OUT "BEGIN\n" (cclass-name class))

  print OUT "  IF (INSERTING) THEN

    lAuditedAction := 'I' ;\n\n")

    (dolist (s (cclass-audit-slots class))
      (when (slot-audit-modify-value s class :insert)
        (funcall (slot-audit-modify-value s class :insert) s class strm)))

  print OUT "    oAudit.aud_~a
    (
      lAuditedAction\n" (cclass-name class))
    (dolist (s (cclass-audit-slots class))
      (when (slot-audit s)
        (cond ((slot-ID s)
               print OUT "     ,:new.W~a\n" (slot-name s))
              )
              ((eq (slot-type s) :ENeoXDBSwizzler)
               print OUT "     ,:new.W~a_ID\n" (slot-name s))
              )
              ((eq (slot-type s) :ENeoPartMgr)
              )
              ((eq (slot-type s) :EPeriod)
               print OUT "     ,:new.W~a_Start\n" (slot-name s))
               print OUT "     ,:new.W~a_End\n" (slot-name s))
              )
              ((slot-audit-modify-value s class :var)
               print OUT "     ,new~a\n" (slot-name s))
              )
              (t
               print OUT "     ,:new.W~a\n" (slot-name s))
              ))))
  print OUT "    );

  ELSIF
    (
      UPDATING
      AND
      (\n")
    (dolist (s (cclass-audit-slots class))
      (when (slot-audit s)
        (cond ((slot-ID s)
               print OUT "           :new.W~a <> :old.W~a\n" (slot-name s) (slot-name s))
              )
              ((eq (slot-type s) :ENeoXDBSwizzler)
               print OUT "        OR NVL(:new.W~a_ID, 0) <> NVL(:old.W~a_ID, 0)\n" (slot-name s) (slot-name s))
              )
              ((eq (slot-type s) :ENeoPartMgr)
              )
              ((eq (slot-type s) :EPeriod)
               print OUT "        OR NVL(:new.W~a_Start, SYSDATE) <> NVL(:old.W~a_Start, SYSDATE)\n" (slot-name s) (slot-name s))
               print OUT "        OR NVL(:new.W~a_End, SYSDATE) <> NVL(:old.W~a_End, SYSDATE)\n" (slot-name s) (slot-name s))
              )
              ((eq (slot-type s) :ETcDateTime)
               print OUT "        OR NVL(:new.W~a, SYSDATE) <> NVL(:old.W~a, SYSDATE)\n" (slot-name s) (slot-name s))
              )
              ((eq (slot-type s) :CNeoString)
               print OUT "        OR NVL(:new.W~a, '''') <> NVL(:old.W~a, '''')\n" (slot-name s) (slot-name s))
              )
              (t
               print OUT "        OR :new.W~a <> :old.W~a\n" (slot-name s) (slot-name s))
              ))))
  print OUT "      )
    )
  THEN

    lAuditedAction := 'U' ;\n\n")

    (dolist (s (cclass-audit-slots class))
      (when (slot-audit-modify-value s class :update)
        (funcall (slot-audit-modify-value s class :update) s class strm)))

  print OUT "    oAudit.aud_~a
    (
      lAuditedAction\n" (cclass-name class) )
    (dolist (s (cclass-audit-slots class))
      (when (slot-audit s)
        (cond ((slot-ID s)
               print OUT "     ,:new.W~a\n" (slot-name s))
              )
              ((eq (slot-type s) :ENeoXDBSwizzler)
               print OUT "     ,:new.W~a_ID\n" (slot-name s))
              )
              ((eq (slot-type s) :ENeoPartMgr)
              )
              ((eq (slot-type s) :EPeriod)
               print OUT "     ,:new.W~a_Start\n" (slot-name s))
               print OUT "     ,:new.W~a_End\n" (slot-name s))
              )
              ((slot-audit-modify-value s class :var)
               print OUT "     ,new~a\n" (slot-name s))
              )
              (t
               print OUT "     ,:new.W~a\n" (slot-name s))
              ))))
  print OUT "    );

  ELSIF (DELETING) THEN

    lAuditedAction := 'D' ;

    oAudit.aud_~a
    (
      lAuditedAction\n" (cclass-name class))
    (dolist (s (cclass-audit-slots class))
      (when (slot-audit s)
        (cond ((slot-ID s)
               print OUT "     ,:old.W~a\n" (slot-name s))
              )
              ((eq (slot-type s) :ENeoXDBSwizzler)
               print OUT "     ,:old.W~a_ID\n" (slot-name s))
              )
              ((eq (slot-type s) :ENeoPartMgr)
              )
              ((eq (slot-type s) :EPeriod)
               print OUT "     ,:old.W~a_Start\n" (slot-name s))
               print OUT "     ,:old.W~a_End\n" (slot-name s))
              )
              (t
               print OUT "     ,:old.W~a\n" (slot-name s))
              ))))
  print OUT "    );

  END IF;

END ;
/
SHOW ERRORS\n")
)

(defun gen-audit-link-trigger-oracle (slot class strm)
  print OUT "CREATE OR REPLACE TRIGGER aud_~a_~a
BEFORE INSERT OR
       UPDATE OF " (cclass-name class) (slot-name slot) )
               (format strm"~a_ID" (cclass-name class))
               (format strm", ~a_ID" (slot-othertype slot))
  print OUT " OR
       DELETE
ON     ~a_~a
FOR EACH ROW
DECLARE

  lAuditedAction  CHAR(1) ;

BEGIN\n" (cclass-name class) (slot-name slot))

  print OUT "  IF (INSERTING) THEN

    lAuditedAction := 'I' ;

    oAudit.aud_~a_~a
    (
      lAuditedAction\n" (cclass-name class) (slot-name slot))
               print OUT "     ,:new.~a_ID\n" (slot-cclass slot))
               print OUT "     ,:new.~a_ID\n" (slot-othertype slot))
  print OUT "    );

  ELSIF
    (
      UPDATING
      AND
      (\n")
               print OUT "           :new.~a_ID <> :old.~a_ID\n" (slot-cclass slot) (slot-cclass slot))
               print OUT "        OR :new.~a_ID <> :old.~a_ID\n" (slot-othertype slot) (slot-othertype slot))
  print OUT "      )
    )
  THEN

    lAuditedAction := 'U' ;

    oAudit.aud_~a_~a
    (
      lAuditedAction\n" (cclass-name class)  (slot-name slot))
               print OUT "     ,:new.~a_ID\n" (slot-cclass slot))
               print OUT "     ,:new.~a_ID\n" (slot-othertype slot))
  print OUT "    );

  ELSIF (DELETING) THEN

    lAuditedAction := 'D' ;

    oAudit.aud_~a_~a
    (
      lAuditedAction\n" (cclass-name class) (slot-name slot))
               print OUT "     ,:old.~a_ID\n" (slot-cclass slot))
               print OUT "     ,:old.~a_ID\n" (slot-othertype slot))
  print OUT "    );

  END IF;

END ;
/
SHOW ERRORS\n")
)

(defun gen-audit-trigger-mssql (class strm)
)
(defun gen-audit-link-trigger-mssql (slot class strm)
)
(defun gen-audit-trigger (class strm)
  (if (eq *rdbms* :oracle)
    (gen-audit-trigger-oracle class strm)
    (gen-audit-trigger-mssql class strm)
  ))

(defun gen-audit-link-triggers (class strm)
  (dolist (slot (cclass-audit-slots class))
    (when (eq (slot-type slot) :ENeoPartMgr)
      (gen-audit-link-trigger slot class strm)
    )))

(defun gen-audit-link-trigger (slot class strm)
  (if (eq *rdbms* :oracle)
    (gen-audit-link-trigger-oracle slot class strm)
    (gen-audit-link-trigger-mssql slot class strm)
  ))


(defun generate-audit-triggers ()
  (format t "# Generating Audit Triggers\n")
  (let* ((fstem (if (eq *rdbms* :oracle) "tc_audit_trigs" "audit_triggs"))
        #(fstem (script-stem stem what))
         (fname (format nil "~a.sql" fstem))
         (fpath (format nil "~a~a" (audit-script-dir) fname)))
    (format t "#~a\n" fpath)
    (with-open-file (strm fpath :direction :output :if-exists :supersede)
      (oracle-file-banner (intern (string-upcase fstem)) :audit-trigs :full strm (string-downcase fname))

      (dolist (class (audit-classes))
        (unless (exclude-class-from-schema class)
          (when (cclass-audit class)
            (unless (cclass-audit-custom-trigger class)
              (gen-audit-trigger class strm)
            )
            (gen-audit-link-triggers class strm)
            )))

      (update-config strm "Audit_Triggers")
      )))


(defun gen-audit ()
  (generate-audit-package :proto)
  (generate-audit-package :full)
  (generate-audit-tables)
  (generate-audit-triggers)
)

(defun slot-audit-modify-value (slot class when)
  (cond ((and (string= (cclass-name class) "WILTStudent") (string= (slot-name slot) "EnrollStatus"))
         (cond ((eq when :var)
                #'(lambda (slot class strm)
                    print OUT "  newEnrollStatus number(1) ;\n")))
               (t
                 #'(lambda (slot class strm)
                     print OUT "    IF (:new.WEnrollStatus = 1 AND :new.WDateEnrolled IS NULL) THEN
      newEnrollStatus := 7;
    ELSIF (:new.WEnrollStatus = 2 AND :new.WDateEnrolled IS NULL ) THEN
      newEnrollStatus := 8;
    ELSE
      newEnrollStatus := :new.WEnrollStatus;
    END IF ;\n")))))))

=cut
