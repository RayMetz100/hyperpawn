using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Threading;
using System.Printing;
using System.IO;

namespace HyperPawn.Reporting
{
    class PrintXPS
    {
        
        public static void Print()
        {
            //MessageBox.Show("PrintXPS");

            // Create the secondary thread and pass the printing method for 
            // the constructor's ThreadStart delegate parameter. The BatchXPSPrinter
            // class is defined below.
            Thread printingThread = new Thread(BatchXPSPrinter.PrintXPS);

            // Set the thread that will use PrintQueue.AddJob to single threading.
            printingThread.SetApartmentState(ApartmentState.STA);

            // Start the printing thread. The method passed to the Thread 
            // constructor will execute.
            printingThread.Start();
        }

    }
    public class BatchXPSPrinter
    {
        public static void PrintXPS()
        {
            // Create print server and print queue.
            LocalPrintServer localPrintServer = new LocalPrintServer();
            PrintQueue defaultPrintQueue = LocalPrintServer.GetDefaultPrintQueue();

            try
            {
                // Print the Xps file while providing XPS validation and progress notifications.
                PrintSystemJobInfo xpsPrintJob = defaultPrintQueue.AddJob("Pawn Ticket", @"C:\Users\raymetz\Desktop\WPF Printing notes.xps", false);
            }
            catch (Exception e) // PrintJobException not found?
            {
                MessageBox.Show(e.InnerException.Message);
            }
        }// end PrintXPS method

    }// end BatchXPSPrinter class
}
