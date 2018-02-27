namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates a number as defined by the CSS spec.
 */
class AttrDefCSSNumber extends \HTMLPurifier\AttrDef
{
    /**
     * Indicates whether or not only positive values are allowed.
     * @type bool
     */
    protected non_negative = false;
    /**
     * @param bool $non_negative indicates whether negatives are forbidden
     */
    public function __construct(bool non_negative = false) -> void
    {
        let this->non_negative = non_negative;
    }
    
    /**
     * @param string $number
     * @param Config $config
     * @param Context $context
     * @return string|bool
     * @warning Some contexts do not pass $config, $context. These
     *          variables should not be used without checking Length
     */
    public function validate(string number, <Config> config, <Context> context)
    {
        var sign, left, right, tmpListLeftRight;
    
        let number =  this->parseCDATA(number);
        if number === "" {
            return false;
        }
        if number === "0" {
            return "0";
        }
        let sign = "";
        switch (number[0]) {
            case "-":
                if this->non_negative {
                    return false;
                }
                let sign = "-";
            case "+":
                let number =  substr(number, 1);
        }
        if ctype_digit(number) {
            let number =  ltrim(number, "0");
            return  number ? sign . number  : "0";
        }
        // Period is the only non-numeric character allowed
        if strpos(number, ".") === false {
            return false;
        }
        let tmpListLeftRight = explode(".", number, 2);
        let left = tmpListLeftRight[0];
        let right = tmpListLeftRight[1];
        if left === "" && right === "" {
            return false;
        }
        if left !== "" && !(ctype_digit(left)) {
            return false;
        }
        let left =  ltrim(left, "0");
        let right =  rtrim(right, "0");
        if right === "" {
            return  left ? sign . left  : "0";
        } elseif !(ctype_digit(right)) {
            return false;
        }
        return sign . left . "." . right;
    }

}