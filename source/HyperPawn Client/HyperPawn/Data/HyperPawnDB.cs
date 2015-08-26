using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Xml;
using System.Windows;

namespace Shell.Data
{
    public class HyperPawnDB
    {
        private string connectionString = Properties.Settings.Default.DatabaseConnection;

        public Pawn PawnGetDetails(int pawnid)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("PawnGetDetails", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PawnId", pawnid);

            try
            {
                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                if (reader.Read())
                {
                    DateTime dti;
                    decimal ir;
                    Pawn currentpawn = new Pawn(pawnid,
                        DateTime.Parse(reader["PawnDate"].ToString()),
                        int.Parse(reader["FirstPawnId"].ToString()),
                        DateTime.Parse(reader["FirstPawnDate"].ToString()),
                        reader["Location"].ToString(),
                        Char.Parse(reader["PawnStatusId"].ToString()),
                        DateTime.TryParse(reader["PawnStatusDate"].ToString(), out dti) ? dti : (DateTime?)null,
                        decimal.TryParse(reader["InterestReceived"].ToString(), out ir) ? ir : (decimal?)null,
                        null,
                        decimal.Parse(reader["Amount"].ToString()),
                        0,
                        reader["Note"].ToString());
                    currentpawn.Customer = PartyGetDetails(Int32.Parse(reader["CustomerId"].ToString()));

                    currentpawn.Items = new ObservableCollection<Item>();

                    reader.NextResult();

                    Item currentitem;

                    while (reader.Read())
                    {
                        int ig;
                        currentitem = new Item(
                        int.Parse(reader["ItemId"].ToString()), int.Parse(reader["ItemTypeId"].ToString()), int.Parse(reader["ItemSubTypeId"].ToString()), int.Parse(reader["ItemTableId"].ToString()),
                            //int.Parse(reader["DisplayOrder"].ToString()), 
                        (decimal)reader["Amount"], reader["Description"].ToString(), int.TryParse(reader["GunLogNumber"].ToString(), out ig) ? ig : (int?)null,
                        reader["Make"].ToString(), reader["Model"].ToString(), reader["Serial"].ToString(),
                        reader["Caliber"].ToString(), reader["Action"].ToString(), reader["Barrel"].ToString()
                        );

                        currentpawn.Items.Add(currentitem);
                    }

                    return currentpawn;
                    //if (i.ItemTypeId == 3)
                    //    l.IsGun = true;
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                conn.Close();
            }
        }

        public Party PartyGetDetails(int partyid)
        {
            SqlConnection conn = new SqlConnection(connectionString);

            try
            {
                SqlCommand cmd = new SqlCommand("PartyGetDetails", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PartyId", partyid);
                //cmd.Parameters.AddWithValue("@IDNumber", IDNumber);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.Read())
                {
                    DateTime dti;
                    DateTime dtb;
                    Party party = new Party(partyid, reader["IDNumber"].ToString(),
                        DateTime.TryParse(reader["IdExpiration"].ToString(), out dti) ? dti : (DateTime?)null,
                        DateTime.TryParse(reader["DateOfBirth"].ToString(), out dtb) ? dtb : (DateTime?)null,
                        reader["Last"].ToString(), reader["First"].ToString(), reader["Middle"].ToString(),
                        reader["Street"].ToString(), reader["City"].ToString(), reader["State"].ToString(), reader["Zip"].ToString(),
                        reader["Sex"].ToString(), reader["Height"].ToString(), reader["Weight"].ToString(), reader["Eyes"].ToString(), reader["Race"].ToString(), reader["Hair"].ToString(),
                        reader["Phone"].ToString(), reader["Email"].ToString(), reader["Note"].ToString(),
                        0, 0, int.Parse(reader["ItemsAvailable"].ToString()), reader["IntegrationId"].ToString());
                    return party;
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                conn.Close();
            }
        }

        public ObservableCollection<Item> PartyGetItems(int partyid)
        {
            SqlConnection conn = new SqlConnection(connectionString);

            SqlCommand cmd = new SqlCommand("PartyGetItems", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PartyId", partyid);

            ObservableCollection<Item> items = new ObservableCollection<Item>();
            try
            {
                Item currentitem = new Item();
                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                while (reader.Read())
                {
                    currentitem = new Item(
                        int.Parse(reader["ItemId"].ToString()),
                        int.Parse(reader["ItemTypeId"].ToString()),
                        int.Parse(reader["ItemSubTypeId"].ToString()),
                        int.Parse(reader["ItemTableId"].ToString()),
                        //0,//display order
                        decimal.Parse(reader["Amount"].ToString()),
                        reader["ItemDescription"].ToString(),
                        null,//GunLogNumber
                        reader["Make"].ToString(),
                        reader["Model"].ToString(),
                        reader["SerialNumber"].ToString(),
                        reader["Caliber"].ToString(),
                        reader["Action"].ToString(),
                        reader["BarrelLength"].ToString()
                        );
                    currentitem.MaxPawnDate = DateTime.Parse(reader["MaxPawnDate"].ToString());
                    items.Add(currentitem);
                }
                return items;
            }
            catch (Exception Ex)
            {
                new Exception("Failed to Get Items", Ex);
            }
            finally
            {
                conn.Close();
            }
            return items;
        }

        public Collection<Party> PartySearch(string Last, string First, ref int PawnToCustomerId)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PartySearch", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Last", Last);
            cmd.Parameters.AddWithValue("@First", First);
            SqlParameter PawnToCustomerIdParameter = new SqlParameter("@PawnToCustomerId", SqlDbType.Int);
            PawnToCustomerIdParameter.Direction = ParameterDirection.InputOutput;
            PawnToCustomerIdParameter.Value = PawnToCustomerId;
            cmd.Parameters.Add(PawnToCustomerIdParameter);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                Collection<Party> parties = new Collection<Party>();
                Party currentparty;
                DateTime dob;
                while (reader.Read())
                {
                    currentparty = new Party(
                        int.Parse(reader["PartyId"].ToString()),
                        reader["IDNumber"].ToString(),
                        DateTime.TryParse(reader["DateOfBirth"].ToString(), out dob) ? dob : (DateTime?)null,
                        reader["Last"].ToString(),
                        reader["First"].ToString(),
                        reader["City"].ToString(),
                        int.Parse(reader["ActivePawns"].ToString()),
                        int.Parse(reader["TotalPawns"].ToString()),
                        0//ItemsAvailable
                        );
                    parties.Add(currentparty);
                }
                PawnToCustomerId = int.Parse(PawnToCustomerIdParameter.Value.ToString());
                return parties;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Party PartySearchById(string IDNumber)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PartySearchById", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@IDNumber", IDNumber);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                Party p = null;
                DateTime dob;
                while (reader.Read())
                {
                    p = new Party(
                        int.Parse(reader["PartyId"].ToString()),
                        reader["IDNumber"].ToString(),
                        DateTime.TryParse(reader["DateOfBirth"].ToString(), out dob) ? dob : (DateTime?)null,
                        reader["Last"].ToString(),
                        reader["First"].ToString(),
                        reader["City"].ToString(),
                        int.Parse(reader["ActivePawns"].ToString()),
                        int.Parse(reader["TotalPawns"].ToString()),
                        0//ItemsAvailable
                        );
                    
                }
                
                return p;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Collection<PutAwayPawn> PawnGetPutAwayItems()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnGetPutAwayItems", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                Collection<PutAwayPawn> pawns = new Collection<PutAwayPawn>();
                PutAwayPawn currentpawn;
                while (reader.Read())
                {
                    currentpawn = new PutAwayPawn(
                        int.Parse(reader["PawnId"].ToString()),
                        DateTime.Parse(reader["PawnDate"].ToString()),
                        reader["Last"].ToString(),
                        reader["Item"].ToString()//,
                        //int.Parse(reader["FirearmLogReferenceId"].ToString())
                        );
                    pawns.Add(currentpawn);
                }
                return pawns;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Collection<PawnListEntry> TotalsGetDayDetail(DateTime day)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("TotalsGetDayDetail", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StartDate", day);
            cmd.Parameters.AddWithValue("@EndDate", day);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                Collection<PawnListEntry> rows = new Collection<PawnListEntry>();
                PawnListEntry currentrow;
                while (reader.Read())
                {
                    currentrow = new PawnListEntry(
                        reader["Type"].ToString(),
                        int.Parse(reader["Id"].ToString()),
                        DateTime.Parse(reader["PawnDate"].ToString()),
                        reader["Name"].ToString(),
                        reader["Description"].ToString(),
                        decimal.Parse(reader["Amount"].ToString()),
                        reader["Location"].ToString(),
                        reader["CurrentStatus"].ToString(),
                        DateTime.Parse(reader["StatusDate"].ToString()),
                        reader["Employee"].ToString()
                        );
                    rows.Add(currentrow);
                }
                return rows;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public ObservableCollection<PawnListEntry> PawnGetFloorList(int ItemTypeId)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnGetFloorList", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ItemTypeId", ItemTypeId);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                ObservableCollection<PawnListEntry> rows = new ObservableCollection<PawnListEntry>();
                PawnListEntry currentrow;
                while (reader.Read())
                {
                    currentrow = new PawnListEntry(
                        reader["Type"].ToString(),
                        int.Parse(reader["Id"].ToString()),
                        DateTime.Parse(reader["PawnDate"].ToString()),
                        int.Parse(reader["FirstPawnId"].ToString()),
                        DateTime.Parse(reader["FirstPawnDate"].ToString()),
                        reader["Name"].ToString(),
                        reader["Description"].ToString(),
                        decimal.Parse(reader["Amount"].ToString()),
                        reader["Location"].ToString(),
                        reader["CurrentStatus"].ToString(),
                        DateTime.Parse(reader["StatusDate"].ToString()),
                        reader["Employee"].ToString(),
                        reader["CustomerNote"].ToString(),
                        reader["PawnNote"].ToString(),
                        int.Parse(reader["Active"].ToString()),
                        int.Parse(reader["PaidInt"].ToString()),
                        int.Parse(reader["PickedUp"].ToString()),
                        int.Parse(reader["Floored"].ToString()),
                        int.Parse(reader["MonthsBehind"].ToString())
                        );
                    rows.Add(currentrow);
                }
                return rows;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Collection<PawnListEntry> ReportSearchItems(string SearchString, char? PawnStatusId)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("ReportSearchItems", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SearchString", SearchString);
            cmd.Parameters.AddWithValue("@PawnStatusId", PawnStatusId);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                Collection<PawnListEntry> rows = new Collection<PawnListEntry>();
                PawnListEntry currentrow;
                while (reader.Read())
                {
                    currentrow = new PawnListEntry(
                        reader["Type"].ToString(),
                        int.Parse(reader["Id"].ToString()),
                        DateTime.Parse(reader["PawnDate"].ToString()),
                        reader["Name"].ToString(),
                        reader["Description"].ToString(),
                        decimal.Parse(reader["Amount"].ToString()),
                        reader["Location"].ToString(),
                        reader["CurrentStatus"].ToString(),
                        DateTime.Parse(reader["StatusDate"].ToString()),
                        reader["Employee"].ToString()
                        );
                    rows.Add(currentrow);
                }
                return rows;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Collection<FirearmLogEntry> FirearmGetLog(int? lognumber, string receiptname, string dispositionname, string serialnumber)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("FirearmGetLog", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Top", 50);
            cmd.Parameters.AddWithValue("@All", 0);
            cmd.Parameters.AddWithValue("@LogNumber", lognumber);
            cmd.Parameters.AddWithValue("@ReceiptName", receiptname);
            cmd.Parameters.AddWithValue("@DispositionName", dispositionname);
            cmd.Parameters.AddWithValue("@SerialNumber", serialnumber);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                Collection<FirearmLogEntry> FirearmLogEntries = new Collection<FirearmLogEntry>();
                FirearmLogEntry CurrentFirearmLogEntry;
                DateTime DispositionDate;
                while (reader.Read())
                {
                    CurrentFirearmLogEntry = new FirearmLogEntry(
                    int.Parse(reader["FirearmLogReferenceId"].ToString()),
            int.Parse(reader["CreatedBy"].ToString()),
            reader["manufacturer and importer"].ToString(),
            reader["model"].ToString(),
            reader["serial number"].ToString(),
            reader["type"].ToString(),
            reader["caliber or guage"].ToString(),
            DateTime.Parse(reader["Receipt date"].ToString()),
            reader["Receipt name"].ToString(),
            reader["Receipt address or license number"].ToString(),
            DateTime.TryParse(reader["Disposition date of sale or other"].ToString(), out DispositionDate) ? DispositionDate : (DateTime?)null,
            reader["Disposition name"].ToString(),
            reader["Disposition address or license number"].ToString(),
            reader["FirstPawnId"].ToString(),
            reader["Location"].ToString(),
            reader["PawnStatus"].ToString(),
            reader["PawnStatusDate"].ToString()
             );
                    FirearmLogEntries.Add(CurrentFirearmLogEntry);
                }
                return FirearmLogEntries;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }

        }

        public ObservableCollection<Pawn> PawnGet(int partyid, int top, bool showall)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnGet", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PartyId", partyid);
            cmd.Parameters.AddWithValue("@Top", top);
            cmd.Parameters.AddWithValue("@ShowAll", showall);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);

                ObservableCollection<Pawn> pawns = new ObservableCollection<Pawn>();

                Pawn currentpawn;

                while (reader.Read())
                {
                    DateTime dti;
                    currentpawn = new Pawn(
                        int.Parse(reader["PawnId"].ToString()),
                        DateTime.Parse(reader["PawnDate"].ToString()),
                        int.Parse(reader["FirstPawnId"].ToString()),
                        DateTime.Parse(reader["FirstPawnDate"].ToString()),
                        reader["Location"].ToString(),
                        Char.Parse(reader["PawnStatusId"].ToString()),
                        DateTime.TryParse(reader["PawnStatusDate"].ToString(), out dti) ? dti : (DateTime?)null,
                        null,// interest received
                        reader["ItemDescriptionTicket"].ToString(),
                        decimal.Parse(reader["Amount"].ToString()),
                        int.Parse(reader["NumberOfFirearms"].ToString()),
                        reader["Note"].ToString()
                        );
                    currentpawn.Customer = PartyGetDetails(Int32.Parse(reader["PartyId"].ToString())
                    );
                    pawns.Add(currentpawn);
                }
                return pawns;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
            finally
            {
                conn.Close();
            }
        }

        public int PartySave(Party party, int employee)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            SqlCommand cmd = new SqlCommand("PartyUpsert", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter p = cmd.Parameters.Add("@PartyId", SqlDbType.Int);
            if (party.PartyId == 0)
                p.Direction = ParameterDirection.Output;
            else
                p.Direction = ParameterDirection.Input;
            p.Value = party.PartyId;
            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            cmd.Parameters.AddWithValue("@IdTypeId", 1);
            cmd.Parameters.AddWithValue("@IdState", "WA");
            cmd.Parameters.AddWithValue("@IDNumber", party.IDNumber);
            cmd.Parameters.AddWithValue("@IdIssued", null);
            cmd.Parameters.AddWithValue("@IdExpiration", party.IdExpiration);
            cmd.Parameters.AddWithValue("@DateOfBirth", party.DateOfBirth);
            cmd.Parameters.AddWithValue("@Last", party.Last);
            cmd.Parameters.AddWithValue("@First", party.First);
            cmd.Parameters.AddWithValue("@Middle", party.Middle);
            cmd.Parameters.AddWithValue("@Street", party.Street);
            cmd.Parameters.AddWithValue("@City", party.City);
            cmd.Parameters.AddWithValue("@State", party.State);
            cmd.Parameters.AddWithValue("@Zip", party.Zip);
            cmd.Parameters.AddWithValue("@Sex", party.Sex);
            cmd.Parameters.AddWithValue("@Height", party.Height);
            cmd.Parameters.AddWithValue("@Weight", party.Weight);
            cmd.Parameters.AddWithValue("@Eyes", party.Eyes);
            cmd.Parameters.AddWithValue("@Race", party.Race);
            cmd.Parameters.AddWithValue("@Hair", party.Hair);
            cmd.Parameters.AddWithValue("@Phone", party.Phone);
            cmd.Parameters.AddWithValue("@Email", party.Email);
            cmd.Parameters.AddWithValue("@Note", party.Note);


            cmd.ExecuteNonQuery();

            return Int32.Parse(p.Value.ToString());
        }

        public void FirearmAppendLogEntry(Data.FirearmLogEntry e)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            SqlCommand cmd = new SqlCommand("FirearmAppendLogEntry", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@FirearmLogReferenceId", e.FirearmLogReferenceId);
            cmd.Parameters.AddWithValue("@EmployeeId", e.EmployeeId);
            cmd.Parameters.AddWithValue("@Make", e.Make);
            cmd.Parameters.AddWithValue("@Model", e.Model);
            cmd.Parameters.AddWithValue("@Serial", e.Serial);
            cmd.Parameters.AddWithValue("@Type", e.Type);
            cmd.Parameters.AddWithValue("@Caliber", e.Caliber);
            cmd.Parameters.AddWithValue("@ReceiptDate", e.ReceiptDate);
            cmd.Parameters.AddWithValue("@ReceiptName", e.ReceiptName);
            cmd.Parameters.AddWithValue("@ReceiptAddress", e.ReceiptAddress);
            cmd.Parameters.AddWithValue("@DispositionDate", e.DispositionDate);
            cmd.Parameters.AddWithValue("@DispositionName", e.DispositionName);
            cmd.Parameters.AddWithValue("@DispositionAddress", e.DispositionAddress);
            try
            {
                cmd.ExecuteNonQuery();
                return;
            }
            catch (Exception Ex)
            {
                throw new Exception("FirearmAppendLogEntry: Failed to save Pawn", Ex);
            }
        }

        public int PawnSave(Pawn pawn, int employee)
        {
            //pawn.Customer.PartyId = PartySave(pawn.Customer, employee);

            SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            SqlCommand cmd = new SqlCommand("PawnSave", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter pawnidparam = cmd.Parameters.Add("@PawnId", SqlDbType.Int);
            if (pawn.PawnId == 0)
                pawnidparam.Direction = ParameterDirection.Output;
            else
                pawnidparam.Direction = ParameterDirection.Input;
            pawnidparam.Value = pawn.PawnId;
            cmd.Parameters.AddWithValue("@FirstPawnId", pawn.FirstPawnId);
            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            cmd.Parameters.AddWithValue("@PawnDate", pawn.Date);
            cmd.Parameters.AddWithValue("@CustomerId", pawn.Customer.PartyId);


            cmd.Parameters.AddWithValue("@Location", pawn.Location);
            cmd.Parameters.AddWithValue("@PawnStatusId", pawn.PawnStatusId);
            cmd.Parameters.AddWithValue("@PawnStatusDate", pawn.PawnStatusDate);
            cmd.Parameters.AddWithValue("@InterestReceived", pawn.InterestReceived);

            cmd.Parameters.AddWithValue("@ItemsXml", pawn.ItemsXml);
            cmd.Parameters.AddWithValue("@PawnNote", pawn.PawnNote);

            try
            {
                cmd.ExecuteNonQuery();
                return Int32.Parse(pawnidparam.Value.ToString());
            }
            catch (Exception Ex)
            {
                throw new Exception("Failed to save Pawn\n" + Ex.Message);
            }
        }

        public bool PawnUpdateLocation(int employee, int pawnid, string location)
        {
            //pawn.Customer.PartyId = PartySave(pawn.Customer, employee);

            SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            SqlCommand cmd = new SqlCommand("PawnUpdateLocation", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@PawnId", pawnid);
            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            cmd.Parameters.AddWithValue("@Location", location);

            try
            {
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception Ex)
            {
                throw new Exception("PawnUpdateLocation: Failed to update Pawn", Ex);
            }
        }

        public int PurchaseSave(Purchase purchase, int employee)
        {
            //purchase.Customer.PartyId = PartySave(purchase.Customer, employee);

            SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            SqlCommand cmd = new SqlCommand("PurchaseSave", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter purchaseidparam = cmd.Parameters.Add("@PurchaseId", SqlDbType.Int);
            if (purchase.PurchaseId == 0)
                purchaseidparam.Direction = ParameterDirection.Output;
            else
                purchaseidparam.Direction = ParameterDirection.Input;
            purchaseidparam.Value = purchase.PurchaseId;
            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            cmd.Parameters.AddWithValue("@PurchaseDate", purchase.Date);
            cmd.Parameters.AddWithValue("@CustomerId", purchase.Customer.PartyId);
            cmd.Parameters.AddWithValue("@Location", purchase.Location);
            cmd.Parameters.AddWithValue("@ItemsXml", purchase.ItemsXml);

            try
            {
                cmd.ExecuteNonQuery();
                return Int32.Parse(purchaseidparam.Value.ToString());
            }
            catch (Exception Ex)
            {
                throw new Exception("PurchaseSave: Failed to save Pawn", Ex);
            }
        }

        public bool PawnDelete(int pawnid)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnDelete", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PawnId", pawnid);
            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public bool PawnFloor(int pawnid, int employee)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnFloor", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PawnId", pawnid);
            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public bool PawnRedeem(int pawnid, decimal interestreceived, int employee)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnRedeem", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PawnId", pawnid);
            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            cmd.Parameters.AddWithValue("@InterestReceived", interestreceived);
            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public int PawnRenew(int renewingpawnid, DateTime renewdate, decimal interestreceived, int employee)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            //Create Command w/Parameters 
            SqlCommand cmd = new SqlCommand("PawnRenew", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@RenewingPawnId", renewingpawnid);
            cmd.Parameters.AddWithValue("@InterestReceived", interestreceived);

            SqlParameter newpawnidparam = cmd.Parameters.Add("@NewPawnId", SqlDbType.Int);
            newpawnidparam.Direction = ParameterDirection.Output;

            cmd.Parameters.AddWithValue("@EmployeeId", employee);
            cmd.Parameters.AddWithValue("@RenewDate", renewdate);
            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                int newpawnid = 0;
                return int.TryParse(newpawnidparam.Value.ToString(), out newpawnid) ? newpawnid : 0;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }



        public List<PawnStatus> TaxyGetPawnStatus()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetPawnStatus", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                PawnStatus currentitem;
                List<PawnStatus> pawnstatus = new List<PawnStatus>();
                while (reader.Read())
                {
                    currentitem = new PawnStatus(
                        Char.Parse(reader["PawnStatusId"].ToString()),
                        reader["PawnStatus"].ToString()
                        );
                    pawnstatus.Add(currentitem);
                }

                return pawnstatus;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }

        }

        public List<ItemType> TaxyGetItemTypes()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetItemTypes", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                ItemType currentitem;
                List<ItemType> itemtypes = new List<ItemType>();
                while (reader.Read())
                {
                    currentitem = new ItemType(int.Parse(reader["ItemTypeId"].ToString()), int.Parse(reader["DisplayOrder"].ToString()), reader["ItemTypeName"].ToString());
                    itemtypes.Add(currentitem);
                }

                return itemtypes;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }

        }

        public List<ItemSubType> TaxyGetItemSubTypes()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetItemSubTypes", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                ItemSubType currentitem;
                List<ItemSubType> itemsubtypes = new List<ItemSubType>();
                while (reader.Read())
                {
                    currentitem = new ItemSubType(int.Parse(reader["ItemTypeId"].ToString()), int.Parse(reader["ItemSubTypeId"].ToString()), int.Parse(reader["DisplayOrder"].ToString()), reader["ItemSubTypeName"].ToString(), int.Parse(reader["ItemTableId"].ToString()));
                    itemsubtypes.Add(currentitem);
                }

                return itemsubtypes;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }

        }

        public List<PawnFees_WA_Interest> TaxyGetPawnFees_WA_Interest()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetPawnFees_WA_Interest", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                PawnFees_WA_Interest currentitem;
                List<PawnFees_WA_Interest> interestwa = new List<PawnFees_WA_Interest>();
                while (reader.Read())
                {
                    currentitem = new PawnFees_WA_Interest(
                        decimal.Parse(reader["AmountStart"].ToString()),
                        decimal.Parse(reader["AmountEnd"].ToString()),
                        decimal.Parse(reader["MonthlyInterestAmount"].ToString()),
                        decimal.Parse(reader["MonthlyInterestPercent"].ToString())
                        );
                    interestwa.Add(currentitem);
                }
                return interestwa;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public List<PawnFees_WA_Preparation> TaxyGetPawnFees_WA_Preparation()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetPawnFees_WA_Preparation", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                PawnFees_WA_Preparation currentitem;
                List<PawnFees_WA_Preparation> interestwa = new List<PawnFees_WA_Preparation>();
                while (reader.Read())
                {
                    currentitem = new PawnFees_WA_Preparation(
                        decimal.Parse(reader["AmountStart"].ToString()),
                        decimal.Parse(reader["AmountEnd"].ToString()),
                        decimal.Parse(reader["PreparationAmount"].ToString())
                        );
                    interestwa.Add(currentitem);
                }
                return interestwa;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Collection<TaxyComboSource> TaxyGetComboSource(string source, int top)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand(source, conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Top", top);
            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                TaxyComboSource currentitem;
                Collection<TaxyComboSource> list = new Collection<TaxyComboSource>();
                while (reader.Read())
                {
                    currentitem = new TaxyComboSource(
                        int.Parse(reader["Id"].ToString()),
                        reader["Value"].ToString(),
                        int.Parse(reader["Count"].ToString())
                        );
                    list.Add(currentitem);
                }
                return list;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }


        }

        public List<Employee> TaxyGetEmployees()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetEmployees", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                Employee currentitem;
                List<Employee> employees = new List<Employee>();
                while (reader.Read())
                {
                    currentitem = new Employee(
                        int.Parse(reader["EmployeeId"].ToString()),
                        reader["Initials"].ToString(),
                        reader["Last"].ToString(),
                        reader["First"].ToString(),
                        reader["Middle"].ToString()
                        );
                    employees.Add(currentitem);
                }
                return employees;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public ObservableCollection<Account> TaxyGetAccounts()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetAccounts", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                Account currentitem;
                ObservableCollection<Account> items = new ObservableCollection<Account>();
                while (reader.Read())
                {
                    currentitem = new Account(
                        int.Parse(reader["AccountId"].ToString()),
                        reader["AccountName"].ToString()
                        );
                    items.Add(currentitem);
                }
                return items;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public ObservableCollection<AccountTransactionTaxCategory> TaxyGetAccountTransactionTaxCategories()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TaxyGetAccountTransactionTaxCategories", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                AccountTransactionTaxCategory currentitem;
                ObservableCollection<AccountTransactionTaxCategory> items = new ObservableCollection<AccountTransactionTaxCategory>();
                while (reader.Read())
                {
                    currentitem = new AccountTransactionTaxCategory(
                        int.Parse(reader["AccountTransactionTaxCategoryId"].ToString()),
                        reader["AccountTransactionTaxCategoryName"].ToString()
                        );
                    items.Add(currentitem);
                }
                return items;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public Collection<AccountTransaction> AccountTransactionsGet(DateTime? StartDate, DateTime? EndDate)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("AccountTransactionsGet", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StartDate", StartDate);
            cmd.Parameters.AddWithValue("@EndDate", EndDate);

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                AccountTransaction currentitem;
                Collection<AccountTransaction> items = new Collection<AccountTransaction>();
                while (reader.Read())
                {
                    currentitem = new AccountTransaction(
                        int.Parse(reader["AccountTransactionId"].ToString()),
                        DateTime.Parse(reader["TransactionDate"].ToString()),
                        int.Parse(reader["AccountId"].ToString()),
                        int.Parse(reader["AccountTransactionTaxCategoryId"].ToString()),
                        decimal.Parse(reader["Amount"].ToString())
                        );
                    items.Add(currentitem);
                }
                return items;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public void AccountTransactionsSave(Collection<AccountTransaction> transactions)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand insertCommand = new SqlCommand("AccountTransactionsSave", conn);
            insertCommand.CommandType = CommandType.StoredProcedure;
            SqlParameter tvpParam = insertCommand.Parameters.AddWithValue("@tvpAccountTransactions", transactions);
            tvpParam.SqlDbType = SqlDbType.Structured;

            try
            {
                conn.Open();
                //insertCommand.ExecuteNonQuery();

                return;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public List<TaxTotal> TotalsGetTaxTotals(DateTime StartDate, DateTime EndDate)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TotalsGetTaxTotals", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StartDate", StartDate);
            cmd.Parameters.AddWithValue("@EndDate", EndDate);

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.Default);
                TaxTotal currentitem;
                List<TaxTotal> items = new List<TaxTotal>();
                while (reader.Read())
                {
                    currentitem = new TaxTotal(
                        DateTime.Parse(reader["StartDate"].ToString()),
                        DateTime.Parse(reader["EndDate"].ToString()),
                        reader["TaxLine"].ToString(),
                        Decimal.Parse(reader["Amount"].ToString())
                        );
                    items.Add(currentitem);
                }
                return items;
            }
            catch (Exception Ex)
            {
                throw Ex;
            }
        }

        public XmlDocument LeadsOnlineGet(DateTime start, DateTime end)
        {
            XmlDocument doc = new XmlDocument();

            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("LeadsOnlineGet", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@StartDate", start);
            cmd.Parameters.AddWithValue("@EndDate", end);

            try
            {
                conn.Open();



                //SqlDataReader dr = cmd.ExecuteReader();
                //doc.Load(dr.GetSqlXml(0).CreateReader());

                XmlReader reader = cmd.ExecuteXmlReader();
                reader.Read();
                while (reader.ReadState != System.Xml.ReadState.EndOfFile)
                {
                    doc.Load(reader);
                }

                conn.Close();
            }
            catch (Exception Ex)
            {
                MessageBox.Show(Ex.ToString());
            }

            return doc;
        }

        public decimal TotalsGetAmountLoanedOut()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("TotalsGetAmountLoanedOut", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter amountloanedoutparameter = new SqlParameter("@AmountLoanedOut", SqlDbType.Money);
            amountloanedoutparameter.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(amountloanedoutparameter);
            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                return (decimal)amountloanedoutparameter.Value;
            }
            catch
            {
                return 0;
            }

        }

        public bool CheckDbConnection()
        {
            SqlConnection conn = new SqlConnection(connectionString);
            try
            {
                conn.Open();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public bool ReportValidatePassword(string password)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("ReportValidatePassword", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@password", password);

            SqlParameter RetVal = cmd.Parameters.Add("RetVal", SqlDbType.Int);
            RetVal.Direction = ParameterDirection.ReturnValue;

            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
                if ((int)(cmd.Parameters["RetVal"].Value) == 0)
                    return true;
                else
                {
                    MessageBox.Show("Wrong Password");
                    return false;
                }
            }
            catch (Exception Ex)
            {
                MessageBox.Show(Ex.ToString());
                return false;
            }
        }

        public bool SettingMaintain(
            string key,
            string value,
            bool deleteKey,
            string encryptedValueOld,
            string encryptedValueNew
            )
        {
            

            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SettingMaintain", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@Key", key);
            cmd.Parameters.AddWithValue("@Value", value);
            cmd.Parameters.AddWithValue("@DeleteKey", deleteKey);
            cmd.Parameters.AddWithValue("@EncryptedValueOld", encryptedValueOld);
            cmd.Parameters.AddWithValue("@EncryptedValueNew", encryptedValueNew);

            SqlParameter RetVal = cmd.Parameters.Add("RetVal", SqlDbType.Int);
            RetVal.Direction = ParameterDirection.ReturnValue;

            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
                if ((int)(cmd.Parameters["RetVal"].Value) == 0)
                    return true;
                else
                {
                    MessageBox.Show("Old report password did not match!  No change.");
                    return false;
                }
            }
            catch (Exception Ex)
            {
                MessageBox.Show(Ex.ToString());
                return false;
            }
        }

        // <summary>
        /// Gets the data from the Datalayer
        /// </summary>
        /// <returns>DataTable</returns>

        public DataTable GetSQLDailyTransactionData(DateTime StartDate, DateTime EndDate)
        {
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("ReportDailyTotals", conn);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@StartDate", StartDate);
            cmd.Parameters.AddWithValue("@EndDate", EndDate);

            DataTable table = new DataTable();
            try
            {
                conn.Open();
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                adapter.Fill(table);
                conn.Close();
                return table;
            }
            catch (Exception Ex)
            {
                MessageBox.Show(Ex.ToString());
                return table;
            }

        }


    }
}
