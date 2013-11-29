

--筛选，计算运算符
/*
	Filter :扫描输入，仅返回那些符合 Argument 列中的筛选表达式（谓词）的行。
		在条件中进行筛选时，使用的运算符。在查找，扫描运算符的WHERE条件中，也隐含Filter运算。
		
	CONVERT_IMPLICIT():Filter运算中使用的类型转换函数	
*/
|--Clustered Index Seek(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SEEK:([Test].[dbo].[NTest].[companyID] > [Expr1024] AND [Test].[dbo].[NTest].[companyID] < [Expr1025]),  WHERE:(CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[companyID],0)=[@4] AND CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[billno],0)=[@5] AND CONVERT_IMPLICIT(nvarchar(10),[Test].[dbo].[NTest].[sequence],0)=[@6]) ORDERED FORWARD)