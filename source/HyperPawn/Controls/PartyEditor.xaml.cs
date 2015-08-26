using System.Windows.Controls;
using System.Windows;
using System.Windows.Threading;
using System;
using System.Windows.Media;

namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for PartyDetails.xaml
    /// </summary>
    public partial class PartyEditor : UserControl
    {
        Data.Party party;
        int Employee = 0;

        DispatcherTimer saveindicatortimer = new DispatcherTimer();

        //event definition
        public static readonly RoutedEvent PartySavedEvent;

        //event registration
        static PartyEditor()
        {
            PartyEditor.PartySavedEvent = EventManager.RegisterRoutedEvent("PartySaved", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
        }

        // The Traditional Event wrapper.
        //public event RoutedEventHandler PartySaved
        //{
        //    add
        //    {
        //        base.AddHandler(PartyEditor.PartySavedEvent, value);
        //    }
        //    remove
        //    {
        //        base.RemoveHandler(PartyEditor.PartySavedEvent, value);
        //    }
        //}

        

        public PartyEditor(int partyid, int employee)
        {
            saveindicatortimer.Interval = new TimeSpan(0, 0, 1);
            saveindicatortimer.Tick += new EventHandler(saveindicatortimer_Tick);

            Employee = employee;
            InitializeComponent();

            CityComboBox.ItemsSource = App.TaxyCities;
            RaceComboBox.ItemsSource = App.TaxyRaces;
            HairComboBox.ItemsSource = App.TaxyHairColors;
            EyesComboBox.ItemsSource = App.TaxyEyeColors;

            if (partyid != 0)
            {
                try
                {
                    party = App.HyperPawnDB.PartyGetDetails(partyid);
                }
                catch
                {
                    MessageBox.Show("PartyGetDetails stored procedure failure");
                }
            }
            else
            {
                party = new Shell.Data.Party();
            }
            DataContext = party;
        }

        private void SaveCustomer_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            saveindicatortimer.Stop();
            try
            {
                int partyid = App.HyperPawnDB.PartySave(party, Employee);
                SaveCustomer.Content = "Saved";
                saveindicatortimer.Start();
                RoutedEventArgs PartySavedArgs = new RoutedEventArgs(PartyEditor.PartySavedEvent, partyid);
                base.RaiseEvent(PartySavedArgs);
            }
            catch
            {
                SaveCustomer.Content = "Error! Not Saved!";
                saveindicatortimer.Start();
            }
        }

        void saveindicatortimer_Tick(object sender, EventArgs e)
        {
            saveindicatortimer.Stop();
            SaveCustomer.Content = "Save Customer";
        }

        private void ProcessBarcodeButton_Click(object sender, RoutedEventArgs e)
        {
            int StartPosition = 0;
            try
            {
                getNextBarcodeValue("DAA", ref StartPosition);

                party.Last = getNextBarcodeValue(",", ref StartPosition);
                LastName.Text = party.Last;

                party.First = getNextBarcodeValue(",", ref StartPosition);
                FirstName.Text = party.First;

                party.Middle = getNextBarcodeValue("DAG", ref StartPosition);
                MiddleName.Text = party.Middle;

                party.Street = getNextBarcodeValue("DAI", ref StartPosition);
                Street.Text = party.Street;

                party.City = getNextBarcodeValue("DAJ", ref StartPosition);
                CityComboBox.Text = party.City;

                party.State = getNextBarcodeValue("DAK", ref StartPosition);
                State.Text = party.State;

                party.Zip = (getNextBarcodeValue("DAQ", ref StartPosition)).Trim();
                Zip.Text = party.Zip;

                party.IDNumber = getNextBarcodeValue("DAR", ref StartPosition);
                IDNumber.Text = party.IDNumber;

                getNextBarcodeValue("DAS", ref StartPosition);
                getNextBarcodeValue("DAT", ref StartPosition);
                getNextBarcodeValue("DBA", ref StartPosition);

                party.IdExpiration = DateTime.Parse(getNextBarcodeValue("DBB", ref StartPosition).Insert(4, "-").Insert(7, "-"));
                IdExpiration.Text = party.IdExpiration.ToString();

                party.DateOfBirth = DateTime.Parse(getNextBarcodeValue("DBC", ref StartPosition).Insert(4, "-").Insert(7, "-"));
                DateOfBirth.Text = party.DateOfBirth.ToString();

                string intSex = getNextBarcodeValue("DBD", ref StartPosition);
                if (intSex == "1")
                {
                    party.Sex = "M";
                    Sex.Text = "M";
                }
                if (intSex == "2")
                {
                    party.Sex = "F";
                    Sex.Text = "F";
                }
                getNextBarcodeValue("DAU", ref StartPosition);

                party.Height = getNextBarcodeValue("DAW", ref StartPosition);
                HeightText.Text = party.Height;

                party.Weight = getNextBarcodeValue("DAY", ref StartPosition);
                Weight.Text = party.Weight;

                party.Eyes = getNextBarcodeValue("DAL", ref StartPosition);
                EyesComboBox.Text = party.Eyes;

            }
            catch (Exception)
            {
                MessageBox.Show("Unable to read this barcode");
            }
            BarcodeTextbox.Text = null;

            
        }

        private string getNextBarcodeValue(string delimiter, ref int StartPosition)
        {
            string value;
            int NextDelimiterLocation;
            NextDelimiterLocation = BarcodeTextbox.Text.IndexOf(delimiter, StartPosition);
            value = BarcodeTextbox.Text.Substring(StartPosition, NextDelimiterLocation - StartPosition);
            StartPosition = NextDelimiterLocation + delimiter.Length;
            return value;
        }

    }
}
