

declare @s varchar(max)
declare @htmlFlag varchar(10) --ɾ��ָ��־
declare @htmlFlagLen varchar(10)
declare @i int
set @s='<body<div id=u><<a href=http://passport.bai>du.com/?login&tpl=mn>��¼</a></div><center><img src=http://www.baidu.com/img/baidu_logo.gif width=270 height=129 usemap="#mp" id=lg><br><br><br><br><table cellpadding=0 cellspacing=0 id=l><tr><td><div id=m><a onclick=s(this) href=http://news.baidu.com>��&nbsp;��</a><b>��&nbsp;ҳ</b><a onclick=s(this) href=http://tieba.baidu.com>��&nbsp;��</a><a onclick=s(this) href=http://zhidao.baidu.com>֪&nbsp;��</a><a onclick=s(this) href=http://mp3.baidu.com>MP3</a><a onclick=s(this) href=http://image.baidu.com>ͼ&nbsp;Ƭ</a><a onclick=s(this) href=http://video.baidu.com>��&nbsp;Ƶ</a></div></td></tr></table><table cellpadding=0 cellspacing=0 style="margin-left:15px"><tr valign=top><td style="height:62px;padding-left:92px" nowrap><div style="position:relative"><form name=f action=/s><input type=text name=wd id=kw size=42 maxlength=100> <input type=submit value=�ٶ�һ��id=sb><div id=sug onselectstart="return false"></div><span id=hp><a href=/search/jiqiao.html>����</a><br><a href=/gaoji/advanced.html>�߼�</a></span></form></div></td></tr></table></body>'
--set @s='body><div><a href="http://passport.baidu.com/?login&tpl=mn">��¼</a></div></body>'

set @htmlFlag='a'
set @htmlFlagLen = len(@htmlFlag + ' a')-2

--Ԥ����ʵ�����
set @s = replace(@s,' ','')
set @s = replace(@s,'&nbsp;','')
set @s = replace(@s,'&lt;','<')
set @s = replace(@s,'&gt;','>')

declare @posstart int
declare @possend int

while charindex('<'+@htmlFlag,@s)>0
begin 
	set @posstart= charindex('<'+@htmlFlag,@s)
	set @possend = charindex('>',@s,@posstart)
	set @s = stuff(@s,@posstart,@possend-@posstart+1,'')
	--select @s
end
if @htmlFlag>'' set @s=replace(@s,'</'+@htmlFlag+'>','')
set @s=ltrim(rtrim(@s))
set @s=replace(@s,char(9),'')
set @s=replace(@s,char(10),'')
set @s=replace(@s,char(13),'')
select @s

--������
use master
go
sp_configure 'show advanced options', 1
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1
GO
RECONFIGURE;
GO

declare @Textstr varchar(max)
DECLARE @hr integer 
DECLARE @objRegExp integer 
DECLARE @sStr varchar(5000) 
DECLARE @re integer 
DECLARE @results varchar(5000) 

set @Textstr ='<body<div id=u><<a href=http://passport.bai>du.com/?login&tpl=mn>��¼</a></div><center><img src=http://www.baidu.com/img/baidu_logo.gif width=270 height=129 usemap="#mp" id=lg><br><br><br><br><table cellpadding=0 cellspacing=0 id=l><tr><td><div id=m><a onclick=s(this) href=http://news.baidu.com>��&nbsp;��</a><b>��&nbsp;ҳ</b><a onclick=s(this) href=http://tieba.baidu.com>��&nbsp;��</a><a onclick=s(this) href=http://zhidao.baidu.com>֪&nbsp;��</a><a onclick=s(this) href=http://mp3.baidu.com>MP3</a><a onclick=s(this) href=http://image.baidu.com>ͼ&nbsp;Ƭ</a><a onclick=s(this) href=http://video.baidu.com>��&nbsp;Ƶ</a></div></td></tr></table><table cellpadding=0 cellspacing=0 style="margin-left:15px"><tr valign=top><td style="height:62px;padding-left:92px" nowrap><div style="position:relative"><form name=f action=/s><input type=text name=wd id=kw size=42 maxlength=100> <input type=submit value=�ٶ�һ��id=sb><div id=sug onselectstart="return false"></div><span id=hp><a href=/search/jiqiao.html>����</a><br><a href=/gaoji/advanced.html>�߼�</a></span></form></div></td></tr></table></body>'

EXEC @hr = sp_OACreate 'VBScript.RegExp', @objRegExp OUTPUT 
	IF @hr <> 0 BEGIN 
		select '���ܴ���VBScript.RegExp����' 
	END 
EXEC @hr = sp_OASetProperty @objRegExp, 'Pattern', '<(.[^>]*)>' 
	IF @hr <> 0 BEGIN 
	select 'Pattern�������' 
	END 
EXEC @hr = sp_OASetProperty @objRegExp, 'Global', True 
	IF @hr <> 0 BEGIN 
	select 'Global�������' 
	END 
EXEC @hr = sp_OASetProperty @objRegExp, 'IgnoreCase', True 
	IF @hr <> 0 BEGIN 
	select 'IgnoreCase�������' 
	END 
EXEC @hr = sp_OAMethod @objRegExp, 'Replace', @results OUTPUT, @Textstr,'' 
	IF @hr <> 0 BEGIN 
	select @Textstr 
	END 
EXEC @hr = sp_OADestroy @objRegExp 
	IF @hr <> 0 BEGIN 
	select '����ע��VBScript.RegExp����' 
    END 
-- Set @results = Replace(Replace(Replace(@results,'&nbsp;',''),'��',''),' ','') 
-- RETURN @results 
    select  Replace(Replace(Replace(@results,'&nbsp;',''),'��',''),' ','') 


