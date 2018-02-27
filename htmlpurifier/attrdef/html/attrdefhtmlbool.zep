namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates a boolean attribute
 */
class AttrDefHTMLBool extends \HTMLPurifier\AttrDef
{
    /**
     * @type bool
     */
    protected name;
    /**
     * @type bool
     */
    public minimized = true;
    /**
     * @param bool $name
     */
    public function __construct(bool name = false) -> void
    {
        let this->name = name;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        return this->name;
    }
    
    /**
     * @param string $string Name of attribute
     * @return AttrDefHTMLBool
     */
    public function make(string stringg) -> <AttrDefHTMLBool>
    {
        return new AttrDefHTMLBool(stringg);
    }

}