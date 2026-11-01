/* ============================================================
   物料类型编号表（对应数据库 mesdemo，连接串见 web.config 的 MesDemoDb）
   字段：material_type 物料类型 / max_code 当前最大物料编号
   ============================================================ */

IF DB_ID(N'mesdemo') IS NULL
BEGIN
    CREATE DATABASE mesdemo;
END
GO

USE mesdemo;
GO

IF OBJECT_ID(N'dbo.material_code', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.material_code
    (
        material_type VARCHAR(200) NULL,   -- 物料类型
        max_code      BIGINT       NULL    -- 当前最大物料编号
    );
END
GO
