<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Yield.aspx.cs" Inherits="MesDemo.pages.Yield" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>产量录入</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">产量录入</div>
            <div class="layui-card-body">
                <form class="layui-form" lay-filter="yieldForm">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">工单号</label>
                            <div class="layui-input-inline">
                                <select name="orderId" lay-verify="required" lay-filter="orderId" lay-search="">
                                    <option value="">请选择工单</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">产品</label>
                            <div class="layui-input-inline">
                                <input type="text" name="product" class="layui-input" readonly="readonly" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">工序</label>
                            <div class="layui-input-inline">
                                <select name="processCode" lay-verify="required">
                                    <option value="">请选择工序</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">报工日期</label>
                            <div class="layui-input-inline">
                                <input type="text" name="reportDate" id="reportDate" class="layui-input" lay-verify="required" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">合格数量</label>
                            <div class="layui-input-inline">
                                <input type="number" name="goodQty" class="layui-input" min="1" lay-verify="required|number" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">不良数量</label>
                            <div class="layui-input-inline">
                                <input type="number" name="badQty" class="layui-input" min="0" value="0" lay-verify="required|number" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">操作员</label>
                            <div class="layui-input-inline">
                                <input type="text" name="operator" class="layui-input" value="张三" lay-verify="required" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <div class="layui-input-inline" style="margin-left: 110px;">
                                <button class="layui-btn" lay-submit="" lay-filter="saveYield">提交录入</button>
                                <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="layui-card" style="margin-top: 16px;">
            <div class="layui-card-header">最近报工</div>
            <div class="layui-card-body">
                <table id="reportTable" lay-filter="reportTable"></table>
            </div>
        </div>
    </div>

    <script src="../lib/layui/layui.js"></script>
    <script src="../js/app-data.js"></script>
    <script>
        layui.use(["form", "laydate", "table", "layer"], function () {
            var form = layui.form;
            var laydate = layui.laydate;
            var table = layui.table;
            var layer = layui.layer;
            var $ = layui.$;
            var orders = [];
            var processes = [];

            function showError(message) {
                layer.msg(message || "服务端请求失败");
            }

            function fillSelects() {
                var orderHtml = '<option value="">请选择工单</option>';
                layui.each(orders, function (i, item) {
                    orderHtml += '<option value="' + item.Id + '">' + item.Id + " / " + item.Product + "</option>";
                });
                $("select[name=orderId]").html(orderHtml);

                var processHtml = '<option value="">请选择工序</option>';
                layui.each(processes, function (i, item) {
                    if (item.Status === "启用") {
                        processHtml += '<option value="' + item.Code + '">' + item.Code + " " + item.Name + "</option>";
                    }
                });
                $("select[name=processCode]").html(processHtml);
                form.render("select");
            }

            function renderReports(list) {
                table.render({
                    elem: "#reportTable",
                    data: list,
                    page: true,
                    limit: 8,
                    cols: [[
                        { field: "OrderId", title: "工单号", minWidth: 160 },
                        { field: "ProcessCode", title: "工序", width: 110 },
                        { field: "GoodQty", title: "合格数量", width: 110 },
                        { field: "BadQty", title: "不良数量", width: 110 },
                        { field: "ReportDate", title: "报工日期", width: 130 },
                        { field: "Operator", title: "操作员", width: 110 }
                    ]]
                });
            }

            function reloadReports() {
                AppData.getReports(renderReports, showError);
            }

            AppData.getOrders(function (list) {
                orders = list || [];
                AppData.getProcesses(function (list2) {
                    processes = list2 || [];
                    fillSelects();
                }, showError);
            }, showError);

            reloadReports();

            laydate.render({
                elem: "#reportDate",
                value: "2026-10-31"
            });

            form.on("select(orderId)", function (obj) {
                var product = "";
                layui.each(orders, function (i, item) {
                    if (item.Id === obj.value) {
                        product = item.Product;
                    }
                });
                $("input[name=product]").val(product);
            });

            form.on("submit(saveYield)", function (obj) {
                var field = obj.field;
                AppData.saveYield({
                    OrderId: field.orderId,
                    ProcessCode: field.processCode,
                    GoodQty: Number(field.goodQty),
                    BadQty: Number(field.badQty),
                    ReportDate: field.reportDate,
                    Operator: field.operator
                }, function () {
                    reloadReports();
                    layer.msg("产量已录入");
                }, showError);
                return false;
            });
        });
    </script>
</body>
</html>
