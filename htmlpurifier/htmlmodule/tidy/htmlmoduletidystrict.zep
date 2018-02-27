namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\ChildDef\ChildDefStrictBlockquote;
class HTMLModuleTidyStrict extends HTMLModuleTidyXHTMLAndHTML4
{
    /**
     * @type string
     */
    public name = "Tidy_Strict";
    /**
     * @type string
     */
    public defaultLevel = "light";
    /**
     * @return array
     */
    public function makeFixes() -> array
    {
        var r;
    
        let r =  parent::makeFixes();
        let r["blockquote#content_model_type"] = "strictblockquote";
        return r;
    }
    
    /**
     * @type bool
     */
    public defines_child_def = true;
    /**
     * @param ElementDef $def
     * @return ChildDefStrictBlockquote
     */
    public function getChildDef(<ElementDef> def) -> <ChildDefStrictBlockquote>
    {
        if def->content_model_type != "strictblockquote" {
            return parent::getChildDef(def);
        }
        return new ChildDefStrictBlockquote(def->content_model);
    }

}