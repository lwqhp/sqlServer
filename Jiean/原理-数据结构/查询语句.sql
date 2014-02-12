

--数据结构之-查询语句
/*
逻辑查询处理的步骤：

5）select (5-2) distinct (5-3) top (5-1) <filed>
1) from (1-j) <leftTable> join <rightTable> （1-j2）on <on_predicate> （1-j3添加外部行）
2) where <>
3) group by <>
4) having <>
6) order by <Filed>

第一个处理的子句是From ,每一步都会生成一个虚拟表，该虚拟表会作为下一步的输入，这些虚拟表对于调用者是不可用的。
只有最后一步生成的虚拟表才会返回给调用者。

查询中有三种筛选器（on ,where,having）从执行顺序上看，on筛选器中的谓词作用于上一步返回的虚拟表（1-j）中的所有行,
只有使<on_predicate>为ture的那些行，才会包含在由这一步返回的(1-j2)虚拟表中,2-where 条件对上一步的(1-j2)表进行
筛选，结果为true的才会插入到虚表t2中，同理，having 对t3中的分组进行筛选，结果为true的组，才会插入到t4.
(注：在实际语句执行中，筛选器的执行主执行计划决定，执行计划会根据预估查询成本对筛选条件顺序作调整)

对于outer join 关联，筛选条件逻辑表达式不能放在on的后面，而应该放在where后面，因为ON筛选器在添加
外部行（1-j3）之前应用,而where 则是在1-j3之后应用，ON筛选器对保留表中部份行的删除并不是最终的，国为步骤1-j3
会把这些行再添加回来，相反，where 筛选器对行的删除是最终的(做个小测试)
当使用内联接时，在哪里指定逻辑表达式都一样，因为将会跳过步骤3,在彼此相连连的两个步骤中应用这些筛选器，中间没
有其他任何步骤。 

order by子句中的列名列表对上一步返回的行进行排序，返回游标vc6(注：order by 后不返回虚表，所以不能把有order by 
的结果作为表集处理，但如果加了top选项，则order by 还有另一个作用:“根据什么顺序来进行top选择”，最终生成虚表)
order by 查询中，如果指定了distinct ,则order by 子句中的表达式只能访问上一步返回的虚表t5,如果没有指定distinct,
则order by 子句中的表达式可以访问select阶段的输入和输出虚表，也就是说，可以在order by 子句中指定任何可以在
select 子句使用的表达式，即可以按不在最后返回的结果集中的表达式来进行排序。      

为什么order by 不是返回虚表？
答：因为sql的理伦基础是集合论，集合中的行之间没有预先定义的顺序，它只是成员的一种逻辑组合，成员之间的顺序无关
紧要，对于带有排序作用的order by 查询，可以返回一个对象，其中的行按特定的顺序组织在一起，ANSI把这种对象称为游标。

order by 的排序只服务于top 逻辑含议，而不会保证查询结果有固定的排序顺序，因为top查询是用于定义表表达式，这时
它代表的就是一个没有固定顺序的表，所以用order by + top不能返回一个固定顺序的虚表。

                                                                                                                                                                                                                                           
*/
--小测试
CREATE TABLE #tbM(
	mid INT ,
	mval VARCHAR(20)
)

CREATE TABLE #tbD(
	did INT,
	mid INT,
	dval VARCHAR(20)
)

INSERT INTO #tbM
SELECT 1,'a' UNION ALL
SELECT 2,'b' UNION ALL
SELECT 3,'c'

INSERT INTO #tbD
SELECT 1,1,'da' UNION ALL
SELECT 2,2, 'db'

SELECT * FROM #tbm a
LEFT JOIN #tbd b ON a.mid = b.mid AND a.mval <>'c'
--WHERE a.mval <> 'c'