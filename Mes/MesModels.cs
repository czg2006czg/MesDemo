using System.Collections.Generic;

namespace MesDemo
{
    /// <summary>生产工单</summary>
    public class Order
    {
        public string Id { get; set; }
        public string Product { get; set; }
        public int PlanQty { get; set; }
        public int DoneQty { get; set; }
        public string Status { get; set; }
        public string CreatedAt { get; set; }
    }

    /// <summary>工序</summary>
    public class ProcessItem
    {
        public string Code { get; set; }
        public string Name { get; set; }
        public string Station { get; set; }
        public int StandardMinutes { get; set; }
        public string Status { get; set; }
    }

    /// <summary>产量报工记录</summary>
    public class Report
    {
        public string OrderId { get; set; }
        public string ProcessCode { get; set; }
        public int GoodQty { get; set; }
        public int BadQty { get; set; }
        public string ReportDate { get; set; }
        public string Operator { get; set; }
    }

    /// <summary>站点数据集合，持久化到 App_Data/mes-data.json</summary>
    public class MesData
    {
        public List<Order> Orders { get; set; }
        public List<ProcessItem> Processes { get; set; }
        public List<Report> Reports { get; set; }
    }
}
