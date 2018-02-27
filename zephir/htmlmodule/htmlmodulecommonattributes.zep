namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
class HTMLModuleCommonAttributes extends HTMLModule
{
    /**
     * @type string
     */
    public name = "CommonAttributes";
    /**
     * @type array
     */
    public attr_collections = ["Core" : [0 : ["Style"], "class" : "Class", "id" : "ID", "title" : "CDATA"], "Lang" : [], "I18N" : [0 : ["Lang"]], "Common" : [0 : ["Core", "I18N"]]];
}