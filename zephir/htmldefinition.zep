namespace HTMLPurifier;

/**
 * Definition of the purified HTML that describes allowed children,
 * attributes, and many other things.
 *
 * Conventions:
 *
 * All member variables that are prefixed with info
 * (including the main $info array) are used by HTML Purifier internals
 * and should not be directly edited when customizing the HTMLDefinition.
 * They can usually be set via configuration directives or custom
 * modules.
 *
 * On the other hand, member variables without the info prefix are used
 * internally by the HTMLDefinition and MUST NOT be used by other HTML
 * Purifier internals. Many of them, however, are public, and may be
 * edited by userspace code to tweak the behavior of HTMLDefinition.
 *
 * @note This class is inspected by Printer_HTMLDefinition; please
 *       update that class if things here change.
 *
 * @warning Directives that change this object's structure must be in
 *          the HTML or Attr namespace!
 */
class HTMLDefinition extends Definition
{
    // FULLY-PUBLIC VARIABLES ---------------------------------------------
    /**
     * Associative array of element names to ElementDef.
     * @type ElementDef[]
     */
    public info = [];
    /**
     * Associative array of global attribute name to attribute definition.
     * @type array
     */
    public info_global_attr = [];
    /**
     * String name of parent element HTML will be going into.
     * @type string
     */
    public info_parent = "div";
    /**
     * Definition for parent element, allows parent element to be a
     * tag that's not allowed inside the HTML fragment.
     * @type ElementDef
     */
    public info_parent_def;
    /**
     * String name of element used to wrap inline elements in block context.
     * @type string
     * @note This is rarely used except for BLOCKQUOTEs in strict mode
     */
    public info_block_wrapper = "p";
    /**
     * Associative array of deprecated tag name to TagTransform.
     * @type array
     */
    public info_tag_transform = [];
    /**
     * Indexed list of AttrTransform to be performed before validation.
     * @type AttrTransform[]
     */
    public info_attr_transform_pre = [];
    /**
     * Indexed list of AttrTransform to be performed after validation.
     * @type AttrTransform[]
     */
    public info_attr_transform_post = [];
    /**
     * Nested lookup array of content set name (Block, Inline) to
     * element name to whether or not it belongs in that content set.
     * @type array
     */
    public info_content_sets = [];
    /**
     * Indexed list of Injector to be used.
     * @type Injector[]
     */
    public info_injector = [];
    /**
     * Doctype object
     * @type Doctype
     */
    public doctype;
    // RAW CUSTOMIZATION STUFF --------------------------------------------
    /**
     * Adds a custom attribute to a pre-existing element
     * @note This is strictly convenience, and does not have a corresponding
     *       method in HTMLModule
     * @param string $element_name Element name to add attribute to
     * @param string $attr_name Name of attribute
     * @param mixed $def Attribute definition, can be string or object, see
     *             AttrTypes for details
     */
    public function addAttribute(element_name, attr_name, def) -> void
    {
        var module, element;
    
        let module =  this->getAnonymousModule();
        if !(isset module->info[element_name]) {
            let element =  module->addBlankElement(element_name);
        } else {
            let element = module->info[element_name];
        }
        let element->attr[attr_name] = def;
    }
    
    /**
     * Adds a custom element to your HTML definition
     * @see HTMLModule::addElement() for detailed
     *       parameter and return value descriptions.
     */
    public function addElement(element_name, type, contents, attr_collections, attributes = [])
    {
        var module, element;
    
        let module =  this->getAnonymousModule();
        // assume that if the user is calling this, the element
        // is safe. This may not be a good idea
        let element =  module->addElement(element_name, type, contents, attr_collections, attributes);
        return element;
    }
    
    /**
     * Adds a blank element to your HTML definition, for overriding
     * existing behavior
     * @param string $element_name
     * @return ElementDef
     * @see HTMLModule::addBlankElement() for detailed
     *       parameter and return value descriptions.
     */
    public function addBlankElement(string element_name) -> <ElementDef>
    {
        var module, element;
    
        let module =  this->getAnonymousModule();
        let element =  module->addBlankElement(element_name);
        return element;
    }
    
    /**
     * Retrieves a reference to the anonymous module, so you can
     * bust out advanced features without having to make your own
     * module.
     * @return HTMLModule
     */
    public function getAnonymousModule() -> <HTMLModule>
    {
        if !(this->_anonModule) {
            let this->_anonModule =  new HTMLModule();
            let this->_anonModule->name = "Anonymous";
        }
        return this->_anonModule;
    }
    
    protected _anonModule = null;
    // PUBLIC BUT INTERNAL VARIABLES --------------------------------------
    /**
     * @type string
     */
    public type = "HTML";
    /**
     * @type HTMLModuleManager
     */
    public manager;
    /**
     * Performs low-cost, preliminary initialization.
     */
    public function __construct() -> void
    {
        let this->manager =  new HTMLModuleManager();
    }
    
    /**
     * @param Config $config
     */
    protected function doSetup(<Config> config) -> void
    {
        var k, v;
    
        this->processModules(config);
        this->setupConfigStuff(config);
        unset this->manager;
        
        // cleanup some of the element definitions
        for k, v in this->info {
            unset this->info[k]->content_model;
            
            unset this->info[k]->content_model_type;
        
        }
    }
    
    /**
     * Extract out the information from the manager
     * @param Config $config
     */
    protected function processModules(<Config> config) -> void
    {
        var module, k, v;
    
        if this->_anonModule {
            // for user specific changes
            // this is late-loaded so we don't have to deal with PHP4
            // reference wonky-ness
            this->manager->addModule(this->_anonModule);
            unset this->_anonModule;
        
        }
        this->manager->setup(config);
        let this->doctype =  this->manager->doctype;
        for module in this->manager->modules {
            for k, v in module->info_tag_transform {
                if v === false {
                    unset this->info_tag_transform[k];
                
                } else {
                    let this->info_tag_transform[k] = v;
                }
            }
            for k, v in module->info_attr_transform_pre {
                if v === false {
                    unset this->info_attr_transform_pre[k];
                
                } else {
                    let this->info_attr_transform_pre[k] = v;
                }
            }
            for k, v in module->info_attr_transform_post {
                if v === false {
                    unset this->info_attr_transform_post[k];
                
                } else {
                    let this->info_attr_transform_post[k] = v;
                }
            }
            for k, v in module->info_injector {
                if v === false {
                    unset this->info_injector[k];
                
                } else {
                    let this->info_injector[k] = v;
                }
            }
        }
        let this->info =  this->manager->getElements();
        let this->info_content_sets =  this->manager->contentSets->lookup;
    }
    
    /**
     * Sets up stuff based on config. We need a better way of doing this.
     * @param Config $config
     */
    protected function setupConfigStuff(<Config> config) -> void
    {
        var block_wrapper, parent, def, support, allowed_elements, allowed_attributes, allowed, tmpListAllowed_elementsAllowed_attributes, name, d, element, allowed_attributes_mutable, attr, x, keys, delete, key, tag, info, elattr, bits, c, attribute, forbidden_elements, forbidden_attributes, v, i, injector;
    
        let block_wrapper =  config->get("HTML.BlockWrapper");
        if isset this->info_content_sets["Block"][block_wrapper] {
            let this->info_block_wrapper = block_wrapper;
        } else {
            trigger_error("Cannot use non-block element as block wrapper", E_USER_ERROR);
        }
        let parent =  config->get("HTML.Parent");
        let def =  this->manager->getElement(parent, true);
        if def {
            let this->info_parent = parent;
            let this->info_parent_def = def;
        } else {
            trigger_error("Cannot use unrecognized element as parent", E_USER_ERROR);
            let this->info_parent_def =  this->manager->getElement(this->info_parent, true);
        }
        // support template text
        let support = "(for information on implementing this, see the support forums) ";
        // setup allowed elements -----------------------------------------
        let allowed_elements =  config->get("HTML.AllowedElements");
        let allowed_attributes =  config->get("HTML.AllowedAttributes");
        // retrieve early
        if !(is_array(allowed_elements)) && !(is_array(allowed_attributes)) {
            let allowed =  config->get("HTML.Allowed");
            if is_string(allowed) {
                let tmpListAllowed_elementsAllowed_attributes = this->parseTinyMCEAllowedList(allowed);
                let allowed_elements = tmpListAllowed_elementsAllowed_attributes[0];
                let allowed_attributes = tmpListAllowed_elementsAllowed_attributes[1];
            }
        }
        if is_array(allowed_elements) {
            for name, d in this->info {
                if !(isset allowed_elements[name]) {
                    unset this->info[name];
                
                }
                unset allowed_elements[name];
            
            }
            // emit errors
            for element, d in allowed_elements {
                let element =  htmlspecialchars(element);
                // PHP doesn't escape errors, be careful!
                trigger_error("Element '{element}' is not supported {support}", E_USER_WARNING);
            }
        }
        // setup allowed attributes ---------------------------------------
        let allowed_attributes_mutable = allowed_attributes;
        // by copy!
        if is_array(allowed_attributes) {
            // This actually doesn't do anything, since we went away from
            // global attributes. It's possible that userland code uses
            // it, but HTMLModuleManager doesn't!
            for attr, x in this->info_global_attr {
                let keys =  [attr, "*@{attr}", "*.{attr}"];
                let delete =  true;
                for key in keys {
                    if delete && isset allowed_attributes[key] {
                        let delete =  false;
                    }
                    if isset allowed_attributes_mutable[key] {
                        unset allowed_attributes_mutable[key];
                    
                    }
                }
                if delete {
                    unset this->info_global_attr[attr];
                
                }
            }
            for tag, info in this->info {
                for attr, x in info->attr {
                    let keys =  ["{tag}@{attr}", attr, "*@{attr}", "{tag}.{attr}", "*.{attr}"];
                    let delete =  true;
                    for key in keys {
                        if delete && isset allowed_attributes[key] {
                            let delete =  false;
                        }
                        if isset allowed_attributes_mutable[key] {
                            unset allowed_attributes_mutable[key];
                        
                        }
                    }
                    if delete {
                        if this->info[tag]->attr[attr]->required {
                            trigger_error("Required attribute '{attr}' in element '{tag}' " . "was not allowed, which means '{tag}' will not be allowed either", E_USER_WARNING);
                        }
                        unset this->info[tag]->attr[attr];
                    
                    }
                }
            }
            // emit errors
            for elattr, d in allowed_attributes_mutable {
                let bits =  preg_split("/[.@]/", elattr, 2);
                let c =  count(bits);
                if 2 {
                    if bits[0] !== "*" {
                        let element =  htmlspecialchars(bits[0]);
                        let attribute =  htmlspecialchars(bits[1]);
                        if !(isset this->info[element]) {
                            trigger_error("Cannot allow attribute '{attribute}' if element " . "'{element}' is not allowed/supported {support}");
                        } else {
                            trigger_error("Attribute '{attribute}' in element '{element}' not supported {support}", E_USER_WARNING);
                        }
                        break;
                    }
                } else {
                    let attribute =  htmlspecialchars(bits[0]);
                    trigger_error("Global attribute '{attribute}' is not " . "supported in any elements {support}", E_USER_WARNING);
                }
            }
        }
        // setup forbidden elements ---------------------------------------
        let forbidden_elements =  config->get("HTML.ForbiddenElements");
        let forbidden_attributes =  config->get("HTML.ForbiddenAttributes");
        for tag, info in this->info {
            if isset forbidden_elements[tag] {
                unset this->info[tag];
                
                continue;
            }
            for attr, x in info->attr {
                if isset forbidden_attributes["{tag}@{attr}"] || isset forbidden_attributes["*@{attr}"] || isset forbidden_attributes[attr] {
                    unset this->info[tag]->attr[attr];
                    
                    continue;
                } elseif isset forbidden_attributes["{tag}.{attr}"] {
                    // this segment might get removed eventually
                    // $tag.$attr are not user supplied, so no worries!
                    trigger_error("Error with {tag}.{attr}: tag.attr syntax not supported for " . "HTML.ForbiddenAttributes; use tag@attr instead", E_USER_WARNING);
                }
            }
        }
        for key, v in forbidden_attributes {
            if strlen(key) < 2 {
                continue;
            }
            if key[0] != "*" {
                continue;
            }
            if key[1] == "." {
                trigger_error("Error with {key}: *.attr syntax not supported for HTML.ForbiddenAttributes; use attr instead", E_USER_WARNING);
            }
        }
        // setup injectors -----------------------------------------------------
        for i, injector in this->info_injector {
            if injector->checkNeeded(config) !== false {
                // remove injector that does not have it's required
                // elements/attributes present, and is thus not needed.
                unset this->info_injector[i];
            
            }
        }
    }
    
    /**
     * Parses a TinyMCE-flavored Allowed Elements and Attributes list into
     * separate lists for processing. Format is element[attr1|attr2],element2...
     * @warning Although it's largely drawn from TinyMCE's implementation,
     *      it is different, and you'll probably have to modify your lists
     * @param array $list String list to parse
     * @return array
     * @todo Give this its own class, probably static interface
     */
    public function parseTinyMCEAllowedList(array list) -> array
    {
        var tmpArray42fdc03ca88e4deccee19891073b5327, elements, attributes, chunks, chunk, element, attr, tmpListElementAttr, key, tmpArrayad4885dcf8863e9ed0ab76955108def6;
    
        let tmpArray42fdc03ca88e4deccee19891073b5327 = [" ", "	"];
        let list =  str_replace(tmpArray42fdc03ca88e4deccee19891073b5327, "", list);
        let elements =  [];
        let attributes =  [];
        let chunks =  preg_split("/(,|[\\n\\r]+)/", list);
        for chunk in chunks {
            if empty(chunk) {
                continue;
            }
            // remove TinyMCE element control characters
            if !(strpos(chunk, "[")) {
                let element = chunk;
                let attr =  false;
            } else {
                let tmpListElementAttr = explode("[", chunk);
                let element = tmpListElementAttr[0];
                let attr = tmpListElementAttr[1];
            }
            if element !== "*" {
                let elements[element] = true;
            }
            if !(attr) {
                continue;
            }
            let attr =  substr(attr, 0, strlen(attr) - 1);
            // remove trailing ]
            let attr =  explode("|", attr);
            for key in attr {
                let attributes["{element}.{key}"] = true;
            }
        }
        let tmpArrayad4885dcf8863e9ed0ab76955108def6 = [elements, attributes];
        return tmpArrayad4885dcf8863e9ed0ab76955108def6;
    }

}