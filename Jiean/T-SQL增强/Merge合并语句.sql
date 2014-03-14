

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
MERGE INTO #Servertb a  --Ŀ���target,�����Ǳ���ͼ
USING #Clienttb b	--Դ��source����������ͼ��������cte,��ֵ����
ON a.code = b.code --����
WHEN MATCHED --matched ƥ�� ��ֻ֧�ָ��º�ɾ��
AND a.NAME<> b.NAME THEN UPDATE SET a.name=b.NAME,a.modifyDTM = b.modifyDTM --��ƥ�������Ʋ���ͬʱ����������
--WHEN MATCHED AND a.modifyDTM <> b.modifyDTM THEN UPDATE SET a.modifyDTM = b.modifyDTM 
WHEN NOT MATCHED BY TARGET AND a.NAME<> b.NAME THEN INSERT(code,name,modifyDTM)VALUES(b.code,b.name,b.modifyDTM)--��������������
WHEN NOT MATCHED BY SOURCE AND a.NAME<> b.NAME THEN DELETE--�����Ӽ���ɾ��
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET name = 'a' --��Ŀ�����Դ����ʱ������Ŀ����״̬

OUTPUT $ACTION AS ACTION,INSERTED.NAME,DELETED.NAME; --ʹ��output��仹���Է���ִ�еĶ������Ͳ����ļ�¼
/*
ʹ��merge����ŵ��ǲ���Ҫ�����������Σ�����merge�������Ϊԭ�Ӳ������д���ģ���������ʽ�����������Ҫ����һ
�����䣬���²�����������Ҫ��ʾ���������԰�����������Ϊһ��ԭ��������



��merge�ǰ�������ʽ��¼��־�ģ��� insert select ����ܹ���ĳЩ�ض�������°���С��ʽ��¼��־�������ڴ�����
merge���龰�£�����ü�ģʽ������������Ҳ��������

Merge��Ҫ�������Ӽ����������������������Ҫ��Sqlserver�����Զ���Դ���ݽ�������������ȷ��ʹ�ú��ʵ�������

���ӱ��ʣ�
matched : ��������
not matched :��������
not matched :��Ŀ����Դ����бȽϺ����߲���ʱ����һ��ȫ���ӡ�

֧��ͬʱ����when matched�Ӿ䣬�������һ��matchedҪ����һ��ν������������2���Ӿ�ɴ��ɲ�����ֻ�е�onν�ʺ�
��1��when�Ӿ�Ķ���ν��Ϊtrueʱ����ִ�е�һ��matched,���onν��Ϊtrue,����1��when �Ӿ�Ķ���ν��Ϊfull ��
unknown,ʱ������������2��when�Ӿ䣬���磺
���������ĳ��������ʱ����Ŀ�����������¼����ȫ�����ϣ���ɾ����
when matched and a<>b then update
when matched then delete;

��֧�� һ��when not matched [target] �Ӿ䣬֧������ when not matched by source �Ӿ�

slqserver��֧��merge�������������Ŀ����϶�����insert ,update ,delete��������ÿ��������Ҳֻ����һ�Ρ�
*/

--Merge����"����ֵ"��Ҫ�������еļ�¼�����ǲ������

MERGE INTO #Servertb a
USING (VALUES(@a,@b)) AS b(code,NAME)
ON a.code = b.code
WHEN MATCHED 
AND a.NAME<> b.NAME THEN UPDATE SET a.name=b.NAME,a.modifyDTM = b.modifyDTM 
WHEN NOT MATCHED THEN INSERT(code)VALUES('a');