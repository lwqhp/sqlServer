
ANSI_PADDING
--���ݿⳣ��һЩ����


/*
SET QUOTED_IDENTIFIER ON ����ʹ�ùؼ��֣�"select" "update" �ȣ���Ϊ������(����)
��SET QUOTED_IDENTIFIER OFF ��������ôʹ�ã���Ϊϵͳ�����"select"��"update"��Ϊ�ؼ���
*/
SET QUOTED_IDENTIFIER ON  
GO 
SET QUOTED_IDENTIFIER OFF  
GO 

/*
ָ���ڶԿ�ֵʹ�õ��� (=) �Ͳ����� (<>) �Ƚ������ʱ���Ƿ���� SQL-92 ��׼��ON ��ӣ�OFF �����

SQL-92 ��׼:�Կ�ֵ�ĵ��� (=) �򲻵��� (<>) �Ƚ�ȡֵΪ FALSE��
Column_name = null��Column_name <> null ��Ч����ȷӦ���� column_name is null ,column_name is not null
*/
SET ANSI_NULLS ON
GO
SET ANSI_NULLS OFF
go 

/*
�Ƿ񷵻���Ӱ�������
*/
SET NOCOUNT ON
GO
SET NOCOUNT OFF
GO 


/*
�� SET XACT_ABORT Ϊ ON ʱ�����ִ�� Transact-SQL ����������ʱ����������������ֹ���ع���
�� SET XACT_ABORT Ϊ OFF ʱ����ʱֻ�ع���������� Transact-SQL ��䣬�����񽫼������д��������������أ���ô��ʹ SET XACT_ABORT Ϊ OFF��Ҳ���ܻع���������
����������﷨���󣩲��� SET XACT_ABORT ��Ӱ�졣
*/
SET XACT_ABORT ON 
GO
SET XACT_ABORT OFF
GO

/*
�Կո��Ӱ�죬ONʱ����sql ��׼�������ո�OFFʱ��ȥ��ǰ��ո񣬲���������char,varchar,binary
*/

SET ANSI_PADDING ON
GO
SET ANSI_PADDING OFF
GO