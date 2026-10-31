using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class Partners : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static List<Partner> QueryPartners(string keyword, string nature)
        {
            return DataStore.GetPartners(keyword, nature);
        }

        [WebMethod]
        public static Partner SavePartner(string code, string name, string nature, string contact, string phone, string address)
        {
            Partner partner = new Partner
            {
                Code = code,
                Name = name,
                Nature = nature,
                Contact = contact,
                Phone = phone,
                Address = address
            };
            return DataStore.SavePartner(partner);
        }
    }
}
