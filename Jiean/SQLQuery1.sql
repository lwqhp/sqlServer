

SELECT db_name() AS TABLE_CATALOG, user_name(obj.uid) AS TABLE_SCHEMA, 
      obj.name AS TABLE_NAME, CASE WHEN EXISTS
          (SELECT *
         FROM syscomments com3
         WHERE com3.id = obj.id AND com3.colid > 1) THEN NULL 
      ELSE com.text END AS VIEW_DEFINITION, CASE WHEN EXISTS
          (SELECT *
         FROM syscomments com2
         WHERE com2.id = obj.id AND CHARINDEX('WITH CHECK OPTION', 
               upper(com2.text)) > 0) 
      THEN 'CASCADE' ELSE 'NONE' END AS CHECK_OPTION, 
      'NO' AS IS_UPDATABLE
FROM sysobjects obj, syscomments com
WHERE permissions(obj.id) != 0 AND obj.xtype = 'V' AND obj.id = com.id AND com.colid = 1