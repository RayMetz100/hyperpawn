using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing.Imaging;
using System.Drawing.Printing;
using System.IO;
using System.Text;
using Microsoft.Reporting.WinForms;



namespace Shell
{
    public class PrintSRSReport
    {
        private int _currentPage;
        private IList<MemoryStream> _streams;

        public void PrintPawnTicket(int pawnid)
        {
            LocalReport report = new LocalReport();

            // Set report path (*)
            report.ReportPath = Properties.Settings.Default.TicketReportFile;// @"PawnTicket2005.rdl";

            // Set report parameters (*)
            ReportParameter input1 = new ReportParameter("PawnId", "1");
            report.SetParameters(new ReportParameter[] { input1 });

            // Hook everything up and render the report.
            DataSet data = this.GetPawnReportDataSource(pawnid);
            report.DataSources.Add(new ReportDataSource(report.GetDataSourceNames()[0], data.Tables[0]));

            // Set printer page settings (*)
            string deviceInfo =
              "<DeviceInfo>" +
              "  <OutputFormat>EMF</OutputFormat>" +
              "  <PageWidth>8.5in</PageWidth>" +
              "  <PageHeight>" + Properties.Settings.Default.TicketHeight + "in</PageHeight>" +
              "  <MarginTop>0in</MarginTop>" +
              "  <MarginLeft>0in</MarginLeft>" +
              "  <MarginRight>0in</MarginRight>" +
              "  <MarginBottom>0in</MarginBottom>" +
              "</DeviceInfo>";

            ExportReportToStreams(report, deviceInfo);

            _currentPage = 0;
            Print(Properties.Settings.Default.TicketPrinterName);
            report.Dispose();
            data.Dispose();
        }

        public void PrintPawnPoliceReport(int pawnid)
        {


            LocalReport report = new LocalReport();

            // Set report path (*)
            report.ReportPath = Properties.Settings.Default.PoliceReportFile;

            // Set report parameters (*)
            ReportParameter input1 = new ReportParameter("PawnId", "1");
            report.SetParameters(new ReportParameter[] { input1 });

            // Hook everything up and render the report.
            DataSet data = this.GetPawnReportDataSource(pawnid);
            report.DataSources.Add(new ReportDataSource(report.GetDataSourceNames()[0], data.Tables[0]));

            // Set printer page settings (*)
            string deviceInfo =
              "<DeviceInfo>" +
              "  <OutputFormat>EMF</OutputFormat>" +
              "  <PageWidth>8.5in</PageWidth>" +
              "  <PageHeight>5.5in</PageHeight>" +
              "  <MarginTop>0in</MarginTop>" +
              "  <MarginLeft>0in</MarginLeft>" +
              "  <MarginRight>0in</MarginRight>" +
              "  <MarginBottom>0in</MarginBottom>" +
              "</DeviceInfo>";

            ExportReportToStreams(report, deviceInfo);

            _currentPage = 0;
            Print(Properties.Settings.Default.PolicePrinterName);
            report.Dispose();
            data.Dispose();
        }

        private DataSet GetPawnReportDataSource(int pawnid)
        {
            DataSet results = new DataSet();

            using (SqlConnection connection = new SqlConnection(Properties.Settings.Default.DatabaseConnection))
            using (SqlCommand command = new SqlCommand("GetTicket", connection))
            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
            {
                // Set report parameters here, too (*)
                command.Parameters.Add(new SqlParameter("@PawnId", pawnid));

                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "GetTicket";

                connection.Open();
                dataAdapter.Fill(results);
            }

            return results;
        }

        
        
        public void PrintLabel(char type, int id)
        {


            LocalReport report = new LocalReport();

            // Set report path (*)
            report.ReportPath = Properties.Settings.Default.LabelReportFile;

            // Set report parameters (*)
            ReportParameter input1 = new ReportParameter("Type", "1");
            ReportParameter input2 = new ReportParameter("Id", "1");
            report.SetParameters(new ReportParameter[] { input1, input2 });

            // Hook everything up and render the report.
            DataSet data = this.GetJewelryLabelReportDataSource(type, id);
            report.DataSources.Add(new ReportDataSource(report.GetDataSourceNames()[0], data.Tables[0]));

            // Set printer page settings (*)
            string deviceInfo =
              "<DeviceInfo>" +
              "  <OutputFormat>EMF</OutputFormat>" +
              "  <PageWidth>2.3125in</PageWidth>" +
              "  <PageHeight>4in</PageHeight>" +
              "  <MarginTop>0in</MarginTop>" +
              "  <MarginLeft>0in</MarginLeft>" +
              "  <MarginRight>0in</MarginRight>" +
              "  <MarginBottom>0in</MarginBottom>" +
              "</DeviceInfo>";

            ExportReportToStreams(report, deviceInfo);

            _currentPage = 0;
            Print(Properties.Settings.Default.LabelPrinterName);
            report.Dispose();
            data.Dispose();
        }

        private DataSet GetJewelryLabelReportDataSource(char type, int id)
        {
            DataSet results = new DataSet();

            using (SqlConnection connection = new SqlConnection(Properties.Settings.Default.DatabaseConnection))
            using (SqlCommand command = new SqlCommand("PrintingGetJewelryLabel", connection))
            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
            {
                // Set report parameters here, too (*)
                command.Parameters.Add(new SqlParameter("@Type", type));
                command.Parameters.Add(new SqlParameter("@Id", id));

                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "PrintingGetJewelryLabel";

                connection.Open();
                dataAdapter.Fill(results);
            }

            return results;
        }


        public void PrintFloorReport(string pawnids)
        {
            LocalReport report = new LocalReport();

            // Set report path (*)
            report.ReportPath = Properties.Settings.Default.FloorReportFile;

            // Set report parameters (*)
            ReportParameter input1 = new ReportParameter("PawnIds", "AnyString");
            report.SetParameters(new ReportParameter[] { input1 });

            // Hook everything up and render the report.
            DataSet data = this.GetFloorReportDataSource(pawnids);
            report.DataSources.Add(new ReportDataSource(report.GetDataSourceNames()[0], data.Tables[0]));

            // Set printer page settings (*)
            string deviceInfo =
              "<DeviceInfo>" +
              "  <OutputFormat>EMF</OutputFormat>" +
              "  <PageWidth>8.5in</PageWidth>" +
              "  <PageHeight>11in</PageHeight>" +
              "  <MarginTop>.5in</MarginTop>" +
              "  <MarginLeft>.5in</MarginLeft>" +
              "  <MarginRight>.5in</MarginRight>" +
              "  <MarginBottom>.5in</MarginBottom>" +
              "</DeviceInfo>";

            ExportReportToStreams(report, deviceInfo);

            _currentPage = 0;
            Print(Properties.Settings.Default.ReportPrinterName);
            report.Dispose();
            data.Dispose();
        }

        private DataSet GetFloorReportDataSource(string pawnids)
        {
            DataSet results = new DataSet();

            using (SqlConnection connection = new SqlConnection(Properties.Settings.Default.DatabaseConnection))
            using (SqlCommand command = new SqlCommand("GetFloorReport", connection))
            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
            {
                // Set report parameters here, too (*)
                command.Parameters.Add(new SqlParameter("@PawnIds", pawnids));

                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "GetFloorReport";

                connection.Open();
                dataAdapter.Fill(results);
            }

            return results;
        }


        public void PrintPurchasePoliceReport(int purchaseid)
        {


            LocalReport report = new LocalReport();

            // Set report path (*)
            report.ReportPath = Properties.Settings.Default.PurchasePoliceReportFile;

            // Set report parameters (*)
            ReportParameter input1 = new ReportParameter("PurchaseId", "1");
            report.SetParameters(new ReportParameter[] { input1 });

            // Hook everything up and render the report.
            DataSet data = this.GetPurchaseReportDataSource(purchaseid);
            report.DataSources.Add(new ReportDataSource(report.GetDataSourceNames()[0], data.Tables[0]));

            // Set printer page settings (*)
            string deviceInfo =
              "<DeviceInfo>" +
              "  <OutputFormat>EMF</OutputFormat>" +
              "  <PageWidth>8.5in</PageWidth>" +
              "  <PageHeight>5.5in</PageHeight>" +
              "  <MarginTop>0in</MarginTop>" +
              "  <MarginLeft>0in</MarginLeft>" +
              "  <MarginRight>0in</MarginRight>" +
              "  <MarginBottom>0in</MarginBottom>" +
              "</DeviceInfo>";

            ExportReportToStreams(report, deviceInfo);

            _currentPage = 0;
            Print(Properties.Settings.Default.PolicePrinterName);
            report.Dispose();
            data.Dispose();
        }

        private DataSet GetPurchaseReportDataSource(int purchaseid)
        {
            DataSet results = new DataSet();

            using (SqlConnection connection = new SqlConnection(Properties.Settings.Default.DatabaseConnection))
            using (SqlCommand command = new SqlCommand("PurchaseGetTicket", connection))
            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
            {
                // Set report parameters here, too (*)
                command.Parameters.Add(new SqlParameter("@PurchaseId", purchaseid));

                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "PurchaseGetTicket";

                connection.Open();
                dataAdapter.Fill(results);
            }

            return results;
        }




        private void Print(string PrinterName)
        {
            PrintDocument printDoc = new PrintDocument();

            // Set printer to use (*)
            printDoc.PrinterSettings.PrinterName = PrinterName;

            // Set print margins (*)
            printDoc.DefaultPageSettings.Margins.Top = 0;
            printDoc.DefaultPageSettings.Margins.Left = 0;
            printDoc.DefaultPageSettings.Margins.Right = 0;
            printDoc.DefaultPageSettings.Margins.Bottom = 0;

            if (_streams == null || _streams.Count == 0)
                return;

            if (!printDoc.PrinterSettings.IsValid)
            {
                Console.WriteLine("Printer settings are invalid. Check that the printer exists.");
                return;
            }
            printDoc.PrintPage += new PrintPageEventHandler(PrintPage);
            printDoc.Print();
            printDoc.Dispose();
        }

        private void ExportReportToStreams(LocalReport report, string deviceInfo)
        {
            Warning[] warnings;
            _streams = new List<MemoryStream>();
            report.Render("Image", deviceInfo, CreateStream, out warnings);
            report.Dispose();

            foreach (Stream stream in _streams)
            {
                stream.Position = 0;
            }
        }

        private Stream CreateStream(string name, string fileNameExtension, Encoding encoding,
                                  string mimeType, bool willSeek)
        {
            MemoryStream stream = new MemoryStream();
            //Stream stream = new FileStream(name + "." + fileNameExtension, FileMode.Create);
            _streams.Add(stream);
            return stream;
        }

        private void PrintPage(object sender, PrintPageEventArgs ev)
        {
            Metafile pageImage = new Metafile(_streams[_currentPage]);
            ev.Graphics.DrawImage(pageImage, ev.PageBounds);

            _currentPage++;
            ev.HasMorePages = (_currentPage < _streams.Count);
        }
    }
}
