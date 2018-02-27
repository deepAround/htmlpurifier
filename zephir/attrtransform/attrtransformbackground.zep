namespace HTMLPurifier\AttrTransform;

/**
 * Pre-transform that changes proprietary background attribute to CSS.
 */
class AttrTransformBackground extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var background;
    
        if !(isset attr["background"]) {
            return attr;
        }
        let background =  this->confiscateAttr(attr, "background");
        // some validation should happen here
        this->prependCSS(attr, "background-image:url({background});");
        return attr;
    }

}