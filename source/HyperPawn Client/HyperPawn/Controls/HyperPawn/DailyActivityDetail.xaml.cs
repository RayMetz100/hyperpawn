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

namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for PutAwayControl.xaml
    /// </summary>
    public partial class DailyActivityDetail : Window
    {
        Collection<Data.PawnListEntry> rows = new Collection<Shell.Data.PawnListEntry>();
        //int Employee;

        public DailyActivityDetail()
        {
            InitializeComponent();
            DateTextBox.Focus();
        }

        private void RunButton_Click(object sender, RoutedEventArgs e)
        {
            FillView();
        }

        private void FillView()
        {
            DateTime day;
            if (DateTime.TryParse(DateTextBox.Text, out day))
            {
                rows = App.HyperPawnDB.TotalsGetDayDetail(day);
                myListView.ItemsSource = null;
                myListView.ItemsSource = rows;
            }
            else
            {
                MessageBox.Show("Invalid date");
            }
        }

        private void DateTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                FillView();
        }

        //private void CloseButton_Click(object sender, RoutedEventArgs e)
        //{
        //    Close();
        //}

        //private void myListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        //{
        //    MessageBox.Show("he");
        //}

        //private void LocationTextBox_LostFocus(object sender, RoutedEventArgs e)
        //{
        //    DependencyObject 
        //    MessageBox.Show(((TextBox)e.OriginalSource).Text);
        //}
    }
}
