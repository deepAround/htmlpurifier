namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLLinkTypes;
/**
 * XHTML 1.1 Hypertext Module, defines hypertext links. Core Module.
 */
class HTMLModuleHypertext extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Hypertext";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var a, tmpArrayc518ba8adad4be248fcee5ad92a3aa6e;
    
        let tmpArrayc518ba8adad4be248fcee5ad92a3aa6e = ["href" : "URI", "rel" : new AttrDefHTMLLinkTypes("rel"), "rev" : new AttrDefHTMLLinkTypes("rev")];
        let a =  this->addElement("a", "Inline", "Inline", "Common", tmpArrayc518ba8adad4be248fcee5ad92a3aa6e);
        let a->formatting =  true;
        let a->excludes =  ["a" : true];
    }

}