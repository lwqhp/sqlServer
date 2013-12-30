

--动态语句
/*
使用exec 动态格式化可以执行的字符串，但其存在注入和性能问题
1，可以代入的变量，会被恶意的加入其它执行语句
2，动态生成的sql语句，会在第每次执行时生成新的执行计划

替代方法：sp_executesql 可以重用的，只有查询参数发生更新的果谒执行计划
*/

EXEC sp_executesql N'select * from tb where id = @id',N'@id int',@id=5
