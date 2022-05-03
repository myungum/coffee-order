﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace coffee_order
{
    public partial class _Default : Page
    {
        private static JObject orders = new JObject();
        private static JObject coffees = GetCoffees();
        private static int id = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        private static JObject GetCoffees()
        {
            // deserialize JSON directly from a file
            using (StreamReader file = File.OpenText(@"coffee.json"))
            {
                using (JsonTextReader reader = new JsonTextReader(file))
                {
                    return (JObject)JToken.ReadFrom(reader);
                }
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetData(string cmd)
        {
            switch (cmd)
            {
                case "get_coffees":
                    return GetSuccessString(coffees);
                case "get_orders":
                    return GetSuccessString(orders);
                case "get_name":
                    return GetSuccessString((string)(HttpContext.Current.Session["name"] ?? string.Empty));
                default:
                    return GetFailString("unknown cmd");
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string SetData(string cmd, string data)
        {

            switch (cmd)
            {
                case "add_order":
                    if (HttpContext.Current.Session["name"] != null)
                    {
                        JObject json = JObject.Parse(data);
                        json["id"] = id++;
                        json["주문자"] = (string)HttpContext.Current.Session["name"];
                        orders[json["id"].ToString()] = json;
                        return GetSuccessString("add order success");
                    }
                    return GetFailString("unknown user");
                case "remove_order":
                    if (orders.ContainsKey(data))
                    {
                        orders.Remove(data);
                        return GetSuccessString("remove order success");
                    }
                    return GetFailString("unknown order id");
                case "set_name":
                    HttpContext.Current.Session["name"] = data;
                    return GetSuccessString("set name success");
                default:
                    return GetFailString("unknown cmd");
            }
        }

        public static string GetSuccessString(JToken data)
        {
            JObject json = new JObject();
            json["result"] = "success";
            if (data != null)
            {
                json["data"] = data;
            }
            return json.ToString();
        }

        public static string GetFailString(string msg)
        {
            JObject json = new JObject();
            json["result"] = "fail";
            json["data"] = msg;
            return json.ToString();
        }
    }
}