namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates the value for the CSS property text-decoration
 * @note This class could be generalized into a version that acts sort of
 *       like Enum except you can compound the allowed values.
 */
class AttrDefCSSTextDecoration extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var allowed_values, parts, final, part;
    
        
            let allowed_values =  ["line-through" : true, "overline" : true, "underline" : true];
        let stringg =  strtolower(this->parseCDATA(stringg));
        if stringg === "none" {
            return stringg;
        }
        let parts =  explode(" ", stringg);
        let final = "";
        for part in parts {
            if isset allowed_values[part] {
                let final .= part . " ";
            }
        }
        let final =  rtrim(final);
        if final === "" {
            return false;
        }
        return final;
    }

}