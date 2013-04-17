


--遍历所有数据库中指定表，字段的取值
DECLARE @sql nVARCHAR(max)
DECLARE @i INT
SET @i=''
DECLARE @dbName varchar(50)
IF object_id('tempdb.dbo.#T') IS NOT NULL DROP TABLE #T
CREATE TABLE #T(dbName VARCHAR(100),comapnyID VARCHAR(10),sysparacode VARCHAR(100))
DECLARE db_cur CURSOR FOR
SELECT name FROM sys.databases WHERE database_id >4

OPEN db_cur
FETCH NEXT FROM db_cur INTO @dbName
WHILE @@FETCH_STATUS =0
BEGIN 
PRINT @dbName
	SET @sql =N'if EXISTS(select 1 FROM [#@db#].sys.objects a
INNER JOIN [#@db#].sys.columns b ON a.object_id=b.object_id
WHERE a.type =''U'' AND a.name=''Sys_ParameterDetail'' AND  b.name =''sysparacode'')
insert into #T
Select ''[#@db#]'',companyid,sysparacode from (SELECT  companyid,sysparacode,count(*) as repeatnum FROM [#@db#].dbo.Sys_ParameterDetail 
GROUP BY companyid,sysparacode 
HAVING count(*)>1) a'
	
	SET @sql = REPLACE(@sql,'#@db#',@dbName)
	PRINT @sql
	EXEC(@sql)
	--EXEC sys.sp_executesql @sql,N'@db varchar(50)',@db=@dbName

FETCH NEXT FROM db_cur INTO @dbName
END
CLOSE db_cur
DEALLOCATE db_cur

PRINT @i

SELECT * FROM #T

