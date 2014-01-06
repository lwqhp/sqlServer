

--Merge 合并语句

/*
SQL2008提供了类似于源码管理功能的合并语句，子集是主表的副本，在客户端进行了处理后，签回主表，根据关键字关联，
不同的更新，新增的插入，子集中已经不存在的删除。

合并语句在正式的生产环境中可能会很难看到，但在平时日常工作中以数据的处理中可以派上用场，大大减少我们敲代码的时间。

*/

IF object_Id('tempdb.dbo.#Servertb') IS NOT NULL DROP TABLE #Servertb
CREATE TABLE #Servertb(id INT IDENTITY(1,1) NOT null,code VARCHAR(10),NAME VARCHAR(20),modifyDTM DATETIME)
go
INSERT INTO #Servertb(code,NAME,modifyDTM)
VALUES('A001','AA',GETDATE()),
	  ('A002','BB',GETDATE()),
	  ('A003','CC',GETDATE()),
	  ('A004','DD',GETDATE())
	  
	  
IF object_Id('tempdb.dbo.#Clienttb') IS NOT NULL DROP TABLE #Clienttb
CREATE TABLE #Clienttb(id INT IDENTITY(1,1) NOT null,code VARCHAR(10),NAME VARCHAR(20),modifyDTM DATETIME)
go
INSERT INTO #Clienttb(code,NAME,modifyDTM)
VALUES('A001','AA1',GETDATE()),
	  ('A002','BB2',GETDATE()),
	  ('A005','CC',GETDATE()),
	  ('A006','DD',GETDATE())	  
/*
SELECT * FROM #Servertb
SELECT * FROM #Clienttb
*/
MERGE INTO #Servertb a  --目标表target
USING #Clienttb b	--源表source
ON a.code = b.code --关联
WHEN MATCHED --matched 匹配
AND a.NAME<> b.NAME THEN UPDATE SET a.name=b.NAME,a.modifyDTM = b.modifyDTM --当匹配且名称不相同时，更新主表
--WHEN MATCHED AND a.modifyDTM <> b.modifyDTM THEN UPDATE SET a.modifyDTM = b.modifyDTM 
WHEN NOT MATCHED BY TARGET THEN INSERT(code,name,modifyDTM)VALUES(b.code,b.name,b.modifyDTM)--不在主表中新增
WHEN NOT MATCHED BY SOURCE THEN DELETE;--不在子集中删除

