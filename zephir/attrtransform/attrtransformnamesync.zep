namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\AttrDef\Html\AttrDefHTMLID;
/**
 * Post-transform that performs validation to the name attribute; if
 * it is present with an equivalent id attribute, it is passed through;
 * otherwise validation is performed.
 */
class AttrTransformNameSync extends \HTMLPurifier\AttrTransform
{
    public function __construct() -> void
    {
        let this->idDef =  new AttrDefHTMLID();
    }
    
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var name, result;
    
        if !(isset attr["name"]) {
            return attr;
        }
        let name = attr["name"];
        if isset attr["id"] && attr["id"] === name {
            return attr;
        }
        let result =  this->idDef->validate(name, config, context);
        if result === false {
            unset attr["name"];
        
        } else {
            let attr["name"] = result;
        }
        return attr;
    }

}