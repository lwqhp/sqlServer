
/*
数据结构之-数据类型


当我们用 alter table 对表结构列类型进行增，删，改的时候，SQLServer会校验数据的兼容性，
并只修改元数据而可能不会去触碰页面上的物理数据
*/

IF object_id('altertc') IS NOT NULL DROP TABLE altertc
create table altertc(id int identity(1,1),col char(10))
go

insert into altertc
select REPLICATE('a',5) union all
select REPLICATE('b',5) 

--select * from altertc



--查看数据行
dbcc ind(Test,altertc,-1)--查询一个存储对象的内部存储结构信息
dbcc traceon(3604)
dbcc page(Test,1,1014,1)

/*

Slot 0, Offset 0x60, Length 21, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 21

Memory Dump @0x000000000B2EA060

0000000000000000:   10001200 01000000 61616161 61202020 †........aaaaa    
0000000000000010:   20200200 00††††††††††††††††††††††††††  ...            

Slot 1, Offset 0x75, Length 21, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 21

Memory Dump @0x000000000B2EA075

0000000000000000:   10001200 02000000 62626262 62202020 †........bbbbb    
0000000000000010:   20200200 00††††††††††††††††††††††††††  ...  
*/

--增加一列
ALTER TABLE altertc ADD col2 char(20) 
/*


Slot 0, Offset 0x60, Length 21, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 21

Memory Dump @0x000000000B2EA060

0000000000000000:   10001200 01000000 61616161 61202020 †........aaaaa    
0000000000000010:   20200200 00††††††††††††††††††††††††††  ...            

Slot 1, Offset 0x75, Length 21, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 21

Memory Dump @0x000000000B2EA075

0000000000000000:   10001200 02000000 62626262 62202020 †........bbbbb    
0000000000000010:   20200200 00††††††††††††††††††††††††††  ...  
*/

--插入一列
INSERT INTO altertc
SELECT REPLICATE('c',5),''

INSERT INTO altertc(col)
SELECT REPLICATE('c',5)
/*
Slot 1, Offset 0x75, Length 21, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 21

Memory Dump @0x000000000B2EA075

0000000000000000:   10001200 02000000 62626262 62202020 †........bbbbb    
0000000000000010:   20200200 00††††††††††††††††††††††††††  ...            

Slot 2, Offset 0x8a, Length 41, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 41

Memory Dump @0x000000000B2EA08A

0000000000000000:   10002600 03000000 63636363 63202020 †..&.....ccccc    
0000000000000010:   20202020 20202020 20202020 20202020 †                 
0000000000000020:   20202020 20200300 00†††††††††††††††††      ...        
*/

--插入有默认值列
ALTER TABLE altertc ADD col2 char(20)  DEFAULT(0)
INSERT INTO altertc(col)
SELECT REPLICATE('c',5)
/*
Slot 2, Offset 0x8a, Length 41, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 41

Memory Dump @0x000000000F26C08A

0000000000000000:   10002600 03000000 63636363 63202020 †..&.....ccccc    
0000000000000010:   20203020 20202020 20202020 20202020 †  0              
0000000000000020:   20202020 20200300 00†††††††††††††††††      ...     
*/

/*
从测试来看：新增加的列并不会改变原记录的存储大小，只会影响新增加的列，其实这也很好理解，记录在介质的物理存储，
是反映当前记录在写入时的实际数据大小，而结构的变更只会影响后续的操作。

常见场景：新增列或给某列指定一个默认值。还需要手动去更新下以前的记录。

*/


--------------------------------------------------------------------------------------
--删除列
SELECT * FROM altertc

ALTER TABLE altertc DROP COLUMN col
/*
Slot 2, Offset 0x8a, Length 41, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 41

Memory Dump @0x000000000EAFA08A

0000000000000000:   10002600 03000000 63636363 63202020 †..&.....ccccc    
0000000000000010:   2020e186 00000000 c0f4a386 00000000 †  .............. 
0000000000000020:   e0e5e186 00000300 04†††††††††††††††††.........        

*/

/*
当我们把列删除后再去查看数据页，数据还是存在的，这和磁盘的工作原理是吻合的，对磁盘的数据删除，采用的是复盖删
除的方式，只对删除数据作删除标志，写数据时会复盖已删除的扇区，好吧，我只知道文件分配表会标识磁盘的可用扇区，
sqlServer就不知道它是怎么标记的。

*/

--------------------------------------------------------------------------------------
--修改列
ALTER TABLE altertc ALTER COLUMN col CHAR(200)

DBCC IND(test,altertc,-1)
DBCC TRACEON(3604)
DBCC PAGE(test,1,1014,1)
/*

Slot 1, Offset 0x167, Length 221, DumpStyle BYTE

Record Type = PRIMARY_RECORD         Record Attributes =  NULL_BITMAP     Record Size = 221

Memory Dump @0x000000000F26C167

0000000000000000:   1000da00 02000000 62626262 62202020 †........bbbbb    
0000000000000010:   20206262 62626220 20202020 20202020 †  bbbbb          
0000000000000020:   20202020 20202020 20202020 20202020 †                 
0000000000000030:   20202020 20202020 20202020 20202020 †                 
0000000000000040:   20202020 20202020 20202020 20202020 †                 
0000000000000050:   20202020 20202020 20202020 20202020 †                 
0000000000000060:   20202020 20202020 20202020 20202020 †                 
0000000000000070:   20202020 20202020 20202020 20202020 †                 
0000000000000080:   20202020 20202020 20202020 20202020 †                 
0000000000000090:   20202020 20202020 20202020 20202020 †                 
00000000000000A0:   20202020 20202020 20202020 20202020 †                 
00000000000000B0:   20202020 20202020 20202020 20202020 †                 
00000000000000C0:   20202020 20202020 20202020 20202020 †                 
00000000000000D0:   20202020 20202020 20200300 00††††††††          ...    

*/

SELECT 
    cast(object_name(P.OBJECT_ID) as varchar(10)) as obj_name,
    cast(c.name as varchar(10)) as name ,
    max_inrow_length,
    IPC.system_type_id,IPC.max_length,
    CAST(leaf_offset AS BINARY(2)) AS leaf_offset
FROM SYS.SYSTEM_INTERNALS_PARTITION_COLUMNS IPC
INNER JOIN SYS.PARTITIONS P ON IPC.PARTITION_ID = P.PARTITION_ID
INNER JOIN SYS.COLUMNS C ON C.COLUMN_ID = PARTITION_COLUMN_ID AND C.OBJECT_ID = P.OBJECT_ID
WHERE P.OBJECT_ID = OBJECT_ID('altertc')

/*
从测试来看，原类型长度改变后，当原存储区不能放下新类型数据时，SQLServer做了这样一个动作：重新给该列分配一
个新的存储地址，并把原来的数据移到新存储区，从下面的查询可以看到:col列的存储偏移量指向了0x0012，数据行的
总量是累加了。

常见场景：给一个大数据量表更新字段类型长度，让升级脚本无响应。
*/

/*从上面的测试可以看出表结构的更改是造成碎片的主要原因之一，因为它影响的是整个表的记录存储，可见，在系统设
计之初，为什么要强调表设计的合理性，不合理的表结构设计带来的频繁修改，只会让数据库变得越来越大，越来越慢。


测试告一小段，还有好几种情况可以测试，比如改成其它类型，改小类型，修改删除后新增记录的存储等，慢慢玩。
*/

