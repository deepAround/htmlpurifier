namespace HTMLPurifier\AttrDef\Html;

/**
 * Special-case enum attribute definition that lazy loads allowed frame targets
 */
class AttrDefHTMLFrameTarget extends \HTMLPurifier\AttrDef\AttrDefEnum
{
    /**
     * @type array
     */
    public valid_values = false;
    // uninitialized value
    /**
     * @type bool
     */
    protected case_sensitive = false;
    public function __construct() -> void
    {
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        if this->valid_values === false {
            let this->valid_values =  config->get("Attr.AllowedFrameTargets");
        }
        return parent::validate(stringg, config, context);
    }

}