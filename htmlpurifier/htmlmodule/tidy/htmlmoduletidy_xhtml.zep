namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\AttrTransform\AttrTransformLang;
use HTMLPurifier\HTMLModule\HTMLModuleTidy;
class HTMLModuleTidy_XHTML extends HTMLModuleTidy
{
    /**
     * @type string
     */
    public name = "Tidy_XHTML";
    /**
     * @type string
     */
    public defaultLevel = "medium";
    /**
     * @return array
     */
    public function makeFixes() -> array
    {
        var r;
    
        let r =  [];
        let r["@lang"] = new AttrTransformLang();
        return r;
    }

}