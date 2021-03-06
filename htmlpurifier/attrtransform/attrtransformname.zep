namespace HTMLPurifier\AttrTransform;

/**
 * Pre-transform that changes deprecated name attribute to ID if necessary
 */
class AttrTransformName extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var id;
    
        // Abort early if we're using relaxed definition of name
        if config->get("HTML.Attr.Name.UseCDATA") {
            return attr;
        }
        if !(isset attr["name"]) {
            return attr;
        }
        let id =  this->confiscateAttr(attr, "name");
        if isset attr["id"] {
            return attr;
        }
        let attr["id"] = id;
        return attr;
    }

}