namespace HTMLPurifier;

/**
 * Structure that stores an HTML element definition. Used by
 * HTMLDefinition and HTMLModule.
 * @note This class is inspected by Printer_HTMLDefinition.
 *       Please update that class too.
 * @warning If you add new properties to this class, you MUST update
 *          the mergeIn() method.
 */
class ElementDef
{
    /**
     * Does the definition work by itself, or is it created solely
     * for the purpose of merging into another definition?
     * @type bool
     */
    public standalone = true;
    /**
     * Associative array of attribute name to AttrDef.
     * @type array
     * @note Before being processed by AttrCollections
     *       when modules are finalized during
     *       HTMLDefinition->setup(), this array may also
     *       contain an array at index 0 that indicates which attribute
     *       collections to load into the full array. It may also
     *       contain string indentifiers in lieu of AttrDef,
     *       see AttrTypes on how they are expanded during
     *       HTMLDefinition->setup() processing.
     */
    public attr = [];
    // XXX: Design note: currently, it's not possible to override
    // previously defined AttrTransforms without messing around with
    // the final generated config. This is by design; a previous version
    // used an associated list of attr_transform, but it was extremely
    // easy to accidentally override other attribute transforms by
    // forgetting to specify an index (and just using 0.)  While we
    // could check this by checking the index number and complaining,
    // there is a second problem which is that it is not at all easy to
    // tell when something is getting overridden. Combine this with a
    // codebase where this isn't really being used, and it's perfect for
    // nuking.
    /**
     * List of tags AttrTransform to be done before validation.
     * @type array
     */
    public attr_transform_pre = [];
    /**
     * List of tags AttrTransform to be done after validation.
     * @type array
     */
    public attr_transform_post = [];
    /**
     * ChildDef of this tag.
     * @type ChildDef
     */
    public child;
    /**
     * Abstract string representation of internal ChildDef rules.
     * @see ContentSets for how this is parsed and then transformed
     * into an ChildDef.
     * @warning This is a temporary variable that is not available after
     *      being processed by HTMLDefinition
     * @type string
     */
    public content_model;
    /**
     * Value of $child->type, used to determine which ChildDef to use,
     * used in combination with $content_model.
     * @warning This must be lowercase
     * @warning This is a temporary variable that is not available after
     *      being processed by HTMLDefinition
     * @type string
     */
    public content_model_type;
    /**
     * Does the element have a content model (#PCDATA | Inline)*? This
     * is important for chameleon ins and del processing in
     * ChildDef_Chameleon. Dynamically set: modules don't
     * have to worry about this one.
     * @type bool
     */
    public descendants_are_inline = false;
    /**
     * List of the names of required attributes this element has.
     * Dynamically populated by HTMLDefinition::getElement()
     * @type array
     */
    public required_attr = [];
    /**
     * Lookup table of tags excluded from all descendants of this tag.
     * @type array
     * @note SGML permits exclusions for all descendants, but this is
     *       not possible with DTDs or XML Schemas. W3C has elected to
     *       use complicated compositions of content_models to simulate
     *       exclusion for children, but we go the simpler, SGML-style
     *       route of flat-out exclusions, which correctly apply to
     *       all descendants and not just children. Note that the XHTML
     *       Modularization Abstract Modules are blithely unaware of such
     *       distinctions.
     */
    public excludes = [];
    /**
     * This tag is explicitly auto-closed by the following tags.
     * @type array
     */
    public autoclose = [];
    /**
     * If a foreign element is found in this element, test if it is
     * allowed by this sub-element; if it is, instead of closing the
     * current element, place it inside this element.
     * @type string
     */
    public wrap;
    /**
     * Whether or not this is a formatting element affected by the
     * "Active Formatting Elements" algorithm.
     * @type bool
     */
    public formatting;
    /**
     * Low-level factory constructor for creating new standalone element defs
     */
    public static function create(content_model, content_model_type, attr)
    {
        var def;
    
        let def =  new ElementDef();
        let def->content_model = content_model;
        let def->content_model_type = content_model_type;
        let def->attr = attr;
        return def;
    }
    
    /**
     * Merges the values of another element definition into this one.
     * Values from the new element def take precedence if a value is
     * not mergeable.
     * @param ElementDef $def
     */
    public function mergeIn(<ElementDef> def) -> void
    {
        var k, v, v2;
    
        // later keys takes precedence
        for k, v in def->attr {
            if k === 0 {
                // merge in the includes
                // sorry, no way to override an include
                for v2 in v {
                    let this->attr[0][] = v2;
                }
                continue;
            }
            if v === false {
                if isset this->attr[k] {
                    unset this->attr[k];
                
                }
                continue;
            }
            let this->attr[k] = v;
        }
        this->_mergeAssocArray(this->excludes, def->excludes);
        let this->attr_transform_pre =  array_merge(this->attr_transform_pre, def->attr_transform_pre);
        let this->attr_transform_post =  array_merge(this->attr_transform_post, def->attr_transform_post);
        if !(empty(def->content_model)) {
            let this->content_model =  str_replace("#SUPER", this->content_model, def->content_model);
            let this->child =  false;
        }
        if !(empty(def->content_model_type)) {
            let this->content_model_type =  def->content_model_type;
            let this->child =  false;
        }
        if !(is_null(def->child)) {
            let this->child =  def->child;
        }
        if !(is_null(def->formatting)) {
            let this->formatting =  def->formatting;
        }
        if def->descendants_are_inline {
            let this->descendants_are_inline =  def->descendants_are_inline;
        }
    }
    
    /**
     * Merges one array into another, removes values which equal false
     * @param $a1 Array by reference that is merged into
     * @param $a2 Array that merges into $a1
     */
    protected function _mergeAssocArray(a1, a2) -> void
    {
        var k, v;
    
        for k, v in a2 {
            if v === false {
                if isset a1[k] {
                    unset a1[k];
                
                }
                continue;
            }
            let a1[k] = v;
        }
    }

}