using System.Windows;
using System.Linq;
//using System.Drawing;
using System.Windows.Media;
using System;
using System.Windows.Controls;
//using System.Windows.Forms;

namespace Shell
{
    /// <summary>
    /// Interaction logic for NewLoanOrPurchase.xaml
    /// </summary>
    public partial class PurchaseEditor : UserControl
    {
        Data.Purchase purchase;
        //Controls.PartySelector partyselector;
        //Controls.PartyEditor partydetails;
        Controls.ItemSelector itemselector;
        int employee;

        public static readonly RoutedEvent PurchaseSaveAndCloseEvent;
        //public static readonly RoutedEvent SaveAndCloseEvent;

        static PurchaseEditor()
        {
            PurchaseEditor.PurchaseSaveAndCloseEvent = EventManager.RegisterRoutedEvent("PurchaseSaveAndCloseEvent", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
            //PurchaseEditor.SaveAndCloseEvent = EventManager.RegisterRoutedEvent("SaveAndClose", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
        }

        public PurchaseEditor(int partyid, int employee)
        {
            this.employee = employee;
            InitializeComponent();
            purchase = new Data.Purchase();
            InitializeFields();
            purchase.Customer.PartyId = partyid;
            itemselector = new Controls.ItemSelector();
            ItemsContentControl.Content = itemselector;
            itemselector.itemsupdated += new Shell.Controls.ItemSelector.ItemsUpdated(itemselector_itemsupdated);
        }


        private void InitializeFields()
        {
            //partyselector = new Controls.PartySelector();
            //partydetails = new Controls.PartyEditor(employee);
            //CustomerStackPanel.Children.Add(partydetails);
            //CustomerStackPanel.Children.Add(partyselector);
            //partyselector.Visibility = Visibility.Collapsed;
            LoanStackPanel.DataContext = purchase;
            //partydetails.DataContext = purchase.Customer;
        }

        private void NotDone_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Not Done");
        }

        private void DontSaveAndClose_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("All Unsaved Purchase Information will be Lost!", "Warning", MessageBoxButton.OKCancel) == MessageBoxResult.OK)
            {
                purchase = null;
                //Close();
            }
        }




        /* Customer Section
         * */


        private void SearchCustomer_Click(object sender, RoutedEventArgs e)
        {
            //partydetails.Visibility = Visibility.Collapsed;
            //partyselector.Visibility = Visibility.Visible;
            //partyselector.PartySelected += new Shell.Controls.PartySelector.idHandler(partyselector_PartySelected);
        }

        //void partyselector_PartySelected(int partyid)
        //{
        //    try
        //    {
        //        purchase.Customer = App.HyperPawnDB.PartyGetDetails(partyid);
        //    }
        //    catch
        //    {
        //        MessageBox.Show
        //    }
        //    //partyselector.Visibility = Visibility.Collapsed;
        //    //partydetails.Visibility = Visibility.Visible;
        //    //partydetails.DataContext = purchase.Customer;
        //    itemselector = new Controls.ItemSelector(purchase.Customer.PartyId, purchase.Items);
        //    ItemsContentControl.Content = itemselector;
        //    itemselector.itemsupdated += new Shell.Controls.ItemSelector.ItemsUpdated(itemselector_itemsupdated);
        //    //PreviousItems.Content = null;
        //    //if (pawn.Customer.ItemsAvailable > 0)
        //    //{
        //    //    //PreviousItemsButton.Visibility = Visibility.Visible;
        //    //    //PreviousItemsButton.Content = pawn.Customer.ItemsAvailable.ToString() + " Items are available to Re-Pawn";
        //    //}
        //    //else
        //    //{
        //    //    //PreviousItemsButton.Visibility = Visibility.Hidden;
        //    //    //PreviousItemsButton.Content = null;
        //    //}
        //}


        void itemselector_itemsupdated(System.Collections.ObjectModel.ObservableCollection<Shell.Data.Item> pawnitems)
        {
            purchase.Items = pawnitems;
        }

        private void DontSaveAndClear_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("All Unsaved Purchase Information will be Lost!", "Warning", MessageBoxButton.OKCancel) == MessageBoxResult.OK)
            {
                purchase = new Data.Purchase();
                InitializeFields();
            }
        }

        /* Loan Section */

        //LoanNumber.GetBindingExpression(TextBox.TextProperty).UpdateTarget();

        private void Print()
        {
            PrintSRSReport printer = new PrintSRSReport();
            try
            {
                printer.PrintPurchasePoliceReport(purchase.PurchaseId);
            }
            catch (Exception Ex)
            {
                MessageBox.Show("Print Failed: " + Ex.Message);
            }
        }

        private bool PurchaseIsValid()
        {
            var results = from Data.Item i in purchase.Items
                          where i.Amount <= 0
                          select i;

            foreach (var result in results)
            {
                return false;
            }

            if (purchase.Items.Count > 0)
                return true;
            else
                return false;
        }

        private bool SavePurchase()
        {
            try
            {
                purchase.PurchaseId = App.HyperPawnDB.PurchaseSave(purchase, employee);
                return true;
            }
            catch (Exception Ex)
            {
                MessageBox.Show("Error: Purchase did not save. "+Ex.Message);
                return false;
            }
        }

        private void PreSavePurchase()
        {
            purchase.Items = itemselector.PawnItems;
        }

        private void PrintAndDoMore_Click(object sender, RoutedEventArgs e)
        {
            PreSavePurchase();
            if (PurchaseIsValid())
            {
                bool saved = SavePurchase();
                if (saved)
                {
                    Print();
                    Data.Party p = purchase.Customer;
                    purchase = new Data.Purchase();
                    purchase.Customer = p;
                    InitializeFields();
                }
            }
            else
            {
                MessageBox.Show("Purchase Failed Validation.  Please Correct and try again.");
            }
        }

        private void PrintAndClose_Click(object sender, RoutedEventArgs e)
        {
            PreSavePurchase();
            if (PurchaseIsValid())
            {
                bool saved = SavePurchase();
                if (saved)
                {
                    Print();
                    RoutedEventArgs PurchaseSaveAndCloseArgs = new RoutedEventArgs(PurchaseEditor.PurchaseSaveAndCloseEvent, this);
                    base.RaiseEvent(PurchaseSaveAndCloseArgs);
                }
            }
            else
            {
                MessageBox.Show("Purchase Failed Validation.  Please Correct and try again.");
            }
        }

        private void SaveAndCloseOnly_Click(object sender, RoutedEventArgs e)
        {
            PreSavePurchase();
            if (PurchaseIsValid())
            {
                bool saved = SavePurchase();
                if (saved)
                {
                    //RoutedEventArgs SaveAndCloseArgs = new RoutedEventArgs(PurchaseEditor.SaveAndCloseEvent, this);
                    //base.RaiseEvent(SaveAndCloseArgs);
                }
            }
            else
            {
                MessageBox.Show("Purchase Failed Validation.  Please Correct and try again.");
            }
        }
    }
}
