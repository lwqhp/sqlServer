

--数据类型隐式转换对性能的影响

/*
当条件语句中左右表达式的数据类型不一致时，会产生隐式类型转换，根据数据类型优先级顺序，低类型向高类型转换。
这会使原有的索引无法使用，而带来性能问题,当这种情况出现在update,delete语句中时，性能问题是致命的，产生的
死锁让应用程序无法正常运行。
*/

CREATE TABLE NTest(companyID VARCHAR(20),billno VARCHAR(20),sequence VARCHAR(10),val1 INT,val2 INT ,val3 INT)

INSERT INTO NTest
VALUES('WK','WK20130930-001','001',1,0,1)

CREATE CLUSTERED INDEX IX_NTest ON NTest(companyID,billno,sequence)
--SELECT * FROM NTest

SET STATISTICS PROFILE ON


--数据类型匹配
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '001'
/*
  |--Clustered Index Update(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SET:([Test].[dbo].[NTest].[val1] = [@1],[Test].[dbo].[NTest].[val2] = [@2],[Test].[dbo].[NTest].[val3] = [@3]), WHERE:([Test].[dbo].[NTest].[companyID]=[@4] AND [Test].[dbo].[NTest].[billno]=[@5] AND [Test].[dbo].[NTest].[sequence]=[@6]))

使用聚集索引更新，简单干净
*/

--出现了数据类型隐式转换
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'001'
/*

  |--Clustered Index Update(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SET:([Test].[dbo].[NTest].[val1] = [@1],[Test].[dbo].[NTest].[val2] = [@2],[Test].[dbo].[NTest].[val3] = [@3]))
       |--Top(ROWCOUNT est 0)
            |--Nested Loops(Inner Join, OUTER REFERENCES:([Expr1024], [Expr1025], [Expr1023]))
                 |--Compute Scalar(DEFINE:(([Expr1024],[Expr1025],[Expr1023])=GetRangeThroughConvert([@4],[@4],(62))))
                 |    |--Constant Scan
                 |--Clustered Index Seek(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SEEK:([Test].[dbo].[NTest].[companyID] > [Expr1024] AND [Test].[dbo].[NTest].[companyID] < [Expr1025]),  WHERE:(CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[companyID],0)=[@4] AND CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[billno],0)=[@5] AND CONVERT_IMPLICIT(nvarchar(10),[Test].[dbo].[NTest].[sequence],0)=[@6]) ORDERED FORWARD)
   
执行计划变得复杂了很多，执行计划为了使用到索引查找，免避表扫描或索引扫描;
首先引入N'WK',
GetRangeThroughConvert()函数扩展companyID值为'WK'的varchar类型的范围[Expr1024],[Expr1025]，
确保可以转换成我们目标的nvarchar值的varchar数据落在这个范围之内，

然后使用这个范围和原表按索引进行关联，产生一个临时表，然后对这个少数据量临时表进行数据类型转换比较，
最终返回准确的结果集top运算符。
 

在这样一个过程中，SQL Server采用了一种迂回的方式使用了index seek而避免了表扫描。在实际生产库中，当筛选的范围
记录数达到NN时，就极易产生死锁。


            
*/       