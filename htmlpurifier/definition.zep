namespace HTMLPurifier;

/**
 * Super-class for definition datatype objects, implements serialization
 * functions for the class.
 */
abstract class Definition
{
    /**
     * Has setup() been called yet?
     * @type bool
     */
    public setup = false;
    /**
     * If true, write out the final definition object to the cache after
     * setup.  This will be true only if all invocations to get a raw
     * definition object are also optimized.  This does not cause file
     * system thrashing because on subsequent calls the cached object
     * is used and any writes to the raw definition object are short
     * circuited.  See enduser-customize.html for the high-level
     * picture.
     * @type bool
     */
    public optimized = null;
    /**
     * What type of definition is it?
     * @type string
     */
    public type;
    /**
     * Sets up the definition object into the final form, something
     * not done by the constructor
     * @param Config $config
     */
    protected abstract function doSetup(<Config> config) -> void;
    
    /**
     * Setup function that aborts if already setup
     * @param Config $config
     */
    public function setup(<Config> config)
    {
        if this->setup {
            return;
        }
        let this->setup =  true;
        this->doSetup(config);
    }

}