namespace HTMLPurifier;

/**
 * Abstract class representing Definition cache managers that implements
 * useful common methods and is a factory.
 * @todo Create a separate maintenance file advanced users can use to
 *       cache their custom HTMLDefinition, which can be loaded
 *       via a configuration directive
 * @todo Implement memcached
 */
abstract class DefinitionCache
{
    /**
     * @type string
     */
    public type;
    /**
     * @param string $type Type of definition objects this instance of the
     *      cache will handle.
     */
    public function __construct(string type) -> void
    {
        let this->type = type;
    }
    
    /**
     * Generates a unique identifier for a particular configuration
     * @param Config $config Instance of Config
     * @return string
     */
    public function generateKey(<Config> config) -> string
    {
        return config->version . "," . config->getBatchSerial(this->type) . "," . config->get(this->type . ".DefinitionRev");
    }
    
    /**
     * Tests whether or not a key is old with respect to the configuration's
     * version and revision number.
     * @param string $key Key to test
     * @param Config $config Instance of Config to test against
     * @return bool
     */
    public function isOld(string key, <Config> config) -> bool
    {
        var version, hash, revision, tmpListVersionHashRevision, compare;
    
        if substr_count(key, ",") < 2 {
            return true;
        }
        let tmpListVersionHashRevision = explode(",", key, 3);
        let version = tmpListVersionHashRevision[0];
        let hash = tmpListVersionHashRevision[1];
        let revision = tmpListVersionHashRevision[2];
        let compare =  version_compare(version, config->version);
        // version mismatch, is always old
        if compare != 0 {
            return true;
        }
        // versions match, ids match, check revision number
        if hash == config->getBatchSerial(this->type) && revision < config->get(this->type . ".DefinitionRev") {
            return true;
        }
        return false;
    }
    
    /**
     * Checks if a definition's type jives with the cache's type
     * @note Throws an error on failure
     * @param Definition $def Definition object to check
     * @return bool true if good, false if not
     */
    public function checkDefType(<Definition> def) -> bool
    {
        if def->type !== this->type {
            trigger_error("Cannot use definition of type {def->type} in cache for {this->type}");
            return false;
        }
        return true;
    }
    
    /**
     * Adds a definition object to the cache
     * @param Definition $def
     * @param Config $config
     */
    public abstract function add(<Definition> def, <Config> config) -> void;
    
    /**
     * Unconditionally saves a definition object to the cache
     * @param Definition $def
     * @param Config $config
     */
    public abstract function set(<Definition> def, <Config> config) -> void;
    
    /**
     * Replace an object in the cache
     * @param Definition $def
     * @param Config $config
     */
    public abstract function replace(<Definition> def, <Config> config) -> void;
    
    /**
     * Retrieves a definition object from the cache
     * @param Config $config
     */
    public abstract function get(<Config> config) -> void;
    
    /**
     * Removes a definition object to the cache
     * @param Config $config
     */
    public abstract function remove(<Config> config) -> void;
    
    /**
     * Clears all objects from cache
     * @param Config $config
     */
    public abstract function flush(<Config> config) -> void;
    
    /**
     * Clears all expired (older version or revision) objects from cache
     * @note Be careful implementing this method as flush. Flush must
     *       not interfere with other Definition types, and cleanup()
     *       should not be repeatedly called by userland code.
     * @param Config $config
     */
    public abstract function cleanup(<Config> config) -> void;

}