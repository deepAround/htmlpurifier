namespace HTMLPurifier\AttrTransform;

/**
 * Writes default type for all objects. Currently only supports flash.
 */
class AttrTransformSafeObject extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    public name = "SafeObject";
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        if !(isset attr["type"]) {
            let attr["type"] = "application/x-shockwave-flash";
        }
        return attr;
    }

}