namespace HTMLPurifier;

class HTMLModuleManager
{
    /**
     * @type DoctypeRegistry
     */
    public doctypes;
    /**
     * Instance of current doctype.
     * @type string
     */
    public doctype;
    /**
     * @type AttrTypes
     */
    public attrTypes;
    /**
     * Active instances of modules for the specified doctype are
     * indexed, by name, in this array.
     * @type HTMLModule[]
     */
    public modules = [];
    /**
     * Array of recognized HTMLModule instances,
     * indexed by module's class name. This array is usually lazy loaded, but a
     * user can overload a module by pre-emptively registering it.
     * @type HTMLModule[]
     */
    public registeredModules = [];
    /**
     * List of extra modules that were added by the user
     * using addModule(). These get unconditionally merged into the current doctype, whatever
     * it may be.
     * @type HTMLModule[]
     */
    public userModules = [];
    /**
     * Associative array of element name to list of modules that have
     * definitions for the element; this array is dynamically filled.
     * @type array
     */
    public elementLookup = [];
    /**
     * List of prefixes we should use for registering small names.
     * @type array
     */
    public prefixes = ["HTMLModule_"];
    /**
     * @type ContentSets
     */
    public contentSets;
    /**
     * @type AttrCollections
     */
    public attrCollections;
    /**
     * If set to true, unsafe elements and attributes will be allowed.
     * @type bool
     */
    public trusted = false;
    public function __construct() -> void
    {
        var common, transitional, xml, non_xml, tmpArrayd153346ed2749514660f35117387ac04, tmpArray40cd750bba9870f18aada2478b24840a, tmpArray66b6e6be4e62c1c03493d1f30ab0e589, tmpArrayd6c0dd1f95c4e2d4a8af797125c18e24, tmpArray4c4796851a59408e5c5907a719cabe30, tmpArrayb9e16973a74f1749293bf8eaecbf5d41, tmpArrayaf86367e571e47f92b54b7264dc36a40;
    
        // editable internal objects
        let this->attrTypes =  new AttrTypes();
        let this->doctypes =  new DoctypeRegistry();
        // setup basic modules
        let common =  ["CommonAttributes", "Text", "Hypertext", "List", "Presentation", "Edit", "Bdo", "Tables", "Image", "StyleAttribute", "Scripting", "Object", "Forms", "Name"];
        let transitional =  ["Legacy", "Target", "Iframe"];
        let xml =  ["XMLCommonAttributes"];
        let non_xml =  ["NonXMLCommonAttributes"];
        // setup basic doctypes
        let tmpArrayd153346ed2749514660f35117387ac04 = ["Tidy_Transitional", "Tidy_Proprietary"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        this->doctypes->register("HTML 4.01 Transitional", false, array_merge(common, transitional, non_xml), tmpArrayd153346ed2749514660f35117387ac04, tmpArray40cd750bba9870f18aada2478b24840a, "-//W3C//DTD HTML 4.01 Transitional//EN", "http://www.w3.org/TR/html4/loose.dtd");
        let tmpArray66b6e6be4e62c1c03493d1f30ab0e589 = ["Tidy_Strict", "Tidy_Proprietary", "Tidy_Name"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        this->doctypes->register("HTML 4.01 Strict", false, array_merge(common, non_xml), tmpArray66b6e6be4e62c1c03493d1f30ab0e589, tmpArray40cd750bba9870f18aada2478b24840a, "-//W3C//DTD HTML 4.01//EN", "http://www.w3.org/TR/html4/strict.dtd");
        let tmpArrayd6c0dd1f95c4e2d4a8af797125c18e24 = ["Tidy_Transitional", "Tidy_XHTML", "Tidy_Proprietary", "Tidy_Name"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        this->doctypes->register("XHTML 1.0 Transitional", true, array_merge(common, transitional, xml, non_xml), tmpArrayd6c0dd1f95c4e2d4a8af797125c18e24, tmpArray40cd750bba9870f18aada2478b24840a, "-//W3C//DTD XHTML 1.0 Transitional//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd");
        let tmpArray4c4796851a59408e5c5907a719cabe30 = ["Tidy_Strict", "Tidy_XHTML", "Tidy_Strict", "Tidy_Proprietary", "Tidy_Name"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        this->doctypes->register("XHTML 1.0 Strict", true, array_merge(common, xml, non_xml), tmpArray4c4796851a59408e5c5907a719cabe30, tmpArray40cd750bba9870f18aada2478b24840a, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
        let tmpArrayb9e16973a74f1749293bf8eaecbf5d41 = ["Ruby", "Iframe"];
        let tmpArrayaf86367e571e47f92b54b7264dc36a40 = ["Tidy_Strict", "Tidy_XHTML", "Tidy_Proprietary", "Tidy_Strict", "Tidy_Name"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        this->doctypes->register("XHTML 1.1", true, array_merge(common, xml, tmpArrayb9e16973a74f1749293bf8eaecbf5d41), tmpArrayaf86367e571e47f92b54b7264dc36a40, tmpArray40cd750bba9870f18aada2478b24840a, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd");
    }
    
    /**
     * Registers a module to the recognized module list, useful for
     * overloading pre-existing modules.
     * @param $module Mixed: string module name, with or without
     *                HTMLModule prefix, or instance of
     *                subclass of HTMLModule.
     * @param $overload Boolean whether or not to overload previous modules.
     *                  If this is not set, and you do overload a module,
     *                  HTML Purifier will complain with a warning.
     * @note This function will not call autoload, you must instantiate
     *       (and thus invoke) autoload outside the method.
     * @note If a string is passed as a module name, different variants
     *       will be tested in this order:
     *          - Check for HTMLModule_$name
     *          - Check all prefixes with $name in order they were added
     *          - Check for literal object name
     *          - Throw fatal error
     *       If your object name collides with an internal class, specify
     *       your module manually. All modules must have been included
     *       externally: registerModule will not perform inclusions for you!
     */
    public function registerModule(module, overload = false)
    {
        var original_module, ok, prefix;
    
        if is_string(module) {
            // attempt to load the module
            let original_module = module;
            let ok =  false;
            for prefix in this->prefixes {
                let module =  prefix . original_module;
                if class_exists(module) {
                    let ok =  true;
                    break;
                }
            }
            if !(ok) {
                let module = original_module;
                if !(class_exists(module)) {
                    trigger_error(original_module . " module does not exist", E_USER_ERROR);
                    return;
                }
            }
            let module =  new {module}();
        }
        if empty(module->name) {
            trigger_error("Module instance of " . get_class(module) . " must have name");
            return;
        }
        if !(overload) && isset this->registeredModules[module->name] {
            trigger_error("Overloading " . module->name . " without explicit overload parameter", E_USER_WARNING);
        }
        let this->registeredModules[module->name] = module;
    }
    
    /**
     * Adds a module to the current doctype by first registering it,
     * and then tacking it on to the active doctype
     */
    public function addModule(module) -> void
    {
        this->registerModule(module);
        if is_object(module) {
            let module =  module->name;
        }
        let this->userModules[] = module;
    }
    
    /**
     * Adds a class prefix that registerModule() will use to resolve a
     * string name to a concrete class
     */
    public function addPrefix(prefix) -> void
    {
        let this->prefixes[] = prefix;
    }
    
    /**
     * Performs processing on modules, after being called you may
     * use getElement() and getElements()
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var modules, lookup, special_cases, k, m, tmpArray40cd750bba9870f18aada2478b24840a, module, n, injector, classs, name, def;
    
        let this->trusted =  config->get("HTML.Trusted");
        // generate
        let this->doctype =  this->doctypes->make(config);
        let modules =  this->doctype->modules;
        // take out the default modules that aren't allowed
        let lookup =  config->get("HTML.AllowedModules");
        let special_cases =  config->get("HTML.CoreModules");
        if is_array(lookup) {
            for k, m in modules {
                if isset special_cases[m] {
                    continue;
                }
                if !(isset lookup[m]) {
                    unset modules[k];
                
                }
            }
        }
        // custom modules
        if config->get("HTML.Proprietary") {
            let modules[] = "Proprietary";
        }
        if config->get("HTML.SafeObject") {
            let modules[] = "SafeObject";
        }
        if config->get("HTML.SafeEmbed") {
            let modules[] = "SafeEmbed";
        }
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        if config->get("HTML.SafeScripting") !== tmpArray40cd750bba9870f18aada2478b24840a {
            let modules[] = "SafeScripting";
        }
        if config->get("HTML.Nofollow") {
            let modules[] = "Nofollow";
        }
        if config->get("HTML.TargetBlank") {
            let modules[] = "TargetBlank";
        }
        // NB: HTML.TargetNoreferrer and HTML.TargetNoopener must be AFTER HTML.TargetBlank
        // so that its post-attr-transform gets run afterwards.
        if config->get("HTML.TargetNoreferrer") {
            let modules[] = "TargetNoreferrer";
        }
        if config->get("HTML.TargetNoopener") {
            let modules[] = "TargetNoopener";
        }
        // merge in custom modules
        let modules =  array_merge(modules, this->userModules);
        for module in modules {
            this->processModule(module);
            this->modules[module]->setup(config);
        }
        for module in this->doctype->tidyModules {
            this->processModule(module);
            this->modules[module]->setup(config);
        }
        // prepare any injectors
        for module in this->modules {
            let n =  [];
            for injector in module->info_injector {
                if !(is_object(injector)) {
                    let classs = "Injector_{injector}";
                    let injector =  new {classs}();
                }
                let n[injector->name] = injector;
            }
            let module->info_injector = n;
        }
        // setup lookup table based on all valid modules
        for module in this->modules {
            for name, def in module->info {
                if !(isset this->elementLookup[name]) {
                    let this->elementLookup[name] =  [];
                }
                let this->elementLookup[name][] = module->name;
            }
        }
        // note the different choice
        let this->contentSets =  new ContentSets(this->modules);
        let this->attrCollections =  new AttrCollections(this->attrTypes, this->modules);
    }
    
    /**
     * Takes a module and adds it to the active module collection,
     * registering it if necessary.
     */
    public function processModule(module) -> void
    {
        if !(isset this->registeredModules[module]) || is_object(module) {
            this->registerModule(module);
        }
        let this->modules[module] = this->registeredModules[module];
    }
    
    /**
     * Retrieves merged element definitions.
     * @return Array of ElementDef
     */
    public function getElements() -> array
    {
        var elements, module, name, v, n;
    
        let elements =  [];
        for module in this->modules {
            if !(this->trusted) && !(module->safe) {
                continue;
            }
            for name, v in module->info {
                if isset elements[name] {
                    continue;
                }
                let elements[name] =  this->getElement(name);
            }
        }
        // remove dud elements, this happens when an element that
        // appeared to be safe actually wasn't
        for n, v in elements {
            if v === false {
                unset elements[n];
            
            }
        }
        return elements;
    }
    
    /**
     * Retrieves a single merged element definition
     * @param string $name Name of element
     * @param bool $trusted Boolean trusted overriding parameter: set to true
     *                 if you want the full version of an element
     * @return ElementDef Merged ElementDef
     * @note You may notice that modules are getting iterated over twice (once
     *       in getElements() and once here). This
     *       is because
     */
    public function getElement(string name, bool trusted = null) -> <ElementDef>
    {
        var def, module_name, module, new_def, attr_name, attr_def;
    
        if !(isset this->elementLookup[name]) {
            return false;
        }
        // setup global state variables
        let def =  false;
        if trusted === null {
            let trusted =  this->trusted;
        }
        // iterate through each module that has registered itself to this
        // element
        for module_name in this->elementLookup[name] {
            let module = this->modules[module_name];
            // refuse to create/merge from a module that is deemed unsafe--
            // pretend the module doesn't exist--when trusted mode is not on.
            if !(trusted) && !(module->safe) {
                continue;
            }
            // clone is used because, ideally speaking, the original
            // definition should not be modified. Usually, this will
            // make no difference, but for consistency's sake
            let new_def =  clone module->info[name];
            if !(def) && new_def->standalone {
                let def = new_def;
            } elseif def {
                // This will occur even if $new_def is standalone. In practice,
                // this will usually result in a full replacement.
                def->mergeIn(new_def);
            } else {
                // :TODO:
                // non-standalone definitions that don't have a standalone
                // to merge into could be deferred to the end
                // HOWEVER, it is perfectly valid for a non-standalone
                // definition to lack a standalone definition, even
                // after all processing: this allows us to safely
                // specify extra attributes for elements that may not be
                // enabled all in one place.  In particular, this might
                // be the case for trusted elements.  WARNING: care must
                // be taken that the /extra/ definitions are all safe.
                continue;
            }
            // attribute value expansions
            this->attrCollections->performInclusions(def->attr);
            this->attrCollections->expandIdentifiers(def->attr, this->attrTypes);
            // descendants_are_inline, for ChildDef_Chameleon
            if is_string(def->content_model) && strpos(def->content_model, "Inline") !== false {
                if name != "del" && name != "ins" {
                    // this is for you, ins/del
                    let def->descendants_are_inline =  true;
                }
            }
            this->contentSets->generateChildDef(def, module);
        }
        // This can occur if there is a blank definition, but no base to
        // mix it in with
        if !(def) {
            return false;
        }
        // add information on required attributes
        for attr_name, attr_def in def->attr {
            if attr_def->required {
                let def->required_attr[] = attr_name;
            }
        }
        return def;
    }

}