using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Text;
using System.Xml;


namespace Shell.Data
{
    public class Purchase : INotifyPropertyChanged
    {
        public decimal Amount { get; set; }
        
        public int PurchaseId { get; set; }

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

        //public bool IsPurchase { get; set; }
        public string Location { get; set; }

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

        public Purchase()
        {
            Customer = new Party();
            Items = new ObservableCollection<Item>();
            Date = DateTime.Now;
        }

        public Purchase(int purchaseid, 
            DateTime date, string location, 
            string itemdescriptionticket, decimal amount,
            int numberoffirearms)
        {
            PurchaseId = purchaseid;
            Amount = amount;
            Date = date;            
            Location = location;
            ItemDescriptionTicket = itemdescriptionticket;
            NumberOfFirearms = numberoffirearms;
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, e);
        }

    }
}
