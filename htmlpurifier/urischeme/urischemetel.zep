namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;
/**
 * Validates tel (for phone numbers).
 *
 * The relevant specifications for this protocol are RFC 3966 and RFC 5341,
 * but this class takes a much simpler approach: we normalize phone
 * numbers so that they only include (possibly) a leading plus,
 * and then any number of digits and x'es.
 */
class URISchemeTel extends URIScheme
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
        // Delete all non-numeric characters, non-x characters
        // from phone number, EXCEPT for a leading plus sign.
        let uri->path =  preg_replace("/(?!^\\+)[^\\dx]/", "", str_replace("X", "x", uri->path));
        return true;
    }

}