set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER    PROCEDURE [dbo].[BackupDB_CreateDB]
@dbfolder varchar(200),
@dbfile varchar(200)
 AS
SET QUOTED_IDENTIFIER OFF 
 
exec('
CREATE DATABASE '+@dbfile+'
ON 
( NAME = '+@dbfile+'_data,
   FILENAME ='''+ @dbfolder+@dbfile+'_data.mdf'',
   SIZE = 50MB,
  FILEGROWTH = 15% )
LOG ON
( NAME = '+@dbfile+'_log,
 FILENAME ='''+ @dbfolder+@dbfile+'_log.ldf'',
  SIZE = 5MB,
  FILEGROWTH = 5MB )')

exec ('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_search] (
	[office_missive_search_id] [int] IDENTITY (1, 1)  NOT NULL ,
	[office_missive_id] [int] NULL ,
	[office_missive_template_id] [int] NULL ,
	[m_title] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_html] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[m_content] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[m_formula] [varchar] (8000) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_stat_field] [varchar] (8000) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_status] [tinyint] NULL ,
	[m_isback] [tinyint] NULL ,
	[m_istell] [tinyint] NULL ,
	[m_ispause] [tinyint] NULL ,
	[m_issign] [tinyint] NULL ,
	[file_user_id] [int] NULL ,
	[file_user_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_date] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[create_user_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[create_user_id] [int] NULL ,
	[create_date] [datetime] NULL ,
	[is_deleted] [bit] NULL ,
	[m_text] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[m_flag] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_approve_value] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_approve_text] [nvarchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[end_date] [datetime] NULL ,
	[ender_id] [int] NULL ,
	[ender_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_page] [tinyint] NULL ,
	[m_js] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[m_css] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[erp_sql_conn] [varchar] (150) COLLATE Chinese_PRC_CI_AS NULL ,
	[erp_sql_sta] [varchar] (500) COLLATE Chinese_PRC_CI_AS NULL ,
	[erp_sql_url] [varchar] (500) COLLATE Chinese_PRC_CI_AS NULL ,
	[m_isbulletin] [tinyint] NULL ,
	[m_attached] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]')


exec('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_search_flow] (
	[office_missive_search_flow_id] [int] IDENTITY (1, 1)  NOT NULL ,
	[office_missive_flow_id] [int] NOT NULL ,
	[mf_user_id] [int] NULL ,
	[mf_template_id] [int] NULL ,
	[mf_missive_id] [int] NULL ,
	[mf_flow_title] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[mf_flow_order] [int] NULL ,
	[mf_flow_property] [tinyint] NULL ,
	[mf_pass_count] [int] NULL ,
	[mf_pixel_left] [int] NULL ,
	[mf_pixel_top] [int] NULL ,
	[mf_field_edit] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[mf_valid_day] [int] NULL ,
	[mf_valid_hour] [int] NULL ,
	[mf_pv_flow] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mf_approve_value] [nvarchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mf_approve_text] [nvarchar] (4000) COLLATE Chinese_PRC_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]')



exec('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_search_flow_go] (
	[office_missive_search_flow_go_id] [int] IDENTITY (1, 1)  NOT NULL ,
	[office_missive_flow_go_id] [int] NOT NULL ,
	[mfg_template_id] [int] NULL ,
	[mfg_missive_id] [int] NULL ,
	[office_missive_flow_id] [int] NULL ,
	[mfg_property] [tinyint] NULL ,
	[mfg_status] [tinyint] NULL ,
	[receiver_id] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[receiver_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[receiver_script] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[receive_time] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[dealman_id] [int] NULL ,
	[dealman_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[deal_time] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[sender_id] [int] NULL ,
	[sender_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[send_time] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[tell_user_id] [int] NULL ,
	[tell_user_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[tell_content] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[tell_time] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfg_valid_date] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL 
) ON [PRIMARY]')

exec('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_search_flow_record] (
	[office_missive_search_flow_record_id] [int] IDENTITY (1, 1)  NOT NULL ,
	[office_missive_flow_record_id] [int] NULL ,
	[mfr_missive_id] [int] NULL ,
	[mfr_operator_department_id] [int] NULL ,
	[mfr_operator_department_name] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_operator_position_id] [int] NULL ,
	[mfr_operator_position_name] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_operator_id] [int] NULL ,
	[mfr_operator_name] [nvarchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_operate_flow] [int] NULL ,
	[mfr_operate_flow_flag] [int] NULL ,
	[mfr_operate] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_operate_code] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_operate_time] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL 
) ON [PRIMARY]')


exec('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_search_flow_run] (
	[office_missive_search_flow_run_id] [int] IDENTITY (1, 1)  NOT NULL ,
	[office_missive_flow_run_id] [int] NOT NULL ,
	[mfr_template_id] [int] NULL ,
	[mfr_missive_id] [int] NULL ,
	[office_missive_flow_id] [int] NULL ,
	[mfr_if] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_if_caption] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mfr_next] [int] NULL ,
	[mfr_flag] [int] NULL 
) ON [PRIMARY]')


exec('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_search_relation] (	
	[search_relation_id] [int] IDENTITY (1, 1) NOT NULL ,
	[relation_id] [int] NOT NULL ,
	[r_missive_id] [int] NULL ,
	[r_relation_id] [int] NULL ,
	[r_title] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[r_mt_title] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[r_creator_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[r_creator_id] [int] NULL ,
	[r_create_date] [datetime] NULL ,
	[creator_id] [int] NULL ,
	[creator_name] [nvarchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[create_date] [datetime] NULL 
) ON [PRIMARY]')

exec('CREATE TABLE '+@dbfile+'.[dbo].[sys_file_storage] (
	[sys_file_storage_id] [int]  NOT NULL ,
	[baseInfo_id] [int] NULL ,
	[upload_type] [int] NULL ,
	[database_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[table_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[table_id] [bigint] NULL ,
	[file_path] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_type] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_ext] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_size] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_last_modify] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[file_bin_data] [image] NULL ,
	[file_txt_data] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[create_date] [datetime] NULL ,
	[user_id] [bigint] NULL ,
	[user_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[is_deleted] [bit] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]')


exec('CREATE TABLE '+@dbfile+'.[dbo].[wf_office_file] (
	[word_file_id] [int]  NOT NULL ,
	[wordfile] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[title] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[wordid] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[filetype] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[filedata] [image] NULL ,
	[dirFile] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[wf_file_id] [int] NULL ,
	[create_user_id] [int] NULL ,
	[create_user_name] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[create_date] [datetime] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]')

exec('CREATE TABLE '+@dbfile+'.[dbo].[office_missive_template] (
	[office_missive_template_id] [int]  NOT NULL ,
	[mt_class] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_purview_value] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_purview_text] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_title] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_version] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_html] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_edit_user_id] [int] NULL ,
	[mt_edit_user_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_edit_date] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[create_user_id] [int] NULL ,
	[create_user_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[create_date] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[is_deleted] [bit] NULL ,
	[mt_approve_value] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_approve_text] [nvarchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_page] [tinyint] NULL ,
	[mt_js] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_css] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[serial_regulation] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_no] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_read_value] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL ,
	[mt_read_text] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]')

exec('CREATE TABLE '+@dbfile+'.[dbo].[sys_usersinfo] (
	[sys_userinfo_id] [int]  NOT NULL ,
	[u_no] [int] NULL ,
	[u_name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_blood] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_city] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_province] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_department_id] [int] NULL ,
	[u_position_id] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_tech_title] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_office_rank] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_tel] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_btel] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_mobile] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_fax] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_email] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_url] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_icq] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_address] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_postcode] [char] (10) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_sex] [varchar] (5) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_identify] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_religion] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_id_no] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_birthday] [datetime] NULL ,
	[u_married] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_register] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_nation] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_polity] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_signurl] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_frn_language] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_frn_language_level] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_insurance_no] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_education] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_college] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_speciality] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_income] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_computer_level] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_work_age] [int] NOT NULL ,
	[u_enter_time] [datetime] NULL ,
	[u_bank_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_bank_no] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_memo] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[u_sign] [varchar] (500) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_filepath] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_msn] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_character] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_interest] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_homeland] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[edit_date] [datetime] NULL ,
	[u_underling] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_group] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_gender] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_honor] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_head] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_headw] [nvarchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_headh] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_class] [tinyint] NULL ,
	[u_post] [int] NULL ,
	[u_weh] [int] NULL ,
	[u_exp] [int] NULL ,
	[u_lns] [int] NULL ,
	[u_lastlogin] [datetime] NULL ,
	[u_mark] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[u_bz] [varchar] (500) COLLATE Chinese_PRC_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]')

exec(' CREATE TABLE '+@dbfile+'.[dbo].[sys_baseinfo] (
	[sys_baseinfo_id] [int]  NOT NULL ,
	[sys_basetype_id] [int] NULL ,
	[bi_parentid] [int] NULL ,
	[bi_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL ,
	[bi_value] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[bi_order] [int] NULL ,
	[bi_default] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL ,
	[IsDeleted] [bit] NULL 
) ON [PRIMARY]')


