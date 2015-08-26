using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Collections.ObjectModel;
using System.IO;
using System.Xml;

namespace Shell.Utils
{
    public class XMLUtils
    {
        public String UTF16ByteArrayToString(Byte[] characters)
        {

            UnicodeEncoding encoding = new UnicodeEncoding();
            String constructedString = encoding.GetString(characters);
            return (constructedString);
        }

        public Byte[] StringToUTF16ByteArray(String pXmlString)
        {
            UnicodeEncoding encoding = new UnicodeEncoding();
            Byte[] byteArray = encoding.GetBytes(pXmlString);
            return byteArray;
        }

        public string ObjectToXMLString(ObservableCollection<Data.Item> o)
        {
            Type t = typeof(
                ObservableCollection<Data.Item>

                );

            


            XmlSerializer xs = new XmlSerializer(t);

            String XmlizedString = null;



            MemoryStream memoryStream = new MemoryStream();
            XmlTextWriter xmlTextWriter = new XmlTextWriter(memoryStream, Encoding.Unicode);
            xs.Serialize(xmlTextWriter, o);
            memoryStream = (MemoryStream)xmlTextWriter.BaseStream;


            XmlizedString = UTF16ByteArrayToString(memoryStream.ToArray());
            return XmlizedString;
        }
    }
}
