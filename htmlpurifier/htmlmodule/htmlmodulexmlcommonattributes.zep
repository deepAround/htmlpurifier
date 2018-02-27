namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
class HTMLModuleXMLCommonAttributes extends HTMLModule
{
    /**
     * @type string
     */
    public name = "XMLCommonAttributes";
    /**
     * @type array
     */
    public attr_collections = ["Lang" : ["xml:lang" : "LanguageCode"]];
}