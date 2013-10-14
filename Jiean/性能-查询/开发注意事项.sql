
--存储过程开发注意事项

/*
1,数据来源可能来自不同的模块，当数据汇集到存储过程中的数据集时，要保证存储过程中各数据集的数据类型一致，
以避免类型转换带来的性能开销以及索引失效。
*/
--DROP TABLE #sd_posSaleMaster
CREATE TABLE #sd_posSaleMaster(companyID VARCHAR(20),billno VARCHAR(40))
CREATE TABLE #sd_posSaleDetail(companyID VARCHAR(20),billno VARCHAR(40))
go
--创建一个索引
CREATE INDEX IX_sd_posSaleMaster ON #sd_posSaleMaster(companyID,billno)
CREATE INDEX IX_sd_posSaleDetail ON #sd_posSaleDetail(companyID,billno)

--后面两表关联
SET STATISTICS PROFILE ON

SELECT * FROM #sd_posSaleMaster a
INNER JOIN #sd_posSaleDetail b ON a.companyID = b.companyID AND a.billno = b.billno

--执行计划对比

|--Nested Loops(Inner Join, OUTER REFERENCES:([Expr1006], [Expr1007]))
   |--Compute Scalar(DEFINE:([Expr1006]=CONVERT_IMPLICIT(nvarchar(20),[tempdb].[dbo].[#sd_posSaleDetail].[companyID] as [b].[companyID],0), [Expr1007]=CONVERT_IMPLICIT(nvarchar(40),[tempdb].[dbo].[#sd_posSaleDetail].[billno] as [b].[billno],0)))
   |    |--Index Scan(OBJECT:([tempdb].[dbo].[#sd_posSaleDetail] AS [b]))
   |--Index Seek(OBJECT:([tempdb].[dbo].[#sd_posSaleMaster] AS [a]), SEEK:([a].[companyID]=[Expr1006] AND [a].[billno]=[Expr1007]) ORDERED FORWARD)
   
|--Nested Loops(Inner Join, OUTER REFERENCES:([a].[companyID], [a].[billno]))
   |--Index Scan(OBJECT:([tempdb].[dbo].[#sd_posSaleMaster] AS [a]))
   |--Index Seek(OBJECT:([tempdb].[dbo].[#sd_posSaleDetail] AS [b]), SEEK:([b].[companyID]=[tempdb].[dbo].[#sd_posSaleMaster].[companyID] as [a].[companyID] AND [b].[billno]=[tempdb].[dbo].[#sd_posSaleMaster].[billno] as [a].[billno]) ORDERED FORWARD)