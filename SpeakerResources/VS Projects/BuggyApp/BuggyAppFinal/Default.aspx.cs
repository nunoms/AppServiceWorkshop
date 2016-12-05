using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BuggyAppFinal
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            System.Diagnostics.Trace.WriteLine("Entering Default PageLoad");
            new BuggyAPI.BuggyAPIClient().LoadInfo(false);
            System.Diagnostics.Trace.TraceInformation("Displaying the Default page at " + DateTime.Now.ToShortTimeString());
            System.Diagnostics.Trace.WriteLine("Leaving Default PageLoad");
        }
    }
}