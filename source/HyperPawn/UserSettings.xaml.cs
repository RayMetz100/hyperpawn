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
using System.Windows.Shapes;
using System.IO;
using System.Xml;

namespace Shell
{
    /// <summary>
    /// Interaction logic for UserSettings.xaml
    /// </summary>
    public partial class UserSettings : Window
    {
        Data.UserSettings usersettings;

        public UserSettings()
        {
            InitializeComponent();
            usersettings = new Shell.Data.UserSettings(
                Properties.Settings.Default.TicketPrinterName,
                Properties.Settings.Default.TicketReportFile,
                Properties.Settings.Default.TicketHeight,

                Properties.Settings.Default.PolicePrinterName,
                Properties.Settings.Default.PoliceReportFile,
                Properties.Settings.Default.PurchasePoliceReportFile,

                Properties.Settings.Default.LabelPrinterName,
                Properties.Settings.Default.LabelReportFile,

                Properties.Settings.Default.ReportPrinterName,
                Properties.Settings.Default.FloorReportFile,

                Properties.Settings.Default.DatabaseConnection,
                Properties.Settings.Default.EmployeeTimeout
                
                );
            UserSettingsGrid.DataContext = usersettings;
        }

        void SaveSettings_Click(object sender, RoutedEventArgs e)
        {
            Properties.Settings.Default.TicketPrinterName = usersettings.TicketPrinterName;
            Properties.Settings.Default.TicketReportFile = usersettings.TicketReportFile;
            Properties.Settings.Default.TicketHeight = usersettings.TicketHeight;

            Properties.Settings.Default.PolicePrinterName = usersettings.PolicePrinterName;
            Properties.Settings.Default.PoliceReportFile = usersettings.PoliceReportFile;
            Properties.Settings.Default.PurchasePoliceReportFile = usersettings.PurchasePoliceReportFile;

            Properties.Settings.Default.LabelPrinterName = usersettings.LabelPrinterName;
            Properties.Settings.Default.LabelReportFile = usersettings.LabelReportFile;

            Properties.Settings.Default.ReportPrinterName = usersettings.ReportPrinterName;
            Properties.Settings.Default.FloorReportFile = usersettings.FloorReportFile;

            Properties.Settings.Default.DatabaseConnection = usersettings.DatabaseConnection;
            Properties.Settings.Default.EmployeeTimeout = usersettings.EmployeeTimeout;
            Properties.Settings.Default.Save();

            if (usersettings.ReportPasswordNew != null)
            {
                App.HyperPawnDB.SettingMaintain("ReportPassword", null, false, usersettings.ReportPasswordOld, usersettings.ReportPasswordNew);
            }

            Close();
        }

        private void LeadsOnlineButton_Click(object sender, RoutedEventArgs e)
        {
            DateTime start;
            DateTime end;
            XmlDocument doc;
            if (DateTime.TryParse(LeadsOnlineStartTextbox.Text, out start) && DateTime.TryParse(LeadsOnlineEndTextbox.Text, out end))
            {
                //FileStream fs = new FileStream("LeadsOnline.xml", FileMode.Create);
                doc = App.HyperPawnDB.LeadsOnlineGet(start, end);
                XmlWriterSettings writersettings = new XmlWriterSettings();
                writersettings.Encoding = Encoding.UTF8;
                XmlWriter writer = XmlWriter.Create("LeadsOnline.xml",writersettings);
                
                doc.Save(writer);
            }
        }
    }
}
