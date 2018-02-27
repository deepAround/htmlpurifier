namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformTargetBlank;
/**
 * Module adds the target=blank attribute transformation to a tags.  It
 * is enabled by HTML.TargetBlank
 */
class HTMLModuleTargetBlank extends HTMLModule
{
    /**
     * @type string
     */
    public name = "TargetBlank";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var a;
    
        let a =  this->addBlankElement("a");
        let a->attr_transform_post[] = new AttrTransformTargetBlank();
    }

}