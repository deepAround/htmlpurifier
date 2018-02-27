namespace HTMLPurifier\DefinitionCache\Decorator;

use HTMLPurifier\DefinitionCache\DefinitionCacheDecorator;
/**
 * Definition cache decorator class that saves all cache retrievals
 * to PHP's memory; good for unit tests or circumstances where
 * there are lots of configuration objects floating around.
 */
class DefinitionCacheDecoratorMemory extends DefinitionCacheDecorator
{
    /**
     * @type array
     */
    protected definitions;
    /**
     * @type string
     */
    public name = "Memory";
    /**
     * @return DefinitionCacheDecoratorMemory
     */
    public function copy() -> <DefinitionCacheDecoratorMemory>
    {
        return new DefinitionCacheDecoratorMemory();
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function add(<Definition> def, <Config> config)
    {
        var status, tmpThis1;
    
        let status =  parent::add(def, config);
        if status {
            
            this->generateKey(config);
            let tmpThis1 = this;
            
            let this->definitions[tmpThis1] = def;
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
        var status, tmpThis1;
    
        let status =  parent::set(def, config);
        if status {
            
            this->generateKey(config);
            let tmpThis1 = this;
            
            let this->definitions[tmpThis1] = def;
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
        var status, tmpThis1;
    
        let status =  parent::replace(def, config);
        if status {
            
            this->generateKey(config);
            let tmpThis1 = this;
            
            let this->definitions[tmpThis1] = def;
        }
        return status;
    }
    
    /**
     * @param Config $config
     * @return mixed
     */
    public function get(<Config> config)
    {
        var key;
    
        let key =  this->generateKey(config);
        if isset this->definitions[key] {
            return this->definitions[key];
        }
        let this->definitions[key] = parent::get(config);
        return this->definitions[key];
    }

}