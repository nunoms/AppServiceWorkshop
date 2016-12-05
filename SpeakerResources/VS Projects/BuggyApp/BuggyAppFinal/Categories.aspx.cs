using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BuggyAppFinal
{
    public partial class Categories : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            System.Diagnostics.Trace.WriteLine("Entering Categories method");
            var useApi = System.Configuration.ConfigurationManager.AppSettings["useExternalApi"];
            if (useApi != null && Boolean.Parse(useApi))
                new BuggyAPI.BuggyAPIClient().LoadInfo(true);
            else
                new BuggyAPI.BuggyAPIClient().LoadInfo(false);

            myList.DataSource = new List<string>() { "Books", "Toys", "Gadgets" };
            myList.DataBind();
            System.Diagnostics.Trace.WriteLine("Leaving Categories method");
        }

        private void LoadData()
        {
            Random r = new Random();
            var delay = r.Next(28000, 35000);
            System.Threading.Thread.Sleep(delay);
        }
    }
}