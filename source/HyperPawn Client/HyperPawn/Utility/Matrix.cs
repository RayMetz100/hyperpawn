using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Shell.Utility
{
    public struct DNGINFO
    {
        public short LPT_Nr;
        public short LPT_Adr;
        public short DNG_Cnt;
    };

    public class Matrix32
    {
        /* This c#-class will import the Matrix API classes */

        [DllImport(@"MATRIX32.DLL", EntryPoint = "Init_MatrixAPI", CallingConvention = CallingConvention.StdCall)]
        public static extern short Init_MatrixAPI();

        [DllImport("MATRIX32.DLL", EntryPoint = "Release_MatrixAPI", CallingConvention = CallingConvention.StdCall)]
        public static extern short Release_MatrixAPI();

        [DllImport("MATRIX32.DLL", EntryPoint = "GetVersionAPI", CallingConvention = CallingConvention.StdCall)]
        public static extern int GetVersionAPI();

        [DllImport("MATRIX32.DLL", EntryPoint = "GetVersionDRV", CallingConvention = CallingConvention.StdCall)]
        public static extern int GetVersionDRV();

        [DllImport("MATRIX32.DLL", EntryPoint = "GetVersionDRV_USB", CallingConvention = CallingConvention.StdCall)]
        public static extern int GetVersionDRV_USB();

        [DllImport("MATRIX32.DLL", EntryPoint = "GetVersionDRV_USB", CallingConvention = CallingConvention.StdCall)]
        public static extern void SetW95Access(short Mode);

        [DllImport("MATRIX32.DLL", EntryPoint = "GetPortAdr", CallingConvention = CallingConvention.StdCall)]
        public static extern short GetPortAdr(short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "PausePrinterActivity", CallingConvention = CallingConvention.StdCall)]
        public static extern short PausePrinterActivity();

        [DllImport("MATRIX32.DLL", EntryPoint = "ResumePrinterActivity", CallingConvention = CallingConvention.StdCall)]
        public static extern short ResumePrinterActivity();

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_Find", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_Find();

        //[DllImport("MATRIX32.DLL", EntryPoint = "Dongle_FindEx", CallingConvention = CallingConvention.StdCall)]
        //unsafe public static extern short Dongle_FindEx(DNGINFO* DngInfo);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_Version", CallingConvention = CallingConvention.StdCall)]
        public static extern int Dongle_Version(short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_Model", CallingConvention = CallingConvention.StdCall)]
        public static extern int Dongle_Model(short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_MemSize", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_MemSize(short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_Count", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_Count(short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_ReadData", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_ReadData(int UserCode, ref int Data, short Count, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_ReadDataEx", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_ReadDataEx(int UserCode, ref int Data, short Fpos, short Count, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_ReadSerNr", CallingConvention = CallingConvention.StdCall)]
        public static extern int Dongle_ReadSerNr(int UserCode, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_WriteData", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_WriteData(int UserCode, ref int Data, short Count, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_WriteDataEx", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_WriteDataEx(int UserCode, ref int Data, short Fpos, short Count, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_WriteKey", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_WriteKey(int UserCode, ref int KeyData, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_GetKeyFlag", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_GetKeyFlag(int UserCode, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_Exit", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_Exit();

        //[DllImport("MATRIX32.DLL", EntryPoint = "SetConfig_MatrixNet", CallingConvention = CallingConvention.StdCall)]
        //unsafe public static extern short SetConfig_MatrixNet(short nAccess, char* nFile);
        // public static extern short SetConfig_MatrixNet(short nAccess, ref char nFile);

        [DllImport("MATRIX32.DLL", EntryPoint = "GetConfig_MatrixNet", CallingConvention = CallingConvention.StdCall)]
        public static extern int GetConfig_MatrixNet(short Category);

        [DllImport("MATRIX32.DLL", EntryPoint = "LogIn_MatrixNet", CallingConvention = CallingConvention.StdCall)]
        public static extern short LogIn_MatrixNet(int UserCode, short AppSlot, short DngNr);

        [DllImport("MATRIX32.DLL", EntryPoint = "LogOut_MatrixNet", CallingConvention = CallingConvention.StdCall)]
        public static extern short LogOut_MatrixNet(int UserCode, short AppSlot, short DngNr);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_EncryptData", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_EncryptData(int UserCode, ref int DataBlock, short DngNr, short Port);

        [DllImport("MATRIX32.DLL", EntryPoint = "Dongle_DecryptData", CallingConvention = CallingConvention.StdCall)]
        public static extern short Dongle_DecryptData(int UserCode, ref int DataBlock, short DngNr, short Port);

        public static bool ValidateCustomerKey()
        {
/*            short DNG_Port;
            DNG_Port = 85;

            short RetCode;
            RetCode = Init_MatrixAPI();
            if (RetCode < 0)
            {
                MessageBox.Show("Init_MatrixAPI Return-Code: %d", RetCode.ToString());
            }

            if (Dongle_Count(DNG_Port) == 0)
            {
                MessageBox.Show("USB Licence Key Not Found");
                Release_MatrixAPI();
                return false;
            }

            short Count = Dongle_Count(85);

            int data = 0;
            
            RetCode = Dongle_ReadData(48203, ref data, 1, Count, 85);
            
            if (RetCode == -2)
            {
                MessageBox.Show("Incorrect Matrix Dongle(s) found");
                Release_MatrixAPI();
                return false;
            }

            //mxa
*/
            return true;
        }

        public static void TryIt()
        {


        }
    }



    //class Matrix
    //{
    //    [DllImport(@"C:\matrix\API\dll\matrix64.dll")]
    //    private static extern short Init_MatrixAPI();

    //    [DllImport(@"C:\matrix\API\dll\matrix64.dll")]
    //    private static extern short Release_MatrixAPI();

    //    [DllImport(@"C:\matrix\API\dll\matrix64.dll")]
    //    private static extern long GetVersionAPI();

    //    [DllImport(@"C:\matrix\API\dll\matrix64.dll")]
    //    private static extern short Init_MatrixAPI();

    //    [DllImport(@"C:\matrix\API\dll\matrix64.dll")]
    //    private static extern short Init_MatrixAPI();

    //    [DllImport(@"C:\matrix\API\dll\matrix64.dll")]
    //    private static extern short Init_MatrixAPI();



    //    public short start()
    //    {
    //        return Init_MatrixAPI();
    //    }
    //}
}
