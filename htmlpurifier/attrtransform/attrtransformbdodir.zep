namespace HTMLPurifier\AttrTransform;

// this MUST be placed in post, as it assumes that any value in dir is valid
/**
 * Post-trasnform that ensures that bdo tags have the dir attribute set.
 */
class AttrTransformBdoDir extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        if isset attr["dir"] {
            return attr;
        }
        let attr["dir"] =  config->get("Attr.DefaultTextDir");
        return attr;
    }

}