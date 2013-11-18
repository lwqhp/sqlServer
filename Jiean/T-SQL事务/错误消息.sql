

--系统信息

select * from sys.messages

--添加自定义消息
Exec sp_AddMessage 50001, 16, N'Not Bill', N'us_english',False,Replace
Exec sp_AddMessage 50001, 16, N'当前单据不存在！', N'Simplified Chinese',False,Replace
Exec sp_AddMessage 50001, 16, N'當前單據不存在！', N'Traditional Chinese',False,Replace

/*
用户自定义错误消息ID必须大于50000
16 错误消息的严重级别
错误消息的文本
错误消息所使用的语言
指定是否记录错误消息
指定使用新的消息正文和严重级别覆盖现有的错误消息
*/

--删除自定义消息

exec sp_dropmessage 50001,'all'


--修改自定义消息
exec sp_altermessage 50001,'with_log','true'

--抛出错误消息
raiserror(50001,16,1)