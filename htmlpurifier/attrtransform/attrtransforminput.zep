namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\AttrDef\Html\AttrDefHTMLPixels;
/**
 * Performs miscellaneous cross attribute validation and filtering for
 * input elements. This is meant to be a post-transform.
 */
class AttrTransformInput extends \HTMLPurifier\AttrTransform
{
    /**
     * @type AttrDef_HTML_Pixels
     */
    protected pixels;
    public function __construct() -> void
    {
        let this->pixels =  new AttrDefHTMLPixels();
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var t, result;
    
        if !(isset attr["type"]) {
            let t = "text";
        } else {
            let t =  strtolower(attr["type"]);
        }
        if isset attr["checked"] && t !== "radio" && t !== "checkbox" {
            unset attr["checked"];
        
        }
        if isset attr["maxlength"] && t !== "text" && t !== "password" {
            unset attr["maxlength"];
        
        }
        if isset attr["size"] && t !== "text" && t !== "password" {
            let result =  this->pixels->validate(attr["size"], config, context);
            if result === false {
                unset attr["size"];
            
            } else {
                let attr["size"] = result;
            }
        }
        if isset attr["src"] && t !== "image" {
            unset attr["src"];
        
        }
        if !(isset attr["value"]) && (t === "radio" || t === "checkbox") {
            let attr["value"] = "";
        }
        return attr;
    }

}