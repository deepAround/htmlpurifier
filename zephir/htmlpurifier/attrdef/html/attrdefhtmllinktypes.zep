namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates a rel/rev link attribute against a directive of allowed values
 * @note We cannot use Enum because link types allow multiple
 *       values.
 * @note Assumes link types are ASCII text
 */
class AttrDefHTMLLinkTypes extends \HTMLPurifier\AttrDef
{
    /**
     * Name config attribute to pull.
     * @type string
     */
    protected name;
    /**
     * @param string $name
     */
    public function __construct(string name)
    {
        var configLookup;
    
        let configLookup =  ["rel" : "AllowedRel", "rev" : "AllowedRev"];
        if !(isset configLookup[name]) {
            trigger_error("Unrecognized attribute name for link " . "relationship.", E_USER_ERROR);
            return;
        }
        let this->name = configLookup[name];
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var allowed, parts, ret_lookup, part;
    
        let allowed =  config->get("Attr." . this->name);
        if empty(allowed) {
            return false;
        }
        let stringg =  this->parseCDATA(stringg);
        let parts =  explode(" ", stringg);
        // lookup to prevent duplicates
        let ret_lookup =  [];
        for part in parts {
            let part =  strtolower(trim(part));
            if !(isset allowed[part]) {
                continue;
            }
            let ret_lookup[part] = true;
        }
        if empty(ret_lookup) {
            return false;
        }
        let stringg =  implode(" ", array_keys(ret_lookup));
        return stringg;
    }

}