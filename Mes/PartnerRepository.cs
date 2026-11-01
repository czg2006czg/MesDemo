using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace MesDemo
{
    /// <summary>
    /// 往来单位数据库访问。连接字符串读取 web.config 中的 MesDemoDb，
    /// 对应 SQL Server 数据库表 dbo.Partner（见 db/Partner.sql）。
    /// </summary>
    public static class PartnerRepository
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

        public static bool Exists(string code)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Partner WHERE Code = @Code";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@Code", SqlDbType.NVarChar, 30).Value = code;
                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar()) > 0;
            }
        }

        public static Partner GetByCode(string code)
        {
            const string sql = @"SELECT Code, Name, Nature, Address, Contact, Phone, BankName, BankAccount, RelatedNo
                                 FROM dbo.Partner WHERE Code = @Code";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@Code", SqlDbType.NVarChar, 30).Value = code;
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

        public static void Insert(Partner partner)
        {
            const string sql = @"INSERT INTO dbo.Partner
                                    (Code, Name, Nature, Address, Contact, Phone, BankName, BankAccount, RelatedNo, CreatedAt)
                                 VALUES
                                    (@Code, @Name, @Nature, @Address, @Contact, @Phone, @BankName, @BankAccount, @RelatedNo, GETDATE())";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddParameters(command, partner);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        public static void Update(Partner partner)
        {
            const string sql = @"UPDATE dbo.Partner
                                 SET Name = @Name,
                                     Nature = @Nature,
                                     Address = @Address,
                                     Contact = @Contact,
                                     Phone = @Phone,
                                     BankName = @BankName,
                                     BankAccount = @BankAccount,
                                     RelatedNo = @RelatedNo,
                                     UpdatedAt = GETDATE()
                                 WHERE Code = @Code";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddParameters(command, partner);
                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        private static void AddParameters(SqlCommand command, Partner partner)
        {
            command.Parameters.Add("@Code", SqlDbType.NVarChar, 30).Value = partner.Code;
            command.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = partner.Name;
            command.Parameters.Add("@Nature", SqlDbType.NVarChar, 10).Value = partner.Nature;
            command.Parameters.Add("@Address", SqlDbType.NVarChar, 200).Value = ToDbValue(partner.Address);
            command.Parameters.Add("@Contact", SqlDbType.NVarChar, 50).Value = ToDbValue(partner.Contact);
            command.Parameters.Add("@Phone", SqlDbType.NVarChar, 50).Value = ToDbValue(partner.Phone);
            command.Parameters.Add("@BankName", SqlDbType.NVarChar, 100).Value = ToDbValue(partner.BankName);
            command.Parameters.Add("@BankAccount", SqlDbType.NVarChar, 50).Value = ToDbValue(partner.BankAccount);
            command.Parameters.Add("@RelatedNo", SqlDbType.NVarChar, 50).Value = ToDbValue(partner.RelatedNo);
        }

        private static object ToDbValue(string value)
        {
            return string.IsNullOrEmpty(value) ? (object)DBNull.Value : value;
        }

        private static string ReadString(SqlDataReader reader, string column)
        {
            int index = reader.GetOrdinal(column);
            return reader.IsDBNull(index) ? string.Empty : reader.GetString(index);
        }

        private static Partner Map(SqlDataReader reader)
        {
            return new Partner
            {
                Code = ReadString(reader, "Code"),
                Name = ReadString(reader, "Name"),
                Nature = ReadString(reader, "Nature"),
                Address = ReadString(reader, "Address"),
                Contact = ReadString(reader, "Contact"),
                Phone = ReadString(reader, "Phone"),
                BankName = ReadString(reader, "BankName"),
                BankAccount = ReadString(reader, "BankAccount"),
                RelatedNo = ReadString(reader, "RelatedNo")
            };
        }
    }
}
