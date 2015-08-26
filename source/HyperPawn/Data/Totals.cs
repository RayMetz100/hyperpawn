using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Shell.Data
{
    public class TaxTotal
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string TaxLine { get; set; }
        public Decimal Amount { get; set; }

        public TaxTotal(DateTime startdate, DateTime enddate, string taxline, decimal amount)
        {
            StartDate = startdate;
            EndDate = enddate;
            TaxLine = taxline;
            Amount = amount;
        }
    }
}
