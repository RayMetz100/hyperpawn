using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Shell.Data
{
    public class PutAwayPawn
    {
        public int PawnId { get; set; }
        public DateTime PawnDate { get; set; }
        public string Last { get; set; }
        public string Item { get; set; }
        public int FirearmLogReferenceId { get; set; }
        public string Location { get; set; }

        public PutAwayPawn(int pawnid, DateTime pawndate, string last, string item)//, int firearmlogreferenceid)
        {
            PawnId = pawnid;
            PawnDate = pawndate;
            Last = last;
            Item = item;
            //FirearmLogReferenceId = firearmlogreferenceid;
        }
    }
}
