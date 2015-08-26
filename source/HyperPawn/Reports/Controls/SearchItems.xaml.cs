using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Collections.ObjectModel;

namespace Shell.Reports.Controls
{
    /// <summary>
    /// Interaction logic for SearchItems.xaml
    /// </summary>
    public partial class SearchItems : UserControl
    {
        Collection<Data.PawnListEntry> pawns = new Collection<Shell.Data.PawnListEntry>();

        public SearchItems()
        {
            InitializeComponent();
        }

        private void Search()
        {
            myListView.ItemsSource = null;
            pawns = App.HyperPawnDB.ReportSearchItems(SearchStringTextbox.Text, null);
            myListView.ItemsSource = pawns;
        }

        private void SearchButton_Click(object sender, RoutedEventArgs e)
        {
            Search();
        }

        private void SearchStringTextbox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                Search();
        }
    }
}
