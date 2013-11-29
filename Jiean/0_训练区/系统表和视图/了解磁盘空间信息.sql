-- 默认查询硬盘驱动器
EXEC master.dbo.xp_fixeddrives 

-- 查询移动设备(例如U盘)
EXEC master.dbo.xp_fixeddrives 2

-- 查询大量存储设备(CD-ROM，DVD等)
EXEC master.dbo.xp_fixeddrives 3

-- 查询硬盘驱动器
EXEC master.dbo.xp_fixeddrives 4


--了解磁盘的详细信息

-- 打开 xp_cmdshell 选项
EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

-- 使用 msinfo32 查询磁盘空间信息
DECLARE
	@temp_file nvarchar(250),
	@s nvarchar(4000)

-- 通过 msinfo32 将磁盘信息存储到文件中
SELECT
	@temp_file = N'c:\'
		+ CONVERT(nvarchar(36), NEWID())
		+ N'.nfo',
	@s = N'start /wait msinfo32.exe /nfo '
		+ QUOTENAME(@temp_file, N'"')
		+ N' /categories +ComponentsStorage-ComponentsStorageDisks-ComponentsStorageSCSI-ComponentsStorageIDE'
EXEC master.dbo.xp_cmdshell @s, NO_OUTPUT

-- 从文件中获取磁盘信息
DECLARE 
	@xml xml

SELECT
	@s = N'
SELECT
	@xml = CONVERT(xml, T.c)
FROM OPENROWSET(BULK N' + QUOTENAME(@temp_file, N'''')
	+ N', SINGLE_BLOB) T(c)'
EXEC sp_executesql @s, N'@xml xml OUTPUT', @xml OUTPUT

-- 删除磁盘信息文件
SELECT
	@s = N'DEL ' 
		+ QUOTENAME(@temp_file, N'"')
EXEC master.dbo.xp_cmdshell @s, NO_OUTPUT

-- 显示磁盘信息
SELECT
	Item = T.c.value(N'(项目)[1]', 'nvarchar(500)'),
	Value = T.c.value(N'(数值)[1]', 'nvarchar(500)')
FROM @xml.nodes(N'/MsInfo
	/Category[@name="系统摘要"]
	/Category[@name="组件"]
	/Category[@name="存储"]
	/Category[@name="驱动器"]
	/Data') T(c)
