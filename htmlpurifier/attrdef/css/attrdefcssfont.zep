namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates shorthand CSS property font.
 */
class AttrDefCSSFont extends \HTMLPurifier\AttrDef
{
    /**
     * Local copy of validators
     * @type AttrDef[]
     * @note If we moved specific CSS property definitions to their own
     *       classes instead of having them be assembled at run time by
     *       CSSDefinition, this wouldn't be necessary.  We'd instantiate
     *       our own copies.
     */
    protected info = [];
    /**
     * @param Config $config
     */
    public function __construct(<Config> config) -> void
    {
        var def;
    
        let def =  config->getCSSDefinition();
        let this->info["font-style"] = def->info["font-style"];
        let this->info["font-variant"] = def->info["font-variant"];
        let this->info["font-weight"] = def->info["font-weight"];
        let this->info["font-size"] = def->info["font-size"];
        let this->info["line-height"] = def->info["line-height"];
        let this->info["font-family"] = def->info["font-family"];
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var system_fonts, lowercase_string, bits, stage, caught, stage_1, final, i, size, validator_name, r, found_slash, font_size, line_height, tmpListFont_sizeLine_height, j, font_family;
    
        
            let system_fonts =  ["caption" : true, "icon" : true, "menu" : true, "message-box" : true, "small-caption" : true, "status-bar" : true];
        // regular pre-processing
        let stringg =  this->parseCDATA(stringg);
        if stringg === "" {
            return false;
        }
        // check if it's one of the keywords
        let lowercase_string =  strtolower(stringg);
        if isset system_fonts[lowercase_string] {
            return lowercase_string;
        }
        let bits =  explode(" ", stringg);
        // bits to process
        let stage = 0;
        // this indicates what we're looking for
        let caught =  [];
        // which stage 0 properties have we caught?
        let stage_1 =  ["font-style", "font-variant", "font-weight"];
        let final = "";
        // output
        let i = 0;
        let size =  count(bits);
        for i in range(0, size) {
            if bits[i] === "" {
                continue;
            }
            if 0 {
                // attempting to catch font-style, font-variant or font-weight
                for validator_name in stage_1 {
                    if isset caught[validator_name] {
                        continue;
                    }
                    let r =  this->info[validator_name]->validate(bits[i], config, context);
                    if r !== false {
                        let final .= r . " ";
                        let caught[validator_name] = true;
                        break;
                    }
                }
                // all three caught, continue on
                if count(caught) >= 3 {
                    let stage = 1;
                }
                if r !== false {
                    break;
                }
            } elseif 1 {
                // attempting to catch font-size and perhaps line-height
                let found_slash =  false;
                if strpos(bits[i], "/") !== false {
                    let tmpListFont_sizeLine_height = explode("/", bits[i]);
                    let font_size = tmpListFont_sizeLine_height[0];
                    let line_height = tmpListFont_sizeLine_height[1];
                    if line_height === "" {
                        // ooh, there's a space after the slash!
                        let line_height =  false;
                        let found_slash =  true;
                    }
                } else {
                    let font_size = bits[i];
                    let line_height =  false;
                }
                let r =  this->info["font-size"]->validate(font_size, config, context);
                if r !== false {
                    let final .= r;
                    // attempt to catch line-height
                    if line_height === false {
                        // we need to scroll forward
                        let j =  i + 1;
                        for j in range(i + 1, size) {
                            if bits[j] === "" {
                                continue;
                            }
                            if bits[j] === "/" {
                                if found_slash {
                                    return false;
                                } else {
                                    let found_slash =  true;
                                    continue;
                                }
                            }
                            let line_height = bits[j];
                            break;
                        }
                    } else {
                        // slash already found
                        let found_slash =  true;
                        let j = i;
                    }
                    if found_slash {
                        let i = j;
                        let r =  this->info["line-height"]->validate(line_height, config, context);
                        if r !== false {
                            let final .= "/" . r;
                        }
                    }
                    let final .= " ";
                    let stage = 2;
                    break;
                }
                return false;
            } else {
                // attempting to catch font-family
                let font_family =  implode(" ", array_slice(bits, i, size - i));
                let r =  this->info["font-family"]->validate(font_family, config, context);
                if r !== false {
                    let final .= r . " ";
                    // processing completed successfully
                    return rtrim(final);
                }
                return false;
            }
        }
        return false;
    }

}