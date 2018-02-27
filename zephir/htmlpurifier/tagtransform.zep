namespace HTMLPurifier;

/**
 * Defines a mutation of an obsolete tag into a valid tag.
 */
abstract class TagTransform
{
    /**
     * Tag name to transform the tag to.
     * @type string
     */
    public transform_to;
    /**
     * Transforms the obsolete tag into the valid tag.
     * @param Token_Tag $tag Tag to be transformed.
     * @param Config $config Mandatory Config object
     * @param Context $context Mandatory Context object
     */
    public abstract function transform(tag, <Config> config, <Context> context) -> void;
    
    /**
     * Prepends CSS properties to the style attribute, creating the
     * attribute if it doesn't exist.
     * @warning Copied over from AttrTransform, be sure to keep in sync
     * @param array $attr Attribute array to process (passed by reference)
     * @param string $css CSS to prepend
     */
    protected function prependCSS(array attr, string css) -> void
    {
        let attr["style"] =  isset attr["style"] ? attr["style"]  : "";
        let attr["style"] =  css . attr["style"];
    }

}