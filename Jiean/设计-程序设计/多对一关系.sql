
--两个对象实体间的多对一关系

/*
应用场景：

比如某个产品需要对应一个负责人，某个功能允许多个人操作
注意，这里的两个对象都分别所属不同的实体，产品有自己的属性，参数，负责人也有自己架构，属性，而跟一个对象
可能拥有多个属性是不一样的，比如一个客户可能有多个发货地址和发货人，电话等。

设计思想：

应用中设计对象之间的一对一，多对一关系，有两种设计模式：

A：以其中一个对象作为主体，另一对象则作为主体对象的附属属性，存储在主体对象的记录中，
当有多对一关联时，附属对象间用分隔符分隔。

B：创建一个交叉表，交叉表中包含了两个关联对象的外键及对应关系，通常是一笔记录反应一种对应关系。

*/
--两种设计模式的优缺点：

--A：
--产品实体

CREATE TABLE Sal_pub_product(
	productID VARCHAR(20) PRIMARY KEY,
	productName VARCHAR(50) NULL,
	accountID VARCHAR(50) NULL --负责人外键列表
)
go
INSERT INTO Sal_pub_product(productID,productName,accountID)
VALUES('p001','金属','u001,u002,u003'),('p002','铅','u005')
go
--负责人实体
CREATE TABLE sys_user(
	accountID VARCHAR(20) PRIMARY KEY,
	accountName VARCHAR(50) NULL
)
go
INSERT  INTO sys_user(accountID,accountName)values
('u001','小五'),
('u002','小多个'),
('u003','小在'),
('u005','小工')
go

SELECT * FROM Sal_pub_product
SELECT * FROM sys_user

--1,负责人外键列表受字符串长度影响，不能无限添加用户
INSERT INTO Sal_pub_product(productID,productName,accountID)
VALUES('p004','金属','u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003,u001,u002,u003')


--2,分隔符必须永远不能出现在条目中

--3,查找困难

/*
无法对负责人进行聚合统计，需要做数据转换，或者另类处理

比如：统计产品有多少个负责人
*/
SELECT productID,productName,LEN(accountid)-LEN(REPLACE(accountid,',',''))+1
FROM Sal_pub_product 

--在负责人列表中查找指定对象将无法使用索引，并且非常耗时
SELECT * FROM Sal_pub_product WHERE CHARINDEX(',u001,',','+accountid+',')>0

--增加，删除，修改需要依靠程序界面来操作

/*
合适使用场景：

1，存储的列表没必要获取列表中的单独项，通常作为一个整体获取到前台处理
2，不需要再作数据转换后再关联其它表获取相关信息，比如名称，通常会把id,和名称同时对应的保侟。
3，增删改在前台程序处理。
*/


--B:交叉表
CREATE TABLE sal_bas_productAcc(
	productID VARCHAR(20) NOT NULL,
	AccountID VARCHAR(20) NOT NULL,
	demo VARCHAR(50)	--可以添加关联的条件，说明等。
)
GO
INSERT INTO sal_bas_productAcc(productID,AccountID)
VALUES('p001','u001'),
	('p001','u002')

SELECT * FROM sal_bas_productAcc

--通过与交叉表关联，可以进行任何方式的取值和统计

--查找
SELECT * FROM Sal_pub_product a
INNER JOIN sal_bas_productAcc b ON a.productId = b.productID
WHERE b.accountID = 'u001'

--统计
SELECT productid,COUNT(*) '用户数' FROM sal_bas_productAcc GROUP BY productId

--增删改变得更简单