namespace HTMLPurifier\AttrDef;

// Enum = Enumerated
/**
 * Validates a keyword against a list of valid values.
 * @warning The case-insensitive compare of this function uses PHP's
 *          built-in strtolower and ctype_lower functions, which may
 *          cause problems with international comparisons
 */
class AttrDefEnum extends \HTMLPurifier\AttrDef
{
    /**
     * Lookup table of valid values.
     * @type array
     * @todo Make protected
     */
    public valid_values = [];
    /**
     * Bool indicating whether or not enumeration is case sensitive.
     * @note In general this is always case insensitive.
     */
    protected case_sensitive = false;
    // values according to W3C spec
    /**
     * @param array $valid_values List of valid values
     * @param bool $case_sensitive Whether or not case sensitive
     */
    public function __construct(valid_values = [], case_sensitive = false) -> void
    {
        let this->valid_values =  array_flip(valid_values);
        let this->case_sensitive = case_sensitive;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var result;
    
        let stringg =  trim(stringg);
        if !(this->case_sensitive) {
            // we may want to do full case-insensitive libraries
            let stringg =  ctype_lower(stringg) ? stringg  : strtolower(stringg);
        }
        let result =  isset this->valid_values[stringg];
        return  result ? stringg  : false;
    }
    
    /**
     * @param string $string In form of comma-delimited list of case-insensitive
     *      valid values. Example: "foo,bar,baz". Prepend "s:" to make
     *      case sensitive
     * @return AttrDefEnum
     */
    public function make(string stringg) -> <AttrDefEnum>
    {
        var sensitive, values;
    
        if strlen(stringg) > 2 && stringg[0] == "s" && stringg[1] == ":" {
            let stringg =  substr(stringg, 2);
            let sensitive =  true;
        } else {
            let sensitive =  false;
        }
        let values =  explode(",", stringg);
        return new AttrDefEnum(values, sensitive);
    }

}