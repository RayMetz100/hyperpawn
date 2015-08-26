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
using System.Data;

namespace Shell.Reports.Controls
{
    /// <summary>
    /// Interaction logic for SearchItems.xaml
    /// </summary>
    public partial class CopyDailyTransactions : UserControl
    {

        public CopyDailyTransactions()
        {
            InitializeComponent();
        }

        private void CopyDataToClipboard()
        {
            DateTime StartDate;
            DateTime EndDate;

            try
            {
                StartDate = DateTime.Parse(CopyTxDateTextbox.Text);

            }
            catch(Exception Ex)
            {
                MessageBox.Show(Ex.Message);
                return;
            }
            
            

            EndDate = StartDate;

            DataTable SQLDataTable;
            SQLDataTable = App.HyperPawnDB.GetSQLDailyTransactionData(StartDate, EndDate);

            StringBuilder DataBuilder;
            DataBuilder = FormatData(SQLDataTable);

            Clipboard.SetDataObject(DataBuilder.ToString(), true);
        }

        private void CopyButton_Click(object sender, RoutedEventArgs e)
        {
            CopyDataToClipboard();
        }

        private void CopyTxDateTextbox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                CopyDataToClipboard();
        }

        #region FormatData
        /// <summary>
        /// Format the data in the datatable in the format that is expected to be copied in the clipboard
        /// </summary>
        /// <param name="dataTableObject">DataTable</param>
        /// <returns>StringBuilder</returns>

        public StringBuilder FormatData(DataTable dataTableObject)
        {
            StringBuilder DataObjectBuilder = new StringBuilder();

            foreach (DataRow dataRowObject in dataTableObject.Rows)
            {
                for (int intColIndex = 0; intColIndex < dataTableObject.Columns.Count; intColIndex++)
                {
                    if (intColIndex > 0)
                        DataObjectBuilder.Append("\t");
                    DataObjectBuilder.Append(dataRowObject[intColIndex].ToString());
                }
                DataObjectBuilder.Append(Environment.NewLine);
            }

            return DataObjectBuilder;
        }

        #endregion




    }
}
