

--数据库版本
SELECT @@VERSION
--打补丁
SELECT SERVERPROPERTY('productLevel')
--实例
computer_name\instance_name

--统计数据库里每个表的详细情况：
  exec sp_MSforeachtable @command1="sp_spaceused '?'"

  --获得每个表的记录数和容量:
  EXEC sp_MSforeachtable @command1="print '?'",
       @command2="sp_spaceused '?'",
       @command3= "SELECT count(*) FROM ? "

  --获得所有的数据库的存储空间:
  EXEC sp_MSforeachdb  @command1="print '?'",
       @command2="sp_spaceused "
       
       

---------------数据库引擎环境-----------------

--语言环境
/*sql server 中定义了33种语言，每种语言确定了一种日期解释方法，放在 syslanguages 系统表中
SET LANGUAGE 指定SqlServer语言
SET DATEFIRST {number | @number_var} 设置一周的第一天是星期几，对所有用户均有效。
	1~表示一周的第一天是星期一，7~表示一周的第一天对应为星期日。
*/
SELECT @@LANGUAGE

--设置默认语言为英语
use master
exec sp_configure 'default language',0
reconfigure with override 
--SET 指定设置语言(会话型)
set language N'english'

--一周的第一天是星期几,1-7
SELECT @@DATEFIRST

--设置第一天是星期几
set datefirst 7

--设置日期的显示格式
set dateformat dmy --mdy,dmy,ymd,ydm,myd,dym