namespace HTMLPurifier\AttrTransform;

/**
 * Generic pre-transform that converts an attribute with a fixed number of
 * values (enumerated) to CSS.
 */
class AttrTransformEnumToCSS extends \HTMLPurifier\AttrTransform
{
    /**
     * Name of attribute to transform from.
     * @type string
     */
    protected attr;
    /**
     * Lookup array of attribute values to CSS.
     * @type array
     */
    protected enumToCSS = [];
    /**
     * Case sensitivity of the matching.
     * @type bool
     * @warning Currently can only be guaranteed to work with ASCII
     *          values.
     */
    protected caseSensitive = false;
    /**
     * @param string $attr Attribute name to transform from
     * @param array $enum_to_css Lookup array of attribute values to CSS
     * @param bool $case_sensitive Case sensitivity indicator, default false
     */
    public function __construct(string attr, array enum_to_css, bool case_sensitive = false) -> void
    {
        let this->attr = attr;
        let this->enumToCSS = enum_to_css;
        let this->caseSensitive =  (bool) case_sensitive;
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var value;
    
        if !(isset attr[this->attr]) {
            return attr;
        }
        let value =  trim(attr[this->attr]);
        unset attr[this->attr];
        
        if !(this->caseSensitive) {
            let value =  strtolower(value);
        }
        if !(isset this->enumToCSS[value]) {
            return attr;
        }
        this->prependCSS(attr, this->enumToCSS[value]);
        return attr;
    }

}