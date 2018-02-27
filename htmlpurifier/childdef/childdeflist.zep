namespace HTMLPurifier\ChildDef;

use HTMLPurifier\Node\NodeElement;
/**
 * Definition for list containers ul and ol.
 *
 * What does this do?  The big thing is to handle ol/ul at the top
 * level of list nodes, which should be handled specially by /folding/
 * them into the previous list node.  We generally shouldn't ever
 * see other disallowed elements, because the autoclose behavior
 * in MakeWellFormed handles it.
 */
class ChildDefList extends \HTMLPurifier\ChildDef
{
    /**
     * @type string
     */
    public type = "list";
    /**
     * @type array
     */
    // lying a little bit, so that we can handle ul and ol ourselves
    // XXX: This whole business with 'wrap' is all a bit unsatisfactory
    public elements = ["li" : true, "ul" : true, "ol" : true];
    /**
     * @param array $children
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> array
    {
        var result, all_whitespace, current_li, node;
    
        // Flag for subclasses
        let this->whitespace =  false;
        // if there are no tokens, delete parent node
        if empty(children) {
            return false;
        }
        // if li is not allowed, delete parent node
        if !(isset config->getHTMLDefinition()->info["li"]) {
            trigger_error("Cannot allow ul/ol without allowing li", E_USER_WARNING);
            return false;
        }
        // the new set of children
        let result =  [];
        // a little sanity check to make sure it's not ALL whitespace
        let all_whitespace =  true;
        let current_li =  null;
        for node in children {
            if !(empty(node->is_whitespace)) {
                let result[] = node;
                continue;
            }
            let all_whitespace =  false;
            // phew, we're not talking about whitespace
            if node->name === "li" {
                // good
                let current_li = node;
                let result[] = node;
            } else {
                // we want to tuck this into the previous li
                // Invariant: we expect the node to be ol/ul
                // ToDo: Make this more robust in the case of not ol/ul
                // by distinguishing between existing li and li created
                // to handle non-list elements; non-list elements should
                // not be appended to an existing li; only li created
                // for non-list. This distinction is not currently made.
                if current_li === null {
                    let current_li =  new NodeElement("li");
                    let result[] = current_li;
                }
                let current_li->children[] = node;
                let current_li->empty =  false;
            }
        }
        if empty(result) {
            return false;
        }
        if all_whitespace {
            return false;
        }
        return result;
    }

}