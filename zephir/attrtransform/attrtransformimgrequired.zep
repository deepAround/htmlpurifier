namespace HTMLPurifier\AttrTransform;

// must be called POST validation
/**
 * Transform that supplies default values for the src and alt attributes
 * in img tags, as well as prevents the img tag from being removed
 * because of a missing alt tag. This needs to be registered as both
 * a pre and post attribute transform.
 */
class AttrTransformImgRequired extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var src, alt;
    
        let src =  true;
        if !(isset attr["src"]) {
            if config->get("Core.RemoveInvalidImg") {
                return attr;
            }
            let attr["src"] =  config->get("Attr.DefaultInvalidImage");
            let src =  false;
        }
        if !(isset attr["alt"]) {
            if src {
                let alt =  config->get("Attr.DefaultImageAlt");
                if alt === null {
                    let attr["alt"] =  basename(attr["src"]);
                } else {
                    let attr["alt"] = alt;
                }
            } else {
                let attr["alt"] =  config->get("Attr.DefaultInvalidImageAlt");
            }
        }
        return attr;
    }

}