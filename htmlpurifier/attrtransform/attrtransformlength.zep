namespace HTMLPurifier\AttrTransform;

/**
 * Class for handling width/height length attribute transformations to CSS
 */
class AttrTransformLength extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    protected name;
    /**
     * @type string
     */
    protected cssName;
    public function __construct(name, css_name = null) -> void
    {
        let this->name = name;
        let this->cssName =  css_name ? css_name  : name;
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var length;
    
        if !(isset attr[this->name]) {
            return attr;
        }
        let length =  this->confiscateAttr(attr, this->name);
        if ctype_digit(length) {
            let length .= "px";
        }
        this->prependCSS(attr, this->cssName . ":{length};");
        return attr;
    }

}