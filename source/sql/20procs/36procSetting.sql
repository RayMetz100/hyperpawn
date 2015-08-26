USE HyperPawn
GO

/*

!!! Careful !!!  Clears all encrypted data. !!!

IF EXISTS(select 1 from sys.symmetric_keys WHERE name = 'EncryptedValue_Key_01')
	DROP SYMMETRIC KEY EncryptedValue_Key_01

IF EXISTS(select 1 from sys.certificates WHERE name = 'SettingEncryptedValue')
	DROP CERTIFICATE SettingEncryptedValue

IF EXISTS(select 1 from sys.symmetric_keys)
	DROP MASTER KEY

CREATE MASTER KEY ENCRYPTION BY 
	PASSWORD = 'HyperPawn1000'

CREATE CERTIFICATE SettingEncryptedValue
   WITH SUBJECT = 'Setting EncryptedValue'

CREATE SYMMETRIC KEY EncryptedValue_Key_01
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE SettingEncryptedValue

*/


IF OBJECT_ID('SettingMaintain') IS NOT NULL
	DROP PROCEDURE SettingMaintain
GO

CREATE PROCEDURE SettingMaintain
@Key NVARCHAR(100), 
@Value NVARCHAR(100) = NULL,
@DeleteKey BIT = 0,
@EncryptedValueOld NVARCHAR(100) = NULL,
@EncryptedValueNew NVARCHAR(100) = NULL
AS
SET NOCOUNT ON
DECLARE @rowcount INT


-- Process Deletes
IF @DeleteKey = 1
	BEGIN
		DELETE HyperPawnData.dbo.Setting
		WHERE [Key] = @Key
		
		RETURN
	END

-- Check for Insert or Update
IF NOT EXISTS (	SELECT 1
				FROM HyperPawnData.dbo.Setting
				WHERE [Key] = @Key)
-- Insert
	BEGIN
		INSERT INTO HyperPawnData.dbo.Setting
				([Key],	Value)
		VALUES	(@Key,	@Value)
		
		-- Encrypted Insert
		IF @EncryptedValueNew IS NOT NULL
			BEGIN
				OPEN SYMMETRIC KEY EncryptedValue_Key_01
					DECRYPTION BY CERTIFICATE SettingEncryptedValue

				UPDATE HyperPawnData.dbo.Setting
				SET EncryptedValue = EncryptByKey(Key_GUID('EncryptedValue_Key_01'), @EncryptedValueNew)
				WHERE [Key] = @Key

				CLOSE SYMMETRIC KEY EncryptedValue_Key_01

			END		
	END  -- Insert
ELSE
-- Update
	BEGIN
		UPDATE HyperPawnData.dbo.Setting
		SET Value = @Value
		WHERE [Key] = @Key
		
		-- Encrypted Update
		IF @EncryptedValueNew IS NOT NULL
			BEGIN				
				OPEN SYMMETRIC KEY EncryptedValue_Key_01
					DECRYPTION BY CERTIFICATE SettingEncryptedValue

				IF @EncryptedValueOld = (SELECT CONVERT(nvarchar, DecryptByKey(EncryptedValue))
										FROM HyperPawnData.dbo.Setting
										WHERE [Key] = @Key)
					BEGIN
						UPDATE HyperPawnData.dbo.Setting
						SET EncryptedValue = EncryptByKey(Key_GUID('EncryptedValue_Key_01'), @EncryptedValueNew)
						WHERE [Key] = @Key
					END
				ELSE
					BEGIN
						RETURN 1
					END

				CLOSE SYMMETRIC KEY EncryptedValue_Key_01

			END		
	END -- Update

GO

IF OBJECT_ID('ReportValidatePassword') IS NOT NULL
  DROP PROCEDURE ReportValidatePassword
GO

CREATE PROCEDURE ReportValidatePassword
@password NVARCHAR(100)
AS
	OPEN SYMMETRIC KEY EncryptedValue_Key_01
	   DECRYPTION BY CERTIFICATE SettingEncryptedValue

	IF @password = 
		(SELECT CONVERT(nvarchar(30), DecryptByKeyAutoCert(cert_id('SettingEncryptedValue'),NULL,EncryptedValue))
		FROM HyperPawnData.dbo.Setting
		WHERE [Key] = 'ReportPassword')
		BEGIN
			RETURN 0 -- Passed
		END
	ELSE
		BEGIN
			RETURN 1 --Failed
		END

	CLOSE SYMMETRIC KEY EncryptedValue_Key_01
GO

/*
declare @rc int
exec @rc = ReportValidatePassword 'passwor09'
select @rc



declare @rc int
exec @rc = SettingMaintain 
	@Key = 'ReportPassword', 
	--@Value = 'password',
	--@DeleteKey = 1,
	@EncryptedValueOld = N'dog',
	@EncryptedValueNew = N'pant'
select @rc


select * from HyperPawnData.dbo.Setting

delete HyperPawnData.dbo.Setting


OPEN SYMMETRIC KEY EncryptedValue_Key_01
   DECRYPTION BY CERTIFICATE SettingEncryptedValue

SELECT CONVERT(nvarchar, DecryptByKey(EncryptedValue)) 'DecryptedValue'
    FROM HyperPawnData.dbo.Setting;

CLOSE SYMMETRIC KEY EncryptedValue_Key_01

*/
