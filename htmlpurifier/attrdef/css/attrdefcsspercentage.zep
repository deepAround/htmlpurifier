namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates a Percentage as defined by the CSS spec.
 */
class AttrDefCSSPercentage extends \HTMLPurifier\AttrDef
{
    /**
     * Instance to defer number validation to.
     * @type AttrDefCSSNumber
     */
    protected number_def;
    /**
     * @param bool $non_negative Whether to forbid negative values
     */
    public function __construct(bool non_negative = false) -> void
    {
        let this->number_def =  new AttrDefCSSNumber(non_negative);
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var length, number;
    
        let stringg =  this->parseCDATA(stringg);
        if stringg === "" {
            return false;
        }
        let length =  strlen(stringg);
        if length === 1 {
            return false;
        }
        if stringg[length - 1] !== "%" {
            return false;
        }
        let number =  substr(stringg, 0, length - 1);
        let number =  this->number_def->validate(number, config, context);
        if number === false {
            return false;
        }
        return "{number}%";
    }

}