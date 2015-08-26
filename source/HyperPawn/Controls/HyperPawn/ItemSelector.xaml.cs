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
    /// Interaction logic for ItemSelector.xaml
    /// </summary>
    public partial class ItemSelector : UserControl
    {
        public delegate void ItemsUpdated(ObservableCollection<Data.Item> pawnitems);
        public event ItemsUpdated itemsupdated;

        private ObservableCollection<Data.Item> pawnitems;
        public ObservableCollection<Data.Item> PawnItems
        {
            get
            {
                return pawnitems;
            }
            set
            {
                pawnitems = value;
            }
        }
        
        
        private ObservableCollection<Data.Item> previouspawnitems;

        public ItemSelector()
        {
            PawnItems = new ObservableCollection<Shell.Data.Item>();
            //CollectionViewSource cvs = (CollectionViewSource)this.Resources["cvs"];
            //cvs.Source = App.TaxyGunTypes;
            InitializeComponent();
            PawnItemsListBox.ItemsSource = PawnItems;
            ItemTypeComboBox.ItemsSource = App.ItemTypes;
        }

        public ItemSelector(Data.Pawn pawn)//int partyid, ObservableCollection<Data.Item> pawnitems, string pawnnote)
        {
            PawnItems = pawn.Items;
            previouspawnitems = App.HyperPawnDB.PartyGetItems(pawn.Customer.PartyId);
            //CollectionViewSource cvs = (CollectionViewSource)this.Resources["cvs"];
            //cvs.Source = App.TaxyGunTypes;
            InitializeComponent();
            PawnNoteTextbox.DataContext = pawn;
            PreviousItemsListView.ItemsSource = previouspawnitems;
            PawnItemsListBox.ItemsSource = PawnItems;
            ItemTypeComboBox.ItemsSource = App.ItemTypes;
            if (previouspawnitems.Count > 0)
            {
                PreviousItemsButton.Content = previouspawnitems.Count.ToString() + " Previous Iems are available";
            }
        }

        private void ItemTypeComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            if (ItemTypeComboBox.SelectedValue != null)
                ItemSubTypeComboBox.ItemsSource = new Data.ItemType(int.Parse(ItemTypeComboBox.SelectedValue.ToString())).SubTypes;
        }

        private void ItemSubTypeComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            if (ItemSubTypeComboBox.SelectedValue != null)
            {
                Data.Item itemtoinsert = new Shell.Data.Item(int.Parse(ItemTypeComboBox.SelectedValue.ToString()), int.Parse(ItemSubTypeComboBox.SelectedValue.ToString()));
                //itemtoinsert.DisplayOrder = PawnItems.Count();
                PawnItems.Add(itemtoinsert);
                ItemTypeComboBox.SelectedItem = null;
                ItemSubTypeComboBox.ItemsSource = null;
                ItemSubTypeComboBox.SelectedItem = null;
            }
        }

        private void DeleteItemButton_Click(object sender, RoutedEventArgs e)
        {
            if (PawnItemsListBox.SelectedItem != null)
            {
                PawnItems.Remove((Data.Item)PawnItemsListBox.SelectedItem);
            }
            else
                MessageBox.Show("Select an Item to delete and try again");
        }

        private void PreviousItemsButton_Click(object sender, RoutedEventArgs e)
        {
            PreviousItemsListView.Visibility = Visibility.Visible;

        }
        private void PreviousLoansButton_Click(object sender, RoutedEventArgs e)
        {
            //itemselector = new HyperPawn.Controls.ItemSelector(pawn.Customer.PartyId);
            //PreviousItems.Content = itemselector;
        }

        private void ClosePreviousButton_Click(object sender, RoutedEventArgs e)
        {
            PreviousItemsListView.Visibility = Visibility.Collapsed;
            //PreviousPawnsListView.Visibility = Visibility.Collapsed;
        }

        private void AddPreviousItemButton_Click_Click(object sender, RoutedEventArgs e)
        {
            DependencyObject button = e.Source as DependencyObject;
            DependencyObject contentpresenter = VisualTreeHelper.GetParent(button); // ContentPresenter
            if (contentpresenter is ContentPresenter)
            {
                Data.Item itemtoadd = (Data.Item)((ContentPresenter)contentpresenter).Content;
                //itemtoadd.DisplayOrder = PawnItems.Count();
                PawnItems.Add(itemtoadd);
                itemsupdated(PawnItems);
                PreviousItemsListView.Visibility = Visibility.Collapsed;
            }
        }
    }
}
