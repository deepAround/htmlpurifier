namespace HTMLPurifier;

use HTMLPurifier\VarParser\VarParserFlexible;
/**
 * Configuration object that triggers customizable behavior.
 *
 * @warning This class is strongly defined: that means that the class
 *          will fail if an undefined directive is retrieved or set.
 *
 * @note Many classes that could (although many times don't) use the
 *       configuration object make it a mandatory parameter.  This is
 *       because a configuration object should always be forwarded,
 *       otherwise, you run the risk of missing a parameter and then
 *       being stumped when a configuration directive doesn't work.
 *
 * @todo Reconsider some of the public member variables
 */
class Config
{
    /**
     * HTML Purifier's version
     * @type string
     */
    public version = "4.10.0";
    /**
     * Whether or not to automatically finalize
     * the object if a read operation is done.
     * @type bool
     */
    public autoFinalize = true;
    // protected member variables
    /**
     * Namespace indexed array of serials for specific namespaces.
     * @see getSerial() for more info.
     * @type string[]
     */
    protected serials = [];
    /**
     * Serial for entire configuration object.
     * @type string
     */
    protected serial;
    /**
     * Parser for variables.
     * @type VarParser_Flexible
     */
    protected parser = null;
    /**
     * Reference ConfigSchema for value checking.
     * @type ConfigSchema
     * @note This is public for introspective purposes. Please don't
     *       abuse!
     */
    public def;
    /**
     * Indexed array of definitions.
     * @type Definition[]
     */
    protected definitions;
    /**
     * Whether or not config is finalized.
     * @type bool
     */
    protected finalized = false;
    /**
     * Property list containing configuration directives.
     * @type array
     */
    protected plist;
    /**
     * Whether or not a set is taking place due to an alias lookup.
     * @type bool
     */
    protected aliasMode;
    /**
     * Set to false if you do not want line and file numbers in errors.
     * (useful when unit testing).  This will also compress some errors
     * and exceptions.
     * @type bool
     */
    public chatty = true;
    /**
     * Current lock; only gets to this namespace are allowed.
     * @type string
     */
    protected lock;
    /**
     * Constructor
     * @param ConfigSchema $definition ConfigSchema that defines
     * what directives are allowed.
     * @param PropertyList $parent
     */
    public function __construct(<ConfigSchema> definition, <PropertyList> parent = null) -> void
    {
        let parent =  parent ? parent  : definition->defaultPlist;
        let this->plist =  new PropertyList(parent);
        let this->def = definition;
        // keep a copy around for checking
        let this->parser =  new VarParserFlexible();
    }
    
    /**
     * Convenience constructor that creates a config object based on a mixed var
     * @param mixed $config Variable that defines the state of the config
     *                      object. Can be: a Config() object,
     *                      an array of directives based on loadArray(),
     *                      or a string filename of an ini file.
     * @param ConfigSchema $schema Schema object
     * @return Config Configured object
     */
    public static function create(config, <ConfigSchema> schema = null) -> <Config>
    {
        var ret;
    
        if config instanceof Config {
            // pass-through
            return config;
        }
        if !(schema) {
            let ret =  Config::createDefault();
        } else {
            let ret =  new Config(schema);
        }
        if is_string(config) {
            ret->loadIni(config);
        } elseif is_array(config) {
            ret->loadArray(config);
        }
        return ret;
    }
    
    /**
     * Creates a new config object that inherits from a previous one.
     * @param Config $config Configuration object to inherit from.
     * @return Config object with $config as its parent.
     */
    public static function inherit(<Config> config) -> <Config>
    {
        return new Config(config->def, config->plist);
    }
    
    /**
     * Convenience constructor that creates a default configuration object.
     * @return Config default object.
     */
    public static function createDefault() -> <Config>
    {
        var definition, config;
    
        let definition =  ConfigSchema::instance();
        let config =  new Config(definition);
        return config;
    }
    
    /**
     * Retrieves a value from the configuration.
     *
     * @param string $key String key
     * @param mixed $a
     *
     * @return mixed
     */
    public function get(string key, a = null)
    {
        var d, ns, tmpListNs;
    
        if a !== null {
            this->triggerError("Using deprecated API: use \$config->get('{key}.{a}') instead", E_USER_WARNING);
            let key = "{key}.{a}";
        }
        if !(this->finalized) {
            this->autoFinalize();
        }
        if !(isset this->def->info[key]) {
            // can't add % due to SimpleTest bug
            this->triggerError("Cannot retrieve value of undefined directive " . htmlspecialchars(key), E_USER_WARNING);
            return;
        }
        if isset this->def->info[key]->isAlias {
            let d = this->def->info[key];
            this->triggerError("Cannot get value from aliased directive, use real name " . d->key, E_USER_ERROR);
            return;
        }
        if this->lock {
            let tmpListNs = explode(".", key);
            let ns = tmpListNs[0];
            if ns !== this->lock {
                this->triggerError("Cannot get value of namespace " . ns . " when lock for " . this->lock . " is active, this probably indicates a Definition setup method " . "is accessing directives that are not within its namespace", E_USER_ERROR);
                return;
            }
        }
        return this->plist->get(key);
    }
    
    /**
     * Retrieves an array of directives to values from a given namespace
     *
     * @param string $namespace String namespace
     *
     * @return array
     */
    public function getBatch(string namespacee) -> array
    {
        var full;
    
        if !(this->finalized) {
            this->autoFinalize();
        }
        let full =  this->getAll();
        if !(isset full[namespacee]) {
            this->triggerError("Cannot retrieve undefined namespace " . htmlspecialchars(namespacee), E_USER_WARNING);
            return;
        }
        return full[namespacee];
    }
    
    /**
     * Returns a SHA-1 signature of a segment of the configuration object
     * that uniquely identifies that particular configuration
     *
     * @param string $namespace Namespace to get serial for
     *
     * @return string
     * @note Revision is handled specially and is removed from the batch
     *       before processing!
     */
    public function getBatchSerial(string namespacee) -> string
    {
        var batch;
    
        if empty(this->serials[namespacee]) {
            let batch =  this->getBatch(namespacee);
            unset batch["DefinitionRev"];
            
            let this->serials[namespacee] =  sha1(serialize(batch));
        }
        return this->serials[namespacee];
    }
    
    /**
     * Returns a SHA-1 signature for the entire configuration object
     * that uniquely identifies that particular configuration
     *
     * @return string
     */
    public function getSerial() -> string
    {
        if empty(this->serial) {
            let this->serial =  sha1(serialize(this->getAll()));
        }
        return this->serial;
    }
    
    /**
     * Retrieves all directives, organized by namespace
     *
     * @warning This is a pretty inefficient function, avoid if you can
     */
    public function getAll()
    {
        var ret, name, value, ns, key, tmpListNsKey;
    
        if !(this->finalized) {
            this->autoFinalize();
        }
        let ret =  [];
        for name, value in this->plist->squash() {
            let tmpListNsKey = explode(".", name, 2);
            let ns = tmpListNsKey[0];
            let key = tmpListNsKey[1];
            let ret[ns][key] = value;
        }
        return ret;
    }
    
    /**
     * Sets a value to configuration.
     *
     * @param string $key key
     * @param mixed $value value
     * @param mixed $a
     */
    public function set(string key, value, a = null)
    {
        var namespacee, directive, tmpListNamespacee, def, rtype, type, allow_null, e;
    
        if strpos(key, ".") === false {
            let namespacee = key;
            let directive = value;
            let value = a;
            let key = "{key}.{directive}";
            this->triggerError("Using deprecated API: use \$config->set('{key}', ...) instead", E_USER_NOTICE);
        } else {
            let tmpListNamespacee = explode(".", key);
            let namespacee = tmpListNamespacee[0];
        }
        if this->isFinalized("Cannot set directive after finalization") {
            return;
        }
        if !(isset this->def->info[key]) {
            this->triggerError("Cannot set undefined directive " . htmlspecialchars(key) . " to value", E_USER_WARNING);
            return;
        }
        let def = this->def->info[key];
        if isset def->isAlias {
            if this->aliasMode {
                this->triggerError("Double-aliases not allowed, please fix " . "ConfigSchema bug with" . key, E_USER_ERROR);
                return;
            }
            let this->aliasMode =  true;
            this->set(def->key, value);
            let this->aliasMode =  false;
            this->triggerError("{key} is an alias, preferred directive name is {def->key}", E_USER_NOTICE);
            return;
        }
        // Raw type might be negative when using the fully optimized form
        // of stdClass, which indicates allow_null == true
        let rtype =  is_int(def) ? def  : def->type;
        if rtype < 0 {
            let type =  -rtype;
            let allow_null =  true;
        } else {
            let type = rtype;
            let allow_null =  isset def->allow_null;
        }
        try {
            let value =  this->parser->parse(value, type, allow_null);
        } catch VarParserException, e {
            this->triggerError("Value for " . key . " is of invalid type, should be " . VarParser::getTypeName(type), E_USER_WARNING);
            return;
        }
        if is_string(value) && is_object(def) {
            // resolve value alias if defined
            if isset def->aliases[value] {
                let value = def->aliases[value];
            }
            // check to see if the value is allowed
            if isset def->allowed && !(isset def->allowed[value]) {
                this->triggerError("Value not supported, valid values are: " . this->_listify(def->allowed), E_USER_WARNING);
                return;
            }
        }
        this->plist->set(key, value);
        // reset definitions if the directives they depend on changed
        // this is a very costly process, so it's discouraged
        // with finalization
        if namespacee == "HTML" || namespacee == "CSS" || namespacee == "URI" {
            let this->definitions[namespacee] = null;
        }
        let this->serials[namespacee] = false;
    }
    
    /**
     * Convenience function for error reporting
     *
     * @param array $lookup
     *
     * @return string
     */
    protected function _listify(array lookup) -> string
    {
        var list, name, b;
    
        let list =  [];
        for name, b in lookup {
            let list[] = name;
        }
        return implode(", ", list);
    }
    
    /**
     * Retrieves object reference to the HTML definition.
     *
     * @param bool $raw Return a copy that has not been setup yet. Must be
     *             called before it's been setup, otherwise won't work.
     * @param bool $optimized If true, this method may return null, to
     *             indicate that a cached version of the modified
     *             definition object is available and no further edits
     *             are necessary.  Consider using
     *             maybeGetRawHTMLDefinition, which is more explicitly
     *             named, instead.
     *
     * @return HTMLDefinition
     */
    public function getHTMLDefinition(bool raw = false, bool optimized = false) -> <HTMLDefinition>
    {
        return this->getDefinition("HTML", raw, optimized);
    }
    
    /**
     * Retrieves object reference to the CSS definition
     *
     * @param bool $raw Return a copy that has not been setup yet. Must be
     *             called before it's been setup, otherwise won't work.
     * @param bool $optimized If true, this method may return null, to
     *             indicate that a cached version of the modified
     *             definition object is available and no further edits
     *             are necessary.  Consider using
     *             maybeGetRawCSSDefinition, which is more explicitly
     *             named, instead.
     *
     * @return CSSDefinition
     */
    public function getCSSDefinition(bool raw = false, bool optimized = false) -> <CSSDefinition>
    {
        return this->getDefinition("CSS", raw, optimized);
    }
    
    /**
     * Retrieves object reference to the URI definition
     *
     * @param bool $raw Return a copy that has not been setup yet. Must be
     *             called before it's been setup, otherwise won't work.
     * @param bool $optimized If true, this method may return null, to
     *             indicate that a cached version of the modified
     *             definition object is available and no further edits
     *             are necessary.  Consider using
     *             maybeGetRawURIDefinition, which is more explicitly
     *             named, instead.
     *
     * @return URIDefinition
     */
    public function getURIDefinition(bool raw = false, bool optimized = false) -> <URIDefinition>
    {
        return this->getDefinition("URI", raw, optimized);
    }
    
    /**
     * Retrieves a definition
     *
     * @param string $type Type of definition: HTML, CSS, etc
     * @param bool $raw Whether or not definition should be returned raw
     * @param bool $optimized Only has an effect when $raw is true.  Whether
     *        or not to return null if the result is already present in
     *        the cache.  This is off by default for backwards
     *        compatibility reasons, but you need to do things this
     *        way in order to ensure that caching is done properly.
     *        Check out enduser-customize.html for more details.
     *        We probably won't ever change this default, as much as the
     *        maybe semantics is the "right thing to do."
     *
     * @throws Exception
     * @return Definition
     */
    public function getDefinition(string type, bool raw = false, bool optimized = false) -> <Definition>
    {
        var lock, factory, cache, def, extra, msg;
    
        if optimized && !(raw) {
            throw new Exception("Cannot set optimized = true when raw = false");
        }
        if !(this->finalized) {
            this->autoFinalize();
        }
        // temporarily suspend locks, so we can handle recursive definition calls
        let lock =  this->lock;
        let this->lock =  null;
        let factory =  DefinitionCacheFactory::instance();
        let cache =  factory->create(type, this);
        let this->lock = lock;
        if !(raw) {
            // full definition
            // ---------------
            // check if definition is in memory
            if !(empty(this->definitions[type])) {
                let def = this->definitions[type];
                // check if the definition is setup
                if def->setup {
                    return def;
                } else {
                    def->setup(this);
                    if def->optimized {
                        cache->add(def, this);
                    }
                    return def;
                }
            }
            // check if definition is in cache
            let def =  cache->get(this);
            if def {
                // definition in cache, save to memory and return it
                let this->definitions[type] = def;
                return def;
            }
            // initialize it
            let def =  this->initDefinition(type);
            // set it up
            let this->lock = type;
            def->setup(this);
            let this->lock =  null;
            // save in cache
            cache->add(def, this);
            // return it
            return def;
        } else {
            // raw definition
            // --------------
            // check preconditions
            let def =  null;
            if optimized {
                if is_null(this->get(type . ".DefinitionID")) {
                    // fatally error out if definition ID not set
                    throw new Exception("Cannot retrieve raw version without specifying %{type}.DefinitionID");
                }
            }
            if !(empty(this->definitions[type])) {
                let def = this->definitions[type];
                if def->setup && !(optimized) {
                    let extra =  this->chatty ? " (try moving this code block earlier in your initialization)"  : "";
                    throw new Exception("Cannot retrieve raw definition after it has already been setup" . extra);
                }
                if def->optimized === null {
                    let extra =  this->chatty ? " (try flushing your cache)"  : "";
                    throw new Exception("Optimization status of definition is unknown" . extra);
                }
                if def->optimized !== optimized {
                    let msg =  optimized ? "optimized"  : "unoptimized";
                    let extra =  this->chatty ? " (this backtrace is for the first inconsistent call, which was for a {msg} raw definition)"  : "";
                    throw new Exception("Inconsistent use of optimized and unoptimized raw definition retrievals" . extra);
                }
            }
            // check if definition was in memory
            if def {
                if def->setup {
                    // invariant: $optimized === true (checked above)
                    return null;
                } else {
                    return def;
                }
            }
            // if optimized, check if definition was in cache
            // (because we do the memory check first, this formulation
            // is prone to cache slamming, but I think
            // guaranteeing that either /all/ of the raw
            // setup code or /none/ of it is run is more important.)
            if optimized {
                // This code path only gets run once; once we put
                // something in $definitions (which is guaranteed by the
                // trailing code), we always short-circuit above.
                let def =  cache->get(this);
                if def {
                    // save the full definition for later, but don't
                    // return it yet
                    let this->definitions[type] = def;
                    return null;
                }
            }
            // check invariants for creation
            if !(optimized) {
                if !(is_null(this->get(type . ".DefinitionID"))) {
                    if this->chatty {
                        this->triggerError("Due to a documentation error in previous version of HTML Purifier, your " . "definitions are not being cached.  If this is OK, you can remove the " . "%$type.DefinitionRev and %$type.DefinitionID declaration.  Otherwise, " . "modify your code to use maybeGetRawDefinition, and test if the returned " . "value is null before making any edits (if it is null, that means that a " . "cached version is available, and no raw operations are necessary).  See " . "<a href=\"http://htmlpurifier.org/docs/enduser-customize.html#optimized\">" . "Customize</a> for more details", E_USER_WARNING);
                    } else {
                        this->triggerError("Useless DefinitionID declaration", E_USER_WARNING);
                    }
                }
            }
            // initialize it
            let def =  this->initDefinition(type);
            let def->optimized = optimized;
            return def;
        }
        throw new Exception("The impossible happened!");
    }
    
    /**
     * Initialise definition
     *
     * @param string $type What type of definition to create
     *
     * @return CSSDefinition|HTMLDefinition|URIDefinition
     * @throws Exception
     */
    protected function initDefinition(string type)
    {
        var def;
    
        // quick checks failed, let's create the object
        if type == "HTML" {
            let def =  new HTMLDefinition();
        } elseif type == "CSS" {
            let def =  new CSSDefinition();
        } elseif type == "URI" {
            let def =  new URIDefinition();
        } else {
            throw new Exception("Definition of {type} type not supported");
        }
        let this->definitions[type] = def;
        return def;
    }
    
    public function maybeGetRawDefinition(name)
    {
        return this->getDefinition(name, true, true);
    }
    
    /**
     * @return HTMLDefinition
     */
    public function maybeGetRawHTMLDefinition() -> <HTMLDefinition>
    {
        return this->getDefinition("HTML", true, true);
    }
    
    /**
     * @return CSSDefinition
     */
    public function maybeGetRawCSSDefinition() -> <CSSDefinition>
    {
        return this->getDefinition("CSS", true, true);
    }
    
    /**
     * @return URIDefinition
     */
    public function maybeGetRawURIDefinition() -> <URIDefinition>
    {
        return this->getDefinition("URI", true, true);
    }
    
    /**
     * Loads configuration values from an array with the following structure:
     * Namespace.Directive => Value
     *
     * @param array $config_array Configuration associative array
     */
    public function loadArray(array config_array)
    {
        var key, value, namespacee, namespace_values, directive, value2;
    
        if this->isFinalized("Cannot load directives after finalization") {
            return;
        }
        for key, value in config_array {
            let key =  str_replace("_", ".", key);
            if strpos(key, ".") !== false {
                this->set(key, value);
            } else {
                let namespacee = key;
                let namespace_values = value;
                for directive, value2 in namespace_values {
                    this->set(namespacee . "." . directive, value2);
                }
            }
        }
    }
    
    /**
     * Returns a list of array(namespace, directive) for all directives
     * that are allowed in a web-form context as per an allowed
     * namespaces/directives list.
     *
     * @param array $allowed List of allowed namespaces/directives
     * @param ConfigSchema $schema Schema to use, if not global copy
     *
     * @return array
     */
    public static function getAllowedDirectivesForForm(array allowed, <ConfigSchema> schema = null) -> array
    {
        var allowed_ns, allowed_directives, blacklisted_directives, ns_or_directive, ret, key, def, ns, directive, tmpListNsDirective;
    
        if !(schema) {
            let schema =  ConfigSchema::instance();
        }
        if allowed !== true {
            if is_string(allowed) {
                let allowed =  [allowed];
            }
            let allowed_ns =  [];
            let allowed_directives =  [];
            let blacklisted_directives =  [];
            for ns_or_directive in allowed {
                if strpos(ns_or_directive, ".") !== false {
                    // directive
                    if ns_or_directive[0] == "-" {
                        let blacklisted_directives[substr(ns_or_directive, 1)] = true;
                    } else {
                        let allowed_directives[ns_or_directive] = true;
                    }
                } else {
                    // namespace
                    let allowed_ns[ns_or_directive] = true;
                }
            }
        }
        let ret =  [];
        for key, def in schema->info {
            let tmpListNsDirective = explode(".", key, 2);
            let ns = tmpListNsDirective[0];
            let directive = tmpListNsDirective[1];
            if allowed !== true {
                if isset blacklisted_directives["{ns}.{directive}"] {
                    continue;
                }
                if !(isset allowed_directives["{ns}.{directive}"]) && !(isset allowed_ns[ns]) {
                    continue;
                }
            }
            if isset def->isAlias {
                continue;
            }
            if directive == "DefinitionID" || directive == "DefinitionRev" {
                continue;
            }
            let ret[] =  [ns, directive];
        }
        return ret;
    }
    
    /**
     * Loads configuration values from $_GET/$_POST that were posted
     * via ConfigForm
     *
     * @param array $array $_GET or $_POST array to import
     * @param string|bool $index Index/name that the config variables are in
     * @param array|bool $allowed List of allowed namespaces/directives
     * @param bool $mq_fix Boolean whether or not to enable magic quotes fix
     * @param ConfigSchema $schema Schema to use, if not global copy
     *
     * @return mixed
     */
    public static function loadArrayFromForm(array myArray, index = false, allowed = true, bool mq_fix = true, <ConfigSchema> schema = null)
    {
        var ret, config;
    
        let ret =  Config::prepareArrayFromForm(myArray, index, allowed, mq_fix, schema);
        let config =  Config::create(ret, schema);
        return config;
    }
    
    /**
     * Merges in configuration values from $_GET/$_POST to object. NOT STATIC.
     *
     * @param array $array $_GET or $_POST array to import
     * @param string|bool $index Index/name that the config variables are in
     * @param array|bool $allowed List of allowed namespaces/directives
     * @param bool $mq_fix Boolean whether or not to enable magic quotes fix
     */
    public function mergeArrayFromForm(array myArray, index = false, allowed = true, bool mq_fix = true) -> void
    {
        var ret;
    
        let ret =  Config::prepareArrayFromForm(myArray, index, allowed, mq_fix, this->def);
        this->loadArray(ret);
    }
    
    /**
     * Prepares an array from a form into something usable for the more
     * strict parts of Config
     *
     * @param array $array $_GET or $_POST array to import
     * @param string|bool $index Index/name that the config variables are in
     * @param array|bool $allowed List of allowed namespaces/directives
     * @param bool $mq_fix Boolean whether or not to enable magic quotes fix
     * @param ConfigSchema $schema Schema to use, if not global copy
     *
     * @return array
     */
    public static function prepareArrayFromForm(array myArray, index = false, allowed = true, bool mq_fix = true, <ConfigSchema> schema = null) -> array
    {
        var mq, ret, key, ns, directive, tmpListNsDirective, skey, value;
    
        if index !== false {
            let myArray =  isset myArray[index] && is_array(myArray[index]) ? myArray[index]  : [];
        }
        let mq =  mq_fix && function_exists("get_magic_quotes_gpc") && get_magic_quotes_gpc();
        let allowed =  Config::getAllowedDirectivesForForm(allowed, schema);
        let ret =  [];
        for key in allowed {
            let tmpListNsDirective = key;
            let ns = tmpListNsDirective[0];
            let directive = tmpListNsDirective[1];
            let skey = "{ns}.{directive}";
            if !(empty(myArray["Null_{skey}"])) {
                let ret[ns][directive] = null;
                continue;
            }
            if !(isset myArray[skey]) {
                continue;
            }
            let value =  mq ? stripslashes(myArray[skey])  : myArray[skey];
            let ret[ns][directive] = value;
        }
        return ret;
    }
    
    /**
     * Loads configuration values from an ini file
     *
     * @param string $filename Name of ini file
     */
    public function loadIni(string filename)
    {
        var myArray;
    
        if this->isFinalized("Cannot load directives after finalization") {
            return;
        }
        let myArray =  parse_ini_file(filename, true);
        this->loadArray(myArray);
    }
    
    /**
     * Checks whether or not the configuration object is finalized.
     *
     * @param string|bool $error String error message, or false for no error
     *
     * @return bool
     */
    public function isFinalized(error = false) -> bool
    {
        if this->finalized && error {
            this->triggerError(error, E_USER_ERROR);
        }
        return this->finalized;
    }
    
    /**
     * Finalizes configuration only if auto finalize is on and not
     * already finalized
     */
    public function autoFinalize() -> void
    {
        if this->autoFinalize {
            this->finalize();
        } else {
            this->plist->squash(true);
        }
    }
    
    /**
     * Finalizes a configuration object, prohibiting further change
     */
    public function finalize() -> void
    {
        let this->finalized =  true;
        let this->parser =  null;
    }
    
    /**
     * Produces a nicely formatted error message by supplying the
     * stack frame information OUTSIDE of Config.
     *
     * @param string $msg An error message
     * @param int $no An error number
     */
    protected function triggerError(string msg, int no) -> void
    {
        var extra, trace, i, c, frame;
    
        // determine previous stack frame
        let extra = "";
        if this->chatty {
            let trace =  debug_backtrace();
            // zip(tail(trace), trace) -- but PHP is not Haskell har har
            let i = 0;
            let c =  count(trace);
            for i in range(0, c - 1) {
                // XXX this is not correct on some versions of HTML Purifier
                if trace[i + 1]["class"] === "Config" {
                    continue;
                }
                let frame = trace[i];
                let extra = " invoked on line {frame["line"]} in file {frame["file"]}";
                break;
            }
        }
        trigger_error(msg . extra, no);
    }
    
    /**
     * Returns a serialized form of the configuration object that can
     * be reconstituted.
     *
     * @return string
     */
    public function serialize() -> string
    {
        this->getDefinition("HTML");
        this->getDefinition("CSS");
        this->getDefinition("URI");
        return serialize(this);
    }

}