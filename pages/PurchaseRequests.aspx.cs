using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class PurchaseRequests : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static List<PurchaseRequest> QueryPurchaseRequests(string keyword, string status)
        {
            return DataStore.GetPurchaseRequests(keyword, status);
        }

        [WebMethod]
        public static PurchaseRequest SavePurchaseRequest(string itemName, string spec, int qty, string unit, string requiredDate, string applicant)
        {
            PurchaseRequest request = new PurchaseRequest
            {
                ItemName = itemName,
                Spec = spec,
                Qty = qty,
                Unit = unit,
                RequiredDate = requiredDate,
                Applicant = applicant
            };
            return DataStore.AddPurchaseRequest(request);
        }
    }
}
