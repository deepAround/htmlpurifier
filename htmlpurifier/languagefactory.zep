namespace HTMLPurifier;

use HTMLPurifier\AttrDef\AttrDefLang;
/**
 * Class responsible for generating Language objects, managing
 * caching and fallbacks.
 * @note Thanks to MediaWiki for the general logic, although this version
 *       has been entirely rewritten
 * @todo Serialized cache for languages
 */
class LanguageFactory
{
    /**
     * Cache of language code information used to load Language objects.
     * Structure is: $factory->cache[$language_code][$key] = $value
     * @type array
     */
    public cache;
    /**
     * Valid keys in the Language object. Designates which
     * variables to slurp out of a message file.
     * @type array
     */
    public keys = ["fallback", "messages", "errorNames"];
    /**
     * Instance to validate language codes.
     * @type AttrDef_Lang
     *
     */
    protected validator;
    /**
     * Cached copy of dirname(__FILE__), directory of current file without
     * trailing slash.
     * @type string
     */
    protected dir;
    /**
     * Keys whose contents are a hash map and can be merged.
     * @type array
     */
    protected mergeable_keys_map = ["messages" : true, "errorNames" : true];
    /**
     * Keys whose contents are a list and can be merged.
     * @value array lookup
     */
    protected mergeable_keys_list = [];
    /**
     * Retrieve sole instance of the factory.
     * @param LanguageFactory $prototype Optional prototype to overload sole instance with,
     *                   or bool true to reset to default factory.
     * @return LanguageFactory
     */
    public static function instance(<LanguageFactory> prototype = null) -> <LanguageFactory>
    {
        var instance;
    
        
            let instance =  null;
        if prototype !== null {
            let instance = prototype;
        } elseif instance === null || prototype == true {
            let instance =  new LanguageFactory();
            instance->setup();
        }
        return instance;
    }
    
    /**
     * Sets up the singleton, much like a constructor
     * @note Prevents people from getting this outside of the singleton
     */
    public function setup() -> void
    {
        let this->validator =  new AttrDefLang();
        let this->dir =  PREFIX . "/HTMLPurifier";
    }
    
    /**
     * Creates a language object, handles class fallbacks
     * @param Config $config
     * @param Context $context
     * @param bool|string $code Code to override configuration with. Private parameter.
     * @return Language
     */
    public function create(<Config> config, <Context> context, code = false) -> <Language>
    {
        var pcode, depth, lang, classs, file, raw_fallback, fallback;
    
        // validate language code
        if code === false {
            let code =  this->validator->validate(config->get("Core.Language"), config, context);
        } else {
            let code =  this->validator->validate(code, config, context);
        }
        if code === false {
            let code = "en";
        }
        let pcode =  str_replace("-", "_", code);
        // make valid PHP classname
        
            let depth = 0;
        // recursion protection
        if code == "en" {
            let lang =  new Language(config, context);
        } else {
            let classs =  "Language_" . pcode;
            let file =  this->dir . "/Language/classes/" . code . ".php";
            if file_exists(file) || class_exists(classs, false) {
                let lang =  new {classs}(config, context);
            } else {
                // Go fallback
                let raw_fallback =  this->getFallbackFor(code);
                let fallback =  raw_fallback ? raw_fallback  : "en";
                let depth++;
                let lang =  this->create(config, context, fallback);
                if !(raw_fallback) {
                    let lang->error =  true;
                }
                let depth--;
            }
        }
        let lang->code = code;
        return lang;
    }
    
    /**
     * Returns the fallback language for language
     * @note Loads the original language into cache
     * @param string $code language code
     * @return string|bool
     */
    public function getFallbackFor(string code)
    {
        this->loadLanguage(code);
        return this->cache[code]["fallback"];
    }
    
    /**
     * Loads language into the cache, handles message file and fallbacks
     * @param string $code language code
     */
    public function loadLanguage(string code)
    {
        var languages_seen, filename, fallback, cache, fallback_cache, key;
    
        
            let languages_seen =  [];
        // recursion guard
        // abort if we've already loaded it
        if isset this->cache[code] {
            return;
        }
        // generate filename
        let filename =  this->dir . "/Language/messages/" . code . ".php";
        // default fallback : may be overwritten by the ensuing include
        let fallback =  code != "en" ? "en"  : false;
        // load primary localisation
        if !(file_exists(filename)) {
            // skip the include: will rely solely on fallback
            let filename =  this->dir . "/Language/messages/en.php";
            let cache =  [];
        } else {
            include filename;
            let cache =  compact(this->keys);
        }
        // load fallback localisation
        if !(empty(fallback)) {
            // infinite recursion guard
            if isset languages_seen[code] {
                trigger_error("Circular fallback reference in language " . code, E_USER_ERROR);
                let fallback = "en";
            }
            let language_seen[code] = true;
            // load the fallback recursively
            this->loadLanguage(fallback);
            let fallback_cache = this->cache[fallback];
            // merge fallback with current language
            for key in this->keys {
                if isset cache[key] && isset fallback_cache[key] {
                    if isset this->mergeable_keys_map[key] {
                        let cache[key] = cache[key] + fallback_cache[key];
                    } elseif isset this->mergeable_keys_list[key] {
                        let cache[key] =  array_merge(fallback_cache[key], cache[key]);
                    }
                } else {
                    let cache[key] = fallback_cache[key];
                }
            }
        }
        // save to cache for later retrieval
        let this->cache[code] = cache;
        return;
    }

}