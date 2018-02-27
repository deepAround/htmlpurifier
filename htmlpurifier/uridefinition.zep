namespace HTMLPurifier;

use HTMLPurifier\URIFilter\URIFilterDisableExternal;
use HTMLPurifier\URIFilter\URIFilterDisableExternalResources;
use HTMLPurifier\URIFilter\URIFilterDisableResources;
use HTMLPurifier\URIFilter\URIFilterHostBlacklist;
use HTMLPurifier\URIFilter\URIFilterMakeAbsolute;
use HTMLPurifier\URIFilter\URIFilterMunge;
use HTMLPurifier\URIFilter\URIFilterSafeIframe;
class URIDefinition extends Definition
{
    public type = "URI";
    protected filters = [];
    protected postFilters = [];
    protected registeredFilters = [];
    /**
     * URI object of the base specified at %URI.Base
     */
    public base;
    /**
     * String host to consider "home" base, derived off of $base
     */
    public host;
    /**
     * Name of default scheme based on %URI.DefaultScheme and %URI.Base
     */
    public defaultScheme;
    public function __construct() -> void
    {
        this->registerFilter(new URIFilterDisableExternal());
        this->registerFilter(new URIFilterDisableExternalResources());
        this->registerFilter(new URIFilterDisableResources());
        this->registerFilter(new URIFilterHostBlacklist());
        this->registerFilter(new URIFilterSafeIframe());
        this->registerFilter(new URIFilterMakeAbsolute());
        this->registerFilter(new URIFilterMunge());
    }
    
    public function registerFilter(filter) -> void
    {
        let this->registeredFilters[filter->name] = filter;
    }
    
    public function addFilter(filter, config)
    {
        var r;
    
        let r =  filter->prepare(config);
        if r === false {
            return;
        }
        // null is ok, for backwards compat
        if filter->post {
            let this->postFilters[filter->name] = filter;
        } else {
            let this->filters[filter->name] = filter;
        }
    }
    
    protected function doSetup(config) -> void
    {
        this->setupMemberVariables(config);
        this->setupFilters(config);
    }
    
    protected function setupFilters(config) -> void
    {
        var name, filter, conf;
    
        for name, filter in this->registeredFilters {
            if filter->always_load {
                this->addFilter(filter, config);
            } else {
                let conf =  config->get("URI." . name);
                if conf !== false && conf !== null {
                    this->addFilter(filter, config);
                }
            }
        }
        unset this->registeredFilters;
    
    }
    
    protected function setupMemberVariables(config) -> void
    {
        var base_uri, parser;
    
        let this->host =  config->get("URI.Host");
        let base_uri =  config->get("URI.Base");
        if !(is_null(base_uri)) {
            let parser =  new URIParser();
            let this->base =  parser->parse(base_uri);
            let this->defaultScheme =  this->base->scheme;
            if is_null(this->host) {
                let this->host =  this->base->host;
            }
        }
        if is_null(this->defaultScheme) {
            let this->defaultScheme =  config->get("URI.DefaultScheme");
        }
    }
    
    public function getDefaultScheme(config, context)
    {
        return URISchemeRegistry::instance()->getScheme(this->defaultScheme, config, context);
    }
    
    public function filter(uri, config, context)
    {
        var name, f, result;
    
        for name, f in this->filters {
            let result =  f->filter(uri, config, context);
            if !(result) {
                return false;
            }
        }
        return true;
    }
    
    public function postFilter(uri, config, context)
    {
        var name, f, result;
    
        for name, f in this->postFilters {
            let result =  f->filter(uri, config, context);
            if !(result) {
                return false;
            }
        }
        return true;
    }

}