namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates the border property as defined by CSS.
 */
class AttrDefCSSBorder extends \HTMLPurifier\AttrDef
{
    /**
     * Local copy of properties this property is shorthand for.
     * @type AttrDef[]
     */
    protected info = [];
    /**
     * @param Config $config
     */
    public function __construct(<Config> config) -> void
    {
        var def;
    
        let def =  config->getCSSDefinition();
        let this->info["border-width"] = def->info["border-width"];
        let this->info["border-style"] = def->info["border-style"];
        let this->info["border-top-color"] = def->info["border-top-color"];
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var bits, done, ret, bit, propname, validator, r;
    
        let stringg =  this->parseCDATA(stringg);
        let stringg =  this->mungeRgb(stringg);
        let bits =  explode(" ", stringg);
        let done =  [];
        // segments we've finished
        let ret = "";
        // return value
        for bit in bits {
            for propname, validator in this->info {
                if isset done[propname] {
                    continue;
                }
                let r =  validator->validate(bit, config, context);
                if r !== false {
                    let ret .= r . " ";
                    let done[propname] = true;
                    break;
                }
            }
        }
        return rtrim(ret);
    }

}