(function (window) {
  // 前端不再直接读写 localStorage，统一通过 PageMethods 调服务端接口（*.aspx.cs 中的 [WebMethod]）。
  function invoke(method, args, onSuccess, onFail) {
    var proxy = window.PageMethods && window.PageMethods[method];
    if (typeof proxy !== "function") {
      if (onFail) {
        onFail("服务端接口未就绪，请确认页面上已启用 ScriptManager 的 EnablePageMethods。");
      }
      return;
    }
    proxy.apply(window.PageMethods, args.concat([
      function (result) {
        if (onSuccess) onSuccess(result);
      },
      function (error) {
        var message = "服务端请求失败";
        if (error && typeof error.get_message === "function") {
          message = error.get_message() || message;
        }
        if (onFail) onFail(message);
      }
    ]));
  }

  window.AppData = {
    getOrders: function (onSuccess, onFail) {
      invoke("GetOrders", [], onSuccess, onFail);
    },
    queryOrders: function (keyword, status, onSuccess, onFail) {
      invoke("QueryOrders", [keyword || "", status || ""], onSuccess, onFail);
    },
    getProcesses: function (onSuccess, onFail) {
      invoke("GetProcesses", [], onSuccess, onFail);
    },
    queryProcesses: function (keyword, status, onSuccess, onFail) {
      invoke("QueryProcesses", [keyword || "", status || ""], onSuccess, onFail);
    },
    getReports: function (onSuccess, onFail) {
      invoke("GetReports", [], onSuccess, onFail);
    },
    saveYield: function (report, onSuccess, onFail) {
      invoke("SaveYield", [
        report.OrderId,
        report.ProcessCode,
        report.GoodQty,
        report.BadQty,
        report.ReportDate,
        report.Operator
      ], onSuccess, onFail);
    }
  };
})(window);
