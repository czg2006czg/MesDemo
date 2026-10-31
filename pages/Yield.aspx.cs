using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.UI;

namespace MesDemo.pages
{
    public partial class Yield : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static List<Order> GetOrders()
        {
            return DataStore.GetOrders(string.Empty, string.Empty);
        }

        [WebMethod]
        public static List<ProcessItem> GetProcesses()
        {
            return DataStore.GetProcesses(string.Empty, string.Empty);
        }

        [WebMethod]
        public static List<Report> GetReports()
        {
            return DataStore.GetReports();
        }

        [WebMethod]
        public static Report SaveYield(string orderId, string processCode, int goodQty, int badQty, string reportDate, string operatorName)
        {
            Report report = new Report
            {
                OrderId = orderId,
                ProcessCode = processCode,
                GoodQty = goodQty,
                BadQty = badQty,
                ReportDate = reportDate,
                Operator = operatorName
            };
            return DataStore.AddReport(report);
        }
    }
}
