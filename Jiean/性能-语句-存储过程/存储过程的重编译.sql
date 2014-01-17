

--存储过程
/*

--存储过程的重编译
在sqlServer2008以上，存储过程的编译是以语句为单位的，而不是完全编译整个存储过程，这有效降低的重编译的开销，所以在
考虑一个新的处理策略而不是重用现有计划可能是有利的，特别是表(或对应的统计)中数据的分布变化或者表中添加了新的索
引时，选择重编译是不错的选译。

--自动重编译
sqlServer 自动侦测需要重新编译现有计划的条件，sqlserver根据特定的规则确定现有计划需要重新编译的时机,(比如表
,对应的统计中数据的分布变化或者表中添加了新的索引，执行计划老化，SET选项变化等),则存储过程将在每次符合重编译要求
时重新编译.

1)存储过程语句中引用的常规表，临时表或视图的架构变化，架构变化包括表的元数据或表上的索引的变化,执行任何引用这些对象
的语句之前该存储过程必段重编译.

2)常规或临时表的列上的绑定(如默认/规则)变化

3)表索引或列上的统计的变化超过一定的阈值, Sqlserve自动在存储过程中引用该表时更新统计，并在存储过程执行时，自动重新
编译
一组行数超过一定的阈值引起的统计更新公式,n是行数，RT是阈值
实体表 : if (n<=500) {RT=500}else{RT=500+2*n}
临时表 : if (n<6){RT=6}else{if(6<=n<=500){RT=500}else{RT=500+2*n}}

4)存储过程编译时一个对象不存在，但是在执行期间创建，这被称为延迟对象解析

5）SET选项变化,在存储过程式中修乞讨set选项会导致sqlServer在执行set语句后面的语唏之前重编译该存储过程，因此，在执行
set语句之前的语句会发生重编译，set语句之后的语句会发生重编译，第二次执行后不会再重编译，set nocount 没有修改环境
设置，不会引起存储过程重编译

6)执行计划老化并被释放，或者是内存压力而强迫被释放

7)对sp_recompile系统存储过程的显式调用
手工标记需要从编译的存储过程，在存储过程和触发器上调用，则该存储过程或触发器在下次执行时被重编译，在表或视
图上调用标记所有调用该表、视图的存储过程和触发器在下次执行时重新编译。

8)显示使用recompile子句

通过观察跟踪中的EventSubClass数据列可以了解当前重编译的原因解释



*/

--重编译观察
SQL:StmtRecompile --这是跟踪语句重编译
SP:Recompile --这是存储过程跟踪事件
列名:EventSubClass
/*
sp:recompile事件表示计划已经存在但是不能被重用，当服务器重启后的存储过程执行，sqlServer会再次编译存储过程并且生成
执行计划，但这些编译不会被看作存储过程的重编译。
*/

--重编译语句
exec sp_recompile 'spSD_procedure_name'
--临时重编译，不产生计划缓存
EXEC spSD_procdure_name '参数' WITH recompile
/*
4)实体表的重编译
存储过程创建后第一次执行,执行计划在存储过程实际执行之前生成，当存储过程创建之前存储过程中创建的表不存在，则计划不会
包含引用该表的select 语句的处理策略，因此，为发执行select语句，存储过程式必须重编译。
当第二次以后执行,虽然存储过程已经drop掉了实体表，但保存在过程缓冲中的存储过程计划并没有清除，而存储过程的建表操作，
sqlServer考虑其为表架构的一次变化，因此sqlserver在存储过程执行时执行select语句之前重新编译存储过程.

注：存储过程中的实体表创建和使用会引起存储过程全部重编译

而临时表只有在第一次存储过程被重编译，而后续的执行期间的局部临时表架构与前一次执行时保持一致，局部临时表不可用于存储
过程的范围之外，所以其架构不能在多次执行之间以任何方式改变，因此，sqlserver在存储过程后续执行期间安全地重用现有的计划
（根据前一个局部临时表实例）,从而避免了重编译。
*/

create proc spTS_name12345
as
set ansi_nulls on
create table #t12(a1 int)
select * from #t12
set ansi_nulls off
select * from #t12
drop table #t12
go

exec spTS_name12345


--避免重编译
/*
1,不要交替使用DDL和DML语句
2，避免统计变化引起的重编译
有两种避免统计变化引起的重编译的技术：
a）在语句后使用option(keepfixed plan)
b) 禁用该表上的自动更新统计特性 exec sp_autostats 't1','off'

5，使用表变量
6，避免在存储过程中改变SET选项
为了ansi兼容性，建议保持以下set选项为on
arithabort
concat_null_yields_null
quoted_identifier
ansi_nulls
ansi_padding
ansi_warnings
numeric_roundabort 为off

7，使用optimize for查询提示
8，使用计划向导


*/
use AdventureWorks2012
go

CREATE PROC sptemp
AS
CREATE TABLE #myTemptable(id INT,dsc NVARCHAR(50))
INSERT INTO #myTemptable
        ( id, dsc )
SELECT ProductModelID,[name] FROM production.ProductModel /*第一次执行发生重编译,存储过程创建生成的执行计划不包
含任何关于局部临时表的信息，因此，生成的计划不会用于使用DML语句访问临时表*/

SELECT * FROM #myTemptable /*第2次重编译，来自于该表装入时其中包含的数据的变化*/

CREATE CLUSTERED INDEX PK_myTemptable ON #myTemptable(id)

SELECT * FROM #myTemptable/*第3次重编译，是由于临时表的架构变化使现在计划作废，导致在表再次被访问时进行重编译
,如果这个索引在第1次重编译之前已经创建，则现在计划将在第2条select 语句时保持有效，因此，可以将create index
DDL语句放置在所有访问该的DML语句之上来避免这次重编译*/

CREATE TABLE #t2(c1 int)

SELECT * FROM #t2/*第4次重编译，生成一个包含#t2的处理策略的计划*/

go

exec sptemp --第二次执行则会重用计划缓存

--表变量
/*
使用表变量，可以避免临时表引起的重编译，因为表变量不创建统计，与临时表相关的不同重编译问题不适用于它，对于
延迟对象解析，存储过程在第一次执行时被重编译，但表变量不会。
表变量没有事务日志开销，没有锁开销，没有回滚开锁
在创建之后不能在表变量上执行任何ddl语句，约束只能作为表变量的declare语句的一部份，因此，在表变量上只能用
primary key或unique约束创建一个索引
表变量不创建任何统计，这意味着它们在执行计划中被解析为一个单行的表
表变量中不支持以下语句
insert into ta exec spname
select * into from tb
set @tb = value
*/