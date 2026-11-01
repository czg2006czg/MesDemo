using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace MesDemo
{
    /// <summary>
    /// 物料类型编号数据库访问。连接字符串读取 web.config 中的 MesDemoDb，
    /// 对应 SQL Server 数据库表 dbo.material_code（字段 material_type / max_code）。
    /// </summary>
    public static class MaterialCodeRepository
    {
        private const string ConnectionStringName = "MesDemoDb";

        private static string ConnectionString
        {
            get
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings[ConnectionStringName];
                if (settings == null || string.IsNullOrEmpty(settings.ConnectionString))
                {
                    throw new InvalidOperationException("web.config 中未配置数据库连接 MesDemoDb。");
                }
                return settings.ConnectionString;
            }
        }

        public static List<MaterialCode> GetAll()
        {
            const string sql = "SELECT material_type, max_code FROM dbo.material_code ORDER BY material_type";
            List<MaterialCode> list = new List<MaterialCode>();
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(Map(reader));
                    }
                }
            }
            return list;
        }

        public static bool Exists(string materialType)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.material_code WHERE material_type = @MaterialType";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@MaterialType", SqlDbType.VarChar, 200).Value = materialType;
                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar()) > 0;
            }
        }

        public static MaterialCode GetByType(string materialType)
        {
            const string sql = "SELECT material_type, max_code FROM dbo.material_code WHERE material_type = @MaterialType";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@MaterialType", SqlDbType.VarChar, 200).Value = materialType;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (!reader.Read())
                    {
                        return null;
                    }
                    return Map(reader);
                }
            }
        }

        public static void Insert(MaterialCode item)
        {
            const string sql = "INSERT INTO dbo.material_code (material_type, max_code) VALUES (@MaterialType, @MaxCode)";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddParameters(command, item);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        public static void Update(MaterialCode item)
        {
            const string sql = "UPDATE dbo.material_code SET max_code = @MaxCode WHERE material_type = @MaterialType";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddParameters(command, item);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        private static void AddParameters(SqlCommand command, MaterialCode item)
        {
            command.Parameters.Add("@MaterialType", SqlDbType.VarChar, 200).Value = item.MaterialType;
            command.Parameters.Add("@MaxCode", SqlDbType.BigInt).Value = (object)item.MaxCode ?? DBNull.Value;
        }

        private static MaterialCode Map(SqlDataReader reader)
        {
            return new MaterialCode
            {
                MaterialType = reader.IsDBNull(0) ? string.Empty : Convert.ToString(reader.GetValue(0)),
                MaxCode = reader.IsDBNull(1) ? (long?)null : Convert.ToInt64(reader.GetValue(1))
            };
        }
    }
}
