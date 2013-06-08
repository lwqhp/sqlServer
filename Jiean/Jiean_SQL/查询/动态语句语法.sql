--动态sql语句基本语法 
--1 :普通SQL语句可以用Exec执行 

eg:   Select * from tableName 
         Exec('select * from tableName') 
         Exec sp_executesql N'select * from tableName'    -- 请注意字符串前一定要加N 

--2:字段名，表名，数据库名之类作为变量时，必须用动态SQL 

eg:   
declare @fname varchar(20) 
set @fname = 'FiledName' 
Select @fname from tableName              -- 错误,不会提示错误，但结果为固定值FiledName,并非所要。 
Exec('select ' + @fname + ' from tableName')     -- 请注意 加号前后的 单引号的边上加空格 

--当然将字符串改成变量的形式也可 
declare @fname varchar(20) 
set @fname = 'FiledName' --设置字段名 

declare @s varchar(1000) 
set @s = 'select ' + @fname + ' from tableName' 
Exec(@s)                -- 成功 
exec sp_executesql @s   -- 此句会报错 



declare @s Nvarchar(1000)  -- 注意此处改为nvarchar(1000) 
set @s = 'select ' + @fname + ' from tableName' 
Exec(@s)                -- 成功     
exec sp_executesql @s   -- 此句正确 

3. 输出参数 
declare @num int, 
        @sqls nvarchar(4000) 
set @sqls='select count(*) from tableName' 
exec(@sqls) 
--如何将exec执行结果放入变量中？ 

declare @num int, 
               @sqls nvarchar(4000) 
set @sqls='select @a=count(*) from tableName ' 
exec sp_executesql @sqls,N'@a int output',@num output 
select @num 