<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Processes.aspx.cs" Inherits="MesDemo.pages.Processes" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>工序列表</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">工序列表</div>
            <div class="layui-card-body">
                <form class="layui-form">
                    <div class="layui-form-item">
                        <div class="layui-inline">
                            <label class="layui-form-label">工序</label>
                            <div class="layui-input-inline">
                                <input type="text" name="keyword" class="layui-input" placeholder="编码或名称" />
                            </div>
                        </div>
                        <div class="layui-inline">
                            <label class="layui-form-label">状态</label>
                            <div class="layui-input-inline">
                                <select name="status">
                                    <option value="">全部</option>
                                    <option value="启用">启用</option>
                                    <option value="停用">停用</option>
                                </select>
                            </div>
                        </div>
                        <div class="layui-inline">
                            <button class="layui-btn" lay-submit="" lay-filter="searchProcess">查询</button>
                            <button type="reset" class="layui-btn layui-btn-primary">重置</button>
                        </div>
                    </div>
                </form>
                <table id="processTable" lay-filter="processTable"></table>
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
                    elem: "#processTable",
                    data: list,
                    page: true,
                    cols: [[
                        { field: "Code", title: "工序编码", width: 120 },
                        { field: "Name", title: "工序名称", minWidth: 120 },
                        { field: "Station", title: "工位", minWidth: 120 },
                        { field: "StandardMinutes", title: "标准工时(分钟)", width: 150 },
                        { field: "Status", title: "状态", width: 110 }
                    ]]
                });
            }

            AppData.queryProcesses("", "", renderTable, showError);

            form.on("submit(searchProcess)", function (obj) {
                var field = obj.field;
                AppData.queryProcesses(field.keyword, field.status, renderTable, showError);
                return false;
            });
        });
    </script>
</body>
</html>
