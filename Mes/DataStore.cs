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
                }
            };
        }
    }
}
