

--表
/*

表最多能有1024列，实际每行字节总数不能超过8060,一个数据页大小为8K,其中包括存储了该页信息的头，大值数据类型
varchar(max),text,image,xml则不受这个字节限制的约束。
对于普通varchar,nvarchar,varbinary,sql_variant数据类型引入行溢出功能，如果这些数据类型的长度都没有超过8000,
但几列加起来超过8000字节的行限制，则最大宽度的那个列会被动态地移到另外一个8kb页，并且在原如表中使用24字节的
指针代替，依赖页面溢出可能会降低查询性能。

*/
--修改表列的局限性--------------------------------------------------------------------------------
/*
除非列数据类型是varcar,nvarchar,varbinary,否则不能修改用在索引中的列，即使如此，数据类型的新的大小也必须要比
原来的大。也不能对有主键或者外键约束的列使用alter column.
*/
SELECT * FROM dbo.a
ALTER TABLE dbo.a ALTER COLUMN a INT NOT NULL
ALTER TABLE dbo.a ADD CONSTRAINT PK_a PRIMARY KEY CLUSTERED (a)

ALTER TABLE  dbo.a ALTER COLUMN a VARCHAR(30)

ALTER TABLE a ADD a2 VARCHAR(100) NULL

ALTER TABLE a ALTER COLUMN a2 VARCHAR(50)

CREATE NONCLUSTERED INDEX IX_a ON a(a2)

ALTER TABLE a ALTER COLUMN a2 VARCHAR(100)

ALTER TABLE a ALTER COLUMN a2 VARCHAR(50)

--计算列--------------------------------------------------------------------------------
/*
计算列不能用default或者foreign key 约束，计算列不能被显式更新或插入(因为它的值都是计算出的)
计算列能用在索引中，但是一定要符合一些条件，比如是确定的(对于一组给定的输入总是返回相同的结果)
和精确的(不包含浮点值)

对于使用persited物理化的计算列，能用于表分区或者非精确(基于浮点)值的索引。
*/
ALTER TABLE a ADD cost AS(a/a2) -- 用as 定义一个计算列

ALTER TABLE a ADD cost2 AS(a/a2) PERSISTED --用persisted关键字物理化计算列
INSERT INTO a(a,a2)VALUES(10,5)

SELECT * FROM a

--稀疏列--------------------------------------------------------------------------------
/*
这是一种优化的存储方式，为null值启用零字节的存储，因此，可以为表定义大量的稀疏列，目前可以许到30000个。
当数据库设计和应用程序需要大量不常填充的列，或表中列集中和表中存储数据的子集相关时，使用稀疏列是比较理想的
*/

ALTER TABLE a ADD a3 VARCHAR(50) SPARSE NULL  --添加一个稀疏列

SELECT * FROM dbo.a
WHERE a3 IS NULL

/*
列集：可以对所有定义在表中的稀疏列进行逻辑分组，xml数据类型计算列允许selet和数据修改，一个表只可以有一个列集

*/
--不能在一个已经定义了稀疏列的表上增加列集
ALTER TABLE a ADD a4 XML COLUMN_SET FOR ALL_SPARSE_COLUMNS


CREATE TABLE SetSparse (
a1 INT NULL
,a2 VARCHAR(30) SPARSE NULL
,a3 INT SPARSE NULL
,a4 XML COLUMN_SET FOR ALL_SPARSE_COLUMNS --定义列集
)

/*
一旦定义了列集，select *将不显示稀疏列，
可以为稀疏列和列集更新插入，但不能两个同时操作
稀疏列可以使用很多数据类型，但image,ntext,text,timestamp,geometry,geography 或用户定义类型不行。
*/
SELECT a2,* FROM setsparse --定义的稀疏列看不见
INSERT INTO setsparse(a1,a2,a3,a4)
SELECT 1,'a',3,'dfdf'



--删除列--------------------------------------------------------------------------------
ALTER TABLE a DROP COLUMN a1

/*
仅当列没有使用primary key foreign key,uniqu 或check constraint 时，才可以删除列，也不能删除用在索引中或者
绑定了default值的列
*/
--试图删掉一个带约束的列，失败
ALTER TABLE a ADD a5 INT DEFAULT(1)

ALTER TABLE a DROP COLUMN a5