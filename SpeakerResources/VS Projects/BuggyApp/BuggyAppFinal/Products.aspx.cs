using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;
using Microsoft.ApplicationInsights;

namespace BuggyAppFinal
{
    public partial class Products : System.Web.UI.Page
    {
        TelemetryClient client = new TelemetryClient();
        protected void Page_Load(object sender, EventArgs e)
        {
            new BuggyAPI.BuggyAPIClient().LoadInfo(false);

            System.Diagnostics.Trace.WriteLine("Entering Products method");
            try
            {
                throw new ArgumentException("Invalid Key");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Found issue listing products: " + ex.Message);
                client.TrackException(ex);

                throw new HttpException("Invalid Key!");
            }
            System.Diagnostics.Trace.WriteLine("Leaving Products method");
        }
    }
}