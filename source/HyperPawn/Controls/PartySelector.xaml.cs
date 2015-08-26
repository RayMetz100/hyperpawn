using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Threading;
using System;

namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for PartySelector.xaml
    /// </summary>
    public partial class PartySelector : UserControl
    {
        Collection<Data.Party> parties;

        public delegate void idHandler(int i);

        public event idHandler PartySelected;
        //public event idHandler PawnSelected;

        public PartySelector()
        {
            InitializeComponent();
        }

        void PartiesListView_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            DependencyObject dep = e.OriginalSource as DependencyObject;
            dep = VisualTreeHelper.GetParent(dep);
            if (dep is GridViewRowPresenter)
            {
                int partyid = ((Data.Party)((GridViewRowPresenter)dep).Content).PartyId;
                PartySelected(partyid);
            }
            else
            {
                if (dep is ListViewItem)
                {
                    PartySelected(((Data.Party)((ListViewItem)dep).Content).PartyId);
                }
                else
                {
                    MessageBox.Show("Please double-click on data rather than blank space");
                }
            }
        }

        private void SearchText_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                int pawnid;
                if (Int32.TryParse(PawnNumberText.Text, out pawnid))
                {
                    Search("", "", pawnid);
                }
                else
                {
                    Search(LastNameText.Text, FirstNameText.Text, 0);
                    PartiesListView.MouseDoubleClick += new MouseButtonEventHandler(PartiesListView_MouseDoubleClick);
                }
            }
        }


        private void Search(string last, string first, int pawnid)
        {
            
            last = last + "%";
            first = first + "%";

            if (pawnid == 0)
            {
                try
                {
                    parties = App.HyperPawnDB.PartySearch(last, first, ref pawnid);
                }
                catch
                {
                    MessageBox.Show("PartySearch error");
                }
                PartiesListView.ItemsSource = parties;
            }
            else
            {
                int pawntocustomerid = pawnid;
                try
                {
                    parties = App.HyperPawnDB.PartySearch(last, first, ref pawntocustomerid);
                }
                catch
                {
                    MessageBox.Show("PartySearch error");
                }
                int customerid = pawntocustomerid;
                if (customerid > 0)
                    PartySelected(customerid);
            }

        }

        private void NewCustomer_Click(object sender, RoutedEventArgs e)
        {
            PartySelected(0);
        }


        //int FirstTime = 0;
        //int LastTime = 0;
        

        private void BarcodeText_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                String s = "";
                try
                {
                    s = BarcodeText.Text.Substring(0, 12);
                    Data.Party p = new Data.Party();
                    p = App.HyperPawnDB.PartySearchById(s);

                    if (p != null)
                    {
                        PartySelected(p.PartyId);
                    }
                    if (p == null)
                    {
                        PartySelected(0);
                    }
                }
                catch (Exception)
                {
                    MessageBox.Show("Can't read barcode");
                }




                BarcodeText.Text = null;
            }
        }
    }
}
