

SELECT * FROM FIGL_Bas_Account WHERE accountname LIKE '[皮革]'

SELECT * FROM FIGL_Bas_Account WHERE PATINDEX('%[^皮革]%',AccountName)>0


--通配符
/*
有四种通配符
1)% 表示包含零个或多个字符的任意字符串
2)_ 表示任何单个字符
3)[] 指定某个范围或列表中的一个字符
4)[^] 指定不在特定范围中的一个字符

通配符转义 ：escape '/'

使用通配符的命令有两个 like patindex
*/

--like 关键字
SELECT * FROM dbo.FIGL_Bas_Account WHERE AccountName LIKE '%[银行存款]%'
SELECT * FROM dbo.FIGL_Bas_Account WHERE AccountName LIKE '银行__'
SELECT * FROM dbo.FIGL_Bas_Account WHERE AccountName LIKE '[银行存款]'

SELECT * FROM dbo.FIGL_Bas_Account WHERE PATINDEX('%[银存]%',AccountName)>0

SELECT * FROM figl_bas_account WHERE AccountName LIKE '%银%/%%' ESCAPE '/'
/*
说明：
[]表示一个取值范围，里面每一个字符间的有关是'或'关系，^则是'非或'关系，连续字母和数字中间可用'-'表示
转义符在关键字后用escape 声明。

*/

