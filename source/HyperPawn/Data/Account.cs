using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;

namespace Shell.Data
{
    public class myAccountsType : ObservableCollection<Data.Account> { }

    public class Account
    {
        public int Id { get; set; }
        public string Name { get; set; }

        public Account() { }

        public Account(int id, string name)
        {
            Id = id;
            Name = name;
        }

        ObservableCollection<Data.Account> accountTaxonomy = new ObservableCollection<Shell.Data.Account>();

        public ObservableCollection<Data.Account> GetAccounts()
        {
            accountTaxonomy = App.TaxyAccounts;
            return accountTaxonomy;
        }

    }

    public class AccountTransactionTaxCategory
    {
        public int Id { get; set; }
        public string Name { get; set; }

        public AccountTransactionTaxCategory() { }

        public AccountTransactionTaxCategory(int id, string name)
        {
            Id = id;
            Name = name;
        }

        ObservableCollection<Data.AccountTransactionTaxCategory> accountTransactionTaxCategories = new ObservableCollection<Shell.Data.AccountTransactionTaxCategory>();

        public ObservableCollection<Data.AccountTransactionTaxCategory> GetAccountTransactionTaxCategories()
        {
            accountTransactionTaxCategories = App.TaxyAccountTransactionTaxCategories;
            return accountTransactionTaxCategories;
        }

    }

    public class AccountTransaction
    {
        public int Id { get; set; }
        public DateTime TransactionDate { get; set; }
        public int AccountId { get; set; }
        public int AccountTransactionTaxCategoryId { get; set; }
        decimal amount { get; set; }
        public decimal Amount { get { return amount; } set { amount = value; } }
        public decimal AmountOut
        { 
            get 
            {
                decimal d;
                d = 0 - amount;
                if (d > 0)
                    return d;
                return 0;
            } 
            set { amount = 0 - value; }
        }
        public decimal AmountIn 
        { 
            get 
            {
                if (amount > 0)
                    return amount;
                return 0;
            } 
            set { amount = value; }
        }

        public AccountTransaction() { }

        public AccountTransaction(int id, DateTime transactiondate, int accountid, int accounttransactiontaxcategoryid, decimal amount)
        {
            Id = id;
            TransactionDate = transactiondate;
            AccountId = accountid;
            AccountTransactionTaxCategoryId = accounttransactiontaxcategoryid;
            this.amount = amount;
        }
    }
}
