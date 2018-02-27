namespace HTMLPurifier\AttrTransform;

/**
 * Pre-transform that changes deprecated hspace and vspace attributes to CSS
 */
class AttrTransformImgSpace extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    protected attr;
    /**
     * @type array
     */
    protected css = ["hspace" : ["left", "right"], "vspace" : ["top", "bottom"]];
    /**
     * @param string $attr
     */
    public function __construct(string attr) -> void
    {
        let this->attr = attr;
        if !(isset this->css[attr]) {
            trigger_error(htmlspecialchars(attr) . " is not valid space attribute");
        }
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var width, style, suffix, property;
    
        if !(isset attr[this->attr]) {
            return attr;
        }
        let width =  this->confiscateAttr(attr, this->attr);
        // some validation could happen here
        if !(isset this->css[this->attr]) {
            return attr;
        }
        let style = "";
        for suffix in this->css[this->attr] {
            let property = "margin-{suffix}";
            let style .= "{property}:{width}px;";
        }
        this->prependCSS(attr, style);
        return attr;
    }

}