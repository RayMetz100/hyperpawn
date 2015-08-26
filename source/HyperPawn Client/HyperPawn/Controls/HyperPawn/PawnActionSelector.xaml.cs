using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Linq;
using System;

namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for LoanActionSelector.xaml
    /// </summary>
    /// 
    public partial class PawnActionSelector : UserControl
    {
        public static readonly RoutedEvent PawnSelectedEvent;
        public static readonly RoutedEvent CheckOutEvent;

        static PawnActionSelector()
        {
            PawnActionSelector.PawnSelectedEvent = EventManager.RegisterRoutedEvent("PawnSelected", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
            PawnActionSelector.CheckOutEvent = EventManager.RegisterRoutedEvent("CheckOut", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(int));
        }

                
        int employee;
        int PartyId = 0;
        int Top = 0;
        bool ShowAll = false;
        ObservableCollection<Data.Pawn> FoundPawns = new ObservableCollection<Shell.Data.Pawn>();
        
        ObservableCollection<Data.PawnQueueItem> availablepawnsqueue = new ObservableCollection<Data.PawnQueueItem>();
        ObservableCollection<Data.PawnQueueItem> selectedpawnsqueue = new ObservableCollection<Data.PawnQueueItem>();
        Data.PawnCalcTotals pawncalctotals = new Shell.Data.PawnCalcTotals();

        public PawnActionSelector(int partyid, int top, int employee)
        {
            this.employee = employee;
            PartyId = partyid;
            Top = top;
            InitializeComponent();
            AvailablePawnsListView.MouseDoubleClick += new MouseButtonEventHandler(AvailablePawnsListView_MouseDoubleClick);
            Search();
            TotalsStackPanel.DataContext = pawncalctotals;
        }

        void AvailablePawnsListView_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                Data.Pawn selectedpawn = ((Data.PawnQueueItem)AvailablePawnsListView.SelectedItem).Pawn;
                    RoutedEventArgs PawnSelectedArgs = new RoutedEventArgs(PawnActionSelector.PawnSelectedEvent, selectedpawn.PawnId);
                    base.RaiseEvent(PawnSelectedArgs);
            }
            catch
            {
                MessageBox.Show("Please try double-click again)");
            }
        }

        private void Search()
        {
            availablepawnsqueue = new ObservableCollection<Shell.Data.PawnQueueItem>();
            selectedpawnsqueue = new ObservableCollection<Shell.Data.PawnQueueItem>();
            try
            {
                FoundPawns = App.HyperPawnDB.PawnGet(PartyId, Top, ShowAll);
            }
            catch
            {
                MessageBox.Show("Stored Procedure Failure: PawnGet");
            }
            foreach (Data.Pawn pawn in FoundPawns)
            {
                availablepawnsqueue.Add(new Shell.Data.PawnQueueItem(pawn, null));
            }
            SelectedPawnsListView.ItemsSource = selectedpawnsqueue;
            AvailablePawnsListView.ItemsSource = availablepawnsqueue;
        }

        private void ShowAllCheckBox_Click(object sender, RoutedEventArgs e)
        {
            if (((CheckBox)e.Source).IsChecked == true)
                ShowAll = true;
            else
                ShowAll = false;
            Search();
        }

        private void UpdateTotals()
        {
            pawncalctotals.Total = (from Data.PawnQueueItem qi in selectedpawnsqueue
                                    select qi.PawnCalcSelection.ActionAmount).Sum();
            pawncalctotals.Interest = (from Data.PawnQueueItem qi in selectedpawnsqueue
                                       select qi.PawnCalcSelection.InterestAmount).Sum();
        }

        private void ActionAddButton_Click(object sender, RoutedEventArgs e)
        {
            DependencyObject button = e.OriginalSource as DependencyObject; // Button
            DependencyObject stackpanel = VisualTreeHelper.GetParent(button); // StackPanel
            DependencyObject contentpresenter = VisualTreeHelper.GetParent(stackpanel); // ContentPresenter
            if (contentpresenter is ContentPresenter)
            {
                Data.PawnQueueItem pawntoadd = (Data.PawnQueueItem)((ContentPresenter)contentpresenter).Content;
                int index = availablepawnsqueue.IndexOf(pawntoadd);
                //availablepawnsqueue[index].InQueue = true;
                //pawntoadd.InQueue = true;
                ComboBox redeemactioncombobox = (ComboBox)((StackPanel)stackpanel).Children[1];
                Data.PawnCalcSelection pawncalcselection = (Data.PawnCalcSelection)redeemactioncombobox.SelectionBoxItem;
                selectedpawnsqueue.Add(new Shell.Data.PawnQueueItem(pawntoadd.Pawn, pawncalcselection));
                availablepawnsqueue.RemoveAt(index);
            }
            UpdateTotals();
            SelectedPawnsListView.ItemsSource = selectedpawnsqueue;
        }

        private void RemoveButton_Click(object sender, RoutedEventArgs e)
        {
            DependencyObject button = e.OriginalSource as DependencyObject; // Button
            DependencyObject contentpresenter = VisualTreeHelper.GetParent(button); // ContentPresenter
            if (contentpresenter is ContentPresenter)
            {
                Data.PawnQueueItem pawntoremove = (Data.PawnQueueItem)((ContentPresenter)contentpresenter).Content;
                int index = selectedpawnsqueue.IndexOf(pawntoremove);
                //Data.PawnCalcSelection pawncalcselection = (Data.PawnCalcSelection)redeemactioncombobox.SelectionBoxItem;
                availablepawnsqueue.Add(pawntoremove);
                selectedpawnsqueue.RemoveAt(index);
            }
            UpdateTotals();
            SelectedPawnsListView.ItemsSource = selectedpawnsqueue;
        }
        private void CheckoutButton_Click(object sender, RoutedEventArgs e)
        {
            if (selectedpawnsqueue.Count > 0)
            {
                foreach (Data.PawnQueueItem queueitem in selectedpawnsqueue)
                {
                    if (queueitem.PawnCalcSelection.Action == Shell.Data.PawnActionEnum.Redeem)
                    {
                        App.HyperPawnDB.PawnRedeem(queueitem.Pawn.PawnId,queueitem.PawnCalcSelection.ActionAmount - queueitem.Pawn.Amount,employee);
                        //Complete();
                    }
                    if (queueitem.PawnCalcSelection.Action == Shell.Data.PawnActionEnum.Renew)
                    {
                        int newpawnid = 0;
                        try
                        {
                            newpawnid = App.HyperPawnDB.PawnRenew(queueitem.Pawn.PawnId, queueitem.PawnCalcSelection.ActionDate, queueitem.PawnCalcSelection.ActionAmount,employee);
                        }
                        catch (Exception Ex)
                        {
                            MessageBox.Show("Failed to Renew Pawn " + Ex.Message);
                        }
                        PrintSRSReport printer = new PrintSRSReport();
                        if (newpawnid != 0)
                        {
                            try
                            {
                                printer.PrintPawnTicket(newpawnid);
                            }
                            catch (Exception Ex)
                            {
                                MessageBox.Show("Failed to Print " + Ex.Message);
                            }
                        }
                        //Complete();
                    }
                }
            }
            RaiseCloseEvent();
        }

        private void RaiseCloseEvent()
        {
            RoutedEventArgs CheckOutArgs = new RoutedEventArgs(PawnActionSelector.CheckOutEvent, 1);
            base.RaiseEvent(CheckOutArgs);
        }

    }
}
