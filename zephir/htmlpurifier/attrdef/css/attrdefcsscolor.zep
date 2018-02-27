namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates Color as defined by CSS.
 */
class AttrDefCSSColor extends \HTMLPurifier\AttrDef
{
    /**
     * @type AttrDefCSSAlphaValue
     */
    protected alpha;
    public function __construct() -> void
    {
        let this->alpha =  new AttrDefCSSAlphaValue();
    }
    
    /**
     * @param string $color
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string color, <Config> config, <Context> context)
    {
        var colors, lower, length, functionn, parameters_size, alpha_channel, allowed_types, allow_different_types, values, parts, type, new_parts, i, part, result, current_type, max_value, new_values, hex;
    
        
            let colors =  null;
        if colors === null {
            let colors =  config->get("Core.ColorKeywords");
        }
        let color =  trim(color);
        if color === "" {
            return false;
        }
        let lower =  strtolower(color);
        if isset colors[lower] {
            return colors[lower];
        }
        if preg_match("#(rgb|rgba|hsl|hsla)\\(#", color, matches) === 1 {
            let length =  strlen(color);
            if strpos(color, ")") !== length - 1 {
                return false;
            }
            // get used function : rgb, rgba, hsl or hsla
            let functionn = matches[1];
            let parameters_size = 3;
            let alpha_channel =  false;
            if substr(functionn, -1) === "a" {
                let parameters_size = 4;
                let alpha_channel =  true;
            }
            /*
             * Allowed types for values :
             * parameter_position => [type => max_value]
             */
            let allowed_types =  [1 : ["percentage" : 100, "integer" : 255], 2 : ["percentage" : 100, "integer" : 255], 3 : ["percentage" : 100, "integer" : 255]];
            let allow_different_types =  false;
            if strpos(functionn, "hsl") !== false {
                let allowed_types =  [1 : ["integer" : 360], 2 : ["percentage" : 100], 3 : ["percentage" : 100]];
                let allow_different_types =  true;
            }
            let values =  trim(str_replace(functionn, "", color), " ()");
            let parts =  explode(",", values);
            if count(parts) !== parameters_size {
                return false;
            }
            let type =  false;
            let new_parts =  [];
            let i = 0;
            for part in parts {
                let i++;
                let part =  trim(part);
                if part === "" {
                    return false;
                }
                // different check for alpha channel
                if alpha_channel === true && i === count(parts) {
                    let result =  this->alpha->validate(part, config, context);
                    if result === false {
                        return false;
                    }
                    let new_parts[] = (string) result;
                    continue;
                }
                if substr(part, -1) === "%" {
                    let current_type = "percentage";
                } else {
                    let current_type = "integer";
                }
                if !(array_key_exists(current_type, allowed_types[i])) {
                    return false;
                }
                if !(type) {
                    let type = current_type;
                }
                if allow_different_types === false && type != current_type {
                    return false;
                }
                let max_value = allowed_types[i][current_type];
                if current_type == "integer" {
                    // Return value between range 0 -> $max_value
                    let new_parts[] = (int) max(min(part, max_value), 0);
                } elseif current_type == "percentage" {
                    let new_parts[] =  (double) max(min(rtrim(part, "%"), max_value), 0) . "%";
                }
            }
            let new_values =  implode(",", new_parts);
            let color =  functionn . "(" . new_values . ")";
        } else {
            // hexadecimal handling
            if color[0] === "#" {
                let hex =  substr(color, 1);
            } else {
                let hex = color;
                let color =  "#" . color;
            }
            let length =  strlen(hex);
            if length !== 3 && length !== 6 {
                return false;
            }
            if !(ctype_xdigit(hex)) {
                return false;
            }
        }
        return color;
    }

}