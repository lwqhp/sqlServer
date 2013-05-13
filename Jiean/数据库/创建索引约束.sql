

--创建约束
/*
create table tb (ID int ,[name ]varchar(10) unique)
--or
alter table tb
add constraint qu unique([name])

ALTER TABLE 表名
  ADD CONSTRAINT 约束名 --可以是任意合法标示符
    UNIQUE (字段列表) -- 字段列表可以使多个字段，用','分开。 
    
    */
    
 SELECT * FROM m_bas_subType  
 SELECT * FROM dbo.m_bas_subDes
 ALTER TABLE  m_bas_subType ADD CONSTRAINT m_subTypeID UNIQUE(m_subTypeID)
 
 ALTER TABLE m_bas_subDes ADD CONSTRAINT PK_subDesID UNIQUE(m_subDesID)

--创建索引
/*
CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] 
    INDEX   index_name
     ON table_name (column_name…)
      [WITH FILLFACTOR=x]
q       UNIQUE表示唯一索引，可选
q       CLUSTERED、NONCLUSTERED表示聚集索引还是非聚集索引，可选
q       FILLFACTOR表示填充因子，指定一个0到100之间的值，该值指示索引页填满的空间所占的百分比
*/