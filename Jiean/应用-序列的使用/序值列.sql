

--序列值
/*
序列值：按某类型进行排序生成排序序列
*/

--生成排序序列方法：

--1）
SELECT IDENTITY(INT,1,1) id INTO # FROM TB

--2)排名函数
SELECT ROW_NUMBER() OVER(ORDER BY column) ,DENSE_RANK() OVER(PARTITION BY column) FROM TB
