

--范式

/*
范式设计之前，在顶层对象和业务逻辑上先满足一些要求:
1)一个表，作为一个对象，它或者是一个对象实体，或者是业务流程中一个环节，但它必须是独立的，无岐议的。
2）所有行必须是唯一，而且必须有一个主键。

对于关系型数据库，范式设计的目的在于更好的体现对象之间的关系模型，当你发现对象之间的边界在模糊，那么你很可能
已经进入了反范式设计中。

第一范式：原子性>>要求表中的每一列具有不可再拆分性，描述信息明确。
比如
a)家庭电话和手机放在同一个字段里：列名'电话'：可以放手机号也可以放家庭电话号，两个都有就放两个。
b)家庭地址：广东省广州市作为一个字段放在一个列中。
c)权限描述中的，用一个字段存放用户具有的所有权限，1，2，3，4
d)订单中同一用户的购买多个产品，放在一个产品列中，产品1;产品2;产品3

对于这样的反模式设计的危害，我有另一篇文章具体讲述，在这里，只讲如果规范1范式。

对于这种原子性不明的列，有两种优化方式：拆分到列和拆分到行。
比如，电话，系统中已明确不会出现第三种情况（如办公室电话），那么可以考虑折分到列，有两个字段单独描述手机和家庭电话。
对于权限和购买产品列表，这种可能随着业务的进展，系统的使用，会经常出现多或少的情况，可以拆分到行，每一行描述一个实体。

通常在拆分到行的过程中，需要考虑两点：主键和序号
当数据被拆分到多行时，原来的主键有可能会出现重复，这时候，我们需要重新选择能作为主键的列或组合。
一般建议增加序号列和原主键列作为新的主键。

---------------
第二范式：减少重复数据出现>>在列维度上对重复数据进行整合
比如，经过原子性拆分后，同一笔记录列上出现多个重复信息。

把相同的重复出现的列，提取出来，形成单独的主表。主，明细表根据主键关联。


---------------------
第三范式：任何列不能依赖于非键列，不可以有派生的数据>>对列维度上的列依赖整合
比如，货号，货号名称，货品类别，同属依赖于货号
职员，电话，家庭电话，手机，同属于一个职员

把同依赖于一个对象的列提取出来，生成一个独立的对象表。主外键关联。


反范式：
按范式设计是一种标准，但并不是唯一标准，设计模型必须根据业务需求和业务处理来灵活调整。

有时候，反范式设计，牺牲了空间，但保证了数据的实时性和查询性能的提高
比如单据，当单据生效后，就要保留生效那一刻数据的实时性，不对因为修改基础档或参数而改变了单据的信息和状态。

金额 可以通过数量和单价生成，根据范式，金额应该就属于反范式，但冗余的金额字段却可以大大减少查询过程中的计算时间，加快查询性能。



*/