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
    /// Interaction logic for ActionTabs.xaml
    /// </summary>
    public partial class ActionTabs : UserControl
    {
        PawnEditor pawneditor;
        PurchaseEditor purchaseeditor;
        PawnActionSelector pawnactionselector;
        int PartyId;
        int Employee;

        public ActionTabs(int partyid, int employeeid)
        {
            PartyId = partyid;
            Employee = employeeid;
            pawneditor = new PawnEditor(partyid, employeeid);
            purchaseeditor = new PurchaseEditor(partyid, employeeid);
            pawnactionselector = new Shell.Controls.PawnActionSelector(partyid, 1000, employeeid);

            InitializeComponent();
            
            PawnTab.Content = pawneditor;
            PurchaseTab.Content = purchaseeditor;
            RenewRedeemTab.Content = pawnactionselector;

            RenewRedeemTab.AddHandler(PawnActionSelector.PawnSelectedEvent, new RoutedEventHandler(PawnSelected));
            PawnTab.AddHandler(PawnEditor.PawnSaveAndCloseEvent, new RoutedEventHandler(PawnSaveAndClose));

            Tabs.SelectedIndex = 2;


        }

        private void PawnSelected(object sender, RoutedEventArgs e)
        {
            Tabs.SelectedIndex = 0;
            pawneditor = new PawnEditor((int)e.OriginalSource, "edit", Employee);
            PawnTab.Content = pawneditor;
        }

        private void PawnSaveAndClose(object sender, RoutedEventArgs e)
        {

            pawnactionselector = new Shell.Controls.PawnActionSelector(PartyId, 1000, Employee);
            RenewRedeemTab.Content = pawnactionselector;
            Tabs.SelectedIndex = 2;
            pawneditor = new PawnEditor(PartyId, Employee);
            PawnTab.Content = pawneditor;
        }



    }
}
