

--子查询索引策略
/*
select * from tb where id =(select max(id) from tc where tb.a = tc.a)
子查询其实是个隐式分组tb.a=tc.a,决胜属性是max(id),通过它可以唯一地对元素进行排名。

在这类决胜属性的子查询中，索引准则是(分组列，排序列，决胜属性列)
*/

--Exists查询
/*
根据子查询结果true或false决定是否返回该行。
1）exists只关心行是否存在，而不关心任何特定属性，优化器将忽略在子查询中指定的select列表，当对*号进行扩展时，
须要检查列的访问许可权限，这可能会带来一些解析开销，但这种开销非常容易被忽略。


exists 和in的区别

exists 和 in的区别主要在于 null值的判断，exists不会返回unknown,如果子查询的筛选器为某个行返回unknown,则不会
返回该行。而in是允许三值逻辑的，但因为unknown 和false的处理方式相同，所以在 exists 和 in所生成的执行计划是
一样的。

但在 not exists 和 not in上就会有明显的区别

exists使用top运算符（因为只须确定是否至少有一个匹配即可），这在包含大量重复时特别有效，每个分组只查找一次，
在叶级只扫描一行，以查找一个而不是所有的匹配。而 not in 需要对是否有 null值做特别的查找，这是因为null值会
影响返回值的判断，当有null值时， not in 永远返回空行。
*/