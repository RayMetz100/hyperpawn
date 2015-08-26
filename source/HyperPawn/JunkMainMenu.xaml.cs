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
using System.Globalization;
using System.Threading;
using System.Windows.Threading;

namespace Shell
{
    /// <summary>
    /// Interaction logic for MainMenu.xaml
    /// </summary>
    public partial class JunkMainMenu : Window
    {
        List<Data.Employee> employees = App.Employees;
        string[] barcodelines = new string[3]; 
        int barcodelinecurrent = 0;
        int selectedemployee = 0;
        DispatcherTimer employeeresettimer = new DispatcherTimer();

        public JunkMainMenu()
        {
            //employeeresettimer.Interval = new TimeSpan(0, 0, Properties.Settings.Default.EmployeeTimeout);

            InitializeComponent();
        }



        //private void SearchCustomers_Click(object sender, RoutedEventArgs e)
        //{
        //    if (selectedemployee > 0)
        //    {
        //        SearchCustomersAndPawns loanaction = new SearchCustomersAndPawns(selectedemployee);
        //        loanaction.Owner = this;
        //        loanaction.ShowDialog();
        //    }
        //    else
        //    {
        //        MessageBox.Show("Select Employee First");
        //    }
        //}

        

        private void DeleteLoan_Enter(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Return)
            {
                int loannumber;
                bool result;
                try
                {
                    loannumber = Int32.Parse(DeleteLoanTextbox.Text);
                    result = App.HyperPawnDB.PawnDelete(loannumber);
                    if (result)
                        MessageBox.Show("Deleted.");
                    else
                        MessageBox.Show("Failed to Delete");
                }
                catch
                {
                    MessageBox.Show("Check Loan Number");
                    DeleteLoanTextbox.Text = "";
                }
                DeleteLoanTextbox.Text = "";
            }
        }


        private void MainMenuWindow_KeyDown(object sender, KeyEventArgs e)
        {

            if (e.Key == Key.D2 && e.KeyboardDevice.Modifiers == ModifierKeys.Shift)
            {
                Barcode.Focus();
                barcodelinecurrent = 0;
                Barcode.Text = "";
            }
        }

        //int kpos = 0;
        //Key[] k = new Key[400];
        //ModifierKeys[] m = new ModifierKeys[400];
        private void Barcode_KeyDown(object sender, KeyEventArgs e)
        {

            
            //k[kpos] = e.Key;
            //m[kpos] = e.KeyboardDevice.Modifiers;

            //if (kpos == 275)
            //{
            //    MessageBox.Show(k[kpos].ToString());
            //}
            //kpos++;

            if (e.Key == Key.Return)
            {
                if (barcodelinecurrent == 2 && Barcode.Text.Substring(0, 12) == "@ANSI 636045") // washington state id found
                {
                    if (selectedemployee > 0)
                    {
                        int startpos = 41;
                        int endpos = Barcode.Text.IndexOf("DAG", startpos, 30);
                        string name = Barcode.Text.Substring(startpos, endpos - startpos);

                        string last = name.Substring(0, name.IndexOf(','));
                        int i = name.IndexOf(',', last.Length + 1) - last.Length - 1;
                        string first = name.Substring(last.Length + 1, i);
                        //i = name.Length - last.Length - 1 - first.Length - 1;
                        string middle = name.Substring(last.Length + 1 + first.Length + 1);//, i);

                        startpos = startpos + name.Length + 3;
                        endpos = Barcode.Text.IndexOf("DAI", startpos, 30);
                        string address = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = startpos + address.Length + 3;
                        endpos = Barcode.Text.IndexOf("DAJ", startpos, 20);
                        string city = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = startpos + city.Length + 3;
                        endpos = startpos + 2;
                        string state = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = startpos + state.Length + 3;
                        endpos = startpos + 10;
                        string zip = Barcode.Text.Substring(startpos, endpos - startpos).Trim();

                        startpos = endpos + 4;
                        endpos = startpos + 12;
                        string wadl = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = endpos + 31;
                        endpos = startpos + 8;
                        string expires = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = endpos + 3;
                        endpos = startpos + 8;
                        //IFormattable dateformat = new 
                        //IFormatProvider ifp = new forma
                        CultureInfo provider = CultureInfo.InvariantCulture;
                        string birthdate = DateTime.ParseExact(Barcode.Text.Substring(startpos, endpos - startpos), "yyyyMMdd",provider).ToString();

                        startpos = endpos + 3;
                        endpos = startpos + 1;
                        string sex = (Barcode.Text.Substring(startpos, endpos - startpos) == "1")?"M":"F";

                        startpos = endpos + 14;
                        endpos = startpos + 3;
                        string height = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = endpos + 3;
                        endpos = startpos + 3;
                        string weight = Barcode.Text.Substring(startpos, endpos - startpos);

                        startpos = endpos + 3;
                        endpos = startpos + 3;
                        string eyes = Barcode.Text.Substring(startpos, endpos - startpos);

                        MessageBox.Show(last + "\n" + first + "\n" + middle + "\n" + address + "\n" + city + "\n" + state
                            + "\n" + zip + "\n" + wadl + "\n" + expires + "\n" + birthdate + "\n" + sex
                            + "\n" + height + "\n" + weight + "\n" + eyes);


                        //SearchCustomersAndPawns loanaction = new SearchCustomersAndPawns();
                        //loanaction.Owner = this;
                        //loanaction.ShowDialog();
                    }
                    else
                    {
                        MessageBox.Show("Select Employee First");
                    }
                }
                barcodelinecurrent++;
            }
        }

        private void test_Click(object sender, RoutedEventArgs e)
        {
            //Utility.Matrix64 m = new HyperPawn.Utility.Matrix64();
            Utility.Matrix32.TryIt();
        }
    }
}
