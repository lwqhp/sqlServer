
USE AdventureWorks
go

BEGIN TRAN 
SELECT productID,modifieddate
FROM production.ProductDocument WITH (TABLOCK)

rollback tran 

--锁活动查询
SELECT 
request_session_id,
resource_type,
resource_database_id,
OBJECT_NAME(resource_associated_entity_id,resource_database_id),
request_mode,
request_status
 FROM sys.dm_tran_locks
WHERE resource_type IN('database','object')
/*
resource_type指定锁定的资源类型（锁范围的类型）
resource_associated_entity_id 依赖资源类型，
1）如果该列包含对象ID是object类型的，可以用sys.objects 视图来关联
2）如果该列包含分配单元ID(类型是allocation_unit),可以引用sys.allocation_units 和container_id,然后可以将
	container_id 联结到sys.partitions上，此时就可以确定对象ID了
3)如果该包含hobt ID(资源类型为key,page,row,hobt),可以直接引用sys.partitions,然后查找相应的对象ID
4）对于database,extent,application或metadata的资源类型，该列值为0
*/

--锁的禁用
/*
1，table,这是默认行为，当设置为该值时，就在表级别启用了锁升级，不论是否为分区表
2，auto如果是表已分区，则在分区级别（堆或B树）启用锁升级，如果表未分区，锁升级将发生在表级别上。
3，disable在表级别删除锁升级，注意，对于用了tablock提示或使用可序列化隔离级别下堆的查询时，你仍然可能看到表锁
*/
ALTER TABLE person.Address
SET (lock_escalation=auto)




SELECT request_session_id	--锁的来源进程
,resource_type --来源锁的类型
,request_status
,request_mode	--锁的名称
,b.index_id  --索引ID
,b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id
ORDER BY a.request_session_id,a.resource_type

-------------------------------------------------------------------------------------------------------------

--B连接

/*
sys.dm_tran_locks 锁视图分析查询结束以后连接A还持有的锁
*/
USE AdventureWorks
GO


SELECT request_session_id	--锁的来源进程
,resource_type --来源锁的类型
,request_status
,request_mode	--锁的名称
,b.index_id  --索引ID
,b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id
ORDER BY a.request_session_id,a.resource_type

/*
1,database 因为连接正在访问数据库adventureworks,所以它在数据库一级加了一个共享锁，以防止别人将数据库删除。
2，object 因为正在防问表格，所以在表格上加了一个意向共享锁，以防别人修改表的定义。
3，key,Page 查询有1条记录返回，所以在这条记录所在的聚集索引键上，持有一个共享锁。在这个键所在的页面上，持有一个意向共享锁。

总结：这个查询申请锁的数目是很少的。其他用户访问同一张表，只要不访问这条记录，就不会被影响到。这是因为查询
使用了clustered index seek 的关系。
*/

-----------------

--查询2
/*
因为在Empoyee_demo_Heap的EmployeeID上是一个非聚集索引，所以SQLServer在用非聚集索引找到这条记录后，必须再到
数据页面上把其它的行上面的数据找出来(所谓的Bookmark Lookup),虽然只返回一条记录，可是它在PK_employee_demo_heap
上申请了一个KEY锁，在RID（data page 上的row）申请了一个row锁。在这两个资源所在的页面上各申请了一个page意向锁。

总结：虽然返回的结果和查询1一样，但是由于它使用的是非聚集索引+bookmark lookup,所以申请的锁的数目要比查询1多。
一个查询要使用的索引键(或者RID)数目越多，它申请的锁也就会越多，没有使用到的索引上不会申请共享锁。
*/


--查询3
SET STATISTICS PROFILE ON

BEGIN TRAN 
SELECT employeeid,loginID,title 
FROM employee_demo_heap WHERE employeeID IN(3,30,200)

/*
由于要返回3条分布在不同数据页上的记录，SQLServer认为做非聚集索引+Bookmark Lookup并不比做一个表扫描快，所以它
直接选择了一个表扫描，这样的执行计划会带来什么样的效果呢？

查询3在1:4621:22 4621页面的读到第22行，在这个页面上申请一个意向锁和行锁共享锁，但因为上一个语句在
修改这一行的记录，已经添加了一个行锁排它锁，所以查询3被阻塞了。

看看一次表扫描所有数据页面带来的后果：

查询3不但在记录页上申请了意向锁，还在表格的所有页面上都申请了意向锁，查询3在扫描每一张页面的时间，会对读到的
每一个数据记录加上一个共享锁（读完了这条记录就会释放，不用等到整个语句结束），只要有任何一个记录上的锁没有申请
到，查询就会被阻塞住。
*/

ROLLBACK TRAN 

--同样的查询，运行在employee_demo_Btree上
BEGIN TRAN 
SELECT employeeid,loginID,title 
FROM employee_demo_Btree WHERE employeeID IN(3,30,200)

/*
没有发生阻塞，这是因为查询使用的是index seek,不需要每条记录都读一遍，所以就不用去读employeeid=70,也就不会被阻塞住
*/


/*
总结：

在非“未提交读” 的隔离级别上

1,查询在运行的过程中，会对每一条读到的记录或键值加共享锁，如果记录不用返回，那锁就会被释放，如果记录需要返回，
则视隔离级别而定，如果是"已提交读"，则也释放，否则不释放。

2，对每一个使用到的索引sqlserver也会对上面的键值加共享锁。

3，对每一个读过的页面，sqlserver会加一个意向锁。

4，查询需要扫描的页面和记录越多，锁的数目也会越多，查询用到的索引越多，锁的数目也会越多。

所以，如果想减少一个查询被别人阻塞或阻塞去哪里人的概率数据库设计者能做的事情有：

a,尽量返回少的记录集。返回的结果越多，需要的锁也就越多。
b,如果返回结果集只是表格所有记录的一小部份，要尽量使用index seek,避免全表扫描这种执行计划。
c,可能的话，设计好合适的索引，避免sqlServer通过多个索引才找到数据。

当然这些都是对于“已提交读”以上的隔离级别而言。如果选用“未提交读”，sqlServer就不会申请这些共享锁，阻塞也就不会发生。
*/

--查询某个数据库上面的锁是在哪些表格，哪些索引上面.
select request_session_id,resource_type,resource_associated_entity_id,
request_status,request_mode,resource_description,p.object_id,object_name(p.object_id) as object_name,p.*
 from sys.dm_tran_locks a
left join sys.partitions p on a.resource_associated_entity_id = p.hobt_id
where a.resource_database_id = db_id('adventureworks2012')
order by request_session_id,resource_type,resource_associated_entity_id

/*
在事件里启用lock:accquired 和lock:released 跟踪语句的锁的申请和释放
*/


/*
测试
*/

select BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, 
JobTitle, 
BirthDate, 
MaritalStatus, 
Gender, 
HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid,
ModifiedDate
into Employee_Demo_Btree
from HumanResources.Employee


alter table Employee_Demo_Btree add constraint PK_Employee_Demo_Btree primary key clustered (BusinessEntityID)
create nonclustered index IX_Employee_Demo_Btree on Employee_Demo_Btree(LoginID)
create nonclustered index IX_Employee_Demo_Btree_MD on Employee_Demo_Btree(ModifiedDate)


select BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, 
JobTitle, 
BirthDate, 
MaritalStatus, 
Gender, 
HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid,
ModifiedDate
into Employee_Demo_Heap
from HumanResources.Employee

alter table Employee_Demo_Heap add constraint PK_Employee_Demo_Heap primary key nonclustered (BusinessEntityID)
create nonclustered index IX_Employee_Demo_Heap on Employee_Demo_Heap(LoginID)
create nonclustered index IX_Employee_Demo_Heap_EH on Employee_Demo_Heap(ModifiedDate)

/*
在可重复读的级别下，共享锁要保留到事务提交的时候才释放，所以在测试环境下，如果在这人隔离级别下开启一个事务，再运行一个查询
语句，就能看到这个查询所申请的主要共享锁。
*/

--将事务隔离级别设成可重复读(repeatable Read)
--爱蛇'累神
set transaction isolation level repeatable read

set statistics profile on

begin tran 
select BusinessEntityID,LoginID,JobTitle from Employee_Demo_Btree where BusinessEntityID=3
begin tran 
select BusinessEntityID,LoginID,JobTitle from Employee_Demo_Heap where BusinessEntityID=3

rollback tran 
--在另一个连接中执行
select request_session_id,resource_type, resource_associated_entity_id,
request_status,request_mode,resource_description,p.index_id,p.object_id,object_name(p.object_id) as object_name,p.*
 from sys.dm_tran_locks a
left join sys.partitions p on a.resource_associated_entity_id = p.hobt_id
--where a.resource_database_id = db_id('adventureworks2012')
order by request_session_id,resource_type

/*
因为连接正在访问数据库，所以它在数据库一级加了一个共享锁，以防止别人将数据库删除
因为正在访问表格,所在在表格上加了一个意向共享锁，以防别人修改表的定义
查询返回1条记录，所以在这条记录所在的聚集索引键上，持有一个共享锁，在这个键所在的页面上，持有一个意向共享锁.
request_session_id resource_type                                                resource_associated_entity_id request_status                                               request_mode                                                 resource_description                                                                                                                                                                                                                                             index_id    object_id   object_name                                                                                                                      partition_id         object_id   index_id    partition_number hobt_id              rows                 filestream_filegroup_id data_compression data_compression_desc
------------------ ------------------------------------------------------------ ----------------------------- ------------------------------------------------------------ ------------------------------------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------- ----------- -------------------------------------------------------------------------------------------------------------------------------- -------------------- ----------- ----------- ---------------- -------------------- -------------------- ----------------------- ---------------- ------------------------------------------------------------
51                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
53                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
54                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
56                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
58                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
58                 KEY                                                          72057594058506240             GRANT                                                        S                                                            (98ec012aa510)                                                                                                                                                                                                                                                   1           935674381   Employee_Demo_Btree                                                                                                              72057594058506240    935674381   1           1                72057594058506240    290                  0                       0                NONE
58                 OBJECT                                                       935674381                     GRANT                                                        IS                                                                                                                                                                                                                                                                                                                            NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
58                 PAGE                                                         72057594058506240             GRANT                                                        IS                                                           1:24312                                                                                                                                                                                                                                                          1           935674381   Employee_Demo_Btree                                                                                                              72057594058506240    935674381   1           1                72057594058506240    290                  0                       0                NONE
59                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL


查询2,一个查询要使用的索引键(RID)数目越多，它申请的锁也就会越多，没有使用到的索引上不会申请共享锁。
*/


--是不是所有的查询都只在返回的记录上加锁呢

begin tran 
update Employee_Demo_Heap set JobTitle='aaa' where BusinessEntityID=70

begin tran
select  BusinessEntityID,loginID,jobTitle from Employee_Demo_Heap where BusinessEntityID in(3,30,200)

rollback tran 
/*
从dmv显示，in查询读到了1:7581:24,它是BusinessEntityID 70 被上面那句update语句修改了，还没有提交，所以in查询就被阻塞了
in查谒不但在这3第记录所在的页面上申请了IS锁，还在表格的所有页面上都申请了 IS锁，这就是一次全表扫描扫描了所有的数据页面还来的
后果，更严重的是，in查询在扫描每一张页面的时候，会对读到的每个数据记录加上一个共享锁（读完了这第记录就会释放，不伤脑筋等到整个语
句结束）只要有任何一个记录上的锁没有申请到，查询就会被阻塞地。

规律(在非'未提交读'的隔离级别上)
1)查询在运行的过程中，会对每一条读到的记录或键值加共享锁，如果记录不用返回，那锁就会被释放，如果记录需要被返回，则视隔离级别
而定，如果是'已提交读'，则也释放，否则不释放
2)对每一个使用到的索引，sqlserver也会对上面的键值加共享锁
3)对每一个读过的页面，sqlserver会加一个意向锁
4)查询需要扫描的页面和记录越多，锁的数目也会越多，查询用的索引越多，锁的数目也会越多，所以，如果想减少一个查询被别人阻塞或
阻塞别人的根率，数据库设计都能做的事有：
1,尽量返回少的记录集，返回的结果越多，需要的锁也就越多
2，如果返回结果集只是表格所有记录的一小部份，要尽量使用index seek ,避免全表扫描这种执行计划。
3，可能的话，设计好合适的索引，避免sqlserver通过多个索引才找到数据.
当然这些都是对于‘已提交读’以上的隔离级别而言，如果选用'未提交读',就不会申请这些共享锁。阻塞地不会发生。


update 的规律
1)对每一个使用到的索引，sqlserver会对上面的键值加U锁
2)sqlserver只对要做修改的记录或键值加x锁
3)使用到要修改的列的索引越多，锁的数目也会越多
4)扫描过的页面越多，意向锁也会越多，在扫描的过程，对所有扫描到的记当也会加锁，哪怕上面没有修改
所以注意点：
1，尽量修改少的记录集，修改的记录越多，需要的锁也就越多
2，尽量减少无谓的索引，索引的数目越多，需要的锁也可能越多


delete 的规律
1)delte的过程是先找到符合条件的记录，然后做删除，可以理解成先是一个select，然后是delete,所以，如果有合适的索引，第一步申请的锁
就比较少
2)delete不但是把数据行本身删除，还要删除所有相关的索引键，所以一张表上索引数目越多，锁的数目就会越多，也就越容易发生阻塞

insert 的规律

1)数据库上的S锁(resource_type=datebase)
2)表上的IX锁(resource_type=object)
3)每个索引上都要插入一条新数据，所以有一个key上的x锁。
4）在每个索引上发生变化的那个页面，申请了一个IX锁。
*/



/*
问题定位和解决
阻塞是事务隔离带来的的产物
*/

begin tran
update Employee_Demo_Heap set JobTitle = 'aaa' where BusinessEntityID =70
update Employee_Demo_Btree set JobTitle ='aaa' where BusinessEntityID =70

select * from master.sys.sysprocesses


select request_session_id,resource_type, resource_associated_entity_id,
request_status,request_mode,resource_description,p.index_id,p.object_id,object_name(p.object_id) as object_name,p.*
 from sys.dm_tran_locks a
left join sys.partitions p on a.resource_associated_entity_id = p.hobt_id
--where a.resource_database_id = db_id('adventureworks2012')
order by request_session_id,resource_type



--如何定位一个阻塞
select * from master.sys.sysprocesses

/*
1)数据库上有没有阻塞发生，哪些接接发生了阻塞，是谁阻塞地谁

须查找有没有那个连接blocked 字段不为0,也不是-2,-3,-4,那它就是被告spid等于这个字段值的那个连接给阻塞住了。
如果你发现一个连接的blocked 字段的值等于它自己，那倒不说明什么问题，常常因为是这个连接正在做磁盘读写，它要等自己的I/o做完。

2)什么时候开始的
只要看waittime,阻塞等待时间

3)在那个数据库上
一般检查dbid，
select * from master.sys.sysdatebases

4)阻塞城哪些个或哪些表格上，哪些资源上
在sp_lock结果集中妹找状态是wait的锁源
select object_name(951674438)
select * from sys.indexes where object_id = 951674438
RID:格式为了fileid:pagenumber:rid 的标识符，其中fileid标识包含页的文件，pagenumber标识包含行的页，rid标识页上的特定行。
fileid 和sys.database_files 目录视图中的file_id列相匹配.
KEY:数据库引擎内部使用的十六进制数，这个值和sys.partitions.hobt_id相对应。出现这种资源说明锁是在一个索引上面的，通过查询
sys.partitions视图里相应的object_id和index_id就能找到这个索引。

PAG:格式为fileid:pagenumber
EXT:标识区中的第一页的数字，该数字的格式为fileid:pagenumber
TAB:没有提供信息，国为已经在objid列中标识了表
DB:没有提供信息，国为已经在dbid列中标识了表
FIL:文件的标识符，与sys.database_files目录视图中的file_id列相匹配.

5)和阻塞圾关的连接是从哪些应用来的
sys.sysprocesses
hostname,program_name,hostprocess
loginame,nt_domain,nt_username...

6)为什么阻塞会发生
a,阻塞的源头是在做事情的时候申请这引起锁，为什么会申请这些锁
锁可能是会话正在运行中的语句申请的，但也可能是这个会话在先前开启了一个事务，没有提交，锁资源是事务开启后的任何时个语句申请的，
当时阻塞可能还没有发生.


*/

--查询阻塞
select convert(smallint,req_spid) as spid,
rsc_dbid as dbid,
rsc_objid as objID,
rsc_indid as indid,
substring(v.name,1,4) as type,
substring(rsc_text,1,32) as resource,
substring(u.name,1,8)as mode,
substring(x.name,1,5) as status
from master.dbo.syslockinfo,
master.dbo.spt_values v,
master.dbo.spt_values x,
master.dbo.spt_values u
where master.dbo.syslockinfo.rsc_type = v.number
and v.type = 'LR'
and master.dbo.syslockinfo.req_status = x.number
and x.type = 'LS'
and master.dbo.syslockinfo.req_mode +1 = u.number
and u.type = 'L'
and substring(x.name,1,5) ='WAIT'
order by spid

--查询正在运行中的语句
/*返回所有正在运行中的连接和它正在运行的语句，如果一个连接处于空闲状态，为虎添翼不会被告返回*/
select 
p.session_id,p.request_id,p.start_time,
p.status,p.command,p.blocking_session_id,p.wait_type,p.wait_time,
p.wait_resource,p.total_elapsed_time,p.open_transaction_count,
p.transaction_isolation_level,
substring(qt.text,p.statement_start_offset/2,
	(case when p.statement_end_offset = -1
	then len(convert(nvarchar(max),qt.text))*2
	else p.statement_end_offset
	end - p.statement_start_offset)/2) as 'sql statement',
	p.statement_start_offset,p.statement_end_offset,bach=qt.text
 from master.sys.dm_exec_requests p
cross apply sys.dm_exec_sql_text(p.sql_handle) as qt
where p.session_id>50

--空闲连接上次运行的最后一条语句
/*
dbcc inputbuffer(<spid>)
可以获得从客户端发送到sqlserver实例的最后一个批处理语句，这个命令的优点是不管连接是否正在运行，都会返回结果，缺点是它返回的是整个批处理语句，而不是当前正在
执行的子句，所以对于正在运行的连接，第一种植方法比较好。

如果阻塞发生在表a上，而当前这句话不可能在这个表上加相应的，那基本上可以断定阻塞是由于一个先前开启的事务导致的。

2）阻塞的源头当时的状态是什么，是一直在执行，还是已经进入空闲状态.
一个最简单的方法，是看sysprocesses 里面的kpid 和waittype两个字段，如果两个都是0,就是一个处于空闲状态的连接。如果不都是0，或者
连接正在运行中，或者它因为资源等待而暂时挂起。

3)如果它一直在执行，为什么要执行那么久
如果一个连接的kpid值不是0（连接拿到了一个线程资源），waittype值是0（它不需要等待任何资源）它的状态就会是runnable 或running.
如果一个连接的kpid值不是0,waittype值也不是0,则说明它要等待某个资源才能继续执行。这时候连接的状态一般是suspended.

4)如果已经进入空闲状态，那为什么没有释放锁资源
如果一个连接的kpid值是0(连接没有占用线程资源),waittype值也是0(它不需要等待任何资源),那么这个连接已经完成了客户端发过来的所有请
求，现在进入了空闲状态，正在等待客户端发送新的请求.

按道理在这种情况下连接应该释放先前申请的锁资源才对。如果这时它还是阻塞的源头，一般是因为这经有先前开启的事务没有及时拉交，这可以通过检查sysprocesses
里的open_tran这段是否大于0确认。通过inputbuffer也可以知道这个连接最后发过来的那句话是什么。

5）其它被阻塞的连接它们想要做什么？为什么也要申请这些锁资源？
使用步骤a里面的脚本，也能够知道被告阻塞的连接正在运行的语句。然后再去比较sp_lock的结果，就能大致判断它申请的锁数量是否合理。
如果不是很合理，可能通过优化语句，加合适的索引解决。

*/
