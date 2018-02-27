namespace HTMLPurifier\AttrDef\Css;

/**
 * Decorator which enables CSS properties to be disabled for specific elements.
 */
class AttrDefCSSDenyElementDecorator extends \HTMLPurifier\AttrDef
{
    /**
     * @type AttrDef
     */
    public def;
    /**
     * @type string
     */
    public element;
    /**
     * @param AttrDef $def Definition to wrap
     * @param string $element Element to deny
     */
    public function __construct(<AttrDef> def, string element) -> void
    {
        let this->def = def;
        let this->element = element;
    }
    
    /**
     * Checks if CurrentToken is set and equal to $this->element
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var token;
    
        let token =  context->get("CurrentToken", true);
        if token && token->name == this->element {
            return false;
        }
        return this->def->validate(stringg, config, context);
    }

}