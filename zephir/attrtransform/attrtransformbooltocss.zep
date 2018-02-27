namespace HTMLPurifier\AttrTransform;

/**
 * Pre-transform that changes converts a boolean attribute to fixed CSS
 */
class AttrTransformBoolToCSS extends \HTMLPurifier\AttrTransform
{
    /**
     * Name of boolean attribute that is trigger.
     * @type string
     */
    protected attr;
    /**
     * CSS declarations to add to style, needs trailing semicolon.
     * @type string
     */
    protected css;
    /**
     * @param string $attr attribute name to convert from
     * @param string $css CSS declarations to add to style (needs semicolon)
     */
    public function __construct(string attr, string css) -> void
    {
        let this->attr = attr;
        let this->css = css;
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        if !(isset attr[this->attr]) {
            return attr;
        }
        unset attr[this->attr];
        
        this->prependCSS(attr, this->css);
        return attr;
    }

}