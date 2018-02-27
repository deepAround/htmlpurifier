namespace HTMLPurifier;

use HTMLPurifier\ChildDef\ChildDefCustom;
use HTMLPurifier\ChildDef\ChildDefEmpty;
use HTMLPurifier\ChildDef\ChildDefOptional;
use HTMLPurifier\ChildDef\ChildDefRequired;
/**
 * @todo Unit test
 */
class ContentSets
{
    /**
     * List of content set strings (pipe separators) indexed by name.
     * @type array
     */
    public info = [];
    /**
     * List of content set lookups (element => true) indexed by name.
     * @type array
     * @note This is in HTMLDefinition->info_content_sets
     */
    public lookup = [];
    /**
     * Synchronized list of defined content sets (keys of info).
     * @type array
     */
    protected keys = [];
    /**
     * Synchronized list of defined content values (values of info).
     * @type array
     */
    protected values = [];
    /**
     * Merges in module's content sets, expands identifiers in the content
     * sets and populates the keys, values and lookup member variables.
     * @param HTMLModule[] $modules List of HTMLModule
     */
    public function __construct(array modules) -> void
    {
        var module, key, value, temp, old_lookup, i, set, add, element, x, lookup;
    
        if !(is_array(modules)) {
            let modules =  [modules];
        }
        // populate content_sets based on module hints
        // sorry, no way of overloading
        for module in modules {
            for key, value in module->content_sets {
                let temp =  this->convertToLookup(value);
                if isset this->lookup[key] {
                    // add it into the existing content set
                    let this->lookup[key] =  array_merge(this->lookup[key], temp);
                } else {
                    let this->lookup[key] = temp;
                }
            }
        }
        let old_lookup =  false;
        while (old_lookup !== this->lookup) {
            let old_lookup =  this->lookup;
            for i, set in this->lookup {
                let add =  [];
                for element, x in set {
                    if isset this->lookup[element] {
                        let add += this->lookup[element];
                        unset this->lookup[i][element];
                    
                    }
                }
                let this->lookup[i] += add;
            }
        }
        for key, lookup in this->lookup {
            let this->info[key] =  implode(" | ", array_keys(lookup));
        }
        let this->keys =  array_keys(this->info);
        let this->values =  array_values(this->info);
    }
    
    /**
     * Accepts a definition; generates and assigns a ChildDef for it
     * @param ElementDef $def ElementDef reference
     * @param HTMLModule $module Module that defined the ElementDef
     */
    public function generateChildDef(<ElementDef> def, <HTMLModule> module)
    {
        var content_model, tmpArrayef028ab6dc8b378eaf4679502ea4f214;
    
        if !(empty(def->child)) {
            // already done!
            return;
        }
        let content_model =  def->content_model;
        if is_string(content_model) {
            // Assume that $this->keys is alphanumeric
            let tmpArrayef028ab6dc8b378eaf4679502ea4f214 = [this, "generateChildDefCallback"];
            let def->content_model =  preg_replace_callback("/\\b(" . implode("|", this->keys) . ")\\b/", tmpArrayef028ab6dc8b378eaf4679502ea4f214, content_model);
        }
        let def->child =  this->getChildDef(def, module);
    }
    
    public function generateChildDefCallback(matches)
    {
        return this->info[matches[0]];
    }
    
    /**
     * Instantiates a ChildDef based on content_model and content_model_type
     * member variables in ElementDef
     * @note This will also defer to modules for custom ChildDef
     *       subclasses that need content set expansion
     * @param ElementDef $def ElementDef to have ChildDef extracted
     * @param HTMLModule $module Module that defined the ElementDef
     * @return ChildDef corresponding to ElementDef
     */
    public function getChildDef(<ElementDef> def, <HTMLModule> module) -> <ChildDef>
    {
        var value, returnn;
    
        let value =  def->content_model;
        if is_object(value) {
            trigger_error("Literal object child definitions should be stored in " . "ElementDef->child not ElementDef->content_model", E_USER_NOTICE);
            return value;
        }
        switch (def->content_model_type) {
            case "required":
                return new ChildDefRequired(value);
            case "optional":
                return new ChildDefOptional(value);
            case "empty":
                return new ChildDefEmpty();
            case "custom":
                return new ChildDefCustom(value);
        }
        // defer to its module
        let returnn =  false;
        if module->defines_child_def {
            // save a func call
            let returnn =  module->getChildDef(def);
        }
        if returnn !== false {
            return returnn;
        }
        // error-out
        trigger_error("Could not determine which ChildDef class to instantiate", E_USER_ERROR);
        return false;
    }
    
    /**
     * Converts a string list of elements separated by pipes into
     * a lookup array.
     * @param string $string List of elements
     * @return array Lookup array of elements
     */
    protected function convertToLookup(string stringg) -> array
    {
        var myArray, ret, k;
    
        let myArray =  explode("|", str_replace(" ", "", stringg));
        let ret =  [];
        for k in myArray {
            let ret[k] = true;
        }
        return ret;
    }

}