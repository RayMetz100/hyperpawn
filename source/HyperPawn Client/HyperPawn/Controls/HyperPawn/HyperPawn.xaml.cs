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
    /// Interaction logic for HyperPawn.xaml
    /// </summary>
    public partial class HyperPawn : UserControl
    {
        int Employee;

        PartySelector partyselector;
        PartyEditor partyeditor;
        ActionTabs actiontabs;
        bool hasactiontabs = false;

        public HyperPawn(int employee)
        {
            Employee = employee;
            InitializeComponent();
            Init();
        }

        private void Init()
        {
            MainStackPanel.Children.Clear();
            partyselector = new PartySelector();
            MainStackPanel.Children.Add(partyselector);
            partyselector.PartySelected += new PartySelector.idHandler(partyselector_PartySelected);
        }

        void partyselector_PartySelected(int partyid)
        {
            MainStackPanel.Children.Clear();
            partyselector = null;
            partyeditor = new PartyEditor(partyid,Employee);
            //partyeditor.HorizontalAlignment = HorizontalAlignment.Stretch;
            partyeditor.AddHandler(PartyEditor.PartySavedEvent, new RoutedEventHandler(onPartySaved));
            
            MainStackPanel.Children.Add(partyeditor);
            if (partyid != 0)
            {
                AddActionTabs(partyid);
            }
        }

        private void onPartySaved(object sender, RoutedEventArgs e)
        {
            int partyid = (int)e.OriginalSource;
            if (hasactiontabs == false)
            {
                AddActionTabs(partyid);
            }
        }

        private void AddActionTabs(int partyid)
        {
            actiontabs = new ActionTabs(partyid, Employee);
            MainStackPanel.Children.Add(actiontabs);
            MainStackPanel.AddHandler(PawnActionSelector.CheckOutEvent, new RoutedEventHandler(Done));
            MainStackPanel.AddHandler(PawnEditor.PawnSavedEvent, new RoutedEventHandler(Done));
            MainStackPanel.AddHandler(PurchaseEditor.PurchaseSaveAndCloseEvent, new RoutedEventHandler(Done));
            hasactiontabs = true;
        }

        private void Done(object sender, RoutedEventArgs e)
        {
            Init();
        }

        //RenewRedeemTab.AddHandler(PawnActionSelector.PawnSelectedEvent, new RoutedEventHandler(PawnSelected));

        

    }
}
