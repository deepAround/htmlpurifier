namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates shorthand CSS property list-style.
 * @warning Does not support url tokens that have internal spaces.
 */
class AttrDefCSSListStyle extends \HTMLPurifier\AttrDef
{
    /**
     * Local copy of validators.
     * @type AttrDef[]
     * @note See AttrDefCSSFont::$info for a similar impl.
     */
    protected info;
    /**
     * @param Config $config
     */
    public function __construct(<Config> config) -> void
    {
        var def;
    
        let def =  config->getCSSDefinition();
        let this->info["list-style-type"] = def->info["list-style-type"];
        let this->info["list-style-position"] = def->info["list-style-position"];
        let this->info["list-style-image"] = def->info["list-style-image"];
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var bits, caught, i, none, bit, key, status, r, ret;
    
        // regular pre-processing
        let stringg =  this->parseCDATA(stringg);
        if stringg === "" {
            return false;
        }
        // assumes URI doesn't have spaces in it
        let bits =  explode(" ", strtolower(stringg));
        // bits to process
        let caught =  [];
        let caught["type"] = false;
        let caught["position"] = false;
        let caught["image"] = false;
        let i = 0;
        // number of catches
        let none =  false;
        for bit in bits {
            if i >= 3 {
                return;
            }
            // optimization bit
            if bit === "" {
                continue;
            }
            for key, status in caught {
                if status !== false {
                    continue;
                }
                let r =  this->info["list-style-" . key]->validate(bit, config, context);
                if r === false {
                    continue;
                }
                if r === "none" {
                    if none {
                        continue;
                    } else {
                        let none =  true;
                    }
                    if key == "image" {
                        continue;
                    }
                }
                let caught[key] = r;
                let i++;
                break;
            }
        }
        if !(i) {
            return false;
        }
        let ret =  [];
        // construct type
        if caught["type"] {
            let ret[] = caught["type"];
        }
        // construct image
        if caught["image"] {
            let ret[] = caught["image"];
        }
        // construct position
        if caught["position"] {
            let ret[] = caught["position"];
        }
        if empty(ret) {
            return false;
        }
        return implode(" ", ret);
    }

}