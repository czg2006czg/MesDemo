<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Partners.aspx.cs" Inherits="MesDemo.pages.Partners" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>往来单位</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">往来单位</div>
            <div class="layui-card-body">
                <form class="layui-form" lay-filter="partnerForm">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">单位编码</label>
                            <div class="layui-input-inline">
                                <input type="text" name="code" class="layui-input" placeholder="如 GYS001" lay-verify="required" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">单位名称</label>
                            <div class="layui-input-inline">
                                <input type="text" name="name" class="layui-input" placeholder="请输入单位名称" lay-verify="required" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">单位性质</label>
                            <div class="layui-input-inline">
                                <select name="nature" lay-verify="required">
                                    <option value="">请选择性质</option>
                                    <option value="供应商">供应商</option>
                                    <option value="客户">客户</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">联系人</label>
                            <div class="layui-input-inline">
                                <input type="text" name="contact" class="layui-input" placeholder="联系人" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">联系电话</label>
                            <div class="layui-input-inline">
                                <input type="text" name="phone" class="layui-input" placeholder="联系电话" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">地址</label>
                            <div class="layui-input-inline" style="width: 260px;">
                                <input type="text" name="address" class="layui-input" placeholder="单位地址" />
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <div class="layui-input-inline" style="margin-left: 110px;">
                                <button class="layui-btn" lay-submit="" lay-filter="savePartner">保存单位</button>
                                <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="layui-card" style="margin-top: 16px;">
            <div class="layui-card-header">单位列表</div>
            <div class="layui-card-body">
                <form class="layui-form">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">关键字</label>
                            <div class="layui-input-inline">
                                <input type="text" name="keyword" class="layui-input" placeholder="编码、名称或联系人" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">单位性质</label>
                            <div class="layui-input-inline">
                                <select name="nature">
                                    <option value="">全部</option>
                                    <option value="供应商">供应商</option>
                                    <option value="客户">客户</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <button class="layui-btn" lay-submit="" lay-filter="searchPartner">查询</button>
                            <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                        </div>
                    </div>
                </form>
                <table id="partnerTable" lay-filter="partnerTable"></table>
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
                    elem: "#partnerTable",
                    data: list,
                    page: true,
                    limit: 8,
                    cols: [[
                        { field: "Code", title: "单位编码", width: 110 },
                        { field: "Name", title: "单位名称", minWidth: 180 },
                        { field: "Nature", title: "单位性质", width: 100 },
                        { field: "Contact", title: "联系人", width: 100 },
                        { field: "Phone", title: "联系电话", minWidth: 130 },
                        { field: "Address", title: "地址", minWidth: 180 }
                    ]]
                });
            }

            AppData.queryPartners("", "", renderTable, showError);

            form.on("submit(savePartner)", function (obj) {
                var field = obj.field;
                AppData.savePartner({
                    Code: field.code,
                    Name: field.name,
                    Nature: field.nature,
                    Contact: field.contact,
                    Phone: field.phone,
                    Address: field.address
                }, function (saved) {
                    AppData.queryPartners("", "", renderTable, showError);
                    layer.msg("单位已保存：" + saved.Code);
                }, showError);
                return false;
            });

            form.on("submit(searchPartner)", function (obj) {
                var field = obj.field;
                AppData.queryPartners(field.keyword, field.nature, renderTable, showError);
                return false;
            });
        });
    </script>
</body>
</html>
