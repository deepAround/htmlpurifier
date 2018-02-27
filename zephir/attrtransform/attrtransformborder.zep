namespace HTMLPurifier\AttrTransform;

/**
 * Pre-transform that changes deprecated border attribute to CSS.
 */
class AttrTransformBorder extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var border_width;
    
        if !(isset attr["border"]) {
            return attr;
        }
        let border_width =  this->confiscateAttr(attr, "border");
        // some validation should happen here
        this->prependCSS(attr, "border:{border_width}px solid;");
        return attr;
    }

}