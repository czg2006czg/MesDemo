<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialCodes.aspx.cs" Inherits="MesDemo.pages.MaterialCodes" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>物料类型编号</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
    <style>
        .page-wrap {
            max-width: 1120px;
            margin: 0 auto;
        }
        .material-form .layui-form-label {
            width: 132px;
            padding: 9px 10px 9px 0;
            text-align: right;
            color: #606266;
        }
        .material-form .layui-input-block {
            margin-left: 142px;
        }
        .material-form .layui-form-item {
            margin-bottom: 14px;
        }
        .form-tip {
            margin: 0 0 16px;
            padding: 8px 12px;
            background: #f6f8fb;
            border-left: 3px solid #16b777;
            color: #7a8699;
            font-size: 13px;
            line-height: 20px;
        }
        .toolbar .layui-btn {
            margin-right: 8px;
        }
        .list-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
    </style>
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">物料类型编号</div>
            <div class="layui-card-body">
                <p class="form-tip">
                    新增：填写物料类型与当前最大物料编号后点「新增保存」。<br />
                    编辑：输入物料类型点「载入」，或直接在下方列表点「编辑」，修改后点「修改保存」。
                </p>
                <form class="layui-form material-form" lay-filter="materialForm">
                    <div class="layui-row layui-col-space10">
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">物料类型</label>
                                <div class="layui-input-block">
                                    <input type="text" name="materialType" class="layui-input" placeholder="如 铜材 / 标准件" maxlength="50" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">当前最大物料编号</label>
                                <div class="layui-input-block">
                                    <input type="number" name="maxCode" class="layui-input" min="0" step="1" placeholder="如 7000001001" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item toolbar">
                        <div class="layui-input-block">
                            <button type="button" id="btnCreate" class="layui-btn">新增保存</button>
                            <button type="button" id="btnLoad" class="layui-btn layui-btn-normal">载入</button>
                            <button type="button" id="btnUpdate" class="layui-btn layui-btn-warm">修改保存</button>
                            <button type="button" id="btnClear" class="layui-btn layui-btn-primary">清空</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="layui-card" style="margin-top: 16px;">
            <div class="layui-card-header list-header">
                <span>数据库列表</span>
                <button type="button" id="btnRefresh" class="layui-btn layui-btn-sm layui-btn-primary">刷新</button>
            </div>
            <div class="layui-card-body">
                <table id="codeTable" lay-filter="codeTable"></table>
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
            var $ = layui.$;

            function showError(message) {
                layer.alert(message || "服务端请求失败", { icon: 2, title: "操作失败" });
            }

            function showOk(message) {
                layer.msg(message, { icon: 1, time: 2500 });
            }

            function emptyForm() {
                form.val("materialForm", { materialType: "", maxCode: "" });
                form.render(null, "materialForm");
            }

            function fillForm(row) {
                form.val("materialForm", {
                    materialType: row.MaterialType || "",
                    maxCode: (row.MaxCode === null || row.MaxCode === undefined) ? "" : String(row.MaxCode)
                });
                form.render(null, "materialForm");
                $("html, body").animate({ scrollTop: 0 }, 150);
            }

            function collect() {
                return {
                    MaterialType: $.trim($("input[name='materialType']").val() || ""),
                    MaxCode: $.trim($("input[name='maxCode']").val() || "")
                };
            }

            function validate(p) {
                if (!p.MaterialType) {
                    layer.msg("请填写物料类型", { icon: 0 });
                    return false;
                }
                if (p.MaxCode && !/^\d+$/.test(p.MaxCode)) {
                    layer.msg("当前最大物料编号必须是非负整数", { icon: 0 });
                    return false;
                }
                return true;
            }

            function renderTable(list) {
                table.render({
                    elem: "#codeTable",
                    id: "codeTable",
                    data: list,
                    page: true,
                    limit: 10,
                    text: { none: "暂无数据" },
                    cols: [[
                        { type: "numbers", title: "序号", width: 70 },
                        { field: "MaterialType", title: "物料类型", minWidth: 240 },
                        { field: "MaxCode", title: "当前最大物料编号", minWidth: 200, align: "right" },
                        { title: "操作", width: 110, align: "center", toolbar: "#codeBar" }
                    ]]
                });
            }

            function loadList() {
                AppData.queryMaterialCodes(function (list) {
                    renderTable(list || []);
                }, showError);
            }

            loadList();

            $("#btnRefresh").on("click", loadList);

            $("#btnCreate").on("click", function () {
                var p = collect();
                if (!validate(p)) return;
                AppData.createMaterialCode(p, function (saved) {
                    showOk("新增成功：" + saved.MaterialType);
                    emptyForm();
                    loadList();
                }, showError);
            });

            $("#btnLoad").on("click", function () {
                var type = $.trim($("input[name='materialType']").val() || "");
                if (!type) {
                    layer.msg("请先输入要载入的物料类型", { icon: 0 });
                    return;
                }
                AppData.getMaterialCode(type, function (row) {
                    fillForm(row);
                    showOk("已载入：" + row.MaterialType);
                }, showError);
            });

            $("#btnUpdate").on("click", function () {
                var p = collect();
                if (!validate(p)) return;
                AppData.updateMaterialCode(p, function (saved) {
                    showOk("修改成功：" + saved.MaterialType);
                    loadList();
                }, showError);
            });

            $("#btnClear").on("click", function () {
                emptyForm();
                $("input[name='materialType']").focus();
            });

            table.on("tool(codeTable)", function (obj) {
                if (obj.event === "edit") {
                    fillForm(obj.data);
                    showOk("已载入到表单：" + (obj.data.MaterialType || ""));
                }
            });
        });
    </script>

    <script type="text/html" id="codeBar">
        <a class="layui-btn layui-btn-xs" lay-event="edit">编辑</a>
    </script>
</body>
</html>
