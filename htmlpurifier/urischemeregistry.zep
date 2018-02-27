namespace HTMLPurifier;

/**
 * Registry for retrieving specific URI scheme validator objects.
 */
class URISchemeRegistry
{
    /**
     * Retrieve sole instance of the registry.
     * @param URISchemeRegistry $prototype Optional prototype to overload sole instance with,
     *                   or bool true to reset to default registry.
     * @return URISchemeRegistry
     * @note Pass a registry object $prototype with a compatible interface and
     *       the function will copy it and return it all further times.
     */
    public static function instance(<URISchemeRegistry> prototype = null) -> <URISchemeRegistry>
    {
        var instance;
    
        
            let instance =  null;
        if prototype !== null {
            let instance = prototype;
        } elseif instance === null || prototype == true {
            let instance =  new URISchemeRegistry();
        }
        return instance;
    }
    
    /**
     * Cache of retrieved schemes.
     * @type URIScheme[]
     */
    protected schemes = [];
    /**
     * Retrieves a scheme validator object
     * @param string $scheme String scheme name like http or mailto
     * @param Config $config
     * @param Context $context
     * @return URIScheme
     */
    public function getScheme(string scheme, <Config> config, <Context> context) -> <URIScheme>
    {
        var allowed_schemes, classs;
    
        if !(config) {
            let config =  Config::createDefault();
        }
        // important, otherwise attacker could include arbitrary file
        let allowed_schemes =  config->get("URI.AllowedSchemes");
        if !(config->get("URI.OverrideAllowedSchemes")) && !(isset allowed_schemes[scheme]) {
            return;
        }
        if isset this->schemes[scheme] {
            return this->schemes[scheme];
        }
        if !(isset allowed_schemes[scheme]) {
            return;
        }
        let classs =  "URIScheme_" . scheme;
        if !(class_exists(classs)) {
            return;
        }
        let this->schemes[scheme] = new {classs}();
        return this->schemes[scheme];
    }
    
    /**
     * Registers a custom scheme to the cache, bypassing reflection.
     * @param string $scheme Scheme name
     * @param URIScheme $scheme_obj
     */
    public function register(string scheme, <URIScheme> scheme_obj) -> void
    {
        let this->schemes[scheme] = scheme_obj;
    }

}