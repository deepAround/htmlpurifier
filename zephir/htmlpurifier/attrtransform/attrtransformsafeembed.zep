namespace HTMLPurifier\AttrTransform;

class AttrTransformSafeEmbed extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    public name = "SafeEmbed";
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        let attr["allowscriptaccess"] = "never";
        let attr["allownetworking"] = "internal";
        let attr["type"] = "application/x-shockwave-flash";
        return attr;
    }

}