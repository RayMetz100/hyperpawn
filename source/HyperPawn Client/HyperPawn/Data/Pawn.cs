using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.Windows.Forms;
using System.Linq;


namespace Shell.Data
{
    public class Pawn : INotifyPropertyChanged
    {
        public decimal? InterestReceived { get; set; }
        public decimal Amount { get; set; }
        
        public int PawnId { get; set; }

        private int firstpawnid;
        public int FirstPawnId
        {
            get
            {
                return firstpawnid;
            }
            set
            {
                firstpawnid = value;
            }
        }

        public int? FirstPawnIdNullable
        {
            get
            {
                return (firstpawnid== PawnId) ? (int?)null : firstpawnid;
            }
            set
            {
                return;
            }
        }

        private DateTime date;
        public DateTime Date
        {
            get { return date; }
            set
            {
                date = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Date"));
            }
        }
        
        private DateTime firstpawndate;
        public DateTime FirstPawnDate
        {
            get
            {
                return firstpawndate;
            }
            set
            {
                firstpawndate = value;
            }
        }
        public DateTime? FirstPawnDateNullable
        {
            get
            {
                return (firstpawndate == Date) ? (DateTime?)null : firstpawndate;
            }
            set
            {
                return;
            }
        }

        //public bool IsPurchase { get; set; }
        private string location;
        public string Location { get { return location; } set { location = value; } }

        public string RedeemLocation
        {
            get
            {
                ;

                return location + " (" + FirstPawnIdNullable.ToString() + ") (" + firstpawndate.ToString("d") + ")";
            }
        }

        private char pawnstatusid;
        public char PawnStatusId { get { return pawnstatusid; } set { pawnstatusid = value; } }

        public string PawnStatus
        {
            get
            {
                var x = from PawnStatus s in App.PawnStatus
                        where s.Id == pawnstatusid
                        select s.Name;
                string r = x.First();
                if (r != null)
                    return r;
                else
                    return "error";
            }
        }

        private DateTime? pawnstatusdate;
        public DateTime? PawnStatusDate { get { return pawnstatusdate; } set { pawnstatusdate = value; } }

        private Party customer;
        public Party Customer
        {
            get { return customer; }
            set
            {
                customer = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Customer"));
            }
        }

        public string ItemDescriptionTicket { get; set; }
        public string PawnNote { get; set; }
        public string PawnNoteVisibility { get { return (PawnNote == "") ? "Collapsed" : "Visible"; } }

        public string PickupCost { get; set; }
        public string RenewCost { get; set; }
        public string By30 { get; set; }
        public string By60 { get; set; }
        public string By90 { get; set; }

        private ObservableCollection<Item> items;
        public ObservableCollection<Item> Items
        {
            get { return items; }
            set
            {
                items = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Items"));
            }
        }

        public int NumberOfFirearms { get; set; }

        public string ItemsXml
        {
            get
            {
                Utils.XMLUtils xmlutil = new Shell.Utils.XMLUtils();
                string s = xmlutil.ObjectToXMLString(items);
                return s;
            }
        }

        public string ItemsText
        {
            get
            {
                StringBuilder sb = new StringBuilder();
                foreach (Item i in items)
                {
                    sb.AppendLine(
                        i.ItemTypeId + " " +
                        i.ItemSubTypeId + " " +
                        i.Make + " " +
                        i.Model + " " +
                        i.Caliber + " " +
                        i.Action + " " +
                        i.Description + " " +
                        i.Amount + " " +
                        "");
                }
                return sb.ToString();
            }
        }

        public Pawn()
        {
            Customer = new Party();

            Items = new ObservableCollection<Item>();

            Date = DateTime.Now;
            PawnStatusId = 'A';
        }

        public Pawn(int pawnid, DateTime date, 
            int firstpawnid, DateTime firstpawndate,
            string location, 
            Char pawnstatusid, DateTime? pawnstatusdate, decimal? interestreceived, 
            string itemdescriptionticket, decimal amount,
            int numberoffirearms,
            string pawnnote)
        {
            PawnId = pawnid;
            Date = date;
            FirstPawnId = firstpawnid;
            FirstPawnDate = firstpawndate;
            Amount = amount;
            
            Location = location;

            PawnStatusId = pawnstatusid;
            PawnStatusDate = pawnstatusdate;
            InterestReceived = interestreceived;
            //ObservableCollection<Item> items = new ObservableCollection<Item>();
            //Items = items;
            ItemDescriptionTicket = itemdescriptionticket;
            NumberOfFirearms = numberoffirearms;
            PawnNote = pawnnote;
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, e);
        }

    }
}
