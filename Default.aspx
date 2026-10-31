<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="MesDemo._Default" ContentType="text/html; charset=utf-8" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>生产管理</title>
    <link rel="stylesheet" href="lib/layui/css/layui.css" />
    <link rel="stylesheet" href="css/app.css" />
</head>
<body>
    <div class="layui-layout layui-layout-admin">
        <div class="layui-header">
            <div class="layui-logo layui-bg-black">生产管理</div>
            <ul class="layui-nav layui-layout-left">
                <li class="layui-nav-item"><a href="javascript:;">车间作业</a></li>
            </ul>
            <ul class="layui-nav layui-layout-right">
                <li class="layui-nav-item"><a href="javascript:;">管理员</a></li>
            </ul>
        </div>

        <div class="layui-side layui-bg-black">
            <div class="layui-side-scroll">
                <ul class="layui-nav layui-nav-tree" lay-filter="sideNav" id="sideNav">
                    <li class="layui-nav-item layui-this">
                        <a href="javascript:;" lay-unselect="" data-url="pages/Yield.aspx">产量录入</a>
                    </li>
                    <li class="layui-nav-item">
                        <a href="javascript:;" lay-unselect="" data-url="pages/WorkOrders.aspx">工单列表</a>
                    </li>
                    <li class="layui-nav-item">
                        <a href="javascript:;" lay-unselect="" data-url="pages/Processes.aspx">工序列表</a>
                    </li>
                </ul>
            </div>
        </div>

        <div class="layui-body">
            <iframe id="contentFrame" class="content-iframe" src="pages/Yield.aspx" title="内容区"></iframe>
        </div>

        <div class="layui-footer">产量录入 / 工单列表 / 工序列表</div>
    </div>

    <script src="lib/layui/layui.js"></script>
    <script>
        layui.use(["element"], function () {
            var $ = layui.$;
            $("#sideNav").on("click", "a[data-url]", function () {
                var $item = $(this).parent();
                $("#contentFrame").attr("src", $(this).attr("data-url"));
                setTimeout(function () {
                    $("#sideNav .layui-nav-item").removeClass("layui-this");
                    $item.addClass("layui-this");
                }, 0);
            });
        });
    </script>
</body>
</html>
