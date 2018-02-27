namespace HTMLPurifier\AttrDef\Css;

use HTMLPurifier\AttrDef\AttrDefInteger;
/**
 * Microsoft's proprietary filter: CSS property
 * @note Currently supports the alpha filter. In the future, this will
 *       probably need an extensible framework
 */
class AttrDefCSSFilter extends \HTMLPurifier\AttrDef
{
    /**
     * @type AttrDef_Integer
     */
    protected intValidator;
    public function __construct() -> void
    {
        let this->intValidator =  new AttrDefInteger();
    }
    
    /**
     * @param string $value
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string value, <Config> config, <Context> context)
    {
        var function_length, functionn, cursor, parameters_length, parameters, params, ret_params, lookup, param, key, tmpListKeyValue, intt, ret_parameters, ret_function;
    
        let value =  this->parseCDATA(value);
        if value === "none" {
            return value;
        }
        // if we looped this we could support multiple filters
        let function_length =  strcspn(value, "(");
        let functionn =  trim(substr(value, 0, function_length));
        if functionn !== "alpha" && functionn !== "Alpha" && functionn !== "progid:DXImageTransform.Microsoft.Alpha" {
            return false;
        }
        let cursor =  function_length + 1;
        let parameters_length =  strcspn(value, ")", cursor);
        let parameters =  substr(value, cursor, parameters_length);
        let params =  explode(",", parameters);
        let ret_params =  [];
        let lookup =  [];
        for param in params {
            let tmpListKeyValue = explode("=", param);
            let key = tmpListKeyValue[0];
            let value = tmpListKeyValue[1];
            let key =  trim(key);
            let value =  trim(value);
            if isset lookup[key] {
                continue;
            }
            if key !== "opacity" {
                continue;
            }
            let value =  this->intValidator->validate(value, config, context);
            if value === false {
                continue;
            }
            let intt =  (int) value;
            if intt > 100 {
                let value = "100";
            }
            if intt < 0 {
                let value = "0";
            }
            let ret_params[] = "{key}={value}";
            let lookup[key] = true;
        }
        let ret_parameters =  implode(",", ret_params);
        let ret_function = "{functionn}({ret_parameters})";
        return ret_function;
    }

}