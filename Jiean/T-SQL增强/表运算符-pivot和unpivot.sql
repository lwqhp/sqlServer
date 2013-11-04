

--增强表运算符 --pivot & unpivot 

/*
序：
a) PIVOT、UNPIVOT是SQL Server 2005 的语法，2000版本使用需修改数据库兼容级别： 在数据库属性->选项->兼容级别改为   90
b) Pivot不支持动态pivoting,与传统行转列没有什么显著的性能差异，生成执行计划是一样的。
c) 不能旋转多个键值列.


*/

/*
表运算符共性：用虚拟表作为它们的左输入，位于FROM子句的第一个表运算符用一个表表达式作为左输入并返回
一个虚拟表作为结果。（表表达式可以理真实的表，临时表，表变量，派生表，CTE，视图，表值函数），Form子句
的第二个表运算符把前一个表操作返回的虚拟表作为左输入。

注：为了更好理解pivot运算符的工作原理，我换一方式去解释：
1，需要转换的列称为轴，列名就是轴点。
2，与轴相关的列称为键值列。
3，轴上的每一个值称为键，对应键值列的值为键值，转换后键为列名，键值为列值。


Pivot 
Pivot运算符用于把数据从多行的分组状态旋转为每一组位于一行的多列状态，并在该过程中执行聚合运算。简单讲就是行转列。

Pivot 运算过程
1, P1:隐式分组
	在第一阶段，把所有未作为pivot输入的列对数据隐式分组，就像有一个隐含的group by
2，P2：隔离值。
	在第二阶段， 隔离目标列对应的值，也就是把列轴以轴点为中心，旋转90度，列轴上的值为‘键’转为行列，列轴对应的
	值转为对应键的列值。
	类似于这样：case when <列轴>='键1' then '键值' end as '键1'
				case when <列轴>='键2' then '键值' end as '键2'
3，P3：应用聚合函数
	在第三阶段，在第一阶段的group by 分组基础上对‘键值’进行聚合运算
	类似于这样：Max(case when <列轴>='键1' then '键值' end) as '键1'
				Max(case when <列轴>='键2' then '键值' end) as '键2'
				
完整语法：

select [键名] from tableName
PIVOT(
	聚合函数（键值列）FOR 轴点-列名 IN(<转轴上的键名>)
) a（运算后返回的虚拟表A）				
*/
/*
列子：比较每年中各季度的销售状况
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




/*
UNPIVOT
	是Pivot的逆过程，即列转行。

注：列转行后，需要重新指定轴点名和键值列名

Pivot运算过程
1, U1:生成副本
	 复制作为UNpivot输入的左表表达式中的行，每一行都会为in子句中的第一个源列复制一次，结果虚拟表将
	 包含 一个新列，用于以字符串格式保存源列的名称。列名称自定义。
	 
2, U2:隔离目标列值
	把目标列值重新放到键值列下（目标列值就是转轴上的键），重新定义键值列名
	
3, U3:过滤掉带有Null的和。	
	去掉键值列中值为null的行。
	
完整语法：

table_source
UNPIVOT(
	新的键值列名 FOR 新的轴点-列名 IN(<原转轴上的列名-键>)
)



/*
总结:
1,因为所有未提定的列将定义组，你可能会无意识地得到意外的分组，要解决这个问题，使用只返回指定列的派生表
或公用表表达式(CTE),然后再为该表表达式应用pivot。

2,聚合函数的输入必须是未被处理的基列，不能是表达式(例如：sum(qty*price),如果你想聚合提供一个表达式作为输
入，可以创建一个派生表或cte,在其中为表达式指定一个列别名（qty*price as totalPrice）,并在外部查询中使用该
列作为pivot聚合函数的输入。

3，同理，如果需要旋转多个列的属性，先在派生表或cte中先进行合并并分配一个列别名(列名1_列名2) as new_column
4, 被反向旋转的所有源属性列必须具有相同的数据类型，如果类型不同，可以创建一个派生表或CTE,把所有的转换列转成varchar类型
*/

看t-sql p369 ,找脚本
*/

--加一种行转列写法
;with tmp as(
select CompanyID,stuff(
	(select ','+sysparaid 
	from Sys_ParameterDetail 
	where companyID = a.companyID and sysparaid in('0015','0019') for xml path('')),1,1,'') as sysparaid
from Sys_ParameterDetail a where SysParaID in('0015','0019')
)
select * from tmp where charindex('0015',sysparaid)>0
	and charindex('0019',sysparaid)=0