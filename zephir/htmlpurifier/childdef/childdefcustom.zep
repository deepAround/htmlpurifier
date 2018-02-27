namespace HTMLPurifier\ChildDef;

/**
 * Custom validation class, accepts DTD child definitions
 *
 * @warning Currently this class is an all or nothing proposition, that is,
 *          it will only give a bool return value.
 */
class ChildDefCustom extends \HTMLPurifier\ChildDef
{
    /**
     * @type string
     */
    public type = "custom";
    /**
     * @type bool
     */
    public allow_empty = false;
    /**
     * Allowed child pattern as defined by the DTD.
     * @type string
     */
    public dtd_regex;
    /**
     * PCRE regex derived from $dtd_regex.
     * @type string
     */
    protected _pcre_regex;
    /**
     * @param $dtd_regex Allowed child pattern from the DTD
     */
    public function __construct(dtd_regex) -> void
    {
        let this->dtd_regex = dtd_regex;
        this->_compileRegex();
    }
    
    /**
     * Compiles the PCRE regex from a DTD regex ($dtd_regex to $_pcre_regex)
     */
    protected function _compileRegex() -> void
    {
        var raw, el, reg, match;
    
        let raw =  str_replace(" ", "", this->dtd_regex);
        if raw[0] != "(" {
            let raw = "({raw})";
        }
        let el = "[#a-zA-Z0-9_.-]+";
        let reg = raw;
        // COMPLICATED! AND MIGHT BE BUGGY! I HAVE NO CLUE WHAT I'M
        // DOING! Seriously: if there's problems, please report them.
        // collect all elements into the $elements array
        preg_match_all("/{el}/", reg, matches);
        for match in matches[0] {
            let this->elements[match] = true;
        }
        // setup all elements as parentheticals with leading commas
        let reg =  preg_replace("/{el}/", "(,\\0)", reg);
        // remove commas when they were not solicited
        let reg =  preg_replace("/([^,(|]\\(+),/", "\\1", reg);
        // remove all non-paranthetical commas: they are handled by first regex
        let reg =  preg_replace("/,\\(/", "(", reg);
        let this->_pcre_regex = reg;
    }
    
    /**
     * @param Node[] $children
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> bool
    {
        var list_of_children, nesting, node, okay;
    
        let list_of_children = "";
        let nesting = 0;
        // depth into the nest
        for node in children {
            if !(empty(node->is_whitespace)) {
                continue;
            }
            let list_of_children .= node->name . ",";
        }
        // add leading comma to deal with stray comma declarations
        let list_of_children =  "," . rtrim(list_of_children, ",");
        let okay =  preg_match("/^,?" . this->_pcre_regex . "$/", list_of_children);
        return (bool) okay;
    }

}