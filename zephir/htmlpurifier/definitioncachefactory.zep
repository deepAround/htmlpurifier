namespace HTMLPurifier;

use HTMLPurifier\DefinitionCache\DefinitionCacheNull;
use HTMLPurifier\DefinitionCache\DefinitionCacheSerializer;
/**
 * Responsible for creating definition caches.
 */
class DefinitionCacheFactory
{
    /**
     * @type array
     */
    protected caches = ["Serializer" : []];
    /**
     * @type array
     */
    protected implementations = [];
    /**
     * @type DefinitionCacheDecorator[]
     */
    protected decorators = [];
    /**
     * Initialize default decorators
     */
    public function setup() -> void
    {
        this->addDecorator("Cleanup");
    }
    
    /**
     * Retrieves an instance of global definition cache factory.
     * @param DefinitionCacheFactory $prototype
     * @return DefinitionCacheFactory
     */
    public static function instance(<DefinitionCacheFactory> prototype = null) -> <DefinitionCacheFactory>
    {
        var instance;
    
        
        if prototype !== null {
            let instance = prototype;
        } elseif instance === null || prototype === true {
            let instance =  new DefinitionCacheFactory();
            instance->setup();
        }
        return instance;
    }
    
    /**
     * Registers a new definition cache object
     * @param string $short Short name of cache object, for reference
     * @param string $long Full class name of cache object, for construction
     */
    public function register(string short, string long) -> void
    {
        let this->implementations[short] = long;
    }
    
    /**
     * Factory method that creates a cache object based on configuration
     * @param string $type Name of definitions handled by cache
     * @param Config $config Config instance
     * @return mixed
     */
    public function create(string type, <Config> config)
    {
        var method, classs, cache, decorator, new_cache;
    
        let method =  config->get("Cache.DefinitionImpl");
        if method === null {
            return new DefinitionCacheNull(type);
        }
        if !(empty(this->caches[method][type])) {
            return this->caches[method][type];
        }
        let classs = this->implementations[method];
        if isset this->implementations[method] && class_exists(classs, false) {
            let cache =  new {classs}(type);
        } else {
            if method != "Serializer" {
                trigger_error("Unrecognized DefinitionCache {method}, using Serializer instead", E_USER_WARNING);
            }
            let cache =  new DefinitionCacheSerializer(type);
        }
        for decorator in this->decorators {
            let new_cache =  decorator->decorate(cache);
            // prevent infinite recursion in PHP 4
            let cache = null;
            
            let cache = new_cache;
        }
        let this->caches[method][type] = cache;
        return this->caches[method][type];
    }
    
    /**
     * Registers a decorator to add to all new cache objects
     * @param DefinitionCacheDecorator|string $decorator An instance or the name of a decorator
     */
    public function addDecorator(decorator) -> void
    {
        var classs;
    
        if is_string(decorator) {
            let classs = "DefinitionCacheDecorator_{decorator}";
            let decorator =  new {classs}();
        }
        let this->decorators[decorator->name] = decorator;
    }

}