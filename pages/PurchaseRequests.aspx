<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PurchaseRequests.aspx.cs" Inherits="MesDemo.pages.PurchaseRequests" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>采购申请</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">采购申请</div>
            <div class="layui-card-body">
                <form class="layui-form" lay-filter="requestForm">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">物料名称</label>
                            <div class="layui-input-inline">
                                <input type="text" name="itemName" class="layui-input" placeholder="请输入物料名称" lay-verify="required" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">规格型号</label>
                            <div class="layui-input-inline">
                                <input type="text" name="spec" class="layui-input" placeholder="如 HT250" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">数量</label>
                            <div class="layui-input-inline">
                                <input type="number" name="qty" class="layui-input" min="1" lay-verify="required|number" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">单位</label>
                            <div class="layui-input-inline">
                                <input type="text" name="unit" class="layui-input" value="件" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">需求日期</label>
                            <div class="layui-input-inline">
                                <input type="text" name="requiredDate" id="requiredDate" class="layui-input" lay-verify="required" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">申请人</label>
                            <div class="layui-input-inline">
                                <input type="text" name="applicant" class="layui-input" value="张三" lay-verify="required" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <div class="layui-input-inline" style="margin-left: 110px;">
                                <button class="layui-btn" lay-submit="" lay-filter="saveRequest">提交申请</button>
                                <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="layui-card" style="margin-top: 16px;">
            <div class="layui-card-header">申请记录</div>
            <div class="layui-card-body">
                <form class="layui-form">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">申请单号</label>
                            <div class="layui-input-inline">
                                <input type="text" name="keyword" class="layui-input" placeholder="单号或物料名称" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">状态</label>
                            <div class="layui-input-inline">
                                <select name="status">
                                    <option value="">全部</option>
                                    <option value="待审批">待审批</option>
                                    <option value="已审批">已审批</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <button class="layui-btn" lay-submit="" lay-filter="searchRequest">查询</button>
                            <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                        </div>
                    </div>
                </form>
                <table id="requestTable" lay-filter="requestTable"></table>
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

            function showError(message) {
                layer.msg(message || "服务端请求失败");
            }

            function renderTable(list) {
                table.render({
                    elem: "#requestTable",
                    data: list,
                    page: true,
                    limit: 8,
                    cols: [[
                        { field: "Id", title: "申请单号", minWidth: 160 },
                        { field: "ItemName", title: "物料名称", minWidth: 130 },
                        { field: "Spec", title: "规格型号", minWidth: 110 },
                        { field: "Qty", title: "数量", width: 90 },
                        { field: "Unit", title: "单位", width: 80 },
                        { field: "RequiredDate", title: "需求日期", width: 120 },
                        { field: "Applicant", title: "申请人", width: 100 },
                        { field: "Status", title: "状态", width: 100 }
                    ]]
                });
            }

            AppData.queryPurchaseRequests("", "", renderTable, showError);

            laydate.render({
                elem: "#requiredDate",
                value: "2026-10-31"
            });

            form.on("submit(saveRequest)", function (obj) {
                var field = obj.field;
                AppData.savePurchaseRequest({
                    ItemName: field.itemName,
                    Spec: field.spec,
                    Qty: Number(field.qty),
                    Unit: field.unit,
                    RequiredDate: field.requiredDate,
                    Applicant: field.applicant
                }, function (saved) {
                    AppData.queryPurchaseRequests("", "", renderTable, showError);
                    layer.msg("申请已提交：" + saved.Id);
                }, showError);
                return false;
            });

            form.on("submit(searchRequest)", function (obj) {
                var field = obj.field;
                AppData.queryPurchaseRequests(field.keyword, field.status, renderTable, showError);
                return false;
            });
        });
    </script>
</body>
</html>
