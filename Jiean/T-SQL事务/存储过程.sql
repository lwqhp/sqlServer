

--存储过程
/*
声明参数
1)名称		:以@开头，不能内嵌空格，符合命名规则
2)数据类型	:sqlserver内置或用户自定义的有效数据类型
3)默认值	：参数初始值
4)方向		：output表示引用外部变量地址。（也可理解为输出参数）

return 返回值：必须为整数，默认返回0,表示存储过程执行成功，return处返回
返回值可用于实际地返回数据，比如标识值或是存储过程影响的行数，一般主要用于确定存储过程的执行状态。
*/
--返回值存变量
DECLARE @RetVal INT
EXEC @RetVal = Sp_TestReturns;
SELECT @RetVal