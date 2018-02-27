namespace HTMLPurifier\DefinitionCache\Decorator;

use HTMLPurifier\DefinitionCache\DefinitionCacheDecorator;
/**
 * Definition cache decorator class that cleans up the cache
 * whenever there is a cache miss.
 */
class DefinitionCacheDecoratorCleanup extends DefinitionCacheDecorator
{
    /**
     * @type string
     */
    public name = "Cleanup";
    /**
     * @return DefinitionCacheDecoratorCleanup
     */
    public function copy() -> <DefinitionCacheDecoratorCleanup>
    {
        return new DefinitionCacheDecoratorCleanup();
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function add(<Definition> def, <Config> config)
    {
        var status;
    
        let status =  parent::add(def, config);
        if !(status) {
            parent::cleanup(config);
        }
        return status;
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function set(<Definition> def, <Config> config)
    {
        var status;
    
        let status =  parent::set(def, config);
        if !(status) {
            parent::cleanup(config);
        }
        return status;
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function replace(<Definition> def, <Config> config)
    {
        var status;
    
        let status =  parent::replace(def, config);
        if !(status) {
            parent::cleanup(config);
        }
        return status;
    }
    
    /**
     * @param Config $config
     * @return mixed
     */
    public function get(<Config> config)
    {
        var ret;
    
        let ret =  parent::get(config);
        if !(ret) {
            parent::cleanup(config);
        }
        return ret;
    }

}