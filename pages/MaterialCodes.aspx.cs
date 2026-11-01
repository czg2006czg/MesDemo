using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class MaterialCodes : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>读取物料类型编号列表（数据库表 material_code）。</summary>
        [WebMethod]
        public static List<MaterialCode> QueryMaterialCodes()
        {
            return MaterialCodeRepository.GetAll();
        }

        /// <summary>按物料类型读取一条记录，供编辑载入。</summary>
        [WebMethod]
        public static MaterialCode GetMaterialCode(string materialType)
        {
            materialType = (materialType ?? string.Empty).Trim();
            if (materialType.Length == 0)
            {
                throw new ArgumentException("请填写物料类型。");
            }

            MaterialCode item = MaterialCodeRepository.GetByType(materialType);
            if (item == null)
            {
                throw new ArgumentException("物料类型不存在：" + materialType);
            }
            return item;
        }

        /// <summary>新增物料类型编号，物料类型不允许重复。</summary>
        [WebMethod]
        public static MaterialCode CreateMaterialCode(string materialType, string maxCode)
        {
            MaterialCode item = Build(materialType, maxCode);
            if (MaterialCodeRepository.Exists(item.MaterialType))
            {
                throw new ArgumentException("物料类型已存在：" + item.MaterialType);
            }

            MaterialCodeRepository.Insert(item);
            return item;
        }

        /// <summary>编辑物料类型编号，按物料类型更新最大物料编号。</summary>
        [WebMethod]
        public static MaterialCode UpdateMaterialCode(string materialType, string maxCode)
        {
            MaterialCode item = Build(materialType, maxCode);
            if (!MaterialCodeRepository.Exists(item.MaterialType))
            {
                throw new ArgumentException("物料类型不存在，无法编辑：" + item.MaterialType);
            }

            MaterialCodeRepository.Update(item);
            return item;
        }

        private static MaterialCode Build(string materialType, string maxCode)
        {
            MaterialCode item = new MaterialCode
            {
                MaterialType = (materialType ?? string.Empty).Trim()
            };

            if (item.MaterialType.Length == 0)
            {
                throw new ArgumentException("请填写物料类型。");
            }
            if (item.MaterialType.Length > 200)
            {
                throw new ArgumentException("物料类型不能超过 200 个字符。");
            }

            maxCode = (maxCode ?? string.Empty).Trim();
            if (maxCode.Length > 0)
            {
                long value;
                if (!long.TryParse(maxCode, out value) || value < 0)
                {
                    throw new ArgumentException("当前最大物料编号必须是大于等于 0 的整数。");
                }
                item.MaxCode = value;
            }

            return item;
        }
    }
}
