


���ݿ����

--����
select * from sys.databases

/*���ݿⱸ����ض���*/
--ÿ�������ݿ�������ʱ��sqlserver��msdb.dbo.backupset���в���һ�м�¼
select * from msdb.dbo.backupset

--���ݿⱸ���ļ���Ϣ
select * from  msdb.dbo.backupfile

--ý�弯
select * from  msdb.dbo.backupmediaset

--����ļ�¼����ĳ��ý�弯��Ű������ٸ������ļ���ÿһ���ֳ�Ϊý���
select * from  msdb.dbo.backupmediafamily
/*
backup_set_id�������ݿ��ÿ�α��ݶ���Ψһ��һ����ţ���Ϊ���ݼ����

media_set_id��Ϊ����ý�弯��ţ���Ϊһ���߼����ƣ������������ļ��ĳ���ĳ�ν������ǰѶ�εı���ͬʱ����һ�������ļ��У��Ǳ���ý�弯����ǲ����

last_family_number�����ݷ�����ٸ������ļ��е�
*/

select * from msdb..backupset

select * from msdb..backupfile