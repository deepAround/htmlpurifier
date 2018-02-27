namespace HTMLPurifier\AttrTransform;

/**
 * Sets height/width defaults for <textarea>
 */
class AttrTransformTextarea extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        // Calculated from Firefox
        if !(isset attr["cols"]) {
            let attr["cols"] = "22";
        }
        if !(isset attr["rows"]) {
            let attr["rows"] = "3";
        }
        return attr;
    }

}