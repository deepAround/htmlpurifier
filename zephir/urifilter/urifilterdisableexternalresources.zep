namespace HTMLPurifier\URIFilter;

class URIFilterDisableExternalResources extends URIFilterDisableExternal
{
    /**
     * @type string
     */
    public name = "DisableExternalResources";
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(uri, <Config> config, <Context> context) -> bool
    {
        if !(context->get("EmbeddedURI", true)) {
            return true;
        }
        return parent::filter(uri, config, context);
    }

}