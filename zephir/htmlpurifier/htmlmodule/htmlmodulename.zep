namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformNameSync;
class HTMLModuleName extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Name";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var elements, name, element;
    
        let elements =  ["a", "applet", "form", "frame", "iframe", "img", "map"];
        for name in elements {
            let element =  this->addBlankElement(name);
            let element->attr["name"] = "CDATA";
            if !(config->get("HTML.Attr.Name.UseCDATA")) {
                let element->attr_transform_post[] = new AttrTransformNameSync();
            }
        }
    }

}