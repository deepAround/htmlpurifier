namespace HTMLPurifier\URIFilter;

use HTMLPurifier\URIFilter;
class URIFilterDisableResources extends URIFilter
{
    /**
     * @type string
     */
    public name = "DisableResources";
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(uri, <Config> config, <Context> context) -> bool
    {
        return !(context->get("EmbeddedURI", true));
    }

}