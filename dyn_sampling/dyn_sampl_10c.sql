spool 10c

set lines 200
set pages 1000


DROP TABLE T_SMALL;
DROP TABLE T_BIG;

CREATE GLOBAL TEMPORARY TABLE T_SMALL ON COMMIT PRESERVE ROWS
AS SELECT rownum id, rpad('a',1000,'b') pad FROM dual connect by level <=1
;

CREATE TABLE T_BIG AS SELECT MOD(rownum, 1e3) id, rownum id2, rpad('a',1000,'b') pad FROM dual connect by level <=1e5;

ALTER TABLE T_BIG ADD CONSTRAINT T_BIG_PK PRIMARY KEY (id, id2) ;

DECLARE
l_name VARCHAR2(30);
BEGIN
--dbms_stats.gather_table_stats(null, 'T_SMALL');
dbms_stats.gather_table_stats(null, 'T_BIG');
END;
/

INSERT INTO T_SMALL
SELECT rownum+1 id, rpad('a',1000,'b') pad FROM dual connect by level <1e3;

commit;

DECLARE 
l_name VARCHAR2(30); 
BEGIN 
  dbms_stats.delete_table_stats(null, 'T_SMALL');   
END; 
/

PROMPT we do not collect stats for T_SMALL and we drop stats additionally for just in case

PAUSE press
PROMPT case 1

BEGIN
FOR c in (SELECT /*+ LEADING(a) USE_NL(b) DYNAMIC_SAMPLING(a 10) */ * FROM T_SMALL a LEFT OUTER JOIN T_BIG b
ON (a.id=b.id AND a.pad >=a.pad)) LOOP
null;
END LOOP;
END;
/

SELECT * FROM TABLE(dbms_xplan.display_cursor('5djb2f16gtb2r', null,'+outline'));

PAUSE press
PROMPT case 2

BEGIN
FOR c in (SELECT /*+ LEADING(a) USE_NL(b) DYNAMIC_SAMPLING_EST_CDN(a) */ * FROM T_SMALL a LEFT OUTER JOIN T_BIG b
ON (a.id=b.id AND a.pad >=a.pad)) LOOP
null;
END LOOP;
END;
/

SELECT * FROM TABLE(dbms_xplan.display_cursor('bcsv036qmwhtk', null,'+outline'));

PAUSE press
PROMPT case 3

BEGIN
FOR c in (SELECT /*+ LEADING(a) USE_NL(b) DYNAMIC_SAMPLING(a 10) DYNAMIC_SAMPLING_EST_CDN(a) */ * FROM T_SMALL a LEFT OUTER JOIN T_BIG b 
ON (a.id=b.id AND a.pad >=a.pad)) LOOP
 null;
END LOOP;
END;
/

SELECT * FROM TABLE(dbms_xplan.display_cursor('3q7xqu002d7kr', null,'+outline'));

PAUSE press
PROMPT case 4

BEGIN
FOR c in (SELECT /*+ LEADING(a) USE_NL(b) OPT_PARAM('optimizer_dynamic_sampling', 10) */ * FROM T_SMALL a LEFT OUTER JOIN T_BIG b
ON (a.id=b.id AND a.pad >=a.pad)) LOOP
null;
END LOOP;
END;
/

SELECT * FROM TABLE(dbms_xplan.display_cursor('dhmbv7c6npwwj', null,'+outline'));

spool off