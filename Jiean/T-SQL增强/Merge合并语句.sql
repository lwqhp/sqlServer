

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
MERGE INTO #Servertb a  --目标表target,可以是表，视图
USING #Clienttb b	--源表source，可以是视图，派生表，cte,表值函数
ON a.code = b.code --关联
WHEN MATCHED --matched 匹配 ，只支持更新和删除
AND a.NAME<> b.NAME THEN UPDATE SET a.name=b.NAME,a.modifyDTM = b.modifyDTM --当匹配且名称不相同时，更新主表
--WHEN MATCHED AND a.modifyDTM <> b.modifyDTM THEN UPDATE SET a.modifyDTM = b.modifyDTM 
WHEN NOT MATCHED BY TARGET AND a.NAME<> b.NAME THEN INSERT(code,name,modifyDTM)VALUES(b.code,b.name,b.modifyDTM)--不在主表中新增
WHEN NOT MATCHED BY SOURCE AND a.NAME<> b.NAME THEN DELETE--不在子集中删除
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET name = 'a' --当目标表不在源表中时，更新目标表的状态

OUTPUT $ACTION AS ACTION,INSERTED.NAME,DELETED.NAME; --使用output语句还可以返回执行的动作名和操作的记录
/*
使用merge语句优点是不需要访问数据两次，而且merge语句是作为原子操作进行处理的，避免了显式声明事务的需要，用一
般的语句，更新插入两个过程要显示声明事务，以把两个步骤作为一个原子来处理。



但merge是按完整方式记录日志的，而 insert select 语句能够在某些特定的情况下按最小方式记录日志，所以在大量用
merge的情景下，最好用简单模式。这好像对性能也提升不大。

Merge需要根据联接键对数据流进行排序，如果需要，Sqlserver将会自动对源数据进行排序，所以请确保使用合适的索引。

连接本质：
matched : 内联两表
not matched :外联连表
not matched :当目标表和源表进行比较和两边操作时，是一个全连接。

支持同时两个when matched子句，但必须第一个matched要带上一个谓词条件，而第2个子句可带可不带，只有当on谓词和
第1个when子句的额外谓词为true时，才执行第一个matched,如果on谓词为true,但第1个when 子句的额外谓词为full 或
unknown,时，则继续处理第2个when子句，比如：
两表关联，某条件不等时更新目标表，如果两表记录能完全关联上，就删除。
when matched and a<>b then update
when matched then delete;

仅支持 一个when not matched [target] 子句，支持两个 when not matched by source 子句

slqserver不支持merge触发器，如果在目标表上定义了insert ,update ,delete触发器，每个触发器也只激发一次。
*/

--Merge处理"变量值"是要更新现有的记录，还是插入表中

MERGE INTO #Servertb a
USING (VALUES(@a,@b)) AS b(code,NAME)
ON a.code = b.code
WHEN MATCHED 
AND a.NAME<> b.NAME THEN UPDATE SET a.name=b.NAME,a.modifyDTM = b.modifyDTM 
WHEN NOT MATCHED THEN INSERT(code)VALUES('a');