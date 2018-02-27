namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
class HTMLModuleNonXMLCommonAttributes extends HTMLModule
{
    /**
     * @type string
     */
    public name = "NonXMLCommonAttributes";
    /**
     * @type array
     */
    public attr_collections = ["Lang" : ["lang" : "LanguageCode"]];
}