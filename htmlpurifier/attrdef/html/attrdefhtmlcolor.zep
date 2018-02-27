namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates a color according to the HTML spec.
 */
class AttrDefHTMLColor extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var colors, lower, hex, length;
    
        
            let colors =  null;
        if colors === null {
            let colors =  config->get("Core.ColorKeywords");
        }
        let stringg =  trim(stringg);
        if empty(stringg) {
            return false;
        }
        let lower =  strtolower(stringg);
        if isset colors[lower] {
            return colors[lower];
        }
        if stringg[0] === "#" {
            let hex =  substr(stringg, 1);
        } else {
            let hex = stringg;
        }
        let length =  strlen(hex);
        if length !== 3 && length !== 6 {
            return false;
        }
        if !(ctype_xdigit(hex)) {
            return false;
        }
        if length === 3 {
            let hex =  hex[0] . hex[0] . hex[1] . hex[1] . hex[2] . hex[2];
        }
        return "#{hex}";
    }

}