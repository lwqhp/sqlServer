

/*
PIVOT的一般语法是：PIVOT(聚合函数(列) FOR 列 in (…) )AS P
 Pivot(聚合指定列值 FOR(是按另一相关列分组) in(列中包含自定义值列)（类拟按相关列分组聚合）
 
完整语法：

select [column] from tableName
PIVOT(
	聚合函数（value_column）FOR pivot_column IN(<column_list>)
) a

UNPIVOT用于将列明转为列值（即列转行），在SQL Server 2000可以用UNION来实现

完整语法：

table_source
UNPIVOT(
	value_column FOR pivot_column IN(<column_list>)
)

注意：PIVOT、UNPIVOT是SQL Server 2005 的语法，使用需修改数据库兼容级别
 在数据库属性->选项->兼容级别改为   90*/ 


/*
需求：比较每年中各季度的销售状况，要怎么办呢？
select * from SalesByQuarter
*/

--一、使用传统Select的CASE语句查询
SELECT year as 年份
    , sum (case when quarter = 'Q1' then amount else 0 end) 一季度
    , sum (case when quarter = 'Q2' then amount else 0 end) 二季度
    , sum (case when quarter = 'Q3' then amount else 0 end) 三季度
    , sum (case when quarter = 'Q4' then amount else 0 end) 四季度
FROM SalesByQuarter GROUP BY year ORDER BY year DESC

--二、使用PIVOT
--（每个PIVOT查询都涉及某种类型的聚合，因此你可以忽略GROUP BY语句。）

    SELECT *
    FROM    SalesByQuarter PIVOT ( SUM(amount) FOR quarter IN ( Q1, Q2, Q3, Q4 ) ) AS P
    ORDER BY YEAR DESC

    SELECT  year AS 年份 ,
            Q1 AS 一季度 ,
            Q2 AS 二季度 ,
            Q3 AS 三季度 ,
            Q4 AS 四季度
    FROM    SalesByQuarter PIVOT ( SUM(amount) FOR quarter IN ( Q1, Q2, Q3, Q4 ) ) AS P
    ORDER BY YEAR DESC
