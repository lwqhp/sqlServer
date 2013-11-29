CREATE FUNCTION dbo.f_CheckCode(
	@ID char(3),  -- 要插入的结点编码
	@PID char(3)  -- 要插入的结点的上级编码
)RETURNS bit
AS
BEGIN
	DECLARE @t TABLE(
		ID char(3),
		Level int,
		Flag tinyint)

	DECLARE @level int
	SET @level = 0
	INSERT @t(
		ID, Level, Flag)
	SELECT
		ID, @level,
		CASE
			WHEN ID = @PID THEN 1
			ELSE 0
		END
	FROM tb
	WHERE PID = @ID
	WHILE @@ROWCOUNT > 0 
		AND NOT EXISTS(
				SELECT * FROM @t
				WHERE Flag = 1)
	BEGIN
		SET @level = @level + 1
		INSERT @t
		SELECT
			ID, @level, 
			CASE
				WHEN ID = @PID THEN 1
				ELSE 0
			END
		FROM tb A, @t B
		WHERE A.PID = B.ID
			AND B.Level = @level - 1
	END

	RETURN((
			SELECT MAX(Flag) FROM @t
		))
END
GO
