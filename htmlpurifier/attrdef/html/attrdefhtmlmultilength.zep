namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates a MultiLength as defined by the HTML spec.
 *
 * A multilength is either a integer (pixel count), a percentage, or
 * a relative number.
 */
class AttrDefHTMLMultiLength extends AttrDefHTMLLength
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var parent_result, length, last_char, intt;
    
        let stringg =  trim(stringg);
        if stringg === "" {
            return false;
        }
        let parent_result =  parent::validate(stringg, config, context);
        if parent_result !== false {
            return parent_result;
        }
        let length =  strlen(stringg);
        let last_char = stringg[length - 1];
        if last_char !== "*" {
            return false;
        }
        let intt =  substr(stringg, 0, length - 1);
        if intt == "" {
            return "*";
        }
        if !(is_numeric(intt)) {
            return false;
        }
        let intt =  (int) intt;
        if intt < 0 {
            return false;
        }
        if intt == 0 {
            return "0";
        }
        if intt == 1 {
            return "*";
        }
        return (string) intt . "*";
    }

}