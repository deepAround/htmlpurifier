namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\ChildDef\ChildDefChameleon;
/**
 * XHTML 1.1 Edit Module, defines editing-related elements. Text Extension
 * Module.
 */
class HTMLModuleEdit extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Edit";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var contents, attr;
    
        let contents = "Chameleon: #PCDATA | Inline ! #PCDATA | Flow";
        let attr =  ["cite" : "URI"];
        this->addElement("del", "Inline", contents, "Common", attr);
        this->addElement("ins", "Inline", contents, "Common", attr);
    }
    
    // HTML 4.01 specifies that ins/del must not contain block
    // elements when used in an inline context, chameleon is
    // a complicated workaround to acheive this effect
    // Inline context ! Block context (exclamation mark is
    // separator, see getChildDef for parsing)
    /**
     * @type bool
     */
    public defines_child_def = true;
    /**
     * @param ElementDef $def
     * @return ChildDefChameleon
     */
    public function getChildDef(<ElementDef> def) -> <ChildDefChameleon>
    {
        var value;
    
        if def->content_model_type != "chameleon" {
            return false;
        }
        let value =  explode("!", def->content_model);
        return new ChildDefChameleon(value[0], value[1]);
    }

}