

--����ĵȴ�״̬


--Ŀ�꣺�鿴SqlServer���е�����״̬�͵ȴ�����Դ

/*
sys.dm_exec_requests :�����й���sqlserver��ִ�е�ÿ���������Ϣ��������ǰ�ĵȴ�״̬

sys.dm_exec_sessions : ����sqlserver��ÿ�����������֤�ĻỰ���᷵����Ӧ��һ��

sys.dm_exec_connections : ������sqlserverʵ�������������йص���Ϣ��ÿ�����ӵ���ϸ��Ϣ��
*/

SELECT 
s.session_id
,s.status
,s.login_time
,s.host_name
,s.program_name
,s.host_process_id
,s.client_version
,s.client_interface_name
,s.login_name
,s.last_request_start_time
,s.last_request_end_time
,c.connect_time
,c.net_transport
,c.net_packet_size
,c.client_net_address
,r.request_id
,r.start_time
,r.status
,r.command
,r.database_id
,r.user_id
,r.blocking_session_id
,r.wait_type
,r.wait_time
,r.last_wait_type
,r.wait_resource
,r.open_resultset_count
,r.transaction_id
,r.percent_complete
,r.cpu_time
,r.reads
,r.writes
,r.granted_query_memory
 FROM sys.dm_exec_requests r
RIGHT JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
RIGHT JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
WHERE s.is_user_process=1

/*
�ڴ滺����е�ҳ���д���ƣ�
��sqlserver������ҳ��������ļ�������ڴ�ʱ��ΪΪ��ֹ�����û����ڴ����ͬһ������ҳ����з��ʣ�sqlserver
�����ڴ������ҳ���ϼ�һ��������letch��������������Ҫ��ȡ�������ڴ����ҳ��ʱ��������һ�������latch.��
lockһ����latchҲ���������������

�����ĵȴ�����
 PageIOLatch :˵��sqlserverһ�����ڵȴ�ĳ��i/o��������ɣ��������һ��sqlserver����������һ��ĵȴ���˵��
 ���̵��ٶȲ�������sqlserver����Ҫ�����Ѿ���Ϊ��һ��sqlserver��һ��ƿ����
 
 PageIOLatch_SH : �����������û�����Ҫȥ����һ������ҳ�棬��ͬʱsqlserverȴҪ�����ҳ��Ӵ��̶����ڴ棬������
 ҳ�����û������п��ܷ��ʵ��ģ���ô��������ڴ治����û���ܹ�������ҳ��ʼ�ջ������ڴ�����ԣ�������������
 ��ѹ��������sqlserver���˺ܶ��ȡҳ��Ĺ������������˴��̶���ƿ��������Ĵ���ƿ���������ڴ�ƿ���ĸ���Ʒ��
 
 PageIOLatch_EX : �����������û�������ҳ�������޸ģ�sqlServerҪ����̻�д��ʱ�򣬻�����ζ�Ŵ��̵�д���ٶȸ����ϡ�
 
 PageLatch_x : �ڸ߲��������У���ͬһ��������¼ʱ�������Latch
 �������һ�������н��ۼ�����������Ҫ����identity���ֶ��ϣ��������������ݾͻᰴ�չ�����ʽ����ͬһʱ��Ĳ����
 �л����ɢ�ڲ�ͬ��ҳ���ϡ�
 
 2�����ʵ����һ��Ҫ�� identity���ֶ��Ͻ��ۼ������������������ĳ���������ڱ���Ͻ�����ʿ����������һ������
 �����ɸ�����������ʹ�õý��������ݵ�ҳ����Ŀ���ӡ�
 
 Runnable ������
�������У�����û�������У�������sqlserver�����·ǳ���æ��Ҳ��Ӧ�þ�������runnable��������running ״̬������
����Ӧ�úܶ�
ԭ��
1,sqlServer cpuʹ�����Ѿ��ӽ�100%,�����û���㹻��cpu��Դ��ʱ�����û��Ĳ�������
2��sqlServerCPUʹ���ʲ����ܸߣ�С��50%,����������ܸ���Դ���������йأ���2008�汾�Ժ�õ������

 TempDb�ϵ�PageLatch
�洢������tempdb�Ľ�ɾ��SGAM,PFS��GAMҳ��Ҳ�����޸ģ���Ҳ���latch,��Щlatch��ĳЩ�����Ҳ�п��ܳ�Ϊϵͳƿ����

�������
1��sqlServerʹ�ü���cpu�����У���Ϊtempdb�������������ļ�
2)��Щ�ļ��Ĵ�С����һ����
3��Ҫ�ϸ��ֹtempdb���ݿռ��þ������������ļ��Զ���������Ϊ�Զ�����ֻ����������һ���ļ������ֻ��һ���ļ��п���
�ռ䣬���е�����ͻᶼ������· ���������ϣ������ֱ��ƿ���ˡ�
*/