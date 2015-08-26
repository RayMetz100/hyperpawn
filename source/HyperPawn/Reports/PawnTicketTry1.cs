using System.IO;
using System.IO.Packaging;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Markup;
using System.Windows.Xps.Packaging;
using System;
using System.Windows.Xps;


namespace HyperPawn.Reports
{
    class PawnTicketTry1
    {

        public void Print()
        {
            MemoryStream xpsStream = new MemoryStream();
            Package pack = Package.Open(xpsStream, FileMode.CreateNew);

            string inMemPackageName= "memorystream://myXps.xps";
            Uri packageUri = new Uri(inMemPackageName);


            PackageStore.AddPackage(packageUri, pack);


            XpsDocument xpsDoc = new XpsDocument(pack, CompressionOption.SuperFast, inMemPackageName);


            XpsDocumentWriter xpsDocWriter = XpsDocument.CreateXpsDocumentWriter(xpsDoc);


            FixedDocument doc = CreatePawnTicket();
            //DocumentPaginator documentPaginator = (FlowDocument)IDocumentPaginatorSource).DocumentPaginator;
            //documentPaginator = New DocumentPaginatorWrapper(documentPaginator, pageSize, margin, documentStatus, firstPageHeaderPath, primaryHeaderPath)
            xpsDocWriter.Write(doc);

            
            
            
            //Package package = 
            //XpsDocument xpsd = new XpsDocument((filename, FileAccess.ReadWrite);
        //    //XpsDocumentWriter xw = XpsDocument.CreateXpsDocumentWriter(xpsd);
        //    xw.Write(doc);
        //    xpsd.Close();
        }

        private FixedDocument CreatePawnTicket()
        {
            FixedDocument doc = new FixedDocument();
            doc.Pages.Add(CreatePawnTicketContent());
            return doc;
        }


        private PageContent CreatePawnTicketContent()
        {
            PageContent pageContent = new PageContent();
            FixedPage fixedPage = new FixedPage();
            UIElement visual = PawnTicketUIElement();

            FixedPage.SetLeft(visual, 0);
            FixedPage.SetTop(visual, 0);

            double pageWidth = 96 * 8.5;
            double pageHeight = 96 * 11;

            fixedPage.Width = pageWidth;
            fixedPage.Height = pageHeight;

            fixedPage.Children.Add((UIElement)visual);

            Size sz = new Size(8.5 * 96, 11 * 96);
            fixedPage.Measure(sz);
            fixedPage.Arrange(new Rect(new Point(), sz));
            fixedPage.UpdateLayout();

            ((IAddChild)pageContent).AddChild(fixedPage);
            return pageContent;
        }

        private UIElement PawnTicketUIElement()
        {
            TextBlock tb = new TextBlock(new Run("Hello World"));
            UIElement ui = tb as UIElement;
            return ui;
        }

    }
}
