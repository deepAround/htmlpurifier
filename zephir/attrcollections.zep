namespace HTMLPurifier;

/**
 * Defines common attribute collections that modules reference
 */
class AttrCollections
{
    /**
     * Associative array of attribute collections, indexed by name.
     * @type array
     */
    public info = [];
    /**
     * Performs all expansions on internal data for use by other inclusions
     * It also collects all attribute collection extensions from
     * modules
     * @param AttrTypes $attr_types AttrTypes instance
     * @param HTMLModule[] $modules Hash array of HTMLModule members
     */
    public function __construct(<AttrTypes> attr_types, array modules) -> void
    {
        this->doConstruct(attr_types, modules);
    }
    
    public function doConstruct(attr_types, modules) -> void
    {
        var module, coll_i, coll, attr_i, attr, name;
    
        // load extensions from the modules
        for module in modules {
            for coll_i, coll in module->attr_collections {
                if !(isset this->info[coll_i]) {
                    let this->info[coll_i] =  [];
                }
                for attr_i, attr in coll {
                    if attr_i === 0 && isset this->info[coll_i][attr_i] {
                        // merge in includes
                        let this->info[coll_i][attr_i] =  array_merge(this->info[coll_i][attr_i], attr);
                        continue;
                    }
                    let this->info[coll_i][attr_i] = attr;
                }
            }
        }
        // perform internal expansions and inclusions
        for name, attr in this->info {
            // merge attribute collections that include others
            this->performInclusions(this->info[name]);
            // replace string identifiers with actual attribute objects
            this->expandIdentifiers(this->info[name], attr_types);
        }
    }
    
    /**
     * Takes a reference to an attribute associative array and performs
     * all inclusions specified by the zero index.
     * @param array &$attr Reference to attribute array
     */
    public function performInclusions(attr)
    {
        var merge, seen, i, key, value;
    
        if !(isset attr[0]) {
            return;
        }
        let merge = attr[0];
        let seen =  [];
        // recursion guard
        // loop through all the inclusions
        
            let i = 0;
        loop {
        if isset merge[i] {
            break;
        }
        
            if isset seen[merge[i]] {
                continue;
            }
            let seen[merge[i]] = true;
            // foreach attribute of the inclusion, copy it over
            if !(isset this->info[merge[i]]) {
                continue;
            }
            for key, value in this->info[merge[i]] {
                if isset attr[key] {
                    continue;
                }
                // also catches more inclusions
                let attr[key] = value;
            }
            if isset this->info[merge[i]][0] {
                // recursion
                let merge =  array_merge(merge, this->info[merge[i]][0]);
            }
        
            let i++;
        }
        unset attr[0];
    
    }
    
    /**
     * Expands all string identifiers in an attribute array by replacing
     * them with the appropriate values inside AttrTypes
     * @param array &$attr Reference to attribute array
     * @param AttrTypes $attr_types AttrTypes instance
     */
    public function expandIdentifiers(attr, <AttrTypes> attr_types) -> void
    {
        var processed, def_i, def, required, t;
    
        // because foreach will process new elements we add, make sure we
        // skip duplicates
        let processed =  [];
        for def_i, def in attr {
            // skip inclusions
            if def_i === 0 {
                continue;
            }
            if isset processed[def_i] {
                continue;
            }
            // determine whether or not attribute is required
            let required =  strpos(def_i, "*");
            if required {
                // rename the definition
                unset attr[def_i];
                
                let def_i =  trim(def_i, "*");
                let attr[def_i] = def;
            }
            let processed[def_i] = true;
            // if we've already got a literal object, move on
            if is_object(def) {
                // preserve previous required
                let attr[def_i]->required =  required || attr[def_i]->required;
                continue;
            }
            if def === false {
                unset attr[def_i];
                
                continue;
            }
            let t =  attr_types->get(def);
            if t {
                let attr[def_i] = t;
                let attr[def_i]->required = required;
            } else {
                unset attr[def_i];
            
            }
        }
    }

}