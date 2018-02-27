namespace HTMLPurifier;

/**
 * Processes an entire attribute array for corrections needing multiple values.
 *
 * Occasionally, a certain attribute will need to be removed and popped onto
 * another value.  Instead of creating a complex return syntax for
 * AttrDef, we just pass the whole attribute array to a
 * specialized object and have that do the special work.  That is the
 * family of AttrTransform.
 *
 * An attribute transformation can be assigned to run before or after
 * AttrDef validation.  See HTMLDefinition for
 * more details.
 */
abstract class AttrTransform
{
    /**
     * Abstract: makes changes to the attributes dependent on multiple values.
     *
     * @param array $attr Assoc array of attributes, usually from
     *              Token_Tag::$attr
     * @param Config $config Mandatory Config object.
     * @param Context $context Mandatory Context object
     * @return array Processed attribute array.
     */
    public abstract function transform(array attr, <Config> config, <Context> context) -> array;
    
    /**
     * Prepends CSS properties to the style attribute, creating the
     * attribute if it doesn't exist.
     * @param array &$attr Attribute array to process (passed by reference)
     * @param string $css CSS to prepend
     */
    public function prependCSS(attr, string css) -> void
    {
        let attr["style"] =  isset attr["style"] ? attr["style"]  : "";
        let attr["style"] =  css . attr["style"];
    }
    
    /**
     * Retrieves and removes an attribute
     * @param array &$attr Attribute array to process (passed by reference)
     * @param mixed $key Key of attribute to confiscate
     * @return mixed
     */
    public function confiscateAttr(attr, key)
    {
        var value;
    
        if !(isset attr[key]) {
            return null;
        }
        let value = attr[key];
        unset attr[key];
        
        return value;
    }

}