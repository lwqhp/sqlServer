

--Merge �ϲ����

/*
SQL2008�ṩ��������Դ������ܵĺϲ���䣬�Ӽ�������ĸ������ڿͻ��˽����˴����ǩ���������ݹؼ��ֹ�����
��ͬ�ĸ��£������Ĳ��룬�Ӽ����Ѿ������ڵ�ɾ����

�ϲ��������ʽ�����������п��ܻ���ѿ���������ƽʱ�ճ������������ݵĴ����п��������ó��������������ô����ʱ�䡣

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
MERGE INTO #Servertb a  --Ŀ���target
USING #Clienttb b	--Դ��source
ON a.code = b.code --����
WHEN MATCHED --matched ƥ��
AND a.NAME<> b.NAME THEN UPDATE SET a.name=b.NAME,a.modifyDTM = b.modifyDTM --��ƥ�������Ʋ���ͬʱ����������
--WHEN MATCHED AND a.modifyDTM <> b.modifyDTM THEN UPDATE SET a.modifyDTM = b.modifyDTM 
WHEN NOT MATCHED BY TARGET THEN INSERT(code,name,modifyDTM)VALUES(b.code,b.name,b.modifyDTM)--��������������
WHEN NOT MATCHED BY SOURCE THEN DELETE;--�����Ӽ���ɾ��

