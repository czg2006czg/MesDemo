/* ============================================================
   往来单位表（供应商 / 客户）
   数据库：mesdemo   连接字符串见 web.config 中的 MesDemoDb
   ============================================================ */

IF DB_ID(N'mesdemo') IS NULL
BEGIN
    CREATE DATABASE mesdemo;
END
GO

USE mesdemo;
GO

IF OBJECT_ID(N'dbo.Partner', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Partner
    (
        Code        NVARCHAR(30)  NOT NULL,                 -- 单位编码
        Name        NVARCHAR(100) NOT NULL,                 -- 单位名称
        Nature      NVARCHAR(10)  NOT NULL,                 -- 单位性质：供应商 / 客户
        Address     NVARCHAR(200) NULL,                     -- 单位地址
        Contact     NVARCHAR(50)  NULL,                     -- 联系人
        Phone       NVARCHAR(50)  NULL,                     -- 联系方式
        BankName    NVARCHAR(100) NULL,                     -- 银行名称
        BankAccount NVARCHAR(50)  NULL,                     -- 银行账号
        RelatedNo   NVARCHAR(50)  NULL,                     -- 关联号
        CreatedAt   DATETIME      NOT NULL DEFAULT(GETDATE()),  -- 创建时间
        UpdatedAt   DATETIME      NULL,                     -- 最后修改时间
        CONSTRAINT PK_Partner PRIMARY KEY (Code),
        CONSTRAINT CK_Partner_Nature CHECK (Nature IN (N'供应商', N'客户'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Partner_Name' AND object_id = OBJECT_ID(N'dbo.Partner'))
BEGIN
    CREATE INDEX IX_Partner_Name ON dbo.Partner (Name);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Partner_Nature' AND object_id = OBJECT_ID(N'dbo.Partner'))
BEGIN
    CREATE INDEX IX_Partner_Nature ON dbo.Partner (Nature);
END
GO
