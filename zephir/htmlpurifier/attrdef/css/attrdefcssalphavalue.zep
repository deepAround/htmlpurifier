namespace HTMLPurifier\AttrDef\Css;

class AttrDefCSSAlphaValue extends AttrDefCSSNumber
{
    public function __construct() -> void
    {
        parent::__construct(false);
    }
    
    /**
     * @param string $number
     * @param Config $config
     * @param Context $context
     * @return string
     */
    public function validate(string number, <Config> config, <Context> context) -> string
    {
        var result, floatt;
    
        let result =  parent::validate(number, config, context);
        if result === false {
            return result;
        }
        let floatt =  (double) result;
        if floatt < 0 {
            let result = "0";
        }
        if floatt > 1 {
            let result = "1";
        }
        return result;
    }

}