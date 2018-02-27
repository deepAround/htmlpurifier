namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates an integer representation of pixels according to the HTML spec.
 */
class AttrDefHTMLPixels extends \HTMLPurifier\AttrDef
{
    /**
     * @type int
     */
    protected max;
    /**
     * @param int $max
     */
    public function __construct(int max = null) -> void
    {
        let this->max = max;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var length, intt;
    
        let stringg =  trim(stringg);
        if stringg === "0" {
            return stringg;
        }
        if stringg === "" {
            return false;
        }
        let length =  strlen(stringg);
        if substr(stringg, length - 2) == "px" {
            let stringg =  substr(stringg, 0, length - 2);
        }
        if !(is_numeric(stringg)) {
            return false;
        }
        let intt =  (int) stringg;
        if intt < 0 {
            return "0";
        }
        // upper-bound value, extremely high values can
        // crash operating systems, see <http://ha.ckers.org/imagecrash.html>
        // WARNING, above link WILL crash you if you're using Windows
        if this->max !== null && intt > this->max {
            return (string) this->max;
        }
        return (string) intt;
    }
    
    /**
     * @param string $string
     * @return AttrDef
     */
    public function make(string stringg) -> <AttrDef>
    {
        var max, classs;
    
        if stringg === "" {
            let max =  null;
        } else {
            let max =  (int) stringg;
        }
        let classs =  get_class(this);
        return new {classs}(max);
    }

}