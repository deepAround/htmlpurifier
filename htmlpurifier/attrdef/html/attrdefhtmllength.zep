namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates the HTML type length (not to be confused with CSS's length).
 *
 * This accepts integer pixels or percentages as lengths for certain
 * HTML attributes.
 */
class AttrDefHTMLLength extends \HTMLPurifier\AttrDef\Html\AttrDefHTMLPixels
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var parent_result, length, last_char, points;
    
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
        if last_char !== "%" {
            return false;
        }
        let points =  substr(stringg, 0, length - 1);
        if !(is_numeric(points)) {
            return false;
        }
        let points =  (int) points;
        if points < 0 {
            return "0%";
        }
        if points > 100 {
            return "100%";
        }
        return (string) points . "%";
    }

}