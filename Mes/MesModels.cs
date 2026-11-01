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

    /// <summary>采购申请（表头 + 明细）</summary>
    public class PurchaseRequest
    {
        public string Id { get; set; }
        public string Applicant { get; set; }
        public string Department { get; set; }
        /// <summary>申请类型，默认非生产性物料</summary>
        public string RequestType { get; set; }
        public string AppliedAt { get; set; }
        public string Status { get; set; }
        public string CreatedAt { get; set; }
        public List<PurchaseItem> Items { get; set; }
    }

    /// <summary>采购申请明细</summary>
    public class PurchaseItem
    {
        /// <summary>物料编码</summary>
        public string ItemCode { get; set; }
        /// <summary>物料名称</summary>
        public string ItemName { get; set; }
        /// <summary>需求数量</summary>
        public int Qty { get; set; }
        /// <summary>需求描述</summary>
        public string Description { get; set; }
        /// <summary>需求日期</summary>
        public string RequiredDate { get; set; }
    }

    /// <summary>往来单位</summary>
    public class Partner
    {
        public string Code { get; set; }
        public string Name { get; set; }
        /// <summary>单位性质：供应商 / 客户</summary>
        public string Nature { get; set; }
        /// <summary>单位地址</summary>
        public string Address { get; set; }
        /// <summary>联系人</summary>
        public string Contact { get; set; }
        /// <summary>联系方式</summary>
        public string Phone { get; set; }
        /// <summary>银行名称</summary>
        public string BankName { get; set; }
        /// <summary>银行账号</summary>
        public string BankAccount { get; set; }
        /// <summary>关联号</summary>
        public string RelatedNo { get; set; }
    }

    /// <summary>物料类型编号（数据库表 material_code）</summary>
    public class MaterialCode
    {
        /// <summary>物料类型</summary>
        public string MaterialType { get; set; }
        /// <summary>当前最大物料编号</summary>
        public long? MaxCode { get; set; }
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
