using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace Shell.Data
{
    public enum PawnTermEnum
    {
        NinetyDays,
        ThreeMonths
    }

    public enum PawnExpireEnum
    {
        AtMidnight,
        TimeBased
    }


    class UserSettings
    {
        private string ticketprintername;
        public string TicketPrinterName { get { return ticketprintername; } set { ticketprintername = value; } }

        private string ticketreportfile;
        public string TicketReportFile { get { return ticketreportfile; } set { ticketreportfile = value; } }

        private string ticketheight;
        public string TicketHeight { get { return ticketheight; } set { ticketheight = value; } }



        private string policeprintername;
        public string PolicePrinterName { get { return policeprintername; } set { policeprintername = value; } }

        private string policereportfile;
        public string PoliceReportFile { get { return policereportfile; } set { policereportfile = value; } }

        private string purchasepolicereportfile;
        public string PurchasePoliceReportFile { get { return purchasepolicereportfile; } set { purchasepolicereportfile = value; } }



        private string labelprintername;
        public string LabelPrinterName { get { return labelprintername; } set { labelprintername = value; } }

        private string labelreportfile;
        public string LabelReportFile { get { return labelreportfile; } set { labelreportfile = value; } }


        private string reportprintername;
        public string ReportPrinterName { get { return reportprintername; } set { reportprintername = value; } }

        private string floorreportfile;
        public string FloorReportFile { get { return floorreportfile; } set { floorreportfile = value; } }



        private string databaseconnection;
        public string DatabaseConnection { get { return databaseconnection; } set { databaseconnection = value; } }

        private int employeetimeout;
        public int EmployeeTimeout { get { return employeetimeout; } set { employeetimeout = value; } }


        private string reportpasswordold;
        public string ReportPasswordOld { get { return reportpasswordold; } set { reportpasswordold = value; } }

        private string reportpasswordnew;
        public string ReportPasswordNew { get { return reportpasswordnew; } set { reportpasswordnew = value; } }


        public UserSettings(
            string ticketprintername, string ticketreportfile, string ticketheight,
            string policeprintername, string policereportfile, string purchasepolicereportfile,
            string labelprintername, string labelreportfile,
            string reportprintername, string floorreportfile,
            string databaseconnection, int employeetimeout)
        {
            TicketPrinterName = ticketprintername;
            TicketReportFile = ticketreportfile;
            TicketHeight = ticketheight;

            PolicePrinterName = policeprintername;
            PoliceReportFile = policereportfile;
            PurchasePoliceReportFile = purchasepolicereportfile;

            LabelPrinterName = labelprintername;
            LabelReportFile = labelreportfile;

            ReportPrinterName = reportprintername;
            FloorReportFile = floorreportfile;

            DatabaseConnection = databaseconnection;
            EmployeeTimeout = employeetimeout;
        }
    }
}
