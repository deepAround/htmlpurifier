namespace HTMLPurifier\AttrDef;

/**
 * Validates an integer.
 * @note While this class was modeled off the CSS definition, no currently
 *       allowed CSS uses this type.  The properties that do are: widows,
 *       orphans, z-index, counter-increment, counter-reset.  Some of the
 *       HTML attributes, however, find use for a non-negative version of this.
 */
class AttrDefInteger extends \HTMLPurifier\AttrDef
{
    /**
     * Whether or not negative values are allowed.
     * @type bool
     */
    protected negative = true;
    /**
     * Whether or not zero is allowed.
     * @type bool
     */
    protected zero = true;
    /**
     * Whether or not positive values are allowed.
     * @type bool
     */
    protected positive = true;
    /**
     * @param $negative Bool indicating whether or not negative values are allowed
     * @param $zero Bool indicating whether or not zero is allowed
     * @param $positive Bool indicating whether or not positive values are allowed
     */
    public function __construct(negative = true, zero = true, positive = true) -> void
    {
        let this->negative = negative;
        let this->zero = zero;
        let this->positive = positive;
    }
    
    /**
     * @param string $integer
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string integer, <Config> config, <Context> context)
    {
        var digits;
    
        let integer =  this->parseCDATA(integer);
        if integer === "" {
            return false;
        }
        // we could possibly simply typecast it to integer, but there are
        // certain fringe cases that must not return an integer.
        // clip leading sign
        if this->negative && integer[0] === "-" {
            let digits =  substr(integer, 1);
            if digits === "0" {
                let integer = "0";
            }
        } elseif this->positive && integer[0] === "+" {
            let digits = substr(integer, 1);
            let integer = substr(integer, 1);
            ;
        } else {
            let digits = integer;
        }
        // test if it's numeric
        if !(ctype_digit(digits)) {
            return false;
        }
        // perform scope tests
        if !(this->zero) && integer == 0 {
            return false;
        }
        if !(this->positive) && integer > 0 {
            return false;
        }
        if !(this->negative) && integer < 0 {
            return false;
        }
        return integer;
    }

}