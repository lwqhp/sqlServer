

--���ṹ
/*
��ҵ���߼���ϵ�У� �㼶��ϵ��ν�޴����ڣ����żܹ�����˾Ŀ¼����Ʒ�б���̳���۵ȣ���������һ������һ���Ĺ�ϵ��
�ڳ����У����ǰ����־��в㼶��ϵ�����ݽṹ��Ϊ�������ṹ�е�ÿһ�������Ϊ�ڵ㣬���ϲ�Ľڵ��Ϊ����û���ӽڵ�
�Ľڵ��ΪҶ�ӣ����м�Ľڵ�򵥵س�Ϊ��Ҷ�ڵ㣬�ڵ��Ĺ�ϵ�Ǹ�-�ӽڵ㣬�ֵܽڵ㡣

����
���������Ľڵ������-���ڵ�Ĳ����������Ҫ��Щ���鴦��
1�������·��ʹ�ñ�ʾ�ڵ�λ�õ�ֵ���кţ�����Щֵ���������˳��
2�����ù̶����ȵĶ������ַ�����
3�������������·��֮���ټ����ʾ·��˳�������ֵ���кţ�����������Щֵ�Բ�νṹ��������

*/

--�����ݿ�����У�ͨ�����������˼�������������Ľṹ��

/*
2.1)˫�ڵ����:һ���ֶα�ʾ��ǰ�ڵ�ID����һ���ֶα�ʾ�ڵ�ĸ�ID(ParentID),����һ����-���ڵ��ϵ��

������Ʒǳ���ʵ�ã�ÿһ���ڵ㶼����Զ����ģ��ڵ㲻��Ҫ�������������ṹ�е�λ�ã�����Ҫ֪�����ж��ٸ����Ƚڵ㣬
Ҳ����Ҫ֪���ж��ٸ�����ڵ㣬��ֻ�������ĸ��ڵ���˭��

�ɼ��������ֽڵ�Ƚ϶�����������ϵ���ٵĽṹ�У�����ڵ㣬ɾ���ڵ㣬�Լ��ƶ��ڵ㶼�Ƿǳ�����ġ�
*/

-- ������������һ����Ӧ�̷��࣬ϵͳ�в�ͬ�����������Ÿ��ԵĹ�Ӧ�̣���Щ��Ӧ��������һ����Ӧ�̵ļ����̻�����̡�
--DROP TABLE Bas_InterCompany
CREATE TABLE Bas_InterCompany(
	CompanyID VARCHAR(20),
	vendcustID VARCHAR(30),
	ParentID VARCHAR(30)
)
go
INSERT INTO Bas_InterCompany(CompanyID,vendcustID,ParentID)
VALUES('PT','PT0001',NULL),('PT','PT0002',NULL),('PT','PT0003','PT0001'),('PT','PT0004','PT0003')

--SELECT * FROM Bas_InterCompany



/*
�����ĸ���˫�ڵ������ڲ���һ��������ʱ���Ǻܸ��ӵģ������ֻ�ǻ�ȡһ�������ڵ��ֱ�Ӹ��ӽڵ㣬ɾ������
һ���½ڵ㣬���ֽṹ�Ǻܷ���ġ�

Ϊ����ҵ������������Ҫ��˫�ڵ���������չ���Լ򻯲���
*/

--A)��������ֶ�[level]
ALTER TABLE dbo.Bas_InterCompany ADD [level] INT 

--SELECT * FROM Bas_InterCompany

;WITH tmp AS(
	SELECT CompanyID,vendcustID,0 [level] FROM Bas_InterCompany WHERE ParentID IS NULL
	UNION ALL 
	SELECT a.CompanyID,a.vendcustID,b.level+1 [level] FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.ParentID = b.vendcustID
)
--SELECT * 
UPDATE a SET a.LEVEL = b.level
FROM Bas_InterCompany a
INNER JOIN  tmp b ON a.CompanyID = b.CompanyID AND a.vendcustID = b.vendcustID

/**/

--B)����·���ֶ�
ALTER TABLE Bas_InterCompany ADD [path] VARCHAR(1000)

;WITH tmp AS(
	SELECT CompanyID,vendcustID,CAST(vendcustID AS  varchar) [path] FROM Bas_InterCompany WHERE ParentID IS NULL
	UNION ALL 
	SELECT a.CompanyID,a.vendcustID,CAST(b.[path]+'.'+a.vendcustID AS  varchar) FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.ParentID = b.vendcustID
)
--SELECT * FROM tmp
UPDATE a SET a.[path] = b.[path]
FROM Bas_InterCompany a
INNER JOIN  tmp b ON a.CompanyID = b.CompanyID AND a.vendcustID = b.vendcustID





