namespace HTMLPurifier\DefinitionCache;

/**
 * Null cache object to use when no caching is on.
 */
use HTMLPurifier\DefinitionCache;
class DefinitionCacheNull extends DefinitionCache
{
    /**
     * @param Definition $def
     * @param Config $config
     * @return bool
     */
    public function add(<Definition> def, <Config> config) -> bool
    {
        return false;
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return bool
     */
    public function set(<Definition> def, <Config> config) -> bool
    {
        return false;
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return bool
     */
    public function replace(<Definition> def, <Config> config) -> bool
    {
        return false;
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function remove(<Config> config) -> bool
    {
        return false;
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function get(<Config> config) -> bool
    {
        return false;
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function flush(<Config> config) -> bool
    {
        return false;
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function cleanup(<Config> config) -> bool
    {
        return false;
    }

}