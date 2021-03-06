namespace HTMLPurifier;

/**
 * Defines allowed child nodes and validates nodes against it.
 */
abstract class ChildDef
{
    /**
     * Type of child definition, usually right-most part of class name lowercase.
     * Used occasionally in terms of context.
     * @type string
     */
    public type;
    /**
     * Indicates whether or not an empty array of children is okay.
     *
     * This is necessary for redundant checking when changes affecting
     * a child node may cause a parent node to now be disallowed.
     * @type bool
     */
    public allow_empty;
    /**
     * Lookup array of all elements that this definition could possibly allow.
     * @type array
     */
    public elements = [];
    /**
     * Get lookup of tag names that should not close this element automatically.
     * All other elements will do so.
     * @param Config $config Config object
     * @return array
     */
    public function getAllowedElements(<Config> config) -> array
    {
        return this->elements;
    }
    
    /**
     * Validates nodes according to definition and returns modification.
     *
     * @param Node[] $children Array of Node
     * @param Config $config Config object
     * @param Context $context Context object
     * @return bool|array true to leave nodes as is, false to remove parent node, array of replacement children
     */
    public abstract function validateChildren(array children, <Config> config, <Context> context);

}