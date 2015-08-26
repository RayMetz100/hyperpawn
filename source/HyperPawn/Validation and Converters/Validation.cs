using System.Globalization;
using System.Windows.Controls;

namespace Shell.Validation
{
    public class IntBlankZeroOrPositiveRule : ValidationRule
    {
        public override ValidationResult Validate(object value, CultureInfo cultureInfo)
        {
            if ((string)value == "")
                return new ValidationResult(true, null);
            int t;
            if ((int.TryParse((string)value, out t)) && t >= 0)
                return new ValidationResult(true, null);
            else
                return new ValidationResult(false, "not a number");
        }
    }
    public class IntGreaterThanZeroRule : ValidationRule
    {
        public override ValidationResult Validate(object value, CultureInfo cultureInfo)
        {
            int t;
            if ((int.TryParse((string)value, out t)) && t > 0)
                return new ValidationResult(true, null);
            else
                return new ValidationResult(false, "not a number");
        }
    }
    public class DecimalGreaterThanZeroRule : ValidationRule
    {
        public override ValidationResult Validate(object value, CultureInfo cultureInfo)
        {
            decimal t;
            if ((decimal.TryParse((string)value, out t)) && t > 0)
                return new ValidationResult(true, null);
            else
                return new ValidationResult(false, "not a number");
        }
    }
    public class MoneyRule : ValidationRule
    {
        public override ValidationResult Validate(object value, CultureInfo cultureInfo)
        {
            decimal t;
            string s = (string)value;
            
            
                        
            if ((decimal.TryParse(s, out t)) && t > 0)
                return new ValidationResult(true, null);
            else
                return new ValidationResult(false, "not a number");
        }
    }
    public class TextRequiredRule : ValidationRule
    {
        public override ValidationResult Validate(object value, CultureInfo cultureInfo)
        {
            if (value.ToString() != "")
                return new ValidationResult(true, null);
            else
                return new ValidationResult(false, "not filled in");
        }
    }
}
