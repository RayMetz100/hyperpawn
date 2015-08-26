using System;
using System.ComponentModel;


namespace Shell.Data
{
    public class Party : INotifyPropertyChanged
    {
        public int PartyId { get; set; }

        public string IntegrationId { get; set; }

        private string idnumber;
        public string IDNumber
        {
            get { return idnumber; }
            set
            {
                idnumber = value;
                OnPropertyChanged(new PropertyChangedEventArgs("IDNumber"));
            }
        }
        private DateTime? idexpiration;
        public DateTime? IdExpiration
        {
            get { return idexpiration; }
            set
            {
                idexpiration = value;
                OnPropertyChanged(new PropertyChangedEventArgs("IdExpiration"));
            }
        }
        private DateTime? dateofbirth;
        public DateTime? DateOfBirth
        {
            get { return dateofbirth; }
            set
            {
                dateofbirth = value;
                OnPropertyChanged(new PropertyChangedEventArgs("DateOfBirth"));
            }
        }

        public int? Age
        {
            get
            {
                return (dateofbirth == null) ? (int?)null : (DateTime.Now - dateofbirth).Value.Days / 365;
            }
        }

        private string last;
        public string Last
        {
            get { return last; }
            set
            {
                last = value;
                OnPropertyChanged(new PropertyChangedEventArgs("LastName"));
            }
        }
        private string first;
        public string First
        {
            get { return first; }
            set
            {
                first = value;
                OnPropertyChanged(new PropertyChangedEventArgs("FirstName"));
            }
        }
        private string middle;
        public string Middle
        {
            get { return middle; }
            set
            {
                middle = value;
                OnPropertyChanged(new PropertyChangedEventArgs("MiddleName"));
            }
        }

        private string street;
        public string Street
        {
            get { return street; }
            set
            {
                street = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Street"));
            }
        }
        private string city;
        public string City
        {
            get { return city; }
            set
            {
                city = value;
                OnPropertyChanged(new PropertyChangedEventArgs("City"));
            }
        }
        private string state;
        public string State
        {
            get { return state; }
            set
            {
                state = value;
                OnPropertyChanged(new PropertyChangedEventArgs("State"));
            }
        }
        private string zip;
        public string Zip
        {
            get { return zip; }
            set
            {
                zip = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Zip"));
            }
        }

        private string sex;
        public string Sex
        {
            get { return sex; }
            set
            {
                sex = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Sex"));
            }
        }
        private string height;
        public string Height
        {
            get { return height; }
            set
            {
                height = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Height"));
            }
        }
        private string weight;
        public string Weight
        {
            get { return weight; }
            set
            {
                weight = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Weight"));
            }
        }
        private string eyes;
        public string Eyes
        {
            get { return eyes; }
            set
            {
                eyes = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Eyes"));
            }
        }
        private string race;
        public string Race
        {
            get { return race; }
            set
            {
                race = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Race"));
            }
        }
        private string hair;
        public string Hair
        {
            get { return hair; }
            set
            {
                hair = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Hair"));
            }
        }

        private string phone;
        public string Phone
        {
            get { return phone; }
            set
            {
                phone = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Phone"));
            }
        }
        private string email;
        public string Email
        {
            get { return email; }
            set
            {
                email = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Email"));
            }
        }
        private string note;
        public string Note
        {
            get { return note; }
            set
            {
                note = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Note"));
            }
        }

        public int ActivePawns { get; set; }
        public int TotalPawns { get; set; }
        public int ItemsAvailable { get; set; }

        public Party() { }
        public Party(int partyid,
            string idnumber, DateTime? dateofbirth,
            string lastname, string firstname,
            string city, int activeloans, int totalloans, int itemsavailable)
            : this(partyid, idnumber, null, dateofbirth, lastname, firstname, null, null, city, null, null, null, null, null, null, null, null, null, null, null, activeloans, totalloans, itemsavailable, null) { }
        public Party(int partyid, 
            string idnumber, DateTime? idexpiration, DateTime? dateofbirth, 
            string lastname, string firstname, string middlename,
            string street, string city, string state, string zip,
            string sex, string height, string weight, string eyes, string race, string hair,
            string phone, string email, string note, 
            int activepawns, int totalpawns, int itemsavailable, string integrationid)
        {
            PartyId = partyid;

            IDNumber = idnumber;
            IdExpiration = idexpiration;
            DateOfBirth = dateofbirth;

            Last = lastname;
            First = firstname;
            Middle = middlename;

            Street = street;
            City = city;
            State = state;
            Zip = zip;

            Sex = sex;
            Height = height;
            Weight = weight;
            Eyes = eyes;
            Race = race;
            Hair = hair;

            Phone = phone;
            Email = email;
            Note = note;

            ActivePawns = activepawns;
            TotalPawns = totalpawns;
            ItemsAvailable = itemsavailable;

            IntegrationId = integrationid;
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, e);
        }
    }
}
