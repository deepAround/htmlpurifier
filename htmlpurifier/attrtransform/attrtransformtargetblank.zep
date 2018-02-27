namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\URIParser;
// must be called POST validation
/**
 * Adds target="blank" to all outbound links.  This transform is
 * only attached if Attr.TargetBlank is TRUE.  This works regardless
 * of whether or not Attr.AllowedFrameTargets
 */
class AttrTransformTargetBlank extends \HTMLPurifier\AttrTransform
{
    /**
     * @type URIParser
     */
    protected parser;
    public function __construct() -> void
    {
        let this->parser =  new URIParser();
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var url, scheme;
    
        if !(isset attr["href"]) {
            return attr;
        }
        // XXX Kind of inefficient
        let url =  this->parser->parse(attr["href"]);
        let scheme =  url->getSchemeObj(config, context);
        if scheme->browsable && !(url->isBenign(config, context)) {
            let attr["target"] = "_blank";
        }
        return attr;
    }

}