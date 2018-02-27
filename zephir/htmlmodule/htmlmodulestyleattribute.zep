namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefCSS;
/**
 * XHTML 1.1 Edit Module, defines editing-related elements. Text Extension
 * Module.
 */
class HTMLModuleStyleAttribute extends HTMLModule
{
    /**
     * @type string
     */
    public name = "StyleAttribute";
    /**
     * @type array
     */
    public attr_collections = ["Style" : ["style" : false], "Core" : [0 : ["Style"]]];
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        let this->attr_collections["Style"]["style"] = new AttrDefCSS();
    }

}