namespace HTMLPurifier\URIFilter;

use HTMLPurifier\URIFilter;
class URIFilterDisableExternal extends URIFilter
{
    /**
     * @type string
     */
    public name = "DisableExternal";
    /**
     * @type array
     */
    protected ourHostParts = false;
    /**
     * @param Config $config
     * @return void
     */
    public function prepare(<Config> config)
    {
        var our_host;
    
        let our_host =  config->getDefinition("URI")->host;
        if our_host !== null {
            let this->ourHostParts =  array_reverse(explode(".", our_host));
        }
    }
    
    /**
     * @param URI $uri Reference
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(uri, <Config> config, <Context> context) -> bool
    {
        var host_parts, i, x;
    
        if is_null(uri->host) {
            return true;
        }
        if this->ourHostParts === false {
            return false;
        }
        let host_parts =  array_reverse(explode(".", uri->host));
        for i, x in this->ourHostParts {
            if !(isset host_parts[i]) {
                return false;
            }
            if host_parts[i] != this->ourHostParts[i] {
                return false;
            }
        }
        return true;
    }

}