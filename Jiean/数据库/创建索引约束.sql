

--����Լ��
/*
create table tb (ID int ,[name ]varchar(10) unique)
--or
alter table tb
add constraint qu unique([name])

ALTER TABLE ����
  ADD CONSTRAINT Լ���� --����������Ϸ���ʾ��
    UNIQUE (�ֶ��б�) -- �ֶ��б����ʹ����ֶΣ���','�ֿ��� 
    
    */
    
 SELECT * FROM m_bas_subType  
 SELECT * FROM dbo.m_bas_subDes
 ALTER TABLE  m_bas_subType ADD CONSTRAINT m_subTypeID UNIQUE(m_subTypeID)
 
 ALTER TABLE m_bas_subDes ADD CONSTRAINT PK_subDesID UNIQUE(m_subDesID)
 
 ALTER TABLE m_bas_subdes ADD CONSTRAINT m_subtypeid DEFAULT(0) FOR(m_subTypeID)

--��������
/*
CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] 
    INDEX   index_name
     ON table_name (column_name��)
      [WITH FILLFACTOR=x]
q       UNIQUE��ʾΨһ��������ѡ
q       CLUSTERED��NONCLUSTERED��ʾ�ۼ��������ǷǾۼ���������ѡ
q       FILLFACTOR��ʾ������ӣ�ָ��һ��0��100֮���ֵ����ֵָʾ����ҳ�����Ŀռ���ռ�İٷֱ�
*/