namespace HTMLPurifier;

/**
 * Object that provides entity lookup table from entity name to character
 */
class EntityLookup
{
    /**
     * Assoc array of entity name to character represented.
     * @type array
     */
    public table;
    /**
     * Sets up the entity lookup table from the serialized file contents.
     * @param bool $file
     * @note The serialized contents are versioned, but were generated
     *       using the maintenance script generate_entity_file.php
     * @warning This is not in constructor to help enforce the Singleton
     */
    public function setup(bool file = false) -> void
    {
        if !(file) {
            let file =  PREFIX . "/HTMLPurifier/EntityLookup/entities.ser";
        }
        let this->table =  unserialize(file_get_contents(file));
    }
    
    /**
     * Retrieves sole instance of the object.
     * @param bool|EntityLookup $prototype Optional prototype of custom lookup table to overload with.
     * @return EntityLookup
     */
    public static function instance(prototype = false) -> <EntityLookup>
    {
        var instance;
    
        // no references, since PHP doesn't copy unless modified
        
            let instance =  null;
        if prototype {
            let instance = prototype;
        } elseif !(instance) {
            let instance =  new EntityLookup();
            instance->setup();
        }
        return instance;
    }

}