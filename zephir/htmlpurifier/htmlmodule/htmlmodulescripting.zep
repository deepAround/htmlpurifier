namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\ElementDef;
use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrDef\AttrDefURI;
use HTMLPurifier\AttrTransform\AttrTransformScriptRequired;
/*
WARNING: THIS MODULE IS EXTREMELY DANGEROUS AS IT ENABLES INLINE SCRIPTING
INSIDE HTML PURIFIER DOCUMENTS. USE ONLY WITH TRUSTED USER INPUT!!!
*/
/**
 * XHTML 1.1 Scripting module, defines elements that are used to contain
 * information pertaining to executable scripts or the lack of support
 * for executable scripts.
 * @note This module does not contain inline scripting elements
 */
class HTMLModuleScripting extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Scripting";
    /**
     * @type array
     */
    public elements = ["script", "noscript"];
    /**
     * @type array
     */
    public content_sets = ["Block" : "script | noscript", "Inline" : "script | noscript"];
    /**
     * @type bool
     */
    public safe = false;
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArray3961bb915722514aa2f3e5a92255fb77, tmpArrayc8165c49036496568499eebcc9b4e51c;
    
        // TODO: create custom child-definition for noscript that
        // auto-wraps stray #PCDATA in a similar manner to
        // blockquote's custom definition (we would use it but
        // blockquote's contents are optional while noscript's contents
        // are required)
        // TODO: convert this to new syntax, main problem is getting
        // both content sets working
        // In theory, this could be safe, but I don't see any reason to
        // allow it.
        let this->info["noscript"] = new ElementDef();
        let this->info["noscript"]->attr =  [0 : ["Common"]];
        let this->info["noscript"]->content_model = "Heading | List | Block";
        let this->info["noscript"]->content_model_type = "required";
        let this->info["script"] = new ElementDef();
        let this->info["script"]->attr =  ["defer" : new AttrDefEnum(tmpArray3961bb915722514aa2f3e5a92255fb77), "src" : new AttrDefURI(true), "type" : new AttrDefEnum(tmpArrayc8165c49036496568499eebcc9b4e51c)];
        let this->info["script"]->content_model = "#PCDATA";
        let this->info["script"]->content_model_type = "optional";
        let this->info["script"]->attr_transform_post[] = new AttrTransformScriptRequired();
        let this->info["script"]->attr_transform_pre[] = this->info["script"]->attr_transform_post[];
    }

}