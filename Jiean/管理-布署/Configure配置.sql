

--Configure配置


--查看SQLServer选顶
SELECT 
name,
value,
maximum,
value_in_use,
is_dynamic,--动态选项，在执行reconfigure命令后配置改变就会生效
is_advanced --高级选顶，需要开启高级选项才能看到这些配置
 FROM sys.configurations
 
 --显示基本选项
 EXEC sys.sp_configure 
 
 --显示高级选项
 EXEC sp_configure 'show advanced option',1
 RECONFIGURE