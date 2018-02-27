namespace HTMLPurifier;

/**
 * Parses string representations into their corresponding native PHP
 * variable type. The base implementation does a simple type-check.
 */
class VarParser
{
    const STRING = 1;
    const ISTRING = 2;
    const TEXT = 3;
    const ITEXT = 4;
    const INT = 5;
    const FLOAT = 6;
    const BOOL = 7;
    const LOOKUP = 8;
    const ALIST = 9;
    const HASH = 10;
    const MIXED = 11;
    /**
     * Lookup table of allowed types. Mainly for backwards compatibility, but
     * also convenient for transforming string type names to the integer constants.
     */
    public static types = ["string" : self::STRING, "istring" : self::ISTRING, "text" : self::TEXT, "itext" : self::ITEXT, "int" : self::INT, "float" : self::FLOAT, "bool" : self::BOOL, "lookup" : self::LOOKUP, "list" : self::ALIST, "hash" : self::HASH, "mixed" : self::MIXED];
    /**
     * Lookup table of types that are string, and can have aliases or
     * allowed value lists.
     */
    public static stringTypes = [self::STRING : true, self::ISTRING : true, self::TEXT : true, self::ITEXT : true];
    /**
     * Validate a variable according to type.
     * It may return NULL as a valid type if $allow_null is true.
     *
     * @param mixed $var Variable to validate
     * @param int $type Type of variable, see VarParser->types
     * @param bool $allow_null Whether or not to permit null as a value
     * @return string Validated and type-coerced variable
     * @throws VarParserException
     */
    public final function parse(varr, int type, bool allow_null = false) -> string
    {
        var k, keys;
    
        if is_string(type) {
            if !(isset VarParser::types[type]) {
                throw new VarParserException("Invalid type '{type}'");
            } else {
                let type = VarParser::types[type];
            }
        }
        let varr =  this->parseImplementation(varr, type, allow_null);
        if allow_null && varr === null {
            return null;
        }
        // These are basic checks, to make sure nothing horribly wrong
        // happened in our implementations.
        if self::STRING || self::ISTRING || self::TEXT || self::ITEXT {
            if !(is_string(varr)) {
                break;
            }
            if type == self::ISTRING || type == self::ITEXT {
                let varr =  strtolower(varr);
            }
            return varr;
        } elseif self::MIXED {
            return varr;
        } elseif self::LOOKUP || self::ALIST || self::HASH {
            if !(is_array(varr)) {
                break;
            }
            if type === self::LOOKUP {
                for k in varr {
                    if k !== true {
                        this->error("Lookup table contains value other than true");
                    }
                }
            } elseif type === self::ALIST {
                let keys =  array_keys(varr);
                if array_keys(keys) !== keys {
                    this->error("Indices for list are not uniform");
                }
            }
            return varr;
        } elseif self::BOOL {
            if !(is_bool(varr)) {
                break;
            }
            return varr;
        } elseif self::FLOAT {
            if !(is_float(varr)) {
                break;
            }
            return varr;
        } elseif self::INT {
            if !(is_int(varr)) {
                break;
            }
            return varr;
        } else {
            this->errorInconsistent(get_class(this), type);
        }
        this->errorGeneric(varr, type);
    }
    
    /**
     * Actually implements the parsing. Base implementation does not
     * do anything to $var. Subclasses should overload this!
     * @param mixed $var
     * @param int $type
     * @param bool $allow_null
     * @return string
     */
    protected function parseImplementation(varr, int type, bool allow_null) -> string
    {
        return varr;
    }
    
    /**
     * Throws an exception.
     * @throws VarParserException
     */
    protected function error(msg) -> void
    {
        throw new VarParserException(msg);
    }
    
    /**
     * Throws an inconsistency exception.
     * @note This should not ever be called. It would be called if we
     *       extend the allowed values of VarParser without
     *       updating subclasses.
     * @param string $class
     * @param int $type
     * @throws Exception
     */
    protected function errorInconsistent(string classs, int type) -> void
    {
        throw new Exception("Inconsistency in {classs}: " . VarParser::getTypeName(type) . " not implemented");
    }
    
    /**
     * Generic error for if a type didn't work.
     * @param mixed $var
     * @param int $type
     */
    protected function errorGeneric(varr, int type) -> void
    {
        var vtype;
    
        let vtype =  gettype(varr);
        this->error("Expected type " . VarParser::getTypeName(type) . ", got {vtype}");
    }
    
    /**
     * @param int $type
     * @return string
     */
    public static function getTypeName(int type) -> string
    {
        var lookup;
    
        
        if !(lookup) {
            // Lazy load the alternative lookup table
            let lookup =  array_flip(VarParser::types);
        }
        if !(isset lookup[type]) {
            return "unknown";
        }
        return lookup[type];
    }

}