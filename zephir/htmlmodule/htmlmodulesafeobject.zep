namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrTransform\AttrTransformSafeObject;
use HTMLPurifier\AttrTransform\AttrTransformSafeParam;
/**
 * A "safe" object module. In theory, objects permitted by this module will
 * be safe, and untrusted users can be allowed to embed arbitrary flash objects
 * (maybe other types too, but only Flash is supported as of right now).
 * Highly experimental.
 */
class HTMLModuleSafeObject extends HTMLModule
{
    /**
     * @type string
     */
    public name = "SafeObject";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var max, object, tmpArray9c8c5482b6201e176f3e2e519937591a, tmpArrayacc1cc82fcd9d4fa9b9a020327a5a68e, param, tmpArray860096ce8748e7bf095c1a5b09ed6e4e;
    
        // These definitions are not intrinsically safe: the attribute transforms
        // are a vital part of ensuring safety.
        let max =  config->get("HTML.MaxImgLength");
        let tmpArray9c8c5482b6201e176f3e2e519937591a = ["type" : "Enum#application/x-shockwave-flash", "width" : "Pixels#" . max, "height" : "Pixels#" . max, "data" : "URI#embedded", "codebase" : new AttrDefEnum(tmpArrayacc1cc82fcd9d4fa9b9a020327a5a68e)];
        let object =  this->addElement("object", "Inline", "Optional: param | Flow | #PCDATA", "Common", tmpArray98cd5e9c983b3422d288e083bfa6a445);
        let object->attr_transform_post[] = new AttrTransformSafeObject();
        let tmpArray860096ce8748e7bf095c1a5b09ed6e4e = ["id" : "ID", "name*" : "Text", "value" : "Text"];
        let param =  this->addElement("param", false, "Empty", false, tmpArray860096ce8748e7bf095c1a5b09ed6e4e);
        let param->attr_transform_post[] = new AttrTransformSafeParam();
        let this->info_injector[] = "SafeObject";
    }

}