using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using System.ComponentModel;
using System.Windows;

namespace Shell.Data
{
    public enum PawnActionEnum
    {
        Redeem,
        Renew
    }

    public enum PawnActionEarlyEnum
    {
        Now,
        NinetyDays
    }

    public enum PawnActionLateEnum
    {
        Month,
        Full,
        BackDate
    }

    public enum PawnChargeTypeEnum
    {
        Principal,
        RedeemInterest,
        RewriteInterest
    }

    public class PawnCharge
    {

        public PawnChargeTypeEnum Type { get; set; }
        public decimal Amount { get; set; }

        public PawnCharge(PawnChargeTypeEnum type, decimal amount)
        {
            Type = type;
            Amount = amount;
        }
    }

    public class PawnFees_WA_Interest
    {
        public decimal AmountStart { get; set; }
        public decimal AmountEnd { get; set; }
        public decimal MonthlyInterestAmount { get; set; }
        public decimal MonthlyInterestPercent { get; set; }

        public PawnFees_WA_Interest(decimal amountstart, decimal amountend, decimal monthlyinterestamount, decimal monthlyinterestpercent)
        {
            AmountStart = amountstart;
            AmountEnd = amountend;
            MonthlyInterestAmount = monthlyinterestamount;
            MonthlyInterestPercent = monthlyinterestpercent;
        }
    }

    public class PawnFees_WA_Preparation
    {
        public decimal AmountStart { get; set; }
        public decimal AmountEnd { get; set; }
        public decimal PreparationAmount { get; set; }

        public PawnFees_WA_Preparation(decimal amountstart, decimal amountend, decimal preparationamount)
        {
            AmountStart = amountstart;
            AmountEnd = amountend;
            PreparationAmount = preparationamount;
        }
    }

    public class PawnCalcItem
    {
        private int numberofguns;
        private decimal amount;
        
        public string GunMessage
        {
            get
            {
                if (numberofguns == 0)
                    return "no guns";
                else
                    return "Gun Fee: " + (3 * numberofguns).ToString("C2", new CultureInfo("en-US"));
            }
        }
        
        public string AmountFinancedMessage
        {
            get
            {
                return "Amount Financed: " + amount.ToString("C2");
            }
        }
        public string FinanceCharge { get; set; }
        //TotalofPayments	
        //APR	
        //Interest90	
        //DocumentPreperationFee	
        //StorageFee	
        //FirearmFee	
        //TotalFinanceCharge	
        public string By30 { get; set; }
        public string By60 { get; set; }
        public string By90 { get; set; }
        public string MonthlyInterestAmount { get; set; }
        public string RenewCost { get; set; }
        public string PickupCost { get; set; }

        public PawnCalcItem(Pawn pawn)
        {
            if (pawn.Amount > 0)
            {
                numberofguns = pawn.NumberOfFirearms;
                amount = pawn.Amount;
                InterestCalcEngine calcengine30;
                try
                {
                    calcengine30 = new InterestCalcEngine(pawn, pawn.Date.Date.AddDays(30), false);
                }
                catch (Exception Ex)
                {
                    throw new Exception("Unable to Calculate Interest",Ex); 
                }
                MonthlyInterestAmount = "Monthly Interest is: " + calcengine30.MonthlyInterest.ToString("c2");
                FinanceCharge = "Finaince Charge is: " + calcengine30.Interest.ToString("c2");
                PickupCost = "Pickup cost is" + (calcengine30.Interest + (calcengine30.MonthlyInterest * 2) + pawn.Amount).ToString("c2");
                RenewCost = "Renew Cost is: " + (calcengine30.Interest + (calcengine30.MonthlyInterest * 2)).ToString("c2");
                By30 = "By " + pawn.Date.Date.AddDays(30).ToString("d") + ", " + (calcengine30.Interest + (calcengine30.MonthlyInterest * 0) + pawn.Amount).ToString("c2") + " is due";
                By60 = "By " + pawn.Date.Date.AddDays(60).ToString("d") + ", " + (calcengine30.Interest + (calcengine30.MonthlyInterest * 1) + pawn.Amount).ToString("c2") + " is due";
                By90 = "By " + pawn.Date.Date.AddDays(90).ToString("d") + ", " + (calcengine30.Interest + (calcengine30.MonthlyInterest * 2) + pawn.Amount).ToString("c2") + " is due";
            }
        }
    }

    public class PawnCalcSelection
    {
        //private PawnActionEnum action;
        public PawnActionEnum Action { get; set; }

        private DateTime actiondate;
        public DateTime ActionDate { get { return actiondate; } set { actiondate = value;} }

        private decimal actionamount;
        public decimal ActionAmount { get { return actionamount; } set { actionamount = value; } }

        private decimal interestamount;
        public decimal InterestAmount { get { return interestamount; } set { interestamount = value; } }

        private string label;
        public string Label { get { return label; } set { label = value; } }

        public string ActionAmountString 
        { 
            get 
            { 
                return actionamount.ToString("c")+ " " + actiondate.ToString("d") + " " + label; 
            } 
        }

        public bool IsDefault { get; set; }

        public PawnCalcSelection(PawnActionEnum action, DateTime actiondate, decimal actionamount, decimal interestamount, bool isdefault, string label)
        {
            Action = action;
            ActionDate = actiondate;
            ActionAmount = actionamount;
            InterestAmount = interestamount;
            IsDefault = isdefault;
            Label = label;
        }
    }

    public class InterestCalcEngine
    {
        decimal interest;
        public decimal Interest { get { return interest; } }

        decimal monthlyinterest;
        public decimal MonthlyInterest { get { return monthlyinterest; } }

        public InterestCalcEngine(Pawn pawn, DateTime actiondate, bool plusInterestOnly)
        {
            actiondate = actiondate.Date;
            pawn.Date = pawn.Date.Date;
            if (actiondate == pawn.Date)
            {
                actiondate = pawn.Date.AddDays(1);
            }



            var pawnfees_wa_interest = from PawnFees_WA_Interest i in App.PawnFees_WA_Interest
                                       where pawn.Amount >= i.AmountStart && pawn.Amount <= i.AmountEnd
                                            select new {i.MonthlyInterestAmount, i.MonthlyInterestPercent };

            foreach (var result in pawnfees_wa_interest)
            {
                monthlyinterest = (result.MonthlyInterestAmount > 0) ? result.MonthlyInterestAmount : (result.MonthlyInterestPercent * pawn.Amount);
            }
            
            var pawnfees_wa_preparation = from PawnFees_WA_Preparation i in App.PawnFees_WA_Preparation
                                       where pawn.Amount >= i.AmountStart && pawn.Amount <= i.AmountEnd
                                       select new { i.PreparationAmount};

            decimal preparation = 0;

            foreach (var result in pawnfees_wa_preparation)
            {
                preparation = result.PreparationAmount;
            }

            decimal firearmfee = App.StorageFee.Firearm;
            decimal storagefee = App.StorageFee.Item;

            decimal firearmcharge = firearmfee * pawn.NumberOfFirearms;

            double days = (actiondate - pawn.Date).Days;
            double interestDays = (DateTime.Now - pawn.Date).Days;
            int months = (int)decimal.Ceiling((decimal)days / 30);
            int interestMonths = (int)decimal.Ceiling((decimal)interestDays / 30);
            int pawnperiods = (int)decimal.Ceiling((decimal)days / 90);

                        if (days > 0)
            {
                if (plusInterestOnly == false)
                {
                    interest =
                        (storagefee * pawnperiods) +
                        (firearmcharge * pawnperiods) +
                        (monthlyinterest * months) +
                        (preparation * pawnperiods);
                }
                else
                {
                    interest =
                        (storagefee * pawnperiods) +
                        (firearmcharge * pawnperiods) +
                        (monthlyinterest * interestMonths) +
                        (preparation * pawnperiods);
                }
            }
            else
            {
                interest = 0;
            }
        }
    }

    public class PawnCalcTotals : INotifyPropertyChanged
    {
        private decimal interest;
        public decimal Interest
        {
            get { return interest; }
            set
            {
                interest = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Interest"));
            }
        }
        private decimal total;
        public decimal Total
        {
            get { return total; }
            set
            {
                total = value;
                OnPropertyChanged(new PropertyChangedEventArgs("Total"));
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, e);
            }
        }

    }
}
