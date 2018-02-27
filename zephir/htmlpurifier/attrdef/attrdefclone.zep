namespace HTMLPurifier\AttrDef;

/**
 * Dummy AttrDef that mimics another AttrDef, BUT it generates clones
 * with make.
 */
class AttrDefClone extends \HTMLPurifier\AttrDef
{
    /**
     * What we're cloning.
     * @type AttrDef
     */
    protected clone;
    /**
     * @param AttrDef $clone
     */
    public function __construct(<AttrDef> clone) -> void
    {
        let this->clone = clone;
    }
    
    /**
     * @param string $v
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string v, <Config> config, <Context> context)
    {
        return this->clone->validate(v, config, context);
    }
    
    /**
     * @param string $string
     * @return AttrDef
     */
    public function make(string stringg) -> <AttrDef>
    {
        return clone this->clone;
    }

}