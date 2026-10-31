using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class Processes : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static List<ProcessItem> QueryProcesses(string keyword, string status)
        {
            return DataStore.GetProcesses(keyword, status);
        }
    }
}
