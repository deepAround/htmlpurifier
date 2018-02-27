namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformTargetNoreferrer;
/**
 * Module adds the target-based noreferrer attribute transformation to a tags.  It
 * is enabled by HTML.TargetNoreferrer
 */
class HTMLModuleTargetNoreferrer extends HTMLModule
{
    /**
     * @type string
     */
    public name = "TargetNoreferrer";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var a;
    
        let a =  this->addBlankElement("a");
        let a->attr_transform_post[] = new AttrTransformTargetNoreferrer();
    }

}