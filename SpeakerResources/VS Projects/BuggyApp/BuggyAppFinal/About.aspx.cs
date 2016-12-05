using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BuggyAppFinal
{
    public partial class About : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            System.Diagnostics.Trace.WriteLine("Entering About PageLoad");
            new BuggyAPI.BuggyAPIClient().LoadInfo(false);
            System.Diagnostics.Trace.TraceWarning("Transient error on the About page at " + DateTime.Now.ToShortTimeString());
            System.Diagnostics.Trace.WriteLine("Leaving About PageLoad");
        }
    }
}