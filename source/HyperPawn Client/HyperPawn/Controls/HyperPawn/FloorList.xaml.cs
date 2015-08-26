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
using System.Xml;

namespace Shell.Controls
{
    /// <summary>
    /// Interaction logic for FloorList.xaml
    /// </summary>
    public partial class FloorList : UserControl
    {
        ObservableCollection<Data.PawnListEntry> rows = new ObservableCollection<Shell.Data.PawnListEntry>();
        int CurrentEmployee;

        public FloorList(int currentemployee)
        {
            CurrentEmployee = currentemployee;
            InitializeComponent();
        }

        private void FillView(int type)
        {

            rows = App.HyperPawnDB.PawnGetFloorList(type);
            myListView.ItemsSource = null;
            myListView.ItemsSource = rows;

        }

        private void PrintCheckedItemsButton_Click(object sender, RoutedEventArgs e)
        {
            PrintSRSReport report = new PrintSRSReport();
            report.PrintFloorReport(SelectedItemsXML());
        }

        private string SelectedItemsXML()
        {
            var s = from Data.PawnListEntry entry in rows
                    where entry.Selected == true
                    select entry.Id;

            StringBuilder sb = new StringBuilder();

            //XmlDocument doc = new XmlDocument();

            sb.Append("<root>");

            foreach (var r in s)
            {
                sb.Append("<row PawnId=\"" + r.ToString() + "\" />");
            }

            sb.Append("</root>");

            return sb.ToString();
        }

        private void JewelryButton_Click(object sender, RoutedEventArgs e)
        {
            FillView(1);
        }

        private void GunsButton_Click(object sender, RoutedEventArgs e)
        {
            FillView(2);
        }

        private void OtherButton_Click(object sender, RoutedEventArgs e)
        {
            FillView(88);
        }

        private void FloorItemButton_Click(object sender, RoutedEventArgs e)
        {
            DependencyObject button = e.OriginalSource as DependencyObject; // Button
            DependencyObject stackpanel = VisualTreeHelper.GetParent(button); // StackPanel
            DependencyObject contentpresenter = VisualTreeHelper.GetParent(stackpanel); // ContentPresenter (PawnListEntry)
            if (contentpresenter is ContentPresenter)
            {
                Data.PawnListEntry pawn = (Data.PawnListEntry)((ContentPresenter)contentpresenter).Content;
                MessageBoxResult result;
                result = MessageBox.Show("Do you really want to floor Pawn #"+ pawn.Id.ToString() + "?\n\n"+pawn.Description, "Floor It?", MessageBoxButton.YesNo, MessageBoxImage.Question, MessageBoxResult.Yes);
                if (result == MessageBoxResult.Yes)
                {
                    App.HyperPawnDB.PawnFloor(pawn.Id, CurrentEmployee);
                    rows.Remove(pawn);
                }
            }
        }

        private void FloorButton_Click(object sender, RoutedEventArgs e)
        {

        }


    }

}
