
--���Բ�ѯ��������������Ϣ
SELECT  *
FROM    ::
        FN_HELPCOLLATIONS()

--���������������������Ϣ
SELECT  *
FROM    ( SELECT    *
          FROM      ::
                    FN_HELPCOLLATIONS()
        ) A
WHERE   name LIKE 'Chinese%'

