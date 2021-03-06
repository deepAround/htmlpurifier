namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformTargetNoopener;
/**
 * Module adds the target-based noopener attribute transformation to a tags.  It
 * is enabled by HTML.TargetNoopener
 */
class HTMLModuleTargetNoopener extends HTMLModule
{
    /**
     * @type string
     */
    public name = "TargetNoopener";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var a;
    
        let a =  this->addBlankElement("a");
        let a->attr_transform_post[] = new AttrTransformTargetNoopener();
    }

}