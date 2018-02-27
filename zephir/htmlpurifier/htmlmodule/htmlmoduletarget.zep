namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLFrameTarget;
/**
 * XHTML 1.1 Target Module, defines target attribute in link elements.
 */
class HTMLModuleTarget extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Target";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var elements, name, e;
    
        let elements =  ["a"];
        for name in elements {
            let e =  this->addBlankElement(name);
            let e->attr =  ["target" : new AttrDefHTMLFrameTarget()];
        }
    }

}