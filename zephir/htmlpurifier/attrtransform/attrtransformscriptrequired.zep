namespace HTMLPurifier\AttrTransform;

/**
 * Implements required attribute stipulation for <script>
 */
class AttrTransformScriptRequired extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        if !(isset attr["type"]) {
            let attr["type"] = "text/javascript";
        }
        return attr;
    }

}