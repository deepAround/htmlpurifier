namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;
// VERY RELAXED! Shouldn't cause problems, not even Firefox checks if the
// email is valid, but be careful!
/**
 * Validates mailto (for E-mail) according to RFC 2368
 * @todo Validate the email address
 * @todo Filter allowed query parameters
 */
class URISchemeMailto extends URIScheme
{
    /**
     * @type bool
     */
    public browsable = false;
    /**
     * @type bool
     */
    public may_omit_host = true;
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function doValidate(uri, <Config> config, <Context> context) -> bool
    {
        let uri->userinfo =  null;
        let uri->host =  null;
        let uri->port =  null;
        // we need to validate path against RFC 2368's addr-spec
        return true;
    }

}