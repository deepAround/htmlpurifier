namespace HTMLPurifier\AttrDef\Css;

use HTMLPurifier\Length;
/**
 * Represents a Length as defined by CSS.
 */
class AttrDefCSSLength extends \HTMLPurifier\AttrDef
{
    /**
     * @type Length|string
     */
    protected min;
    /**
     * @type Length|string
     */
    protected max;
    /**
     * @param Length|string $min Minimum length, or null for no bound. String is also acceptable.
     * @param Length|string $max Maximum length, or null for no bound. String is also acceptable.
     */
    public function __construct(min = null, max = null) -> void
    {
        let this->min =  min !== null ? Length::make(min)  : null;
        let this->max =  max !== null ? Length::make(max)  : null;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var length, c;
    
        let stringg =  this->parseCDATA(stringg);
        // Optimizations
        if stringg === "" {
            return false;
        }
        if stringg === "0" {
            return "0";
        }
        if strlen(stringg) === 1 {
            return false;
        }
        let length =  Length::make(stringg);
        if !(length->isValid()) {
            return false;
        }
        if this->min {
            let c =  length->compareTo(this->min);
            if c === false {
                return false;
            }
            if c < 0 {
                return false;
            }
        }
        if this->max {
            let c =  length->compareTo(this->max);
            if c === false {
                return false;
            }
            if c > 0 {
                return false;
            }
        }
        return length->toString();
    }

}