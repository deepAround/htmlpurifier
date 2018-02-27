namespace HTMLPurifier;

/**
 * Represents a language and defines localizable string formatting and
 * other functions, as well as the localized messages for HTML Purifier.
 */
class Language
{
    /**
     * ISO 639 language code of language. Prefers shortest possible version.
     * @type string
     */
    public code = "en";
    /**
     * Fallback language code.
     * @type bool|string
     */
    public fallback = false;
    /**
     * Array of localizable messages.
     * @type array
     */
    public messages = [];
    /**
     * Array of localizable error codes.
     * @type array
     */
    public errorNames = [];
    /**
     * True if no message file was found for this language, so English
     * is being used instead. Check this if you'd like to notify the
     * user that they've used a non-supported language.
     * @type bool
     */
    public error = false;
    /**
     * Has the language object been loaded yet?
     * @type bool
     * @todo Make it private, fix usage in LanguageTest
     */
    public _loaded = false;
    /**
     * @type Config
     */
    protected config;
    /**
     * @type Context
     */
    protected context;
    /**
     * @param Config $config
     * @param Context $context
     */
    public function __construct(<Config> config, <Context> context) -> void
    {
        let this->config = config;
        let this->context = context;
    }
    
    /**
     * Loads language object with necessary info from factory cache
     * @note This is a lazy loader
     */
    public function load()
    {
        var factory, key;
    
        if this->_loaded {
            return;
        }
        let factory =  LanguageFactory::instance();
        factory->loadLanguage(this->code);
        for key in factory->keys {
            let this->{key} = factory->cache[this->code][key];
        }
        let this->_loaded =  true;
    }
    
    /**
     * Retrieves a localised message.
     * @param string $key string identifier of message
     * @return string localised message
     */
    public function getMessage(string key) -> string
    {
        if !(this->_loaded) {
            this->load();
        }
        if !(isset this->messages[key]) {
            return "[{key}]";
        }
        return this->messages[key];
    }
    
    /**
     * Retrieves a localised error name.
     * @param int $int error number, corresponding to PHP's error reporting
     * @return string localised message
     */
    public function getErrorName(int intt) -> string
    {
        if !(this->_loaded) {
            this->load();
        }
        if !(isset this->errorNames[intt]) {
            return "[Error: {intt}]";
        }
        return this->errorNames[intt];
    }
    
    /**
     * Converts an array list into a string readable representation
     * @param array $array
     * @return string
     */
    public function listify(array myArray) -> string
    {
        var sep, sep_last, ret, i, c;
    
        let sep =  this->getMessage("Item separator");
        let sep_last =  this->getMessage("Item separator last");
        let ret = "";
        let i = 0;
        let c =  count(myArray);
        for i in range(0, c) {
            if i == 0 {
                echo "not allowed";
            } elseif i + 1 < c {
                let ret .= sep;
            } else {
                let ret .= sep_last;
            }
            let ret .= myArray[i];
        }
        return ret;
    }
    
    /**
     * Formats a localised message with passed parameters
     * @param string $key string identifier of message
     * @param array $args Parameters to substitute in
     * @return string localised message
     * @todo Implement conditionals? Right now, some messages make
     *     reference to line numbers, but those aren't always available
     */
    public function formatMessage(string key, array args = []) -> string
    {
        var raw, subst, generator, i, value, stripped_token, keys;
    
        if !(this->_loaded) {
            this->load();
        }
        if !(isset this->messages[key]) {
            return "[{key}]";
        }
        let raw = this->messages[key];
        let subst =  [];
        let generator =  false;
        for i, value in args {
            if is_object(value) {
                if value instanceof Token {
                    // factor this out some time
                    if !(generator) {
                        let generator =  this->context->get("Generator");
                    }
                    if isset value->name {
                        let subst["$" . i . ".Name"] = value->name;
                    }
                    if isset value->data {
                        let subst["$" . i . ".Data"] = value->data;
                    }
                    let subst["$" . i . ".Serialized"] =  generator->generateFromToken(value);
                    let subst["$" . i . ".Compact"] = subst["$" . i . ".Serialized"];
                    // a more complex algorithm for compact representation
                    // could be introduced for all types of tokens. This
                    // may need to be factored out into a dedicated class
                    if !(empty(value->attr)) {
                        let stripped_token =  clone value;
                        let stripped_token->attr =  [];
                        let subst["$" . i . ".Compact"] =  generator->generateFromToken(stripped_token);
                    }
                    let subst["$" . i . ".Line"] =  value->line ? value->line  : "unknown";
                }
                continue;
            } elseif is_array(value) {
                let keys =  array_keys(value);
                if array_keys(keys) === keys {
                    // list
                    let subst["$" . i] =  this->listify(value);
                } else {
                    // associative array
                    // no $i implementation yet, sorry
                    let subst["$" . i . ".Keys"] =  this->listify(keys);
                    let subst["$" . i . ".Values"] =  this->listify(array_values(value));
                }
                continue;
            }
            let subst["$" . i] = value;
        }
        return strtr(raw, subst);
    }

}