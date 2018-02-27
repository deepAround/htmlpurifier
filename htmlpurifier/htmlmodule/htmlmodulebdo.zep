namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformBdoDir;
/**
 * XHTML 1.1 Bi-directional Text Module, defines elements that
 * declare directionality of content. Text Extension Module.
 */
class HTMLModuleBdo extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Bdo";
    /**
     * @type array
     */
    public attr_collections = ["I18N" : ["dir" : false]];
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var bdo, tmpArrayea717f9a4a583d6d1a75d188169fd9f6, tmpArrayfa63c622824619b732442c9bf7c65c91;
    
        let tmpArrayea717f9a4a583d6d1a75d188169fd9f6 = ["Core", "Lang"];
        let tmpArrayfa63c622824619b732442c9bf7c65c91 = ["dir" : "Enum#ltr,rtl"];
        let bdo =  this->addElement("bdo", "Inline", "Inline", tmpArrayea717f9a4a583d6d1a75d188169fd9f6, tmpArrayfa63c622824619b732442c9bf7c65c91);
        let bdo->attr_transform_post[] = new AttrTransformBdoDir();
        let this->attr_collections["I18N"]["dir"] = "Enum#ltr,rtl";
    }

}