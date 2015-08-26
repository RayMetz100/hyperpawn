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
    /// Interaction logic for PutAwayControl.xaml
    /// </summary>
    public partial class PutAwayControl : Window
    {
        Collection<Data.PutAwayPawn> pawns = new Collection<Shell.Data.PutAwayPawn>();
        int Employee;

        public PutAwayControl(int employeeid)
        {
            Employee = employeeid;
            pawns = App.HyperPawnDB.PawnGetPutAwayItems();
            InitializeComponent();
            myListView.ItemsSource = pawns;
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            var rows = from Shell.Data.PutAwayPawn p in pawns
                       where p.Location != "" && p.Location != null
                       select p;

            try
            {
                foreach (Shell.Data.PutAwayPawn row in rows)
                {
                    App.HyperPawnDB.PawnUpdateLocation(Employee, row.PawnId, row.Location);
                }
            }
            catch (Exception Ex)
            {
                MessageBox.Show("Some or all Items were not updated.  "+Ex.Message);
            }

            Close();
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        //private void myListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        //{
        //    MessageBox.Show("he");
        //}

        //private void LocationTextBox_LostFocus(object sender, RoutedEventArgs e)
        //{
        //    DependencyObject 
        //    MessageBox.Show(((TextBox)e.OriginalSource).Text);
        //}
    }
}
