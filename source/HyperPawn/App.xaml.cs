using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Windows;
using System.Collections.ObjectModel;

namespace Shell
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private static Data.HyperPawnDB hyperPawnDB = new Shell.Data.HyperPawnDB();
        public static Data.HyperPawnDB HyperPawnDB
        {
            get { return hyperPawnDB; }
        }

        private static bool connectiontodatabaseverified = HyperPawnDB.CheckDbConnection();
        public static bool ConnectionToDatabaseVerified { get { return connectiontodatabaseverified; } }

        private static List<Data.ItemSubType> itemsubtypes = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetItemSubTypes(): new List<Data.ItemSubType>();
        public static List<Data.ItemSubType> ItemSubTypes { get { return itemsubtypes; } }

        private static List<Data.ItemType> itemtypes = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetItemTypes() : new List<Data.ItemType>();
        public static List<Data.ItemType> ItemTypes { get { return itemtypes; } }

        private static List<Data.PawnStatus> pawnstatus = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetPawnStatus() : new List<Data.PawnStatus>();
        public static List<Data.PawnStatus> PawnStatus { get { return pawnstatus; } }

        private static List<Data.PawnFees_WA_Interest> pawnfees_wa_interest = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetPawnFees_WA_Interest() : new List<Data.PawnFees_WA_Interest>();
        public static List<Data.PawnFees_WA_Interest> PawnFees_WA_Interest { get { return pawnfees_wa_interest; } }

        private static List<Data.PawnFees_WA_Preparation> pawnfees_wa_preparation = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetPawnFees_WA_Preparation() : new List<Data.PawnFees_WA_Preparation>();
        public static List<Data.PawnFees_WA_Preparation> PawnFees_WA_Preparation { get { return pawnfees_wa_preparation; } }

        private static List<Data.Employee> employees = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetEmployees() : new List<Data.Employee>();
        public static List<Data.Employee> Employees { get { return employees; } }

        private static Collection<Data.TaxyComboSource> taxycities = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetComboSource("TaxyGetCities", 12) : new Collection<Data.TaxyComboSource>();
        public static Collection<Data.TaxyComboSource> TaxyCities { get { return taxycities; } }

        private static Collection<Data.TaxyComboSource> taxyguntypes = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetComboSource("TaxyGetGunType", 9) : new Collection<Data.TaxyComboSource>();
        public static Collection<Data.TaxyComboSource> TaxyGunTypes { get { return taxyguntypes; } }

        private static Collection<Data.TaxyComboSource> taxyraces = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetComboSource("TaxyGetRace", 5) : new Collection<Data.TaxyComboSource>();
        public static Collection<Data.TaxyComboSource> TaxyRaces { get { return taxyraces; } }

        private static Collection<Data.TaxyComboSource> taxyhaircolors = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetComboSource("TaxyGetHair", 6) : new Collection<Data.TaxyComboSource>();
        public static Collection<Data.TaxyComboSource> TaxyHairColors { get { return taxyhaircolors; } }

        private static Collection<Data.TaxyComboSource> taxyeyecolors = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetComboSource("TaxyGetEyes", 6) : new Collection<Data.TaxyComboSource>();
        public static Collection<Data.TaxyComboSource> TaxyEyeColors { get { return taxyeyecolors; } }

        private static ObservableCollection<Data.Account> taxyaccounts = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetAccounts() : new ObservableCollection<Data.Account>();
        public static ObservableCollection<Data.Account> TaxyAccounts { get { return taxyaccounts; } }

        private static ObservableCollection<Data.AccountTransactionTaxCategory> taxyaccounttransactiontaxcategories = (connectiontodatabaseverified) ? HyperPawnDB.TaxyGetAccountTransactionTaxCategories() : new ObservableCollection<Data.AccountTransactionTaxCategory>();
        public static ObservableCollection<Data.AccountTransactionTaxCategory> TaxyAccountTransactionTaxCategories { get { return taxyaccounttransactiontaxcategories; } }

    }
}
