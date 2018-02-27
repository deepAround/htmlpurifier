namespace HTMLPurifier;

use stdClass;
/**
 * Configuration definition, defines directives and their defaults.
 */
class ConfigSchema
{
    /**
     * Defaults of the directives and namespaces.
     * @type array
     * @note This shares the exact same structure as Config::$conf
     */
    public defaults = [];
    /**
     * The default property list. Do not edit this property list.
     * @type array
     */
    public defaultPlist;
    /**
     * Definition of the directives.
     * The structure of this is:
     *
     *  array(
     *      'Namespace' => array(
     *          'Directive' => new stdClass(),
     *      )
     *  )
     *
     * The stdClass may have the following properties:
     *
     *  - If isAlias isn't set:
     *      - type: Integer type of directive, see VarParser for definitions
     *      - allow_null: If set, this directive allows null values
     *      - aliases: If set, an associative array of value aliases to real values
     *      - allowed: If set, a lookup array of allowed (string) values
     *  - If isAlias is set:
     *      - namespace: Namespace this directive aliases to
     *      - name: Directive name this directive aliases to
     *
     * In certain degenerate cases, stdClass will actually be an integer. In
     * that case, the value is equivalent to an stdClass with the type
     * property set to the integer. If the integer is negative, type is
     * equal to the absolute value of integer, and allow_null is true.
     *
     * This class is friendly with Config. If you need introspection
     * about the schema, you're better of using the ConfigSchema_Interchange,
     * which uses more memory but has much richer information.
     * @type array
     */
    public info = [];
    /**
     * Application-wide singleton
     * @type ConfigSchema
     */
    protected static singleton;
    public function __construct() -> void
    {
        let this->defaultPlist =  new PropertyList();
    }
    
    /**
     * Unserializes the default ConfigSchema.
     * @return ConfigSchema
     */
    public static function makeFromSerial() -> <ConfigSchema>
    {
        var contents, r, hash;
    
        let contents =  file_get_contents(PREFIX . "/HTMLPurifier/ConfigSchema/schema.ser");
        let r =  unserialize(contents);
        if !(r) {
            let hash =  sha1(contents);
            trigger_error("Unserialization of configuration schema failed, sha1 of file was {hash}", E_USER_ERROR);
        }
        return r;
    }
    
    /**
     * Retrieves an instance of the application-wide configuration definition.
     * @param ConfigSchema $prototype
     * @return ConfigSchema
     */
    public static function instance(<ConfigSchema> prototype = null) -> <ConfigSchema>
    {
        if prototype !== null {
            let ConfigSchema::singleton = prototype;
        } elseif ConfigSchema::singleton === null || prototype === true {
            let ConfigSchema::singleton =  ConfigSchema::makeFromSerial();
        }
        return ConfigSchema::singleton;
    }
    
    /**
     * Defines a directive for configuration
     * @warning Will fail of directive's namespace is defined.
     * @warning This method's signature is slightly different from the legacy
     *          define() static method! Beware!
     * @param string $key Name of directive
     * @param mixed $default Default value of directive
     * @param string $type Allowed type of the directive. See
     *      DirectiveDef::$type for allowed values
     * @param bool $allow_null Whether or not to allow null values
     */
    public function add(string key, default, string type, bool allow_null) -> void
    {
        var obj;
    
        let obj =  new stdClass();
        let obj->type =  is_int(type) ? type  : VarParser::types[type];
        if allow_null {
            let obj->allow_null =  true;
        }
        let this->info[key] = obj;
        let this->defaults[key] = default;
        this->defaultPlist->set(key, default);
    }
    
    /**
     * Defines a directive value alias.
     *
     * Directive value aliases are convenient for developers because it lets
     * them set a directive to several values and get the same result.
     * @param string $key Name of Directive
     * @param array $aliases Hash of aliased values to the real alias
     */
    public function addValueAliases(string key, array aliases) -> void
    {
        var alias, real;
    
        if !(isset this->info[key]->aliases) {
            let this->info[key]->aliases =  [];
        }
        for alias, real in aliases {
            let this->info[key]->aliases[alias] = real;
        }
    }
    
    /**
     * Defines a set of allowed values for a directive.
     * @warning This is slightly different from the corresponding static
     *          method definition.
     * @param string $key Name of directive
     * @param array $allowed Lookup array of allowed values
     */
    public function addAllowedValues(string key, array allowed) -> void
    {
        let this->info[key]->allowed = allowed;
    }
    
    /**
     * Defines a directive alias for backwards compatibility
     * @param string $key Directive that will be aliased
     * @param string $new_key Directive that the alias will be to
     */
    public function addAlias(string key, string new_key) -> void
    {
        var obj;
    
        let obj =  new stdClass();
        let obj->key = new_key;
        let obj->isAlias =  true;
        let this->info[key] = obj;
    }
    
    /**
     * Replaces any stdClass that only has the type property with type integer.
     */
    public function postProcess() -> void
    {
        var key, v;
    
        for key, v in this->info {
            if count((array) v) == 1 {
                let this->info[key] = v->type;
            } elseif count((array) v) == 2 && isset v->allow_null {
                let this->info[key] = -v->type;
            }
        }
    }

}