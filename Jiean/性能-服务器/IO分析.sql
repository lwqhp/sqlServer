

--SqlServer I/O

/*
sqlServer��Ӳ�̽����ĳ���----------------------------
1,�����ڴ���û�л�������ݣ���һ�η���ʱ��Ҫ���������ڵ�ҳ��������ļ��ж�ȡ���ڴ���

2�����κ�insert update delete �ύ֮ǰ��sqlserver��Ҫ��֤��־��¼�ܹ�д�뵽��־�ļ��

3����sqlserver��checkpoint��ʱ����Ҫ���ڴ滺�������侭�������޸ĵ�����ҳ��ͬ����Ӳ���е������ļ���

4,��sqlserver������buffer pool�ռ䲻��ʱ���ᴥ��lazy writer���������ڴ����һЩ�ܾ�û��ʹ�ù�������ҳ���ִ��
�ƻ���ա������Щҳ���Ϸ������޸Ļ�δ�ɼ���checkpointд��Ӳ�̣�lazy writer�������д�ء�

5��һЩ����Ĳ���������dbcc checkdb,reindex,update statistics ���ݿⱸ�ݵȣ�������Ƚϴ��Ӳ�̶�д��

��IO��Ӱ���һЩsqlserver����----------------------------
1��Sqlserver ��recovery interval(sp_configure) ����sqlserver�೤ʱ�����һ��checkpoint .

2,������־�ļ����Զ��������Զ�������

3�������ļ���ҳ����Ƭ����

4������ϵ������ṹ

5������ѹ��

6�������ļ�����־�ļ�����ͬһ�������

7��һ�������ļ����Ƿ��ж���ļ������ҷ��ڲ�ͬ����������ϡ�

�Ӽ������۲�sqlServer io����----------------------------

Buffer Manager :�ܹ���ӳ��buffer pool �йص�i/o����

1��page reads/sec page writes/sec:��ӳsqlserverÿ���Ӷ�д�˶���ҳ�档

2��lazy writes/sec :��ӳlazywriteΪ�����buffer pool ÿ�����˶���ҳ��д�붯����

3��checkpoint writes/sec:ÿ���Ӵ�buffer pool��д�뵽�����ϵ�dirty page��Ŀ��

4��readahead pages/sec : ÿ����sqlserver����Ԥ����Ŀ

access methods : ����sqlserver���ָ��Ĺ���Ҳ�����i/o----------------------------

1,freespace scan/sec :�ڶѽṹ�����ܹ�ʹ�õĿռ䣬�������������ܸߣ�˵��sqlserver�ڶѵĹ����ϻ����˺ܶ���Դ��
Ӧ�ÿ��ǶཨһЩ�ۼ�������

2��page splits/sec : ��������������붯��ʱ��һЩҳ��ᱻ������Ϊ��ά�������ϵ�˳��sqlserver��Ҫ��һҳ������
ҳ��������ͽ�page split,������ֵ�Ƚϸߣ������־�������ȷ��������Ӱ��Ļ������Կ��Ƕ����ؽ�������

3��page allocations/sec : ��sqlserver��Ҫ������������������ʱ��������¶����ҳ��������

4��workfiles/sec : ��sqlserverΪ�����ĳЩ���������ڴ��н���һ��hash�ṹʱ�ü������ͼ�һ�����ĳЩhash�ṹ�Ƚ��Ӵ�
sqlserver���ܻὫһ��������д��Ӳ�������ͨ�����ֵ���˽����ݿ�������ǲ������Ż��ı�Ҫ��

5��worktables/sec : ÿ�봴���Ĺ������������繤��������ڴ洢��ѯ���ѻ�(query spool),lob������xml��������������α����ʱ�����

6��Full scans/sec : ÿ��sqlserver����ȫ��ɨ����Ŀ��

7��index searches /sec : ÿ����������Ĵ�����Ҳ���������������ָ�����Ŀ��

databases ��һЩ����־д���й�ϵ�ļ�����----------------------------

1��log flushes/sec : sqlsererÿ����������ݿ���������־д�Ĵ�����

2��log Bytes Flushed/sec : sqlserverÿ����������ݿ���������־д����

3,log Flush wait time : д����־�Ķ���������Ϊ������������Ӧ�������ĵȴ�ʱ�䡣���ֵȴ��ᵼ��ǰ�˵��������ύ��
���Ի�����Ӱ��sqlserver�����ܣ�������sqlserver���ֵӦ���ھ������ʱ���ﶼ��0��

4,log flush waits/sec : ��ÿ���ύ��������ж��ٸ����������ȴ�����־д����ɡ�


*/

---����ͼ�۲�sqlserver io
SELECT 
wait_type,
waiting_tasks_count,
wait_time_ms
FROM sys.dm_os_wait_stats
/*
������������Ӵ��ڵȴ�����io��һ����������������io���ǱȽ�æ�ģ������ַ�æ�Ѿ�Ӱ�쵽��������Ӧ�ٶȡ�
��sqlserverҪȥ��дһ��ҳ���ʱ�������Ȼ���buffer pool��Ѱ�ң������buffer pool���ҵ��ˣ���ô����д������
�������У�û���κεȴ������û���ҵ�����ôsqlserver�ͻ��������ӵĵȴ�״̬Ϊ
Pageiolatch_ex��д����PageIolatch_sh(��)��Ȼ����һ���첽io��������ҳ�����buffer pool�У���ioû����֮ǰ����
�Ӷ��ᱣ�����״̬��io���ĵ�ʱ��Խ�����ȴ���ʱ��Ҳ��Խ����

Writelog ��־�ļ��ĵȴ�״̬����sqlserverҪд��־�ļ����������������ʱ��sqlserver�᲻�ò�����ȴ�״̬��ֱ����־
��¼��д�룬�Ż��ύ��ǰ���������sqlserver����Ҫ��writelog,ͨ��˵�������ϵ�ƿ�����ǱȽ����صġ�
*/

--�˽����Ǹ����ݿ⣬�Ǹ��ļ�����io
SELECT 
db.name AS database_name,f.fileid AS FILE_ID,
f.filename AS FILE_NAME,
i.num_of_reads,i.num_of_bytes_read,i.io_stall_read_ms,
i.num_of_writes,i.num_of_bytes_written,i.io_stall_write_ms,
i.io_stall,i.size_on_disk_bytes
 FROM sys.databases db 
INNER JOIN sys.sysaltfiles f ON db.database_id = f.dbid
INNER JOIN sys.dm_io_virtual_file_stats(NULL,null) i ON i.database_id = f.dbid AND i.file_id = f.fileid

--��鵱ǰsqlserver��ÿ���������״̬��io����
SELECT 
database_id,file_id,io_stall,io_pending_ms_ticks,scheduler_address
FROM sys.dm_io_virtual_file_stats(NULL,NULL) t1, sys.dm_io_pending_io_requests AS t2
WHERE t1.file_handle = t2.io_handle