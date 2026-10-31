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

    /// <summary>采购申请</summary>
    public class PurchaseRequest
    {
        public string Id { get; set; }
        public string ItemName { get; set; }
        public string Spec { get; set; }
        public int Qty { get; set; }
        public string Unit { get; set; }
        public string RequiredDate { get; set; }
        public string Applicant { get; set; }
        public string Status { get; set; }
        public string CreatedAt { get; set; }
    }

    /// <summary>往来单位</summary>
    public class Partner
    {
        public string Code { get; set; }
        public string Name { get; set; }
        /// <summary>单位性质：供应商 / 客户</summary>
        public string Nature { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Address { get; set; }
    }

    /// <summary>站点数据集合，持久化到 App_Data/mes-data.json</summary>
    public class MesData
    {
        public List<Order> Orders { get; set; }
        public List<ProcessItem> Processes { get; set; }
        public List<Report> Reports { get; set; }
        public List<PurchaseRequest> PurchaseRequests { get; set; }
        public List<Partner> Partners { get; set; }
    }
}
