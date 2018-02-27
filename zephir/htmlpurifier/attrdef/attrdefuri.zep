namespace HTMLPurifier\AttrDef;

use HTMLPurifier\URIParser;
/**
 * Validates a URI as defined by RFC 3986.
 * @note Scheme-specific mechanics deferred to URIScheme
 */
class AttrDefURI extends \HTMLPurifier\AttrDef
{
    /**
     * @type URIParser
     */
    protected parser;
    /**
     * @type bool
     */
    protected embedsResource;
    /**
     * @param bool $embeds_resource Does the URI here result in an extra HTTP request?
     */
    public function __construct(bool embeds_resource = false) -> void
    {
        let this->parser =  new URIParser();
        let this->embedsResource =  (bool) embeds_resource;
    }
    
    /**
     * @param string $string
     * @return AttrDefURI
     */
    public function make(string stringg) -> <AttrDefURI>
    {
        var embeds;
    
        let embeds =  stringg === "embedded";
        return new AttrDefURI(embeds);
    }
    
    /**
     * @param string $uri
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string uri, <Config> config, <Context> context)
    {
        var ok, result, uri_def, scheme_obj;
    
        if config->get("URI.Disable") {
            return false;
        }
        let uri =  this->parseCDATA(uri);
        // parse the URI
        let uri =  this->parser->parse(uri);
        if uri === false {
            return false;
        }
        // add embedded flag to context for validators
        context->register("EmbeddedURI", this->embedsResource);
        let ok =  false;
        do {
            // generic validation
            let result =  uri->validate(config, context);
            if !(result) {
                break;
            }
            // chained filtering
            let uri_def =  config->getDefinition("URI");
            let result =  uri_def->filter(uri, config, context);
            if !(result) {
                break;
            }
            // scheme-specific validation
            let scheme_obj =  uri->getSchemeObj(config, context);
            if !(scheme_obj) {
                break;
            }
            if this->embedsResource && !(scheme_obj->browsable) {
                break;
            }
            let result =  scheme_obj->validate(uri, config, context);
            if !(result) {
                break;
            }
            // Post chained filtering
            let result =  uri_def->postFilter(uri, config, context);
            if !(result) {
                break;
            }
            // survived gauntlet
            let ok =  true;
        } while (false);
        context->destroy("EmbeddedURI");
        if !(ok) {
            return false;
        }
        // back to string
        return uri->toString();
    }

}