using System.ComponentModel;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using System.Linq;
using System;
using System.Xml;
using System.Xml.Serialization;
using System.Text;


namespace Shell.Data
{
    [Serializable]
    public class Item : INotifyPropertyChanged
    {

        // Item Fields
        private int itemid;
        [XmlAttribute]
        public int ItemId { get { return itemid; } set { itemid = value; } }

        private int itemtypeid;
        [XmlAttribute]
        public int ItemTypeId { get { return itemtypeid; } set { itemtypeid = value; } }

        [XmlIgnore]
        public string ItemTypeName
        {
            get
            {
                List<ItemType> itemtypes = App.ItemTypes;
                string result = (from t in itemtypes
                                 where t.Id == itemtypeid
                                 select t.Name).First();

                return result;
            }
        }

        private int itemsubtypeid;
        [XmlAttribute]
        public int ItemSubTypeId { get { return itemsubtypeid; } set { itemsubtypeid = value; } }

        [XmlIgnore]
        public string ItemSubTypeName
        {
            get
            {
                List<ItemSubType> itemsubtypes = App.ItemSubTypes;
                string result = (from t in itemsubtypes
                                 where t.ItemTypeId == itemtypeid && t.ItemSubTypeId == itemsubtypeid
                                 select t.Name).First();

                return result;
            }
        }

        private int itemtableid;
        [XmlAttribute]
        public int ItemTableId
        {
            get
            {
                return itemtableid;
            }
            set
            {
                itemtableid = value;
            }
        }

        // Loan Item Fields
        //private int displayorder;
        //[XmlAttribute]
        //public int DisplayOrder
        //{
        //    get { return displayorder; }
        //    set
        //    {
        //        displayorder = value;
        //        OnPropertyChanged(new PropertyChangedEventArgs("DisplayOrder"));
        //    }
        //}


        private decimal amount;
        [XmlAttribute]
        public decimal Amount
        {
            get { return amount; }
            set
            {
                amount = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Amount"));
            }
        }
        [XmlAttribute]
        public string Description { get; set; }

        [XmlAttribute]
        public int GunLogNumber { get; set; }

        // Item Serial Fields
        [XmlAttribute]
        public string Make { get; set; }
        [XmlAttribute]
        public string Model { get; set; }
        [XmlAttribute]
        public string Serial { get; set; }

        // Firearm fields
        [XmlAttribute]
        public string Caliber { get; set; }
        [XmlAttribute]
        public string Action { get; set; }
        [XmlAttribute]
        public string Barrel { get; set; }

        [XmlIgnore]
        public string DisplayFirearmLine
        {
            get
            {
                if (ItemTableId == 3)
                    return "Visible";
                else
                    return "Collapsed";
            }
        }

        [XmlIgnore]
        public string DisplaySerialLine
        {
            get
            {
                if (new int[] { 2, 3 }.Contains(ItemTableId))
                    return "Visible";
                else
                    return "Collapsed";
            }
        }

        [XmlIgnore]
        public DateTime MaxPawnDate { get; set; }

        [XmlIgnore]
        public string ItemText
        {
            get
            {
                StringBuilder sb = new StringBuilder();
                sb.Append(ItemTypeName + ", ");
                sb.Append(ItemSubTypeName + ", ");
                if (Make != "")
                    sb.Append(Make + ", ");
                if (Model != "")
                    sb.Append(Model + ", ");
                if (Serial != "")
                    sb.Append(Serial + ", ");
                if (Caliber != "")
                    sb.Append(Caliber + ", ");
                if (Action != "")
                    sb.Append(Action + ", ");
                if (Barrel != "")
                    sb.Append(Barrel + ", ");
                sb.Append(Description);
                return sb.ToString();
            }
        }

        public Item() { }

        public Item(int itemtypeid, int itemsubtypeid)
        {
            ItemTypeId = itemtypeid;
            ItemSubTypeId = itemsubtypeid;

            List<ItemSubType> itemsubtypes = App.ItemSubTypes;

            ItemTableId = (from t in itemsubtypes
                           where t.ItemTypeId == itemtypeid && t.ItemSubTypeId == itemsubtypeid
                           select t.ItemTableId).First();

        }

        public Item(int itemid, int itemtypeid, int itemsubtypeid, int itemtableid,
            //int displayorder, 
            decimal amount, string description, int? gunlognumber,
            string make, string model, string serial,
            string caliber, string action, string barrel
            )
        {
            ItemId = itemid;
            ItemTypeId = itemtypeid;
            ItemSubTypeId = itemsubtypeid;
            ItemTableId = itemtableid;

            //DisplayOrder = displayorder;
            Amount = amount;
            Description = description;
            GunLogNumber = (gunlognumber > 0)?int.Parse(gunlognumber.ToString()):0;

            Make = make;
            Model = model;
            Serial = serial;

            Caliber = caliber;
            Action = action;
            Barrel = barrel;
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, e);
            }
        }
    }
}
