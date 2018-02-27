namespace HTMLPurifier\ConfigSchema;

/**
 * Fluent interface for validating the contents of member variables.
 * This should be immutable. See ConfigSchema_Validator for
 * use-cases. We name this an 'atom' because it's ONLY for validations that
 * are independent and usually scalar.
 */
class ConfigSchemaValidatorAtom
{
    /**
     * @type string
     */
    protected context;
    /**
     * @type object
     */
    protected obj;
    /**
     * @type string
     */
    protected member;
    /**
     * @type mixed
     */
    protected contents;
    public function __construct(context, obj, member) -> void
    {
        let this->context = context;
        let this->obj = obj;
        let this->member = member;
        let this->contents = obj->{member};
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertIsString()
    {
        if !(is_string(this->contents)) {
            this->error("must be a string");
        }
        return this;
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertIsBool()
    {
        if !(is_bool(this->contents)) {
            this->error("must be a boolean");
        }
        return this;
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertIsArray()
    {
        if !(is_array(this->contents)) {
            this->error("must be an array");
        }
        return this;
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertNotNull()
    {
        if this->contents === null {
            this->error("must not be null");
        }
        return this;
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertAlnum()
    {
        this->assertIsString();
        if !(ctype_alnum(this->contents)) {
            this->error("must be alphanumeric");
        }
        return this;
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertNotEmpty()
    {
        if empty(this->contents) {
            this->error("must not be empty");
        }
        return this;
    }
    
    /**
     * @return ConfigSchema_ValidatorAtom
     */
    public function assertIsLookup()
    {
        var v;
    
        this->assertIsArray();
        for v in this->contents {
            if v !== true {
                this->error("must be a lookup array");
            }
        }
        return this;
    }
    
    /**
     * @param string $msg
     * @throws ConfigSchema_Exception
     */
    protected function error(string msg) -> void
    {
        throw new ConfigSchemaException(ucfirst(this->member) . " in " . this->context . " " . msg);
    }

}