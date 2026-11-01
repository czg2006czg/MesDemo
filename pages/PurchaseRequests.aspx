<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PurchaseRequests.aspx.cs" Inherits="MesDemo.pages.PurchaseRequests" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>采购申请</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
    <style>
        .page-wrap {
            width: 100%;
            box-sizing: border-box;
        }
        .request-form .layui-form-label {
            width: 92px;
            padding: 9px 10px 9px 0;
            text-align: right;
            color: #606266;
        }
        .request-form .layui-input-block {
            margin-left: 102px;
        }
        .request-form .layui-form-item {
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
        .list-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .submit-bar {
            margin-top: 16px;
        }
        .empty-row td {
            text-align: center;
            color: #999;
        }
    </style>
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">采购申请</div>
            <div class="layui-card-body">
                <p class="form-tip">
                    填写申请人与申请部门，点击「新增」在弹窗中录入物料明细，确认后点「提交申请」。
                </p>
                <form id="purchaseForm" class="layui-form request-form" lay-filter="purchaseForm">
                    <div class="layui-row layui-col-space10">
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">申请人</label>
                                <div class="layui-input-block">
                                    <input type="text" name="applicant" class="layui-input" placeholder="请输入申请人" value="张三" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">申请部门</label>
                                <div class="layui-input-block">
                                    <input type="text" name="department" class="layui-input" placeholder="如 生产部 / 设备部" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">申请类型</label>
                                <div class="layui-input-block">
                                    <select name="requestType">
                                        <option value="非生产性物料" selected>非生产性物料</option>
                                        <option value="生产性物料">生产性物料</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">申请时间</label>
                                <div class="layui-input-block">
                                    <input type="text" name="appliedAt" id="appliedAt" class="layui-input" readonly />
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="layui-card" style="margin-top: 16px;">
            <div class="layui-card-header list-header">
                <span>申请明细</span>
                <button type="button" id="btnAddItem" class="layui-btn layui-btn-sm">新增</button>
            </div>
            <div class="layui-card-body">
                <table class="layui-table" id="itemTable">
                    <colgroup>
                        <col width="70" />
                        <col width="160" />
                        <col width="180" />
                        <col width="110" />
                        <col />
                        <col width="130" />
                        <col width="90" />
                    </colgroup>
                    <thead>
                        <tr>
                            <th>序号</th>
                            <th>物料编码</th>
                            <th>物料名称</th>
                            <th style="text-align: right;">需求数量</th>
                            <th>需求描述</th>
                            <th>需求日期</th>
                            <th style="text-align: center;">操作</th>
                        </tr>
                    </thead>
                    <tbody id="itemBody"></tbody>
                </table>
                <div class="submit-bar">
                    <button type="button" id="btnSubmit" class="layui-btn">提交申请</button>
                    <button type="button" id="btnReset" class="layui-btn layui-btn-primary">清空</button>
                </div>
            </div>
        </div>
    </div>

    <script src="../lib/layui/layui.js"></script>
    <script src="../js/app-data.js"></script>
    <script>
        layui.use(["form", "laydate", "layer"], function () {
            var form = layui.form;
            var laydate = layui.laydate;
            var layer = layui.layer;
            var $ = layui.$;
            var items = [];

            function pad(n) {
                return n < 10 ? "0" + n : "" + n;
            }

            function nowText() {
                var d = new Date();
                return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + " "
                    + pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds());
            }

            function todayText() {
                var d = new Date();
                return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
            }

            function esc(value) {
                return $("<div>").text(value === null || value === undefined ? "" : String(value)).html();
            }

            function showError(message) {
                layer.alert(message || "服务端请求失败", { icon: 2, title: "操作失败" });
            }

            function showOk(message) {
                layer.msg(message, { icon: 1, time: 2500 });
            }

            $("#appliedAt").val(nowText());

            function renderItems() {
                if (items.length === 0) {
                    $("#itemBody").html('<tr class="empty-row"><td colspan="7">暂无明细，请点击右上角「新增」</td></tr>');
                    return;
                }
                var rows = [];
                for (var i = 0; i < items.length; i++) {
                    var it = items[i];
                    rows.push('<tr>'
                        + '<td>' + (i + 1) + '</td>'
                        + '<td>' + esc(it.ItemCode) + '</td>'
                        + '<td>' + esc(it.ItemName) + '</td>'
                        + '<td style="text-align: right;">' + esc(it.Qty) + '</td>'
                        + '<td>' + esc(it.Description) + '</td>'
                        + '<td>' + esc(it.RequiredDate) + '</td>'
                        + '<td style="text-align: center;"><a class="layui-btn layui-btn-xs layui-btn-danger del-item" data-index="' + i + '">删除</a></td>'
                        + '</tr>');
                }
                $("#itemBody").html(rows.join(""));
            }

            renderItems();

            $("#itemBody").on("click", ".del-item", function () {
                var index = Number($(this).attr("data-index"));
                if (index >= 0 && index < items.length) {
                    items.splice(index, 1);
                    renderItems();
                    layer.msg("已删除该明细", { time: 1500 });
                }
            });

            var dialogHtml = [
                '<div style="padding: 18px 24px 0 0;">',
                '<form id="itemForm" class="layui-form" lay-filter="itemForm">',
                '<div class="layui-form-item"><label class="layui-form-label">物料编码</label><div class="layui-input-block"><input type="text" name="itemCode" class="layui-input" placeholder="请输入物料编码" /></div></div>',
                '<div class="layui-form-item"><label class="layui-form-label">物料名称</label><div class="layui-input-block"><input type="text" name="itemName" class="layui-input" placeholder="请输入物料名称" /></div></div>',
                '<div class="layui-form-item"><label class="layui-form-label">需求数量</label><div class="layui-input-block"><input type="number" name="qty" class="layui-input" min="1" step="1" placeholder="请输入需求数量" /></div></div>',
                '<div class="layui-form-item"><label class="layui-form-label">需求描述</label><div class="layui-input-block"><textarea name="description" class="layui-textarea" placeholder="选填，如规格、用途"></textarea></div></div>',
                '<div class="layui-form-item"><label class="layui-form-label">需求日期</label><div class="layui-input-block"><input type="text" name="requiredDate" id="itemRequiredDate" class="layui-input" readonly placeholder="请选择需求日期" /></div></div>',
                '</form>',
                '<div style="padding: 4px 0 18px; text-align: right;">',
                '<button type="button" id="itemCancel" class="layui-btn layui-btn-primary layui-btn-sm">取消</button>',
                '<button type="button" id="itemOk" class="layui-btn layui-btn-sm">确定</button>',
                '</div>',
                '</div>'
            ].join("");

            var dialogIndex = null;

            $("#btnAddItem").on("click", function () {
                dialogIndex = layer.open({
                    type: 1,
                    title: "新增申请明细",
                    area: ["540px", "auto"],
                    shadeClose: false,
                    content: dialogHtml,
                    btn: false,
                    success: function () {
                        form.render(null, "itemForm");
                        laydate.render({ elem: "#itemRequiredDate", type: "date", value: todayText() });

                        $("#itemCancel").on("click", function () {
                            layer.close(dialogIndex);
                        });

                        $("#itemOk").on("click", function () {
                            var $itemForm = $("#itemForm");
                            var code = $.trim($itemForm.find("[name='itemCode']").val() || "");
                            var name = $.trim($itemForm.find("[name='itemName']").val() || "");
                            var qtyText = $.trim($itemForm.find("[name='qty']").val() || "");
                            var desc = $.trim($itemForm.find("[name='description']").val() || "");
                            var date = $.trim($itemForm.find("[name='requiredDate']").val() || "");

                            if (!code) { layer.msg("请填写物料编码", { icon: 0 }); return; }
                            if (!name) { layer.msg("请填写物料名称", { icon: 0 }); return; }
                            if (!/^\d+$/.test(qtyText) || Number(qtyText) <= 0) {
                                layer.msg("需求数量必须是大于 0 的整数", { icon: 0 });
                                return;
                            }
                            if (!date) { layer.msg("请选择需求日期", { icon: 0 }); return; }

                            items.push({
                                ItemCode: code,
                                ItemName: name,
                                Qty: Number(qtyText),
                                Description: desc,
                                RequiredDate: date
                            });
                            renderItems();
                            layer.close(dialogIndex);
                            layer.msg("已添加明细：" + code, { time: 1500 });
                        });
                    }
                });
            });

            function resetAll() {
                var $form = $("#purchaseForm");
                $form.find("[name='applicant']").val("张三");
                $form.find("[name='department']").val("");
                $form.find("[name='requestType']").val("非生产性物料");
                $("#appliedAt").val(nowText());
                form.render(null, "purchaseForm");
                items = [];
                renderItems();
            }

            $("#btnReset").on("click", resetAll);

            $("#btnSubmit").on("click", function () {
                var $form = $("#purchaseForm");
                var applicant = $.trim($form.find("[name='applicant']").val() || "");
                var department = $.trim($form.find("[name='department']").val() || "");
                var requestType = $form.find("[name='requestType']").val() || "非生产性物料";
                var appliedAt = $("#appliedAt").val() || nowText();

                if (!applicant) { layer.msg("请填写申请人", { icon: 0 }); return; }
                if (!department) { layer.msg("请填写申请部门", { icon: 0 }); return; }
                if (items.length === 0) { layer.msg("请至少添加一条申请明细", { icon: 0 }); return; }

                AppData.submitPurchaseRequest({
                    Applicant: applicant,
                    Department: department,
                    RequestType: requestType,
                    AppliedAt: appliedAt
                }, JSON.stringify(items), function (saved) {
                    showOk("提交成功：" + saved.Id);
                    resetAll();
                }, showError);
            });
        });
    </script>
</body>
</html>
