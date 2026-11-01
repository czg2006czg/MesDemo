using System;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class Partners : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>按单位编码读取一条往来单位，供“编辑”功能载入表单。</summary>
        [WebMethod]
        public static Partner GetPartner(string code)
        {
            code = (code ?? string.Empty).Trim();
            if (code.Length == 0)
            {
                throw new ArgumentException("请填写单位编码。");
            }

            Partner partner = PartnerRepository.GetByCode(code);
            if (partner == null)
            {
                throw new ArgumentException("单位编码不存在：" + code);
            }
            return partner;
        }

        /// <summary>新增往来单位，单位编码不允许重复。</summary>
        [WebMethod]
        public static Partner CreatePartner(string code, string name, string nature, string address, string contact,
            string phone, string bankName, string bankAccount, string relatedNo)
        {
            Partner partner = BuildPartner(code, name, nature, address, contact, phone, bankName, bankAccount, relatedNo);

            if (PartnerRepository.Exists(partner.Code))
            {
                throw new ArgumentException("单位编码已存在：" + partner.Code);
            }

            PartnerRepository.Insert(partner);
            return partner;
        }

        /// <summary>编辑往来单位，按单位编码更新数据库记录。</summary>
        [WebMethod]
        public static Partner UpdatePartner(string code, string name, string nature, string address, string contact,
            string phone, string bankName, string bankAccount, string relatedNo)
        {
            Partner partner = BuildPartner(code, name, nature, address, contact, phone, bankName, bankAccount, relatedNo);

            if (!PartnerRepository.Exists(partner.Code))
            {
                throw new ArgumentException("单位编码不存在，无法编辑：" + partner.Code);
            }

            PartnerRepository.Update(partner);
            return partner;
        }

        private static Partner BuildPartner(string code, string name, string nature, string address, string contact,
            string phone, string bankName, string bankAccount, string relatedNo)
        {
            Partner partner = new Partner
            {
                Code = (code ?? string.Empty).Trim(),
                Name = (name ?? string.Empty).Trim(),
                Nature = (nature ?? string.Empty).Trim(),
                Address = (address ?? string.Empty).Trim(),
                Contact = (contact ?? string.Empty).Trim(),
                Phone = (phone ?? string.Empty).Trim(),
                BankName = (bankName ?? string.Empty).Trim(),
                BankAccount = (bankAccount ?? string.Empty).Trim(),
                RelatedNo = (relatedNo ?? string.Empty).Trim()
            };

            if (partner.Code.Length == 0)
            {
                throw new ArgumentException("请填写单位编码。");
            }
            if (partner.Name.Length == 0)
            {
                throw new ArgumentException("请填写单位名称。");
            }
            if (partner.Nature != "供应商" && partner.Nature != "客户")
            {
                throw new ArgumentException("请选择单位性质（供应商/客户）。");
            }
            return partner;
        }
    }
}
