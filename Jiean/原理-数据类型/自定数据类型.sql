

--UDT�û��Զ���������
/*
�û������������ڶ���һ�ֺ���֪ҵ�����Ӧ�ó���Ϊ���ĵ�����һ�µ��������ͣ�ͨ��Ҳ�б�������
������alter�����޸ļ������͡�
*/
create type T_Billno from varchar(20) not null
create type T_billno_L from varchar(40) null


--�����ֵ����
/*
����sqlserver2008���¹��ܣ������Զ����ֵ���ͣ���Ϊ�����ʹ洢���̵ı��������
*/
CREATE TYPE tb_billno AS TABLE(billno VARCHAR(20))
go

CREATE PROCEDURE spPro_Name (@tbBillno tb_billno READONLY)
/*readonly�Ǵ洢���̺��û����庯�����������Ҫ�ģ���Ϊ��sqlserver2008�в�������ı�ֵ�����*/
AS
	SELECT * from @tbbillno
	
	--Ҳ��������ֱ�Ӷ�������
	DECLARE @tbVar AS tb_billno
go


--ɾ��
drop type T_Billno

--�鿴�û��������͵ĵײ��������
EXEC sp_help 'dbo.T_billno'

--���Ƴ��û�������������֮ǰ����Ҫ֪������ҳ�����ĳ�����͵��������ݿ����

--ʹ����UDT���кͲ���
SELECT  OBJECT_NAME(a.object_id) AS table_name,a.name AS  column 
FROM sys.columns a
INNER JOIN sys.types b ON a.user_type_id = b.user_type_id
WHERE b.name='T_billno'

--ʹ����UDT����Ϊ������洢���̵Ĳ������õ�
SELECT * FROM sys.parameters a
INNER JOIN sys.types b ON a.user_type_id = b.user_type_id





