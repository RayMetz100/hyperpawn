using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Shell.Data
{
    public class FirearmLogEntry
    {
        //public int Id {get;set;}
        public int FirearmLogReferenceId { get; set; }
        public int EmployeeId { get; set; }
        public string Make { get; set; }
        public string Model { get; set; }
        public string Serial { get; set; }
        public string Type { get; set; }
        public string Caliber { get; set; }
        public DateTime ReceiptDate { get; set; }
        public string ReceiptName { get; set; }
        public string ReceiptAddress { get; set; }
        public DateTime? DispositionDate { get; set; }
        public string DispositionName { get; set; }
        public string DispositionAddress { get; set; }
        public string FirstPawnId { get; set; }
        public string Location { get; set; }
        public string PawnStatus { get; set; }
        public string PawnStatusDate { get; set; }

        public FirearmLogEntry(int FirearmLogReferenceId, int EmployeeId, string Make, string Model, string Serial, 
            string Type, string Caliber, DateTime ReceiptDate, string ReceiptName, string ReceiptAddress, 
            DateTime? DispositionDate, string DispositionName, string DispositionAddress,
            string FirstPawnId, string Location, string PawnStatus, string PawnStatusDate)
        {
            this.FirearmLogReferenceId = FirearmLogReferenceId;
            this.EmployeeId = EmployeeId;
            this.Make = Make;
            this.Model = Model;
            this.Serial = Serial;
            this.Type = Type;
            this.Caliber = Caliber;
            this.ReceiptDate = ReceiptDate;
            this.ReceiptName = ReceiptName;
            this.ReceiptAddress = ReceiptAddress;
            this.DispositionDate = DispositionDate;
            this.DispositionName = DispositionName;
            this.DispositionAddress = DispositionAddress;
            this.FirstPawnId = FirstPawnId;
            this.Location = Location;
            this.PawnStatus = PawnStatus;
            this.PawnStatusDate = PawnStatusDate;
        }
    }
}
