
--��������ʵ���Ķ��һ��ϵ

/*
Ӧ�ó�����

����ĳ����Ʒ��Ҫ��Ӧһ�������ˣ�ĳ�������������˲���
ע�⣬������������󶼷ֱ�������ͬ��ʵ�壬��Ʒ���Լ������ԣ�������������Ҳ���Լ��ܹ������ԣ�����һ������
����ӵ�ж�������ǲ�һ���ģ�����һ���ͻ������ж��������ַ�ͷ����ˣ��绰�ȡ�

���˼�룺

Ӧ������ƶ���֮���һ��һ�����һ��ϵ�����������ģʽ��

A��������һ��������Ϊ���壬��һ��������Ϊ�������ĸ������ԣ��洢���������ļ�¼�У�
���ж��һ����ʱ������������÷ָ����ָ���

B������һ�������������а�������������������������Ӧ��ϵ��ͨ����һ�ʼ�¼��Ӧһ�ֶ�Ӧ��ϵ��

*/
--�������ģʽ����ȱ�㣺

--A��
--��Ʒʵ��

CREATE TABLE Sal_pub_product(
	productID VARCHAR(20) PRIMARY KEY,
	productName VARCHAR(50) NULL,
	accountID VARCHAR(50) NULL --����������б�
)
go
INSERT INTO Sal_pub_product(productID,productName,accountID)
VALUES('p001','����','u001,u002,u003'),('p002','Ǧ','u005')
go
--������ʵ��
CREATE TABLE sys_user(
	accountID VARCHAR(20) PRIMARY KEY,
	accountName VARCHAR(50) NULL
)
go
INSERT  INTO sys_user(accountID,accountName)values
('u001','С��'),
('u002','С���'),
('u003','С��'),
('u005','С��')
go

SELECT * FROM Sal_pub_product
SELECT * FROM sys_user

--1,����������б����ַ�������Ӱ�죬������������û�
INSERT INTO Sal_pub_product(productID,productName,accountID)
VALUES('p004','����','u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003')


--2,�ָ���������Զ���ܳ�������Ŀ��

--3,��������

/*
�޷��Ը����˽��оۺ�ͳ�ƣ���Ҫ������ת�����������ദ��

���磺ͳ�Ʋ�Ʒ�ж��ٸ�������
*/
SELECT productID,productName,LEN(accountid)-LEN(REPLACE(accountid,',',''))+1
FROM Sal_pub_product 

--�ڸ������б��в���ָ�������޷�ʹ�����������ҷǳ���ʱ
SELECT * FROM Sal_pub_product WHERE CHARINDEX(',u001,',','+accountid+',')>0

--���ӣ�ɾ�����޸���Ҫ�����������������

/*
����ʹ�ó�����

1���洢���б�û��Ҫ��ȡ�б��еĵ����ͨ����Ϊһ�������ȡ��ǰ̨����
2������Ҫ��������ת�����ٹ����������ȡ�����Ϣ���������ƣ�ͨ�����id,������ͬʱ��Ӧ�ı�����
3����ɾ����ǰ̨������
*/


--B:�����
CREATE TABLE sal_bas_productAcc(
	productID VARCHAR(20) NOT NULL,
	AccountID VARCHAR(20) NOT NULL,
	demo VARCHAR(50)	--������ӹ�����������˵���ȡ�
)
GO
INSERT INTO sal_bas_productAcc(productID,AccountID)
VALUES('p001','u001'),
	('p001','u002')

SELECT * FROM sal_bas_productAcc

--ͨ���뽻�����������Խ����κη�ʽ��ȡֵ��ͳ��

--����
SELECT * FROM Sal_pub_product a
INNER JOIN sal_bas_productAcc b ON a.productId = b.productID
WHERE b.accountID = 'u001'

--ͳ��
SELECT productid,COUNT(*) '�û���' FROM sal_bas_productAcc GROUP BY productId

--��ɾ�ı�ø���