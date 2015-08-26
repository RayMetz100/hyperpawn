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

namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for ReportsControl.xaml
    /// </summary>
    public partial class ReportsControl : UserControl
    {
        int CurrentEmployee;

        public ReportsControl(int currentemployee)
        {
            CurrentEmployee = currentemployee;
            InitializeComponent();
        }

        private void SearchItemsButton_Click(object sender, RoutedEventArgs e)
        {
            Shell.Reports.Controls.SearchItems searchitems = new Shell.Reports.Controls.SearchItems();
            ReportContent.Content = searchitems;
        }

        private void ShowFloorListButton_Click(object sender, RoutedEventArgs e)
        {
            if (App.HyperPawnDB.ReportValidatePassword(ReportPasswordTextbox.Text) == true)
            {
                ReportPasswordTextbox.Visibility = System.Windows.Visibility.Hidden;
                FloorList floorlist = new FloorList(CurrentEmployee);
                ReportContent.Content = floorlist;
            }
            else
            {
                ReportPasswordTextbox.Text = null;
            }
        }

        private void ShowAmountLoanedOutButton_Click(object sender, RoutedEventArgs e)
        {
            if (App.HyperPawnDB.ReportValidatePassword(ReportPasswordTextbox.Text) == true)
            {
                ReportPasswordTextbox.Visibility = System.Windows.Visibility.Hidden;
                MessageBox.Show(App.HyperPawnDB.TotalsGetAmountLoanedOut().ToString("C2"));
            }
            else
            {
                ReportPasswordTextbox.Text = null;
            }
        }

        private void TaxReportingButton_Click(object sender, RoutedEventArgs e)
        {
            if (App.HyperPawnDB.ReportValidatePassword(ReportPasswordTextbox.Text) == true)
            {
                ReportPasswordTextbox.Visibility = System.Windows.Visibility.Hidden;
                Shell.Reports.Controls.TaxReporting taxreporting = new Shell.Reports.Controls.TaxReporting();
                ReportContent.Content = taxreporting;
            }
            else
            {
                ReportPasswordTextbox.Text = null;
            }
        }

        private void CopyDayTxButton_Click(object sender, RoutedEventArgs e)
        {
            Shell.Reports.Controls.CopyDailyTransactions copyDailyTransactions = new Shell.Reports.Controls.CopyDailyTransactions();
            ReportContent.Content = copyDailyTransactions;
        }

    }
}
