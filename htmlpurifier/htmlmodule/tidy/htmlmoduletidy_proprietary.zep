namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\AttrTransform\AttrTransformBackground;
use HTMLPurifier\AttrTransform\AttrTransformLength;
use HTMLPurifier\HTMLModule\HTMLModuleTidy;
class HTMLModuleTidy_Proprietary extends HTMLModuleTidy
{
    /**
     * @type string
     */
    public name = "Tidy_Proprietary";
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
    
        let r =  [];
        let r["table@background"] = new AttrTransformBackground();
        let r["td@background"] = new AttrTransformBackground();
        let r["th@background"] = new AttrTransformBackground();
        let r["tr@background"] = new AttrTransformBackground();
        let r["thead@background"] = new AttrTransformBackground();
        let r["tfoot@background"] = new AttrTransformBackground();
        let r["tbody@background"] = new AttrTransformBackground();
        let r["table@height"] = new AttrTransformLength("height");
        return r;
    }

}