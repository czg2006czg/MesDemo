using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class PurchaseRequests : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// 提交采购申请：表头（申请人 / 申请部门 / 申请类型 / 申请时间）+ 明细（JSON 数组，
        /// 每行包含物料编码、物料名称、需求数量、需求描述、需求日期）。
        /// </summary>
        [WebMethod]
        public static PurchaseRequest SubmitPurchaseRequest(string applicant, string department, string requestType,
            string appliedAt, string itemsJson)
        {
            PurchaseRequest request = new PurchaseRequest
            {
                Applicant = applicant,
                Department = department,
                RequestType = requestType,
                AppliedAt = appliedAt
            };

            if (!string.IsNullOrEmpty(itemsJson))
            {
                try
                {
                    request.Items = new JavaScriptSerializer().Deserialize<List<PurchaseItem>>(itemsJson);
                }
                catch (Exception)
                {
                    throw new ArgumentException("申请明细格式不正确。");
                }
            }

            return DataStore.AddPurchaseRequest(request);
        }
    }
}
