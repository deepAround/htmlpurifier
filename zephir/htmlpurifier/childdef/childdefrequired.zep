namespace HTMLPurifier\ChildDef;

use HTMLPurifier\Node\NodeElement;
use HTMLPurifier\Node\NodeText;
/**
 * Definition that allows a set of elements, but disallows empty children.
 */
class ChildDefRequired extends \HTMLPurifier\ChildDef
{
    /**
     * Lookup table of allowed elements.
     * @type array
     */
    public elements = [];
    /**
     * Whether or not the last passed node was all whitespace.
     * @type bool
     */
    protected whitespace = false;
    /**
     * @param array|string $elements List of allowed element names (lowercase).
     */
    public function __construct(elements) -> void
    {
        var keys, i, x;
    
        if is_string(elements) {
            let elements =  str_replace(" ", "", elements);
            let elements =  explode("|", elements);
        }
        let keys =  array_keys(elements);
        if keys == array_keys(keys) {
            let elements =  array_flip(elements);
            for i, x in elements {
                let elements[i] = true;
                if empty(i) {
                    unset elements[i];
                
                }
            }
        }
        let this->elements = elements;
    }
    
    /**
     * @type bool
     */
    public allow_empty = false;
    /**
     * @type string
     */
    public type = "required";
    /**
     * @param array $children
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> array
    {
        var result, pcdata_allowed, all_whitespace, stack, node, i;
    
        // Flag for subclasses
        let this->whitespace =  false;
        // if there are no tokens, delete parent node
        if empty(children) {
            return false;
        }
        // the new set of children
        let result =  [];
        // whether or not parsed character data is allowed
        // this controls whether or not we silently drop a tag
        // or generate escaped HTML from it
        let pcdata_allowed =  isset this->elements["#PCDATA"];
        // a little sanity check to make sure it's not ALL whitespace
        let all_whitespace =  true;
        let stack =  array_reverse(children);
        while (!(empty(stack))) {
            let node =  array_pop(stack);
            if !(empty(node->is_whitespace)) {
                let result[] = node;
                continue;
            }
            let all_whitespace =  false;
            // phew, we're not talking about whitespace
            if !(isset this->elements[node->name]) {
                // special case text
                // XXX One of these ought to be redundant or something
                if pcdata_allowed && node instanceof NodeText {
                    let result[] = node;
                    continue;
                }
                // spill the child contents in
                // ToDo: Make configurable
                if node instanceof NodeElement {
                    let i =  count(node->children) - 1;
                    for i in range(count(node->children) - 1, 0) {
                        let stack[] = node->children[i];
                    }
                    continue;
                }
                continue;
            }
            let result[] = node;
        }
        if empty(result) {
            return false;
        }
        if all_whitespace {
            let this->whitespace =  true;
            return false;
        }
        return result;
    }

}