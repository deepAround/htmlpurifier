namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
/**
 * XHTML 1.1 Object Module, defines elements for generic object inclusion
 * @warning Users will commonly use <embed> to cater to legacy browsers: this
 *      module does not allow this sort of behavior
 */
class HTMLModuleObject extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Object";
    /**
     * @type bool
     */
    public safe = false;
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArray4a7fdbddf7da4f44b96843a3b7aa1f2f, tmpArray40c87820b2367ed5ba68f21f946665e8;
    
        let tmpArray4a7fdbddf7da4f44b96843a3b7aa1f2f = ["archive" : "URI", "classid" : "URI", "codebase" : "URI", "codetype" : "Text", "data" : "URI", "declare" : "Bool#declare", "height" : "Length", "name" : "CDATA", "standby" : "Text", "tabindex" : "Number", "type" : "ContentType", "width" : "Length"];
        this->addElement("object", "Inline", "Optional: #PCDATA | Flow | param", "Common", tmpArray4a7fdbddf7da4f44b96843a3b7aa1f2f);
        let tmpArray40c87820b2367ed5ba68f21f946665e8 = ["id" : "ID", "name*" : "Text", "type" : "Text", "value" : "Text", "valuetype" : "Enum#data,ref,object"];
        this->addElement("param", false, "Empty", null, tmpArray40c87820b2367ed5ba68f21f946665e8);
    }

}