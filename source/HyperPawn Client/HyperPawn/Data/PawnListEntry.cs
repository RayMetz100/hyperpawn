using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Shell.Data
{
    public class PawnListEntry
    {
        public string Type { get; set; }
        public int Id { get; set; }
        public DateTime PawnDate { get; set; }
        public int FirstPawnId { get; set; }
        public DateTime FirstPawnDate { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Amount { get; set; }
        public string Location { get; set; }
        public string CurrentStatus { get; set; }
        public DateTime StatusDate { get; set; }
        public string Employee { get; set; }
        public bool Selected { get; set; }
        public string CustomerNote { get; set; }
        public string PawnNote { get; set; }
        public int Active { get; set; }
        public int PaidInt { get; set; }
        public int PickedUp { get; set; }
        public int Floored { get; set; }
        public int MonthsBehind { get; set; }


        public PawnListEntry(string type, int id, DateTime pawndate, string name, string description, decimal amount,
            string location, string currentstatus, DateTime statusdate, string employee)
            :this(type, id, pawndate, 0, DateTime.Parse("1/1/1900"), name, description, amount, location, currentstatus, statusdate, employee, null, null, 0,0,0,0,0)
        { }


        public PawnListEntry(string type, int id, DateTime pawndate, int firstpawnid, DateTime firstpawndate, string name, string description, decimal amount, 
            string location, string currentstatus, DateTime statusdate, string employee, string customernote, string pawnnote,
            int active, int paidint, int pickedup, int floored, int monthsbehind)
        {
            Type = type;
            Id = id;
            PawnDate = pawndate;
            FirstPawnId = firstpawnid;
            FirstPawnDate = firstpawndate;
            Name = name;
            Description = description;
            Amount = amount;
            Location = location;
            CurrentStatus = currentstatus;
            StatusDate = statusdate;
            Employee = employee;
            CustomerNote = customernote;
            PawnNote = pawnnote;
            Active = active;
            PaidInt = paidint;
            PickedUp = pickedup;
            Floored = floored;
            MonthsBehind = monthsbehind;
        }
    }
}
