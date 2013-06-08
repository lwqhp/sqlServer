
--可以查询所有排序规则的信息
SELECT  *
FROM    ::
        FN_HELPCOLLATIONS()

--查出所有中文排序规则的信息
SELECT  *
FROM    ( SELECT    *
          FROM      ::
                    FN_HELPCOLLATIONS()
        ) A
WHERE   name LIKE 'Chinese%'

