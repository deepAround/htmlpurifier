namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrDef\AttrDefURI;
/**
 * Validates name/value pairs in param tags to be used in safe objects. This
 * will only allow name values it recognizes, and pre-fill certain attributes
 * with required values.
 *
 * @note
 *      This class only supports Flash. In the future, Quicktime support
 *      may be added.
 *
 * @warning
 *      This class expects an injector to add the necessary parameters tags.
 */
class AttrTransformSafeParam extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    public name = "SafeParam";
    /**
     * @type AttrDef_URI
     */
    protected uri;
    public function __construct() -> void
    {
        var tmpArray783782bb5f99554a7b99684775ad69eb;
    
        let this->uri =  new AttrDefURI(true);
        // embedded
        let this->wmode =  new AttrDefEnum(["window", "opaque", "transparent"]);
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        // If we add support for other objects, we'll need to alter the
        // transforms.
        switch (attr["name"]) {
            // application/x-shockwave-flash
            // Keep this synchronized with Injector/SafeObject.php
            case "allowScriptAccess":
                let attr["value"] = "never";
                break;
            case "allowNetworking":
                let attr["value"] = "internal";
                break;
            case "allowFullScreen":
                if config->get("HTML.FlashAllowFullScreen") {
                    let attr["value"] =  attr["value"] == "true" ? "true"  : "false";
                } else {
                    let attr["value"] = "false";
                }
                break;
            case "wmode":
                let attr["value"] =  this->wmode->validate(attr["value"], config, context);
                break;
            case "movie":
            case "src":
                let attr["name"] = "movie";
                let attr["value"] =  this->uri->validate(attr["value"], config, context);
                break;
            case "flashvars":
                // we're going to allow arbitrary inputs to the SWF, on
                // the reasoning that it could only hack the SWF, not us.
                break;
            // add other cases to support other param name/value pairs
            default:
                let attr["value"] = null;
                let attr["name"] = attr["value"];
        }
        return attr;
    }

}