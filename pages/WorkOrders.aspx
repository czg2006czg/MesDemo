<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkOrders.aspx.cs" Inherits="MesDemo.pages.WorkOrders" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>工单列表</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">工单列表</div>
            <div class="layui-card-body">
                <form class="layui-form" lay-filter="searchForm">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">工单号</label>
                            <div class="layui-input-inline">
                                <input type="text" name="id" class="layui-input" placeholder="请输入工单号" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">状态</label>
                            <div class="layui-input-inline">
                                <select name="status">
                                    <option value="">全部</option>
                                    <option value="待开工">待开工</option>
                                    <option value="进行中">进行中</option>
                                    <option value="已完成">已完成</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <button class="layui-btn" lay-submit="" lay-filter="searchOrders">查询</button>
                            <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                        </div>
                    </div>
                </form>
                <table id="orderTable" lay-filter="orderTable"></table>
            </div>
        </div>
    </div>

    <script src="../lib/layui/layui.js"></script>
    <script src="../js/app-data.js"></script>
    <script>
        layui.use(["form", "table", "layer"], function () {
            var form = layui.form;
            var table = layui.table;
            var layer = layui.layer;

            function showError(message) {
                layer.msg(message || "服务端请求失败");
            }

            function renderTable(list) {
                table.render({
                    elem: "#orderTable",
                    data: list,
                    page: true,
                    cols: [[
                        { field: "Id", title: "工单号", minWidth: 160 },
                        { field: "Product", title: "产品", minWidth: 120 },
                        { field: "PlanQty", title: "计划数量", width: 110 },
                        { field: "DoneQty", title: "完成数量", width: 110 },
                        { field: "Status", title: "状态", width: 110 },
                        { field: "CreatedAt", title: "创建时间", minWidth: 170 }
                    ]]
                });
            }

            AppData.queryOrders("", "", renderTable, showError);

            form.on("submit(searchOrders)", function (obj) {
                var field = obj.field;
                AppData.queryOrders(field.id, field.status, renderTable, showError);
                return false;
            });
        });
    </script>
</body>
</html>
