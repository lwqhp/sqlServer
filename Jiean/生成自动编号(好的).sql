

--自动编号
create table temp_tb(id uniqueidentifier rowguidcol primary key default newid(),col uniqueidentifier)

select rowguidcol,* from temp_tb

--生成自动编号
alter table temp_tb alter column col varchar(20)
insert into temp_tb(col)
select 'pt0001' union all 
select 'pt0002' union all 
select 'pt0003'

select 'PT'+right(power(10,4)+(select isnull(max(right(col,4)),0) from temp_tb)+row_number() over(order by col),4), * from temp_tb

