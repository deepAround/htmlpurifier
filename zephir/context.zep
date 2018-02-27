namespace HTMLPurifier;

/**
 * Registry object that contains information about the current context.
 * @warning Is a bit buggy when variables are set to null: it thinks
 *          they don't exist! So use false instead, please.
 * @note Since the variables Context deals with may not be objects,
 *       references are very important here! Do not remove!
 */
class Context
{
    /**
     * Private array that stores the references.
     * @type array
     */
    protected _storage = [];
    /**
     * Registers a variable into the context.
     * @param string $name String name
     * @param mixed $ref Reference to variable to be registered
     */
    public function register(string name, ref)
    {
        if array_key_exists(name, this->_storage) {
            trigger_error("Name {name} produces collision, cannot re-register", E_USER_ERROR);
            return;
        }
        let this->_storage[name] = ref;
    }
    
    /**
     * Retrieves a variable reference from the context.
     * @param string $name String name
     * @param bool $ignore_error Boolean whether or not to ignore error
     * @return mixed
     */
    public function get(string name, bool ignore_error = false)
    {
        var varr;
    
        if !(array_key_exists(name, this->_storage)) {
            if !(ignore_error) {
                trigger_error("Attempted to retrieve non-existent variable {name}", E_USER_ERROR);
            }
            let varr =  null;
            // so we can return by reference
            return varr;
        }
        return this->_storage[name];
    }
    
    /**
     * Destroys a variable in the context.
     * @param string $name String name
     */
    public function destroy(string name)
    {
        if !(array_key_exists(name, this->_storage)) {
            trigger_error("Attempted to destroy non-existent variable {name}", E_USER_ERROR);
            return;
        }
        unset this->_storage[name];
    
    }
    
    /**
     * Checks whether or not the variable exists.
     * @param string $name String name
     * @return bool
     */
    public function exists(string name) -> bool
    {
        return array_key_exists(name, this->_storage);
    }
    
    /**
     * Loads a series of variables from an associative array
     * @param array $context_array Assoc array of variables to load
     */
    public function loadArray(array context_array) -> void
    {
        var key, discard;
    
        for key, discard in context_array {
            this->register(key, context_array[key]);
        }
    }

}