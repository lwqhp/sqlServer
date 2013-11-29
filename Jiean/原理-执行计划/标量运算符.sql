

--标量运算符
/*
	Constant Scan :将一个或多个常量行引入到查询中.多出现在条件语句中使用了常量。
	Compute Scalar:对引入的常量通过表达式求值返回 标量值 或 标量值范围 。
		GetRangeThroughConvert():计算标量值的范围
*/
--GetRangeThroughConvert()函数计算引入的标量值@4，计算定义出一个范围[Expr1024]··[Expr1025]
|--Compute Scalar(DEFINE:(([Expr1024],[Expr1025],[Expr1023])=GetRangeThroughConvert([@4],[@4],(62))))

