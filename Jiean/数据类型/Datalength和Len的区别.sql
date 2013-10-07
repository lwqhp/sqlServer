

--Datalength 和 len 的区别

/*
Len ： 返回指定字符串表达式的字符（不是字节）数，且不包括尾随空格
DataLength : 返回用于表示任何表达式的字节数。
*/

--varchar类型字符串:varchar类型使用了3个单字节字符来存储三个字符的值
SELECT LEN('abcd123'),DATALENGTH('abcd123')
 ----------- -----------
7           7

(1 行受影响)

--整型:int类型不论值是多少，总是使用4个字节。LEN()函数本质上将整型值当成已转换成字符型的数据来处理
SELECT LEN(123),DATALENGTH(123000000)
----------- -----------
3           4

(1 行受影响)


--Nvarchar类型:nVarchar类型来管理相同长度的值，就要占用多一倍的字节
SELECT LEN(N'abcd123'),DATALENGTH(N'abcd123')
----------- -----------
7           14

(1 行受影响)

--首尾有空格:len不包括尾随空格
SELECT LEN(' abcd123  '),DATALENGTH(' abcd123   ')
----------- -----------
8           11

(1 行受影响)

--Null值表达式，返回的都是NULL
DECLARE @Val VARCHAR(30)
SELECT LEN(@Val),DATALENGTH(@Val)
----------- -----------
NULL        NULL

(1 行受影响)


