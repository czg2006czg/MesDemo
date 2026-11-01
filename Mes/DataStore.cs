using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace MesDemo
{
    /// <summary>
    /// 服务端数据访问层。数据以 JSON 形式保存在 App_Data/mes-data.json，
    /// 首次访问时自动写入初始演示数据。
    /// </summary>
    public static class DataStore
    {
        private const string DataFileName = "mes-data.json";
        private static readonly object SyncRoot = new object();

        private static string DataFilePath
        {
            get { return HttpContext.Current.Server.MapPath("~/App_Data/" + DataFileName); }
        }

        public static MesData Load()
        {
            lock (SyncRoot)
            {
                return LoadInternal();
            }
        }

        public static List<Order> GetOrders(string keyword, string status)
        {
            MesData data = Load();
            List<Order> list = new List<Order>();
            keyword = (keyword ?? string.Empty).Trim();
            status = (status ?? string.Empty).Trim();

            for (int i = 0; i < data.Orders.Count; i++)
            {
                Order order = data.Orders[i];
                if (keyword.Length > 0 && order.Id.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0)
                {
                    continue;
                }
                if (status.Length > 0 && order.Status != status)
                {
                    continue;
                }
                list.Add(order);
            }
            return list;
        }

        public static List<ProcessItem> GetProcesses(string keyword, string status)
        {
            MesData data = Load();
            List<ProcessItem> list = new List<ProcessItem>();
            keyword = (keyword ?? string.Empty).Trim();
            status = (status ?? string.Empty).Trim();

            for (int i = 0; i < data.Processes.Count; i++)
            {
                ProcessItem process = data.Processes[i];
                if (keyword.Length > 0
                    && process.Code.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0
                    && process.Name.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0)
                {
                    continue;
                }
                if (status.Length > 0 && process.Status != status)
                {
                    continue;
                }
                list.Add(process);
            }
            return list;
        }

        public static List<Report> GetReports()
        {
            return Load().Reports;
        }

        /// <summary>新增一条报工记录，同时累加工单完成数量并刷新工单状态。</summary>
        public static Report AddReport(Report report)
        {
            if (report == null)
            {
                throw new ArgumentNullException("report");
            }

            lock (SyncRoot)
            {
                MesData data = LoadInternal();

                if (report.GoodQty < 0) report.GoodQty = 0;
                if (report.BadQty < 0) report.BadQty = 0;
                report.OrderId = (report.OrderId ?? string.Empty).Trim();
                report.ProcessCode = (report.ProcessCode ?? string.Empty).Trim();

                if (report.OrderId.Length == 0)
                {
                    throw new ArgumentException("请选择工单。");
                }
                if (report.ProcessCode.Length == 0)
                {
                    throw new ArgumentException("请选择工序。");
                }

                Order order = data.Orders.Find(delegate(Order o) { return o.Id == report.OrderId; });
                if (order == null)
                {
                    throw new ArgumentException("工单不存在：" + report.OrderId);
                }
                if (order.Status == "已完成")
                {
                    throw new ArgumentException("工单已完成，不能再报工：" + report.OrderId);
                }

                data.Reports.Insert(0, report);
                order.DoneQty += report.GoodQty;
                if (order.DoneQty > order.PlanQty)
                {
                    order.DoneQty = order.PlanQty;
                }
                order.Status = ResolveStatus(order);

                SaveInternal(data);
                return report;
            }
        }

        public static List<PurchaseRequest> GetPurchaseRequests(string keyword, string status)
        {
            MesData data = Load();
            List<PurchaseRequest> list = new List<PurchaseRequest>();
            keyword = (keyword ?? string.Empty).Trim();
            status = (status ?? string.Empty).Trim();

            for (int i = 0; i < data.PurchaseRequests.Count; i++)
            {
                PurchaseRequest request = data.PurchaseRequests[i];
                if (keyword.Length > 0
                    && request.Id.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0
                    && (request.Applicant ?? string.Empty).IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0
                    && (request.Department ?? string.Empty).IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0)
                {
                    continue;
                }
                if (status.Length > 0 && request.Status != status)
                {
                    continue;
                }
                list.Add(request);
            }
            return list;
        }

        /// <summary>新增采购申请（表头 + 明细），申请单号按 PR-日期-序号 自动生成，初始状态为待审批。</summary>
        public static PurchaseRequest AddPurchaseRequest(PurchaseRequest request)
        {
            if (request == null)
            {
                throw new ArgumentNullException("request");
            }

            request.Applicant = (request.Applicant ?? string.Empty).Trim();
            request.Department = (request.Department ?? string.Empty).Trim();
            request.RequestType = (request.RequestType ?? string.Empty).Trim();
            request.AppliedAt = (request.AppliedAt ?? string.Empty).Trim();

            if (request.Applicant.Length == 0)
            {
                throw new ArgumentException("请填写申请人。");
            }
            if (request.Department.Length == 0)
            {
                throw new ArgumentException("请填写申请部门。");
            }
            if (request.RequestType.Length == 0)
            {
                request.RequestType = "非生产性物料";
            }
            if (request.AppliedAt.Length == 0)
            {
                request.AppliedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            }

            if (request.Items == null || request.Items.Count == 0)
            {
                throw new ArgumentException("请至少添加一条申请明细。");
            }

            for (int i = 0; i < request.Items.Count; i++)
            {
                PurchaseItem item = request.Items[i];
                if (item == null)
                {
                    throw new ArgumentException("第 " + (i + 1) + " 行明细为空。");
                }

                item.ItemCode = (item.ItemCode ?? string.Empty).Trim();
                item.ItemName = (item.ItemName ?? string.Empty).Trim();
                item.Description = (item.Description ?? string.Empty).Trim();
                item.RequiredDate = (item.RequiredDate ?? string.Empty).Trim();

                if (item.ItemCode.Length == 0)
                {
                    throw new ArgumentException("第 " + (i + 1) + " 行请填写物料编码。");
                }
                if (item.ItemName.Length == 0)
                {
                    throw new ArgumentException("第 " + (i + 1) + " 行请填写物料名称。");
                }
                if (item.Qty <= 0)
                {
                    throw new ArgumentException("第 " + (i + 1) + " 行需求数量必须大于 0。");
                }
                if (item.RequiredDate.Length == 0)
                {
                    throw new ArgumentException("第 " + (i + 1) + " 行请填写需求日期。");
                }
            }

            lock (SyncRoot)
            {
                MesData data = LoadInternal();
                string prefix = "PR-" + DateTime.Now.ToString("yyyyMMdd") + "-";
                int maxSeq = 0;

                for (int i = 0; i < data.PurchaseRequests.Count; i++)
                {
                    string id = data.PurchaseRequests[i].Id ?? string.Empty;
                    if (!id.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }
                    int seq;
                    if (int.TryParse(id.Substring(prefix.Length), out seq) && seq > maxSeq)
                    {
                        maxSeq = seq;
                    }
                }

                request.Id = prefix + (maxSeq + 1).ToString("000");
                request.Status = "待审批";
                request.CreatedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

                data.PurchaseRequests.Insert(0, request);
                SaveInternal(data);
                return request;
            }
        }

        public static List<Partner> GetPartners(string keyword, string nature)
        {
            MesData data = Load();
            List<Partner> list = new List<Partner>();
            keyword = (keyword ?? string.Empty).Trim();
            nature = (nature ?? string.Empty).Trim();

            for (int i = 0; i < data.Partners.Count; i++)
            {
                Partner partner = data.Partners[i];
                if (keyword.Length > 0
                    && partner.Code.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0
                    && partner.Name.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0
                    && partner.Contact.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0)
                {
                    continue;
                }
                if (nature.Length > 0 && partner.Nature != nature)
                {
                    continue;
                }
                list.Add(partner);
            }
            return list;
        }

        /// <summary>新增或更新往来单位（按单位编码判重）。</summary>
        public static Partner SavePartner(Partner partner)
        {
            if (partner == null)
            {
                throw new ArgumentNullException("partner");
            }

            partner.Code = (partner.Code ?? string.Empty).Trim();
            partner.Name = (partner.Name ?? string.Empty).Trim();
            partner.Nature = (partner.Nature ?? string.Empty).Trim();
            partner.Contact = (partner.Contact ?? string.Empty).Trim();
            partner.Phone = (partner.Phone ?? string.Empty).Trim();
            partner.Address = (partner.Address ?? string.Empty).Trim();

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

            lock (SyncRoot)
            {
                MesData data = LoadInternal();
                Partner existing = data.Partners.Find(delegate(Partner p) { return p.Code == partner.Code; });

                if (existing != null)
                {
                    existing.Name = partner.Name;
                    existing.Nature = partner.Nature;
                    existing.Contact = partner.Contact;
                    existing.Phone = partner.Phone;
                    existing.Address = partner.Address;
                    SaveInternal(data);
                    return existing;
                }

                data.Partners.Insert(0, partner);
                SaveInternal(data);
                return partner;
            }
        }

        private static string ResolveStatus(Order order)
        {
            if (order.DoneQty <= 0) return "待开工";
            if (order.DoneQty >= order.PlanQty) return "已完成";
            return "进行中";
        }

        private static MesData LoadInternal()
        {
            string path = DataFilePath;
            if (File.Exists(path))
            {
                string json = File.ReadAllText(path, Encoding.UTF8);
                MesData cached = new JavaScriptSerializer().Deserialize<MesData>(json);
                if (cached != null)
                {
                    if (cached.Orders == null) cached.Orders = new List<Order>();
                    if (cached.Processes == null) cached.Processes = new List<ProcessItem>();
                    if (cached.Reports == null) cached.Reports = new List<Report>();
                    if (cached.PurchaseRequests == null) cached.PurchaseRequests = new List<PurchaseRequest>();
                    if (cached.Partners == null) cached.Partners = new List<Partner>();
                    return cached;
                }
            }

            MesData seeded = CreateSeed();
            SaveInternal(seeded);
            return seeded;
        }

        private static void SaveInternal(MesData data)
        {
            string path = DataFilePath;
            string directory = Path.GetDirectoryName(path);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }
            File.WriteAllText(path, new JavaScriptSerializer().Serialize(data), Encoding.UTF8);
        }

        private static MesData CreateSeed()
        {
            return new MesData
            {
                Orders = new List<Order>
                {
                    new Order { Id = "WO-20261031-001", Product = "电机壳体", PlanQty = 1000, DoneQty = 320, Status = "进行中", CreatedAt = "2026-10-28 09:12:00" },
                    new Order { Id = "WO-20261031-002", Product = "端盖", PlanQty = 500, DoneQty = 500, Status = "已完成", CreatedAt = "2026-10-27 14:30:00" },
                    new Order { Id = "WO-20261031-003", Product = "转子", PlanQty = 800, DoneQty = 0, Status = "待开工", CreatedAt = "2026-10-31 08:05:00" },
                    new Order { Id = "WO-20261031-004", Product = "定子绕组", PlanQty = 600, DoneQty = 180, Status = "进行中", CreatedAt = "2026-10-30 10:40:00" }
                },
                Processes = new List<ProcessItem>
                {
                    new ProcessItem { Code = "OP10", Name = "下料", Station = "下料工位", StandardMinutes = 6, Status = "启用" },
                    new ProcessItem { Code = "OP20", Name = "车削", Station = "数控车床", StandardMinutes = 12, Status = "启用" },
                    new ProcessItem { Code = "OP30", Name = "铣削", Station = "加工中心", StandardMinutes = 18, Status = "启用" },
                    new ProcessItem { Code = "OP40", Name = "检验", Station = "质检台", StandardMinutes = 5, Status = "启用" },
                    new ProcessItem { Code = "OP50", Name = "包装", Station = "包装线", StandardMinutes = 4, Status = "停用" }
                },
                Reports = new List<Report>
                {
                    new Report { OrderId = "WO-20261031-001", ProcessCode = "OP20", GoodQty = 120, BadQty = 2, ReportDate = "2026-10-31", Operator = "张三" },
                    new Report { OrderId = "WO-20261031-004", ProcessCode = "OP10", GoodQty = 80, BadQty = 0, ReportDate = "2026-10-31", Operator = "李四" }
                },
                PurchaseRequests = new List<PurchaseRequest>
                {
                    new PurchaseRequest
                    {
                        Id = "PR-20261031-001", Applicant = "张三", Department = "生产部", RequestType = "非生产性物料",
                        AppliedAt = "2026-10-30 09:20:00", Status = "待审批", CreatedAt = "2026-10-30 09:20:00",
                        Items = new List<PurchaseItem>
                        {
                            new PurchaseItem { ItemCode = "M0001", ItemName = "电机壳体毛坯", Qty = 1200, Description = "HT250 毛坯", RequiredDate = "2026-11-05" }
                        }
                    },
                    new PurchaseRequest
                    {
                        Id = "PR-20261031-002", Applicant = "李四", Department = "设备部", RequestType = "非生产性物料",
                        AppliedAt = "2026-10-29 15:10:00", Status = "已审批", CreatedAt = "2026-10-29 15:10:00",
                        Items = new List<PurchaseItem>
                        {
                            new PurchaseItem { ItemCode = "M0002", ItemName = "端盖铸件", Qty = 600, Description = "ZL102 铸件", RequiredDate = "2026-11-08" }
                        }
                    }
                },
                Partners = new List<Partner>
                {
                    new Partner { Code = "GYS001", Name = "江苏恒力机电有限公司", Nature = "供应商", Contact = "陈经理", Phone = "0512-88886666", Address = "苏州市吴中区" },
                    new Partner { Code = "GYS002", Name = "宁波精工铸造厂", Nature = "供应商", Contact = "刘师傅", Phone = "0574-55553333", Address = "宁波市北仑区" },
                    new Partner { Code = "KH001", Name = "上海雷博电气有限公司", Nature = "客户", Contact = "周总", Phone = "021-66669999", Address = "上海市浦东新区" },
                    new Partner { Code = "KH002", Name = "杭州东成贸易有限公司", Nature = "客户", Contact = "孙经理", Phone = "0571-77778888", Address = "杭州市余杭区" }
                }
            };
        }
    }
}
