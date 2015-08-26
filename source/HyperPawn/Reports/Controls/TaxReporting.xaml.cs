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

namespace Shell.Reports.Controls
{
    /// <summary>
    /// Interaction logic for TaxReporting.xaml
    /// </summary>
    public partial class TaxReporting : UserControl
    {
        List<Data.TaxTotal> taxtotals;

        public TaxReporting()
        {
            InitializeComponent();
        }

        private void GetReportButton_Click(object sender, RoutedEventArgs e)
        {
            GetReport();

        }

        private void GetReport()
        {
            DateTime start;
            DateTime end;

            try
            {
                start = DateTime.Parse(StartDateTextBox.Text);
                end = DateTime.Parse(EndDateTextBox.Text);
            }
            catch
            {
                MessageBox.Show("Please Enter Valid Dates and try again");
                return;
            }
            taxtotals = App.HyperPawnDB.TotalsGetTaxTotals(start, end);
            myListView.ItemsSource = taxtotals;
        }

        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                GetReport();
        }
    }
}
