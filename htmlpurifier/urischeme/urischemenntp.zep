namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;
/**
 * Validates nntp (Network News Transfer Protocol) as defined by generic RFC 1738
 */
class URISchemeNntp extends URIScheme
{
    /**
     * @type int
     */
    public default_port = 119;
    /**
     * @type bool
     */
    public browsable = false;
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function doValidate(uri, <Config> config, <Context> context) -> bool
    {
        let uri->userinfo =  null;
        let uri->query =  null;
        return true;
    }

}