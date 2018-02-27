namespace HTMLPurifier\AttrTransform;

/**
 * Pre-transform that changes deprecated bgcolor attribute to CSS.
 */
class AttrTransformBgColor extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var bgcolor;
    
        if !(isset attr["bgcolor"]) {
            return attr;
        }
        let bgcolor =  this->confiscateAttr(attr, "bgcolor");
        // some validation should happen here
        this->prependCSS(attr, "background-color:{bgcolor};");
        return attr;
    }

}