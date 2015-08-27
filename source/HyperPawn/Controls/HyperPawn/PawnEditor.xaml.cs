using System.Windows;
using System.Linq;
//using System.Drawing;
using System.Windows.Media;
using System;
using System.Windows.Controls;


namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for NewLoanOrPurchase.xaml
    /// </summary>
    public partial class PawnEditor : UserControl
    {
        int employee;
        Data.Pawn pawn;
        Controls.ItemSelector itemselector;

        public static readonly RoutedEvent PawnSavedEvent;
        public static readonly RoutedEvent PawnSaveAndCloseEvent;

        static PawnEditor()
        {
            PawnEditor.PawnSavedEvent = EventManager.RegisterRoutedEvent("PawnSaved", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
            PawnEditor.PawnSaveAndCloseEvent = EventManager.RegisterRoutedEvent("PawnSaveAndClose", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
        }

        public PawnEditor(int partyid, int employeeid)
        {
            this.employee = employeeid;
            InitializeComponent();

            // assign pawn with party
            pawn = new Data.Pawn();
            pawn.Customer.PartyId = partyid;


            InitializeFields();
        }

        private void ResetToDoAnother()
        {
            // assign new pawn with party
            int partyid = pawn.Customer.PartyId;
            pawn = new Data.Pawn();
            pawn.Customer.PartyId = partyid;

            InitializeFields();
        }

        public PawnEditor(int pawnid, string action, int employee)
        {
            // before we start
            this.employee = employee;
            InitializeComponent();

            // assign pawn with party
            pawn = App.HyperPawnDB.PawnGetDetails(pawnid);

            InitializeFields();
        }

        private void InitializeFields()
        {
            LoanStackPanel.DataContext = pawn;
            PawnStatusComboBox.ItemsSource = App.PawnStatus;
            UpdatePrintPreview();
            itemselector = new Controls.ItemSelector(pawn);
            ItemsContentControl.Content = itemselector;
            itemselector.itemsupdated += new Shell.Controls.ItemSelector.ItemsUpdated(itemselector_itemsupdated);
            UpdatePrintPreview();
        }

        void itemselector_itemsupdated(System.Collections.ObjectModel.ObservableCollection<Shell.Data.Item> pawnitems)
        {
            pawn.Items = pawnitems;
            UpdatePrintPreview();
        }

        /* Loan Section */

        //LoanNumber.GetBindingExpression(TextBox.TextProperty).UpdateTarget();

        private void Print(bool withoutpolicereport)
        {
            PrintSRSReport printer = new PrintSRSReport();
            try
            {
                printer.PrintPawnTicket(pawn.PawnId);
                if (withoutpolicereport == false)
                    printer.PrintPawnPoliceReport(pawn.PawnId);

                int numberOfJewelryItems = (from Data.Item i in pawn.Items
                                            where i.ItemTypeId == 1
                                            select i).Count();

                if (numberOfJewelryItems > 0 && Properties.Settings.Default.LabelReportFile.Length > 1)
                    printer.PrintLabel('P', pawn.PawnId);

            }
            catch (Exception Ex)
            {
                MessageBox.Show("Print Failed: " + Ex.Message);
            }
        }

        private bool PawnIsValid()
        {

            var results = from Data.Item i in pawn.Items
                          where i.Amount <= 0
                          select i;

            foreach (var result in results)
            {
                return false;
            }

            if (pawn.Items.Count > 0)
                return true;
            else
                return false;
        }

        private bool SavePawn()
        {
            try
            {
                pawn.PawnId = App.HyperPawnDB.PawnSave(pawn,employee);
                return true;
            }
            catch (Exception Ex)
            {
                MessageBox.Show("Error: Pawn did not save.  \n\n"+Ex.Message);
                return false;
            }
        }

        private void PreSavePawn()
        {
            pawn.Items = itemselector.PawnItems;
        }

        private void PrintAndDoMoreButton_Click(object sender, RoutedEventArgs e)
        {
            PrintAndDoMore(false);
        }

        private void PrintAndDoMoreWithoutPoliceReportButton_Click(object sender, RoutedEventArgs e)
        {
            PrintAndDoMore(true);
        }

        private void PrintAndDoMore(bool withoutpolicereport)
        {
            PreSavePawn();
            if (PawnIsValid())
            {
                bool saved = SavePawn();
                if (saved)
                {
                    Print(withoutpolicereport);
                    ResetToDoAnother();
                }
            }
            else
            {
                MessageBox.Show("Loan Failed Validation.  Please Correct and try again.");
            }
        }

        private void PrintAndClose_Click(object sender, RoutedEventArgs e)
        {
            PreSavePawn();
            if (PawnIsValid())
            {
                bool saved = SavePawn();
                if (saved)
                {
                    Print(false);
                    RoutedEventArgs PawnSavedArgs = new RoutedEventArgs(PawnEditor.PawnSavedEvent, this);
                    base.RaiseEvent(PawnSavedArgs);
                }
            }
            else
            {
                MessageBox.Show("Loan Failed Validation.  Please Correct and try again.");
            }
        }

        private void SavePrintAndCloseWithoutPoliceReport_Click(object sender, RoutedEventArgs e)
        {
            PreSavePawn();
            if (PawnIsValid())
            {
                bool saved = SavePawn();
                if (saved)
                {
                    Print(true);
                    RoutedEventArgs PawnSavedArgs = new RoutedEventArgs(PawnEditor.PawnSavedEvent, this);
                    base.RaiseEvent(PawnSavedArgs);
                }
            }
            else
            {
                MessageBox.Show("Loan Failed Validation.  Please Correct and try again.");
            }
        }

        private void SaveAndCloseOnly_Click(object sender, RoutedEventArgs e)
        {
            PreSavePawn();
            if (PawnIsValid())
            {
                bool saved = SavePawn();
                if (saved)
                {
                    RoutedEventArgs PawnSaveAndCloseArgs = new RoutedEventArgs(PawnEditor.PawnSaveAndCloseEvent, this);
                    base.RaiseEvent(PawnSaveAndCloseArgs);
                }
            }
            else
            {
                MessageBox.Show("Loan Failed Validation.  Please Correct and try again.");
            }
        }


        void PrintPreview_Click(object sender, RoutedEventArgs e)
        {
            pawn.Items = itemselector.PawnItems;
            UpdatePrintPreview();
        }

        private void UpdatePrintPreview()
        {
            pawn.Amount = pawn.Items.Sum(amt => amt.Amount);

            int countguns = (from linqtable in pawn.Items
                             where linqtable.ItemTypeId == 2
                             select linqtable.ItemId).Count();

            pawn.NumberOfFirearms = countguns;

            Data.PawnCalcItem calcs = null;

            try
            {
                calcs = new Data.PawnCalcItem(pawn);
            }
            catch (Exception Ex)
            {
                MessageBox.Show(Ex.Message);
            }

            PrintPreviewStackPanel.DataContext = null;

            if (calcs != null)
            {
                PrintPreviewStackPanel.DataContext = calcs;
                return;
            }
        }

        private void ReprintLabelButton_Click(object sender, RoutedEventArgs e)
        {
            if (pawn.PawnId > 0)
            {
                try
                {
                    PrintSRSReport report = new PrintSRSReport();
                    report.PrintLabel('P', pawn.PawnId);
                }
                catch
                {
                    MessageBox.Show("Failed to reprint label");
                }
            }
            else
                MessageBox.Show("Save Pawn before reprinting");
        }

        private void ReprintPoliceButton_Click(object sender, RoutedEventArgs e)
        {
            if (pawn.PawnId > 0)
            {
                try
                {
                    PrintSRSReport report = new PrintSRSReport();
                    report.PrintPawnPoliceReport(pawn.PawnId);
                }
                catch
                {
                    MessageBox.Show("Failed to reprint Police Report");
                }
            }
            else
                MessageBox.Show("Save Pawn before reprinting");
        }

        private void ReprintTicketButton_Click(object sender, RoutedEventArgs e)
        {
            if (pawn.PawnId > 0)
            {
                try
                {
                    PrintSRSReport report = new PrintSRSReport();
                    report.PrintPawnTicket(pawn.PawnId);
                }
                catch
                {
                    MessageBox.Show("Failed to reprint Pawn Ticket");
                }
            }
            else
                MessageBox.Show("Save Pawn before reprinting");
        }
    }
}
