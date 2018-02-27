namespace HTMLPurifier\DefinitionCache;

use HTMLPurifier\DefinitionCache;
class DefinitionCacheDecorator extends DefinitionCache
{
    /**
     * Cache object we are decorating
     * @type DefinitionCache
     */
    public cache;
    /**
     * The name of the decorator
     * @var string
     */
    public name;
    public function __construct() -> void
    {
    }
    
    /**
     * Lazy decorator function
     * @param DefinitionCache $cache Reference to cache object to decorate
     * @return DefinitionCacheDecorator
     */
    public function decorate(<DefinitionCache> cache) -> <DefinitionCacheDecorator>
    {
        var decorator;
    
        let decorator =  this->copy();
        // reference is necessary for mocks in PHP 4
        let decorator->cache = cache;
        let decorator->type =  cache->type;
        return decorator;
    }
    
    /**
     * Cross-compatible clone substitute
     * @return DefinitionCacheDecorator
     */
    public function copy() -> <DefinitionCacheDecorator>
    {
        return new DefinitionCacheDecorator();
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function add(<Definition> def, <Config> config)
    {
        return this->cache->add(def, config);
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function set(<Definition> def, <Config> config)
    {
        return this->cache->set(def, config);
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function replace(<Definition> def, <Config> config)
    {
        return this->cache->replace(def, config);
    }
    
    /**
     * @param Config $config
     * @return mixed
     */
    public function get(<Config> config)
    {
        return this->cache->get(config);
    }
    
    /**
     * @param Config $config
     * @return mixed
     */
    public function remove(<Config> config)
    {
        return this->cache->remove(config);
    }
    
    /**
     * @param Config $config
     * @return mixed
     */
    public function flush(<Config> config)
    {
        return this->cache->flush(config);
    }
    
    /**
     * @param Config $config
     * @return mixed
     */
    public function cleanup(<Config> config)
    {
        return this->cache->cleanup(config);
    }

}