using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BuggyAPI
{
    public class BuggyAPIClient
    {
        public void LoadInfo(bool useExternalAPI)
        {
            if (useExternalAPI)
            {
                Random r = new Random();
                var delay = r.Next(28000, 35000);
                System.Threading.Thread.Sleep(delay);
            }
            else
            {
                Random r = new Random();
                var delay = r.Next(0, 1000);
                System.Threading.Thread.Sleep(delay);
            }
        }
    }
}
