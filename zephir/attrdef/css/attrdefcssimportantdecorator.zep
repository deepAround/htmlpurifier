namespace HTMLPurifier\AttrDef\Css;

/**
 * Decorator which enables !important to be used in CSS values.
 */
class AttrDefCSSImportantDecorator extends \HTMLPurifier\AttrDef
{
    /**
     * @type AttrDef
     */
    public def;
    /**
     * @type bool
     */
    public allow;
    /**
     * @param AttrDef $def Definition to wrap
     * @param bool $allow Whether or not to allow !important
     */
    public function __construct(<AttrDef> def, bool allow = false) -> void
    {
        let this->def = def;
        let this->allow = allow;
    }
    
    /**
     * Intercepts and removes !important if necessary
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var is_important, temp;
    
        // test for ! and important tokens
        let stringg =  trim(stringg);
        let is_important =  false;
        // :TODO: optimization: test directly for !important and ! important
        if strlen(stringg) >= 9 && substr(stringg, -9) === "important" {
            let temp =  rtrim(substr(stringg, 0, -9));
            // use a temp, because we might want to restore important
            if strlen(temp) >= 1 && substr(temp, -1) === "!" {
                let stringg =  rtrim(substr(temp, 0, -1));
                let is_important =  true;
            }
        }
        let stringg =  this->def->validate(stringg, config, context);
        if this->allow && is_important {
            let stringg .= " !important";
        }
        return stringg;
    }

}