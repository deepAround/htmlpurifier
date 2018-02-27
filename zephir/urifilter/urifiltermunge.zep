namespace HTMLPurifier\URIFilter;

use HTMLPurifier\Exception;
use HTMLPurifier\URIFilter;
use HTMLPurifier\URIParser;
class URIFilterMunge extends URIFilter
{
    /**
     * @type string
     */
    public name = "Munge";
    /**
     * @type bool
     */
    public post = true;
    /**
     * @type string
     */
    protected target;
    /**
     * @type URIParser
     */
    protected parser;
    /**
     * @type bool
     */
    protected doEmbed;
    /**
     * @type string
     */
    protected secretKey;
    /**
     * @type array
     */
    protected replace = [];
    /**
     * @param Config $config
     * @return bool
     */
    public function prepare(<Config> config) -> bool
    {
        let this->target =  config->get("URI." . this->name);
        let this->parser =  new URIParser();
        let this->doEmbed =  config->get("URI.MungeResources");
        let this->secretKey =  config->get("URI.MungeSecretKey");
        if this->secretKey && !(function_exists("hash_hmac")) {
            throw new Exception("Cannot use %URI.MungeSecretKey without hash_hmac support.");
        }
        return true;
    }
    
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(uri, <Config> config, <Context> context) -> bool
    {
        var scheme_obj, new_uri;
    
        if context->get("EmbeddedURI", true) && !(this->doEmbed) {
            return true;
        }
        let scheme_obj =  uri->getSchemeObj(config, context);
        if !(scheme_obj) {
            return true;
        }
        // ignore unknown schemes, maybe another postfilter did it
        if !(scheme_obj->browsable) {
            return true;
        }
        // ignore non-browseable schemes, since we can't munge those in a reasonable way
        if uri->isBenign(config, context) {
            return true;
        }
        // don't redirect if a benign URL
        this->makeReplace(uri, config, context);
        let this->replace =  array_map("rawurlencode", this->replace);
        let new_uri =  strtr(this->target, this->replace);
        let new_uri =  this->parser->parse(new_uri);
        // don't redirect if the target host is the same as the
        // starting host
        if uri->host === new_uri->host {
            return true;
        }
        let uri = new_uri;
        // overwrite
        return true;
    }
    
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     */
    protected function makeReplace(uri, <Config> config, <Context> context) -> void
    {
        var stringg, token;
    
        let stringg =  uri->toString();
        // always available
        let this->replace["%s"] = stringg;
        let this->replace["%r"] =  context->get("EmbeddedURI", true);
        let token =  context->get("CurrentToken", true);
        let this->replace["%n"] =  token ? token->name  : null;
        let this->replace["%m"] =  context->get("CurrentAttr", true);
        let this->replace["%p"] =  context->get("CurrentCSSProperty", true);
        // not always available
        if this->secretKey {
            let this->replace["%t"] =  hash_hmac("sha256", stringg, this->secretKey);
        }
    }

}