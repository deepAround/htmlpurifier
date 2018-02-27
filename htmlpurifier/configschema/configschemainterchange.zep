namespace HTMLPurifier\ConfigSchema;

/**
 * Generic schema interchange format that can be converted to a runtime
 * representation (ConfigSchema) or HTML documentation. Members
 * are completely validated.
 */
class ConfigSchemaInterchange
{
    /**
     * Name of the application this schema is describing.
     * @type string
     */
    public name;
    /**
     * Array of Directive ID => array(directive info)
     * @type ConfigSchema_Interchange_Directive[]
     */
    public directives = [];
    /**
     * Adds a directive array to $directives
     * @param ConfigSchema_Interchange_Directive $directive
     * @throws ConfigSchema_Exception
     */
    public function addDirective(directive) -> void
    {
        var i;
    
        let i =  directive->id->toString();
        if isset this->directives[i] {
            throw new ConfigSchemaException("Cannot redefine directive '{i}'");
        }
        let this->directives[i] = directive;
    }
    
    /**
     * Convenience function to perform standard validation. Throws exception
     * on failed validation.
     */
    public function validate()
    {
        var validator;
    
        let validator =  new ConfigSchemaValidator();
        return validator->validate(this);
    }

}