
SELECT * FROM ��A

UPDATE  t1
SET     t1.d_num = ( SELECT SUM(C_NUM)
                     FROM   ��A t2
                     WHERE  t2.IDNEX_NO = t1.IDNEX_NO
                            AND t2.sort_no <= t1.sort_no
                   )
FROM    ��A t1

