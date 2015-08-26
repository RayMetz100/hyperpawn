using System.Windows;
using System.Windows.Controls;
using System.Collections.ObjectModel;

namespace Shell.Controls.HyperSale
{
    /// <summary>
    /// Interaction logic for HyperSale.xaml
    /// </summary>
    public partial class HyperSale : UserControl
    {
        Collection<Data.AccountTransaction> accounttransactions = new Collection<Data.AccountTransaction>();

        public HyperSale()
        {
            InitializeComponent();
        }

        private void GoButton_Click(object sender, RoutedEventArgs e)
        {
        }

        private void DateSelectionCalendar_SelectedDatesChanged(object sender, SelectionChangedEventArgs e)
        {
            SaveTransactions();
            accounttransactions = App.HyperPawnDB.AccountTransactionsGet(DateSelectionCalendar.SelectedDate, DateSelectionCalendar.SelectedDate);

            TestDataGrid.ItemsSource = accounttransactions;

        }

        private void SaveTransactions()
        {
            App.HyperPawnDB.AccountTransactionsSave(accounttransactions);
        }
    }
}
