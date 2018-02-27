namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformNofollow;
/**
 * Module adds the nofollow attribute transformation to a tags.  It
 * is enabled by HTML.Nofollow
 */
class HTMLModuleNofollow extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Nofollow";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var a;
    
        let a =  this->addBlankElement("a");
        let a->attr_transform_post[] = new AttrTransformNofollow();
    }

}