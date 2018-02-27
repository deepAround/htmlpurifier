namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\URIParser;
// must be called POST validation
/**
 * Adds rel="nofollow" to all outbound links.  This transform is
 * only attached if Attr.Nofollow is TRUE.
 */
class AttrTransformNofollow extends \HTMLPurifier\AttrTransform
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
        var url, scheme, rels;
    
        if !(isset attr["href"]) {
            return attr;
        }
        // XXX Kind of inefficient
        let url =  this->parser->parse(attr["href"]);
        let scheme =  url->getSchemeObj(config, context);
        if scheme->browsable && !(url->isLocal(config, context)) {
            if isset attr["rel"] {
                let rels =  explode(" ", attr["rel"]);
                if !(in_array("nofollow", rels)) {
                    let rels[] = "nofollow";
                }
                let attr["rel"] =  implode(" ", rels);
            } else {
                let attr["rel"] = "nofollow";
            }
        }
        return attr;
    }

}