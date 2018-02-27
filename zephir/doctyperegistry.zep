namespace HTMLPurifier;

class DoctypeRegistry
{
    /**
     * Hash of doctype names to doctype objects.
     * @type array
     */
    protected doctypes;
    /**
     * Lookup table of aliases to real doctype names.
     * @type array
     */
    protected aliases;
    /**
     * Registers a doctype to the registry
     * @note Accepts a fully-formed doctype object, or the
     *       parameters for constructing a doctype object
     * @param string $doctype Name of doctype or literal doctype object
     * @param bool $xml
     * @param array $modules Modules doctype will load
     * @param array $tidy_modules Modules doctype will load for certain modes
     * @param array $aliases Alias names for doctype
     * @param string $dtd_public
     * @param string $dtd_system
     * @return Doctype Editable registered doctype
     */
    public function register(string doctype, bool xml = true, array modules = [], array tidy_modules = [], array aliases = [], string dtd_public = null, string dtd_system = null) -> <Doctype>
    {
        var name, alias;
    
        if !(is_array(modules)) {
            let modules =  [modules];
        }
        if !(is_array(tidy_modules)) {
            let tidy_modules =  [tidy_modules];
        }
        if !(is_array(aliases)) {
            let aliases =  [aliases];
        }
        if !(is_object(doctype)) {
            let doctype =  new Doctype(doctype, xml, modules, tidy_modules, aliases, dtd_public, dtd_system);
        }
        let this->doctypes[doctype->name] = doctype;
        let name =  doctype->name;
        // hookup aliases
        for alias in doctype->aliases {
            if isset this->doctypes[alias] {
                continue;
            }
            let this->aliases[alias] = name;
        }
        // remove old aliases
        if isset this->aliases[name] {
            unset this->aliases[name];
        
        }
        return doctype;
    }
    
    /**
     * Retrieves reference to a doctype of a certain name
     * @note This function resolves aliases
     * @note When possible, use the more fully-featured make()
     * @param string $doctype Name of doctype
     * @return Doctype Editable doctype object
     */
    public function get(string doctype) -> <Doctype>
    {
        var anon;
    
        if isset this->aliases[doctype] {
            let doctype = this->aliases[doctype];
        }
        if !(isset this->doctypes[doctype]) {
            trigger_error("Doctype " . htmlspecialchars(doctype) . " does not exist", E_USER_ERROR);
            let anon =  new Doctype(doctype);
            return anon;
        }
        return this->doctypes[doctype];
    }
    
    /**
     * Creates a doctype based on a configuration object,
     * will perform initialization on the doctype
     * @note Use this function to get a copy of doctype that config
     *       can hold on to (this is necessary in order to tell
     *       Generator whether or not the current document is XML
     *       based or not).
     * @param Config $config
     * @return Doctype
     */
    public function make(<Config> config) -> <Doctype>
    {
        return clone this->get(this->getDoctypeFromConfig(config));
    }
    
    /**
     * Retrieves the doctype from the configuration object
     * @param Config $config
     * @return string
     */
    public function getDoctypeFromConfig(<Config> config) -> string
    {
        var doctype;
    
        // recommended test
        let doctype =  config->get("HTML.Doctype");
        if !(empty(doctype)) {
            return doctype;
        }
        let doctype =  config->get("HTML.CustomDoctype");
        if !(empty(doctype)) {
            return doctype;
        }
        // backwards-compatibility
        if config->get("HTML.XHTML") {
            let doctype = "XHTML 1.0";
        } else {
            let doctype = "HTML 4.01";
        }
        if config->get("HTML.Strict") {
            let doctype .= " Strict";
        } else {
            let doctype .= " Transitional";
        }
        return doctype;
    }

}