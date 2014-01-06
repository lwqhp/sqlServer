

--数据集比对except 和intersect
/*
对比两个数据集的记录是否相同和找不出同的记录，主要用于没有主键的堆表比较。

要求查询必须有相同数量的弄，数据类型要兼容，但列名可以不需要一致
*/

SELECT * 
INTO FIGL_Bas_AccountA
FROM dbo.FIGL_Bas_Account WHERE Accountcode NOT IN( '1001','1002')

SELECT * 
INTO FIGL_Bas_AccountB
FROM dbo.FIGL_Bas_Account WHERE Accountcode NOT IN( '100101','100201')


--except : 查询左表中存在而不在右表中存在的行（查找A,B表比较，A表中多出来的记录）

SELECT * FROM FIGL_Bas_AccountA
EXCEPT 
SELECT * FROM FIGL_Bas_AccountB


--intersect : 同时存在于左右两个表中的不重复行(A,B表中都有的记录)
SELECT * FROM FIGL_Bas_AccountA
INTERSECT  
SELECT * FROM FIGL_Bas_AccountB

SELECT * FROM FIGL_Bas_AccountB


