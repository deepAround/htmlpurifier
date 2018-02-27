namespace HTMLPurifier\ConfigSchema;

use HTMLPurifier\StringHash;
use HTMLPurifier\StringHashParser;
use HTMLPurifier\VarParserException;
use HTMLPurifier\ConfigSchema\Interchange\ConfigSchemaInterchangeDirective;
use HTMLPurifier\ConfigSchema\Interchange\ConfigSchemaInterchangeId;
use HTMLPurifier\VarParser\VarParserNative;
class ConfigSchemaInterchangeBuilder
{
    /**
     * Used for processing DEFAULT, nothing else.
     * @type VarParser
     */
    protected varParser;
    /**
     * @param VarParser $varParser
     */
    public function __construct(<VarParser> varParser = null) -> void
    {
        let this->varParser =  varParser ? varParser  : new VarParserNative();
    }
    
    /**
     * @param string $dir
     * @return ConfigSchema_Interchange
     */
    public static function buildFromDirectory(string dir = null)
    {
        var builder, interchange;
    
        let builder =  new ConfigSchemaInterchangeBuilder();
        let interchange =  new ConfigSchemaInterchange();
        return builder->buildDir(interchange, dir);
    }
    
    /**
     * @param ConfigSchema_Interchange $interchange
     * @param string $dir
     * @return ConfigSchema_Interchange
     */
    public function buildDir(interchange, string dir = null)
    {
        var info, files, dh, file;
    
        if !(dir) {
            let dir =  PREFIX . "/HTMLPurifier/ConfigSchema/schema";
        }
        if file_exists(dir . "/info.ini") {
            let info =  parse_ini_file(dir . "/info.ini");
            let interchange->name = info["name"];
        }
        let files =  [];
        let dh =  opendir(dir);
        let file =  readdir(dh);
        while (file !== false) {
            if !(file) || file[0] == "." || strrchr(file, ".") !== ".txt" {
                continue;
            }
            let files[] = file;
        let file =  readdir(dh);
        }
        closedir(dh);
        sort(files);
        for file in files {
            this->buildFile(interchange, dir . "/" . file);
        }
        return interchange;
    }
    
    /**
     * @param ConfigSchema_Interchange $interchange
     * @param string $file
     */
    public function buildFile(interchange, string file) -> void
    {
        var parser;
    
        let parser =  new StringHashParser();
        this->build(interchange, new StringHash(parser->parseFile(file)));
    }
    
    /**
     * Builds an interchange object based on a hash.
     * @param ConfigSchema_Interchange $interchange ConfigSchema_Interchange object to build
     * @param StringHash $hash source data
     * @throws ConfigSchema_Exception
     */
    public function build(interchange, <StringHash> hash) -> void
    {
        if !(hash instanceof StringHash) {
            let hash =  new StringHash(hash);
        }
        if !(isset hash["ID"]) {
            throw new ConfigSchemaException("Hash does not have any ID");
        }
        if strpos(hash["ID"], ".") === false {
            if count(hash) == 2 && isset hash["DESCRIPTION"] {
                hash->offsetGet("DESCRIPTION");
            } else {
                throw new ConfigSchemaException("All directives must have a namespace");
            }
        } else {
            this->buildDirective(interchange, hash);
        }
        this->_findUnused(hash);
    }
    
    /**
     * @param ConfigSchema_Interchange $interchange
     * @param StringHash $hash
     * @throws ConfigSchema_Exception
     */
    public function buildDirective(interchange, <StringHash> hash) -> void
    {
        var directive, id, type, e, raw_aliases, aliases, alias;
    
        let directive =  new ConfigSchemaInterchangeDirective();
        // These are required elements:
        let directive->id =  this->id(hash->offsetGet("ID"));
        let id =  directive->id->toString();
        // convenience
        if isset hash["TYPE"] {
            let type =  explode("/", hash->offsetGet("TYPE"));
            if isset type[1] {
                let directive->typeAllowsNull =  true;
            }
            let directive->type = type[0];
        } else {
            throw new ConfigSchemaException("TYPE in directive hash '{id}' not defined");
        }
        if isset hash["DEFAULT"] {
            try {
                let directive->default =  this->varParser->parse(hash->offsetGet("DEFAULT"), directive->type, directive->typeAllowsNull);
            } catch VarParserException, e {
                throw new ConfigSchemaException(e->getMessage() . " in DEFAULT in directive hash '{id}'");
            }
        }
        if isset hash["DESCRIPTION"] {
            let directive->description =  hash->offsetGet("DESCRIPTION");
        }
        if isset hash["ALLOWED"] {
            let directive->allowed =  this->lookup(this->evalArray(hash->offsetGet("ALLOWED")));
        }
        if isset hash["VALUE-ALIASES"] {
            let directive->valueAliases =  this->evalArray(hash->offsetGet("VALUE-ALIASES"));
        }
        if isset hash["ALIASES"] {
            let raw_aliases =  trim(hash->offsetGet("ALIASES"));
            let aliases =  preg_split("/\\s*,\\s*/", raw_aliases);
            for alias in aliases {
                let directive->aliases[] =  this->id(alias);
            }
        }
        if isset hash["VERSION"] {
            let directive->version =  hash->offsetGet("VERSION");
        }
        if isset hash["DEPRECATED-USE"] {
            let directive->deprecatedUse =  this->id(hash->offsetGet("DEPRECATED-USE"));
        }
        if isset hash["DEPRECATED-VERSION"] {
            let directive->deprecatedVersion =  hash->offsetGet("DEPRECATED-VERSION");
        }
        if isset hash["EXTERNAL"] {
            let directive->external =  preg_split("/\\s*,\\s*/", trim(hash->offsetGet("EXTERNAL")));
        }
        interchange->addDirective(directive);
    }
    
    /**
     * Evaluates an array PHP code string without array() wrapper
     * @param string $contents
     */
    protected function evalArray(string contents)
    {
        return eval("return array(" . contents . ");");
    }
    
    /**
     * Converts an array list into a lookup array.
     * @param array $array
     * @return array
     */
    protected function lookup(array myArray) -> array
    {
        var ret, val;
    
        let ret =  [];
        for val in myArray {
            let ret[val] = true;
        }
        return ret;
    }
    
    /**
     * Convenience function that creates an ConfigSchema_Interchange_Id
     * object based on a string Id.
     * @param string $id
     * @return ConfigSchema_Interchange_Id
     */
    protected function id(string id)
    {
        return ConfigSchemaInterchangeId::make(id);
    }
    
    /**
     * Triggers errors for any unused keys passed in the hash; such keys
     * may indicate typos, missing values, etc.
     * @param StringHash $hash Hash to check.
     */
    protected function _findUnused(<StringHash> hash) -> void
    {
        var accessed, k, v;
    
        let accessed =  hash->getAccessed();
        for k, v in hash {
            if !(isset accessed[k]) {
                trigger_error("String hash key '{k}' not used by builder", E_USER_NOTICE);
            }
        }
    }

}