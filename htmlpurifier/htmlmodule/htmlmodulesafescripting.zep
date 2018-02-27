namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrTransform\AttrTransformScriptRequired;
/**
 * A "safe" script module. No inline JS is allowed, and pointed to JS
 * files must match whitelist.
 */
class HTMLModuleSafeScripting extends HTMLModule
{
    /**
     * @type string
     */
    public name = "SafeScripting";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var allowed, script, tmpArray0d48a1a626948fa8fee48adc3451cce3;
    
        // These definitions are not intrinsically safe: the attribute transforms
        // are a vital part of ensuring safety.
        let allowed =  config->get("HTML.SafeScripting");
        let tmpArray0d48a1a626948fa8fee48adc3451cce3 = ["type" : "Enum#text/javascript", "src*" : new AttrDefEnum(array_keys(allowed))];
        let script =  this->addElement("script", "Inline", "Empty", null, tmpArray0d48a1a626948fa8fee48adc3451cce3);
        let script->attr_transform_post[] = new AttrTransformScriptRequired();
        let script->attr_transform_pre[] = script->attr_transform_post[];
    }

}