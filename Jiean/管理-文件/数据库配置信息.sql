

--�鿴���ݿ�������Ϣ
SELECT * FROM sys.configurations

--���ݿ����ô洢����
EXEC sys.sp_configure
	@configname = '', -- varchar(35)
    @configvalue = 0 -- int
RECONFIGURE --ǿ�Ƹ��µ�ǰ������ֵ
WITH oerrie --���ڲ��Ϸ���ֵ������ʾ���棬�����ܾ����£��˲�����ǿ���޸����ѡ��ֵ


--�鿴���ݿ�ѡ��
SELECT name,is_read_only,is_auto_close_on,is_auto_shrink_on,* FROM sys.databases
WHERE name='test'

--����ANSI SQLѡ��
/*
ansi����������һ�����ұ�׼ѧ�ᶨ�Ƶ�sql������Ĭ��ֵ
*/

--���ݿ��״̬
/*
online ���������ݿ��Ǵ򿪵Ĳ����ǿ��õ�
offline ���ߣ����ݿ��ǹرյģ����Ҳ������޸Ļ��κ��û���ѯ
emergency �����������������ɫsysadmin��½�����ݿ��ֻ�����ʣ������ѯ�����Կ��Է��ʵ����ݿ����
*/

ALTER DATABASE Test
SET ONLINE | OFFLINE | EMERGENCY


--�޸����ݿ�ӵ����

EXEC sp_changedbowner 'lwqhp'