
/*
自动编号包括：
IDENTITY 属性列
ROWGUIDCOL列 为uniqueidentiier数据类型， 全球唯一，使用NEWID函数生成ID号
*/

--IDENTITY

CREATE TABLE tb(
	id int IDENTITY(1,1) null
)

SELECT id = IDENTITY(int,1,1)

--标识列转换
SET IDENTITY_INSERT tb ON
SET IDENTITY_INSERT tb OFF

--标识列与普通列转换