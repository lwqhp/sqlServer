

ALTER TABLE tb ADD id int IDENTITY(1,1)

--字符类型自增
CREATE TABLE tb (id varchar(10) DEFAULT f_needID(tb))

CREATE FUNCTION f_needID(@tb)
RETURN varchar(10)
AS 
BEGIN 
	DECLARE @id varchar(10)
	SELECT @id = cast(max(cast(id AS int)+1) AS varchar)
	FROM @tb
	RETURN isnull(@id,'1')	
END 



