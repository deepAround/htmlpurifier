namespace HTMLPurifier\URIFilter;

use HTMLPurifier\URIFilter;
// It's not clear to me whether or not Punycode means that hostnames
// do not have canonical forms anymore. As far as I can tell, it's
// not a problem (punycoding should be identity when no Unicode
// points are involved), but I'm not 100% sure
class URIFilterHostBlacklist extends URIFilter
{
    /**
     * @type string
     */
    public name = "HostBlacklist";
    /**
     * @type array
     */
    protected blacklist = [];
    /**
     * @param Config $config
     * @return bool
     */
    public function prepare(<Config> config) -> bool
    {
        let this->blacklist =  config->get("URI.HostBlacklist");
        return true;
    }
    
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(uri, <Config> config, <Context> context) -> bool
    {
        var blacklisted_host_fragment;
    
        for blacklisted_host_fragment in this->blacklist {
            if strpos(uri->host, blacklisted_host_fragment) !== false {
                return false;
            }
        }
        return true;
    }

}