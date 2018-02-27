namespace HTMLPurifier\AttrDef;

/**
 * Decorator that, depending on a token, switches between two definitions.
 */
class AttrDefSwitch
{
    /**
     * @type string
     */
    protected tag;
    /**
     * @type AttrDef
     */
    protected withTag;
    /**
     * @type AttrDef
     */
    protected withoutTag;
    /**
     * @param string $tag Tag name to switch upon
     * @param AttrDef $with_tag Call if token matches tag
     * @param AttrDef $without_tag Call if token doesn't match, or there is no token
     */
    public function __construct(string tag, <AttrDef> with_tag, <AttrDef> without_tag) -> void
    {
        let this->tag = tag;
        let this->withTag = with_tag;
        let this->withoutTag = without_tag;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var token;
    
        let token =  context->get("CurrentToken", true);
        if !(token) || token->name !== this->tag {
            return this->withoutTag->validate(stringg, config, context);
        } else {
            return this->withTag->validate(stringg, config, context);
        }
    }

}