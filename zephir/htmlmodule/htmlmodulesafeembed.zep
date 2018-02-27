namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformSafeEmbed;
/**
 * A "safe" embed module. See SafeObject. This is a proprietary element.
 */
class HTMLModuleSafeEmbed extends HTMLModule
{
    /**
     * @type string
     */
    public name = "SafeEmbed";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var max, embed, tmpArray9f939432e0c56081798d5d027b308df0;
    
        let max =  config->get("HTML.MaxImgLength");
        let tmpArray9f939432e0c56081798d5d027b308df0 = ["src*" : "URI#embedded", "type" : "Enum#application/x-shockwave-flash", "width" : "Pixels#" . max, "height" : "Pixels#" . max, "allowscriptaccess" : "Enum#never", "allownetworking" : "Enum#internal", "flashvars" : "Text", "wmode" : "Enum#window,transparent,opaque", "name" : "ID"];
        let embed =  this->addElement("embed", "Inline", "Empty", "Common", tmpArray9f939432e0c56081798d5d027b308df0);
        let embed->attr_transform_post[] = new AttrTransformSafeEmbed();
    }

}