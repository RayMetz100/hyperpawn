using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using System.ComponentModel;

namespace Shell.Data
{

    public class PawnStatus
    {
        public char Id { get; set; }
        public string Name { get; set; }

        public PawnStatus() { }

        public PawnStatus(char id, string name)
        {
            Id = id;
            Name = name;
        }
    }

    public class TaxyComboSource
    {
        public int Order { get; set; }
        public string Value { get; set; }
        public int Count { get; set; }

        public TaxyComboSource(int order,string value,int count)
        {
            Order = order;
            Value = value;
            Count = count;
        }
    }

    public class ItemType
    {
        private int id;
        public int Id { get { return id; } set { id = value; } }

        public int DisplayOrder { get; set; }
        public string Name { get; set; }

        public IEnumerable<ItemSubType> SubTypes
        {
            get
            {
                List<ItemSubType> itemsubtypes = App.ItemSubTypes;
                var result = from t in itemsubtypes
                             where t.ItemTypeId == id
                             select t;


                return result;
            }
        }

        public ItemType() { }

        public ItemType(int id) { Id = id; }

        public ItemType(int id, int displayorder, string name)
        {
            Id = id;
            DisplayOrder = displayorder;
            Name = name;
        }
    }

    public class ItemSubType
    {
        public int ItemTypeId { get; set; }
        public int ItemSubTypeId { get; set; }
        public int DisplayOrder { get; set; }
        public string Name { get; set; }
        public int ItemTableId { get; set; }

        public ItemSubType() { }

        public ItemSubType(int itemtypeid, int itemsubtypeid, int displayorder, string name, int itemtableid)
        {
            ItemTypeId = itemtypeid;
            ItemSubTypeId = itemsubtypeid;
            DisplayOrder = displayorder;
            Name = name;
            ItemTableId = itemtableid;
        }
    }

    public class ItemTable
    {
        public int Id { get; set; }
        public string Name { get; set; }

        public ItemTable() { }

        public ItemTable(int id, string name)
        {
            Id = id;
            Name = name;
        }
    }

    public class Employee
    {
        public int Id { get; set; }
        public string Initials { get; set; }
        public string Last { get; set; }
        public string First { get; set; }
        public string Middle { get; set; }
        public string Name { get { return First + " " + Last; } }

        public Employee(int id, string initials, string last, string first, string middle)
        {
            Id = id;
            Initials = initials;
            Last = last;
            First = first;
            Middle = middle;
        }
    }

    public class CurrentEmployee : INotifyPropertyChanged
    {
        private int id;
        public int Id
        {
            get { return id; }
            set
            {
                id = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Id"));
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, e);
        }

    }
}
