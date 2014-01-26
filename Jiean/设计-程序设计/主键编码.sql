

--主键编码
/*
主键通常分自然主键和伪主键，几个字段组合称为组合主键。

自然主键 是指实际数据中存在唯一标识的字段，而使用来作为表格主键。
伪主键 是指额外增加的和数据语义没有关联的，仅用来标识数据唯一性的数字序列。

这里主要重点讲下伪主键 的设计方法和优缺点

主键的设计有两种，系统自带的自增类型和全局唯一id函数，另一种是自定义流水号主键。

1）identity类型主键
这是一种自增长类型字段，在插入记录的时候，自动生成一个隐含记数器+1的值作为新记录的ID，
为什么说是隐含呢，因为这是一个系统级的记数器，你不能随意的改变他的记数方式,标识列的修改需要通过其它一些方法来实现。

*/
CREATE TABLE test20131110(
	id INT IDENTITY(1,1) ,
	val VARCHAR(20)
)

--重新指定当前计数器的值
DBCC CHECKIDENT('test20131110',RESEED,6)

--在标识列插入序号
SET IDENTITY_INSERT test20131110 ON 
INSERT INTO test20131110(id,val)
SELECT 4,'3'
SET IDENTITY_INSERT test20131110 OFF  

--重置标识列
TRUNCATE TABLE test20131110

--更新标识列的值
--需要在表设计里，先把identity属性去掉，更新完后，再设回来

/*
identity只是自增标识列，默认是不会重复的，但经过上面步骤的操作后，可能会出现重复id值，这点标识列是不会作判断的
*/

--最标识列最大值
SELECT @@identity --这是全局操作identity列的最大值，比如A表的操作触发了B表的更新，那么@@identity取的就是B表的最大值

SELECT SCOPE_IDENTITY() --这是当前操作或当前会话的标识列的最大值。

SELECT IDENT_CURRENT('TABLEName') --获取跨任何会话或作用域的某个表的最新identity值

/*--------------
2)GUID 全局唯一标识符：它是由网卡上的标识数字(每个网卡都有唯一的标识号)以及 CPU 时钟的唯一数字生成的的一个 16 字节的二进制值。

格式为“xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx”，其中每个 x 是 0-9 或 a-f 范围内的一个十六进制的数字。例如：6F9619FF-8B86-D011-B42D-00C04FC964FF 即为有效的 GUID 值.

这是全世界唯一的序列值，使用它来作为主键，会省去你很多烦恼，

a,不用再操心怎么去生成一个唯一的序号，因为他生来就是唯一的。
b,不用再担心他的序号是否连续，因为他天生就是无序的。
c,不用再困惑怎么取最大值，因为他本身就没有最大值一说。

但快乐往往与烦恼相随
a,16字节的GUID值，占用你更多的硬盘空间，让你的索引维护成本更高，性能却更低。
b,36位长的字符串，需要你有更好的眼力，才能区分他们的差别，如果你还想知道他们的先后顺序，那只能借助另一个时间戳字段来识别了。

总结：GUID主键更适合用在无序列要求，唯一标识数据实体的表中，比如 设备表，唯一标识设备的描述。不适合用于标识单据这种具有很明显
流水性特征的数据。
*/

--定义GUID主键
--在 SQL Server 的表定义中将列类型指定为 uniqueidentifier

--自动生成GUID值
--将 uniqueidentifier 的列的默认值设为 NewID()，这样当新行插入表中时，会自动生成此列 GUID 值

--提前获取 GUID 值
SELECT NEWID() --其全局唯一性，可以预先取得GUID,完成业务逻辑后再插入到数据库，也不会出现重复键。


--自定义流水号主键
/*
自由构建主键规则，可以作为单据的流水号应用，不再是单一的为标识而建的伪主键，根据不同的业务，不同的模块，可以
自义易与区分的主键格式，比如公司代码+流水号，流水号可以是日期+流水号，也可以是特定编码+流水号。

灵活的编码要作为主键，高并发下的约束就显得非常的重要，需要付出更多的操作，但这些操作的付出还是值得，体现在主键的
语义更清淅，索引维护成本性价比更高，代码更规范，结构更简结。

因为自定义主键的编码的多样性，所以关于流水号主键的设计单独分出来讲解。
*/


--定义一个RowGuidCol属性列

CREATE TABLE t2 (buildingEntryExitID UNIQUEIDENTIFIER ROWGUIDCOL DEFAULT NEWID())

--查询，使用通用标识符
SELECT ROWGUIDCOL FROM t2