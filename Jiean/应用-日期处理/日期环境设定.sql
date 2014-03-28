

--（2）日期环境设定

--SQL SERVER 语言，确定了一种日期解释方法
SELECT * FROM sys.syslanguages

-->A.设置默认语言
USE master
EXEC sp_configure 'default language',[langid]
RECONFIGURE WITH override


--在任何应用程序中临时进程设定
SET LANGUAGE

/*----------------------------举例---------------------------*/

		--设置会话的语言环境为: English
		SET LANGUAGE N'English'
		SELECT 
			DATENAME(Month,GETDATE()) AS [Month],
			DATENAME(Weekday,GETDATE()) AS [Weekday],
			CONVERT(varchar,GETDATE(),109) AS [CONVERT]
		/*--结果:
		Month    Weekday   CONVERT
		------------- -------------- -------------------------------
		March    Tuesday   Mar 15 2005  8:59PM
		--*/

		--设置会话的语言环境为: 简体中文
		SET LANGUAGE N'简体中文'
		SELECT 
			DATENAME(Month,GETDATE()) AS [Month],
			DATENAME(Weekday,GETDATE()) AS [Weekday],
			CONVERT(varchar,GETDATE(),109) AS [CONVERT]
		/*--结果
		Month    Weekday    CONVERT
		------------- --------------- -----------------------------------------
		05       星期四     05 19 2005  2:49:20:607PM
		--*/
		
-->B.设置日期显示顺序

SET dateFormat --仅用在将字符串转换为日期值时有用，它对日期值的显示没有影响

/*----------------------------举例---------------------------*/

		--示例 ，在下面的示例中，第一个CONVERT转换未指定style，转换的结果受SET DATAFORMAT的影响，第二个CONVERT转换指定了style，转换结果受style的影响。
		--设置输入日期顺序为 日/月/年
		SET DATEFORMAT DMY

		--不指定Style参数的CONVERT转换将受到SET DATEFORMAT的影响
		SELECT CONVERT(datetime,'2-1-2012')
		--结果: 2012-01-02 00:00:00.000

		--指定Style参数的CONVERT转换不受SET DATEFORMAT的影响
		SELECT CONVERT(datetime,'2-1-2012',101)
		--结果: 2012-02-01 00:00:00.000
		GO

		--2.
		/*--说明

			如果输入的日期包含了世纪部分，则对日期进行解释处理时
			年份的解释不受SET DATEFORMAT设置的影响。
		--*/

		--示例，在下面的代码中，同样的SET DATEFORMAT设置，输入日期的世纪部分与不输入日期的世纪部分，解释的日期结果不同。
		DECLARE @dt datetime

		--设置SET DATEFORMAT为:月日年
		SET DATEFORMAT MDY

		--输入的日期中指定世纪部分
		SET @dt='01-2012-03'
		SELECT @dt
		--结果: 2012-01-03 00:00:00.000

		--输入的日期中不指定世纪部分
		SET @dt='01-02-12'
		SELECT @dt
		--结果: 2012-01-02 00:00:00.000
		GO

		--3.
		/*--说明

			如果输入的日期不包含日期分隔符，那么SQL Server在对日期进行解释时
			将忽略SET DATEFORMAT的设置。
		--*/

		--示例，在下面的代码中，不包含日期分隔符的字符日期，在不同的SET DATEFORMAT设置下，其解释的结果是一样的。
		DECLARE @dt datetime

		--设置SET DATEFORMAT为:月日年
		SET DATEFORMAT MDY
		SET @dt='010203'
		SELECT @dt
		--结果: 2001-02-03 00:00:00.000

		--设置SET DATEFORMAT为:日月年
		SET DATEFORMAT DMY
		SET @dt='010203'
		SELECT @dt
		--结果: 2001-02-03 00:00:00.000

		--输入的日期中包含日期分隔符
		SET @dt='01-02-03'
		SELECT @dt
		--结果: 2003-02-01 00:00:00.000
		
-->C.设置一周的第一天是星期几

set dateFirst 7-- 对所有用户有效，除非再次修改，否则该设置将一直保留

select @@DateFirst

Set DateFirst {number}--1表示星期一，7表示星期天
