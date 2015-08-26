using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.ObjectModel;
using System.ComponentModel;

namespace Shell.Data
{
    public class PawnQueueItem : INotifyPropertyChanged
    {
        public Pawn Pawn { get; set; }
        public PawnCalcSelection PawnCalcSelection { get; set; }

        public bool IsLate
        {
            get
            {
                DateTime nintydaysago = DateTime.Now.Date.AddDays(-90);
                DateTime pawndate = Pawn.Date.Date;
                return (pawndate < nintydaysago);
            }
        }

        public string QueueLineTextColor
        {
            get
            {
                return (IsLate) ? "Red" : "Black";
            }
        }

        private Collection<PawnCalcSelection> selections;

        public Collection<PawnCalcSelection> RedeemSelections
        {
            get
            {
                Collection<PawnCalcSelection> redeemselections = new Collection<PawnCalcSelection>();
                var qry = from PawnCalcSelection pawncalcselection in selections
                          where pawncalcselection.Action == PawnActionEnum.Redeem
                          select pawncalcselection;
                foreach (PawnCalcSelection row in qry)
                {
                    redeemselections.Add(row);
                }
                return redeemselections;
            }
        }

        public Collection<PawnCalcSelection> RenewSelections
        {
            get
            {
                Collection<PawnCalcSelection> redeemselections = new Collection<PawnCalcSelection>();
                var qry = from PawnCalcSelection pawncalcselection in selections
                          where pawncalcselection.Action == PawnActionEnum.Renew
                          select pawncalcselection;
                foreach (PawnCalcSelection row in qry)
                {
                    redeemselections.Add(row);
                }
                return redeemselections;
            }
        }

        public PawnQueueItem(Data.Pawn pawn, PawnCalcSelection selection)
        {
            Pawn = pawn;
            PawnCalcSelection = selection;

            selections = new Collection<PawnCalcSelection>();

            decimal interestNow = new InterestCalcEngine(pawn, DateTime.Now.Date, false).Interest;
            decimal interest90 = new InterestCalcEngine(pawn, Pawn.Date.Date.AddDays(90), false).Interest;
            decimal interest90PlusInterestOnly = new InterestCalcEngine(pawn, Pawn.Date.Date.AddDays(90), true).Interest;

                if (Pawn.Date.Date.AddDays(90) > DateTime.Now.Date) // hasn't expired
                {
                    selections.Add(new PawnCalcSelection(PawnActionEnum.Redeem, DateTime.Now.Date, interestNow + Pawn.Amount, interestNow, true, "")); // Today
                    selections.Add(new PawnCalcSelection(PawnActionEnum.Renew, Pawn.Date.Date.AddDays(90), interest90, interest90, true, ""));  // 90 day
                }
                else // has expired
                {
                    selections.Add(new PawnCalcSelection(PawnActionEnum.Redeem, DateTime.Now.Date, interestNow + Pawn.Amount, interestNow, true,"")); // setup + interest
                    selections.Add(new PawnCalcSelection(PawnActionEnum.Renew, Pawn.Date.Date.AddDays(90), interest90, interest90, true, "Backdate")); // renew backdate (90 day), default
                    selections.Add(new PawnCalcSelection(PawnActionEnum.Renew, DateTime.Now.Date, interest90PlusInterestOnly, interest90PlusInterestOnly, false, "Int Only")); // renew today, extra interest only
                    selections.Add(new PawnCalcSelection(PawnActionEnum.Renew, DateTime.Now.Date, interestNow, interestNow, false,"Full")); // renew today, full setup
                }

        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, e);
        }

    }
}
