<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Partners.aspx.cs" Inherits="MesDemo.pages.Partners" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>往来单位</title>
    <link rel="stylesheet" href="../lib/layui/css/layui.css" />
    <link rel="stylesheet" href="../css/app.css" />
    <style>
        .page-wrap {
            max-width: 1120px;
            margin: 0 auto;
        }
        .partner-form .layui-form-label {
            width: 92px;
            padding: 9px 10px 9px 0;
            text-align: right;
            color: #606266;
        }
        .partner-form .layui-input-block {
            margin-left: 102px;
        }
        .partner-form .layui-form-item {
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
    </style>
</head>
<body>
    <form id="serverForm" runat="server" style="display:none">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" EnablePartialRendering="false" />
    </form>
    <div class="page-wrap">
        <div class="layui-card">
            <div class="layui-card-header">往来单位</div>
            <div class="layui-card-body">
                <p class="form-tip">
                    新增：填写单位编码、单位名称与单位性质后点「新增保存」。<br />
                    编辑：输入已有单位编码后点「载入」，修改内容再点「修改保存」。
                </p>
                <form class="layui-form partner-form" lay-filter="partnerForm">
                    <div class="layui-row layui-col-space10">
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">单位编码</label>
                                <div class="layui-input-block">
                                    <input type="text" name="code" class="layui-input" placeholder="如 GYS001" lay-verify="required" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">单位名称</label>
                                <div class="layui-input-block">
                                    <input type="text" name="name" class="layui-input" placeholder="请输入单位名称" lay-verify="required" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">单位性质</label>
                                <div class="layui-input-block">
                                    <select name="nature" lay-verify="required">
                                        <option value="">请选择性质</option>
                                        <option value="供应商">供应商</option>
                                        <option value="客户">客户</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">单位地址</label>
                                <div class="layui-input-block">
                                    <input type="text" name="address" class="layui-input" placeholder="单位地址" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">联系人</label>
                                <div class="layui-input-block">
                                    <input type="text" name="contact" class="layui-input" placeholder="联系人" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">联系方式</label>
                                <div class="layui-input-block">
                                    <input type="text" name="phone" class="layui-input" placeholder="电话或手机" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">银行名称</label>
                                <div class="layui-input-block">
                                    <input type="text" name="bankName" class="layui-input" placeholder="开户银行" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">银行账号</label>
                                <div class="layui-input-block">
                                    <input type="text" name="bankAccount" class="layui-input" placeholder="银行账号" />
                                </div>
                            </div>
                        </div>
                        <div class="layui-col-md6">
                            <div class="layui-form-item">
                                <label class="layui-form-label">关联号</label>
                                <div class="layui-input-block">
                                    <input type="text" name="relatedNo" class="layui-input" placeholder="关联号" />
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
    </div>

    <script src="../lib/layui/layui.js"></script>
    <script src="../js/app-data.js"></script>
    <script>
        layui.use(["form", "layer"], function () {
            var form = layui.form;
            var layer = layui.layer;
            var $ = layui.$;

            function showError(message) {
                layer.alert(message || "服务端请求失败", { icon: 2, title: "操作失败" });
            }

            function showOk(message) {
                layer.msg(message, { icon: 1, time: 2500 });
            }

            function emptyForm() {
                form.val("partnerForm", {
                    code: "", name: "", nature: "", address: "",
                    contact: "", phone: "", bankName: "", bankAccount: "", relatedNo: ""
                });
                form.render(null, "partnerForm");
            }

            function fillForm(p) {
                form.val("partnerForm", {
                    code: p.Code || "",
                    name: p.Name || "",
                    nature: p.Nature || "",
                    address: p.Address || "",
                    contact: p.Contact || "",
                    phone: p.Phone || "",
                    bankName: p.BankName || "",
                    bankAccount: p.BankAccount || "",
                    relatedNo: p.RelatedNo || ""
                });
                form.render(null, "partnerForm");
            }

            function collect() {
                return {
                    Code: $.trim($("input[name='code']").val() || ""),
                    Name: $.trim($("input[name='name']").val() || ""),
                    Nature: $("select[name='nature']").val() || "",
                    Address: $.trim($("input[name='address']").val() || ""),
                    Contact: $.trim($("input[name='contact']").val() || ""),
                    Phone: $.trim($("input[name='phone']").val() || ""),
                    BankName: $.trim($("input[name='bankName']").val() || ""),
                    BankAccount: $.trim($("input[name='bankAccount']").val() || ""),
                    RelatedNo: $.trim($("input[name='relatedNo']").val() || "")
                };
            }

            function validate(p) {
                if (!p.Code) { layer.msg("请填写单位编码", { icon: 0 }); return false; }
                if (!p.Name) { layer.msg("请填写单位名称", { icon: 0 }); return false; }
                if (!p.Nature) { layer.msg("请选择单位性质（供应商/客户）", { icon: 0 }); return false; }
                return true;
            }

            $("#btnCreate").on("click", function () {
                var p = collect();
                if (!validate(p)) return;
                AppData.createPartner(p, function (saved) {
                    showOk("新增成功：" + saved.Code);
                    emptyForm();
                }, showError);
            });

            $("#btnLoad").on("click", function () {
                var code = $.trim($("input[name='code']").val() || "");
                if (!code) {
                    layer.msg("请先输入要载入的单位编码", { icon: 0 });
                    return;
                }
                AppData.getPartner(code, function (p) {
                    fillForm(p);
                    showOk("已载入：" + p.Code);
                }, showError);
            });

            $("#btnUpdate").on("click", function () {
                var p = collect();
                if (!validate(p)) return;
                AppData.updatePartner(p, function (saved) {
                    showOk("修改成功：" + saved.Code);
                }, showError);
            });

            $("#btnClear").on("click", function () {
                emptyForm();
                $("input[name='code']").focus();
            });
        });
    </script>
</body>
</html>
