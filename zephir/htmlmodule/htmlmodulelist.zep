namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\ChildDef\ChildDefList;
/**
 * XHTML 1.1 List Module, defines list-oriented elements. Core Module.
 */
class HTMLModuleList extends HTMLModule
{
    /**
     * @type string
     */
    public name = "List";
    // According to the abstract schema, the List content set is a fully formed
    // one or more expr, but it invariably occurs in an optional declaration
    // so we're not going to do that subtlety. It might cause trouble
    // if a user defines "List" and expects that multiple lists are
    // allowed to be specified, but then again, that's not very intuitive.
    // Furthermore, the actual XML Schema may disagree. Regardless,
    // we don't have support for such nested expressions without using
    // the incredibly inefficient and draconic Custom ChildDef.
    /**
     * @type array
     */
    public content_sets = ["Flow" : "List"];
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var ol, ul;
    
        let ol =  this->addElement("ol", "List", new ChildDefList(), "Common");
        let ul =  this->addElement("ul", "List", new ChildDefList(), "Common");
        // XXX The wrap attribute is handled by MakeWellFormed.  This is all
        // quite unsatisfactory, because we generated this
        // *specifically* for lists, and now a big chunk of the handling
        // is done properly by the List ChildDef.  So actually, we just
        // want enough information to make autoclosing work properly,
        // and then hand off the tricky stuff to the ChildDef.
        let ol->wrap = "li";
        let ul->wrap = "li";
        this->addElement("dl", "List", "Required: dt | dd", "Common");
        this->addElement("li", false, "Flow", "Common");
        this->addElement("dd", false, "Flow", "Common");
        this->addElement("dt", false, "Inline", "Common");
    }

}