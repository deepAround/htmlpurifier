namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates shorthand CSS property background.
 * @warning Does not support url tokens that have internal spaces.
 */
class AttrDefCSSBackground extends \HTMLPurifier\AttrDef
{
    /**
     * Local copy of component validators.
     * @type AttrDef[]
     * @note See AttrDef_Font::$info for a similar impl.
     */
    protected info;
    /**
     * @param Config $config
     */
    public function __construct(<Config> config) -> void
    {
        var def;
    
        let def =  config->getCSSDefinition();
        let this->info["background-color"] = def->info["background-color"];
        let this->info["background-image"] = def->info["background-image"];
        let this->info["background-repeat"] = def->info["background-repeat"];
        let this->info["background-attachment"] = def->info["background-attachment"];
        let this->info["background-position"] = def->info["background-position"];
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var bits, caught, i, bit, key, status, r, ret, value;
    
        // regular pre-processing
        let stringg =  this->parseCDATA(stringg);
        if stringg === "" {
            return false;
        }
        // munge rgb() decl if necessary
        let stringg =  this->mungeRgb(stringg);
        // assumes URI doesn't have spaces in it
        let bits =  explode(" ", stringg);
        // bits to process
        let caught =  [];
        let caught["color"] = false;
        let caught["image"] = false;
        let caught["repeat"] = false;
        let caught["attachment"] = false;
        let caught["position"] = false;
        let i = 0;
        // number of catches
        for bit in bits {
            if bit === "" {
                continue;
            }
            for key, status in caught {
                if key != "position" {
                    if status !== false {
                        continue;
                    }
                    let r =  this->info["background-" . key]->validate(bit, config, context);
                } else {
                    let r = bit;
                }
                if r === false {
                    continue;
                }
                if key == "position" {
                    if caught[key] === false {
                        let caught[key] = "";
                    }
                    let caught[key] .= r . " ";
                } else {
                    let caught[key] = r;
                }
                let i++;
                break;
            }
        }
        if !(i) {
            return false;
        }
        if caught["position"] !== false {
            let caught["position"] =  this->info["background-position"]->validate(caught["position"], config, context);
        }
        let ret =  [];
        for value in caught {
            if value === false {
                continue;
            }
            let ret[] = value;
        }
        if empty(ret) {
            return false;
        }
        return implode(" ", ret);
    }

}