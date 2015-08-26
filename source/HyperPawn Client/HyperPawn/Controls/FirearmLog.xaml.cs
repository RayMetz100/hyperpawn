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
    /// Interaction logic for FirearmLog.xaml
    /// </summary>
    public partial class FirearmLog : UserControl
    {
        Data.FirearmLogEntry SelectedLogEntry;
        Collection<Data.FirearmLogEntry> log;

        public FirearmLog(int employeeid)
        {
        log = App.HyperPawnDB.FirearmGetLog(null, null, null, null);
            InitializeComponent();
            LogListView.ItemsSource = log;
        }

        private void LogNumberText_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Return)
            {
                try
                {
                    if (LogNumberText.Text == "")
                    {
                        log = App.HyperPawnDB.FirearmGetLog(null, null, null, null);
                        LogListView.ItemsSource = log;
                        return;
                    }
                    int lognumber = Int32.Parse(LogNumberText.Text);
                log = App.HyperPawnDB.FirearmGetLog(lognumber, null, null, null);
                LogListView.ItemsSource = log;
                }
                catch
                {
                    MessageBox.Show("Log number has to be a number");
                }
            }
        }

        private void SerialNumberText_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Return)
            {
                try
                {
                    if (SerialNumberText.Text == "")
                    {
                        log = App.HyperPawnDB.FirearmGetLog(null, null, null, null);
                        LogListView.ItemsSource = log;
                        return;
                    }
                    log = App.HyperPawnDB.FirearmGetLog(null, null, null, SerialNumberText.Text);
                    LogListView.ItemsSource = log;
                }
                catch
                {
                    MessageBox.Show("Serial number error");
                }
            }
        }

        private void ReceiptNameText_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Return)
            {
                try
                {
                    if (ReceiptNameText.Text == "")
                    {
                        log = App.HyperPawnDB.FirearmGetLog(null, null, null, null);
                        LogListView.ItemsSource = log;
                        return;
                    }
                    log = App.HyperPawnDB.FirearmGetLog(null, ReceiptNameText.Text, null, null);
                    LogListView.ItemsSource = log;
                }
                catch
                {
                    MessageBox.Show("Serial number error");
                }
            }
        }

        private void DisppsitionNameText_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Return)
            {
                try
                {
                    if (DisppsitionNameText.Text == "")
                    {
                        log = App.HyperPawnDB.FirearmGetLog(null, null, null, null);
                        LogListView.ItemsSource = log;
                        return;
                    }
                    log = App.HyperPawnDB.FirearmGetLog(null, null, DisppsitionNameText.Text, null);
                    LogListView.ItemsSource = log;
                }
                catch
                {
                    MessageBox.Show("Serial number error");
                }
            }
        }

        private void UpdateLogEntryButton_Click(object sender, RoutedEventArgs e)
        {
            if (LogListView.SelectedItem == null)
            {
                MessageBox.Show("Can't save new entries");
                return; 
            }



            SelectedLogEntry = (Data.FirearmLogEntry)LogListView.SelectedItem;

            try
            {
                App.HyperPawnDB.FirearmAppendLogEntry(SelectedLogEntry);
                MessageBox.Show("Log Entry Saved");
            }
            catch
            {
                MessageBox.Show("Log Entry Failed to Save");
            }
           
        }
    }
}
