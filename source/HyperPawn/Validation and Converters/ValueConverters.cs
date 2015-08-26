using System;
using System.Globalization;
using System.Windows.Data;

namespace Shell.Conversion
{
    [ValueConversion(typeof(decimal), typeof(string))]
    public class AmountConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            decimal amount = (decimal)value;
            if (amount == 0)
                return "";
            else
                return amount.ToString("N2", culture);
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string amount = value.ToString();

            decimal result;
            if (Decimal.TryParse(amount, NumberStyles.Any, culture, out result))
            {
                return result;
            }
            return value;
        }
    }
    [ValueConversion(typeof(decimal), typeof(string))]
    public class PawnIdConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            int pawnid = (int)value;
            if (pawnid == 0)
                return "new";
            return pawnid.ToString();
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string pawnid = value.ToString();

            if (pawnid == "new")
                return (int)0;

            int result;
            if (Int32.TryParse(pawnid, NumberStyles.Any, culture, out result))
            {
                return result;
            }
            return value;
        }
    }
    [ValueConversion(typeof(decimal), typeof(string))]
    public class IntGreaterThanZeroConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            int i = (int)value;
            if (i == 0)
                return "";
            return i.ToString();
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string s = value.ToString();

            if (s == "")
                return (int)0;

            int result;
            if (Int32.TryParse(s, NumberStyles.Integer, culture, out result))
            {
                return result;
            }
            return value;
        }
    }
    public class IntZeroOrPositiveConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            int i = (int)value;
            if (i == 0)
                return "";
            return i.ToString();
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string s = value.ToString();

            if (s == "")
                return (int)0;

            int result;
            if (Int32.TryParse(s, NumberStyles.Integer, culture, out result))
            {
                return result;
            }
            return value;
        }
    }
}
