/*-------计算年龄--------------

将出生日期的年份增加到与当前日期相同，然后再与当前日期比较，如果是大于，
则年龄为当前日期减去出生日期的结果再减一年，否则是两个日期直接相减

*/

datediff(year,'1999-09-09',getdate())
	-CASE WHEN
	dateadd(year,datediff(year,'1999-09-09',getdate()),'1999-09-09')>getdate()
	THEN 1 ELSE 0 END 

