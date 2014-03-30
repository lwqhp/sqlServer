

--序列单值表
/*
序列单值表：是指以具有顺序递增的单值数据的独立表。（递增数据可以是数字，日期等）

序列表有两种应用方式：
1）自身遍历或笛卡尔积，递增数值作为循环的次数或处理的刻度。

2）表关联，反映源表的数据连续性。
*/

--定义序列单值表

--1
SELECT number FROM master..spt_values WHERE type = 'P'

--2
SELECT TOP 1000 IDENTITY(INT,1,1) number 
INTO #
FROM sys.objects a,sys.objects b

SELECT * FROM #