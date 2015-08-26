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
using Shell.Controls;
using System.Windows.Threading;
using Shell.Controls.HyperSale;

namespace Shell
{
    /// <summary>
    /// Interaction logic for Startup.xaml
    /// </summary>
    public partial class Startup : Page
    {
        List<Data.Employee> employees = App.Employees;
        //int previousemployee = 0;
        Data.CurrentEmployee currentemployee = new Shell.Data.CurrentEmployee();
        //DispatcherTimer employeeresettimer = new DispatcherTimer();
        //SearchCustomersAndPawns searchcustomersandpawns;

        Binding employeebinding = new Binding();
        

        public Startup()
        {
            bool PassedMatrixCheck = Utility.Matrix32.ValidateCustomerKey();

                

            //employeeresettimer.Tick += new EventHandler(employeeresettimer_Tick);

            InitializeComponent();
            if (PassedMatrixCheck == false)
            {
                MessageBox.Show(
                    "Your HyperPawn license key must be in your USB port to proceed.\n"+
                    "If necessary, contact HyperPawn support at http://www.HyperPawn.com");
                return;
            }
            CurrentEmployeeComboBox.ItemsSource = employees;

            //employeebinding.Source = currentemployee;
            //employeebinding.Path = new PropertyPath("Id");
            //employeebinding.Mode = BindingMode.TwoWay;
            //CurrentEmployeeComboBox.SetBinding(ComboBox.SelectedValueProperty, employeebinding);
            //CurrentEmployeeComboBox.SelectedValue = currentemployee.Id;

            if (App.ConnectionToDatabaseVerified == false)
            {
                MessageBox.Show("Unable to connect to your HyperPawn server.\n"+
                    "\n"+
                    "1. If you know which compluter is your HyperPawn database server, try rebooting it.\n"+
                    "2. Try clicking your \"Settings\" button, then adjust the \"Database Connection\" property.\n"+
                    "\n"+
                    "You may also contact HyperPawn support at http://www.HyperPawn.com to resolve.");
                //Close;
            }
            currentemployee.Id = 0;
            //ClearAllToHyperPawn();
            //employeeresettimer.Stop();
        }

        //void searchcustomersandpawns_Saved()
        //{
        //    ClearAllToHyperPawn();
        //}

        private void CurrentEmployeeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

            int employeeid = -1;
            try
            {
                employeeid = (int)((ComboBox)e.Source).SelectedValue;
            }
            catch { }

            currentemployee.Id = employeeid;
            ClearAllToHyperPawn();
            //AddEmptyChild();


            //if (employeeid != previousemployee)
            //{
                
            //    ClearAllToHyperPawn();
            //    AddEmptyChild();
            //    employeeresettimer.Start();

            //}
            //else
            //{
            //    currentemployee.Id = employeeid;
            //    UnHide();
            //    employeeresettimer.Start();
            //}
            
        }

        private void ClearAllToHyperPawn()
        {
            //employeeresettimer.Interval = new TimeSpan(0, 0, Properties.Settings.Default.EmployeeTimeout);
            if (StartupStackPanel.Children.Count != 1)
                StartupStackPanel.Children.RemoveAt(1);
            HyperPawn hyperpawn = new HyperPawn(currentemployee.Id);
            StartupStackPanel.Children.Add(hyperpawn);
        }

        private void ClearAllToHyperSale()
        {
            //employeeresettimer.Interval = new TimeSpan(0, 0, Properties.Settings.Default.EmployeeTimeout);
            if (StartupStackPanel.Children.Count != 1)
                StartupStackPanel.Children.RemoveAt(1);
            HyperSale hypersale = new HyperSale();//currentemployee.Id);
            StartupStackPanel.Children.Add(hypersale);
        }

        //private void AddEmptyChild()
        //{
        //    searchcustomersandpawns = new SearchCustomersAndPawns(currentemployee.Id);
        //    searchcustomersandpawns.Saved += new SearchCustomersAndPawns.saved(searchcustomersandpawns_Saved);
        //    StartupStackPanel.Children.Add(searchcustomersandpawns);
        //}

        private void AppSettings_Click(object sender, RoutedEventArgs e)
        {
            UserSettings us = new UserSettings();
            us.WindowStartupLocation = WindowStartupLocation.CenterOwner;
            us.ShowDialog();
        }
        //void employeeresettimer_Tick(object sender, EventArgs e)
        //{
        //    //employeeresettimer.Stop();
            
        //    Hide();
        //}

        //private void Hide()
        //{
        //    //CurrentEmployeeComboBox.SelectedValue
        //    currentemployee.Id = 0;
        //    //CurrentEmployeeComboBox.ItemsSource = null;
        //    CurrentEmployeeComboBox.ClearValue(ComboBox.SelectedValueProperty);
        //    searchcustomersandpawns.Visibility = Visibility.Hidden;
        //    PreviousEmployeeButton.Visibility = Visibility.Visible;
        //}

        private void PreviousEmployeeButton_Click(object sender, RoutedEventArgs e)
        {
            //currentemployee.Id = previousemployee;
            //UnHide();
            //employeeresettimer.Start();
        }

        //private void UnHide()
        //{
        //    CurrentEmployeeComboBox.SelectedValue = currentemployee.Id;
        //    searchcustomersandpawns.Visibility = Visibility.Visible;
        //    PreviousEmployeeButton.Visibility = Visibility.Hidden;
        //}

        private void HyperPawn_Click(object sender, RoutedEventArgs e)
        {
            //currentemployee.Id = 0;
            //CurrentEmployeeComboBox.SelectedValue = currentemployee.Id;
            ClearAllToHyperPawn();
            //employeeresettimer.Stop();
        }

        private void HyperSale_Click(object sender, RoutedEventArgs e)
        {
            //currentemployee.Id = 0;
            //CurrentEmployeeComboBox.SelectedValue = currentemployee.Id;
            ClearAllToHyperSale();
            //employeeresettimer.Stop();
        }

        private void FirearmLogButton_Click(object sender, RoutedEventArgs e)
        {
            ClearAllToFirearmLog();
        }

        private void ClearAllToFirearmLog()
        {
            if (StartupStackPanel.Children.Count != 1)
                StartupStackPanel.Children.RemoveAt(1);
            FirearmLog firearmlog = new FirearmLog(currentemployee.Id);
            StartupStackPanel.Children.Add(firearmlog);
        }

        private void PutAwayButton_Click(object sender, RoutedEventArgs e)
        {
            if (currentemployee.Id > 0)
            {
                PutAwayControl putawaycontrol = new PutAwayControl(currentemployee.Id);
                putawaycontrol.ShowDialog();
            }
            else
            {
                MessageBox.Show("Select Employee First");
            }
        }

        private void DailyActivityButton_Click(object sender, RoutedEventArgs e)
        {
            DailyActivityDetail window = new DailyActivityDetail();
            window.ShowDialog();
        }

        private void ReportsButton_Click(object sender, RoutedEventArgs e)
        {
            ClearAllToReports();
        }

        private void ClearAllToReports()
        {
            if (currentemployee.Id > 0)
            {
                if (StartupStackPanel.Children.Count != 1)
                    StartupStackPanel.Children.RemoveAt(1);
                ReportsControl reportscontrol = new ReportsControl(currentemployee.Id);
                StartupStackPanel.Children.Add(reportscontrol);
            }
            else
            {
                MessageBox.Show("Select Employee First");
            }
        }

    }
}
