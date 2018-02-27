namespace HTMLPurifier\AttrDef\Uri\Email;

/**
 * Primitive email validation class based on the regexp found at
 * http://www.regular-expressions.info/email.html
 */
class AttrDefURIEmailSimpleCheck extends \HTMLPurifier\AttrDef\Uri\AttrDefURIEmail
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var result;
    
        // no support for named mailboxes i.e. "Bob <bob@example.com>"
        // that needs more percent encoding to be done
        if stringg == "" {
            return false;
        }
        let stringg =  trim(stringg);
        let result =  preg_match("/^[A-Z0-9._%-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$/i", stringg);
        return  result ? stringg  : false;
    }

}