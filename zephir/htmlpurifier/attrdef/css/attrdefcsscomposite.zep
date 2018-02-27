namespace HTMLPurifier\AttrDef\Css;

/**
 * Allows multiple validators to attempt to validate attribute.
 *
 * Composite is just what it sounds like: a composite of many validators.
 * This means that multiple AttrDef objects will have a whack
 * at the string.  If one of them passes, that's what is returned.  This is
 * especially useful for CSS values, which often are a choice between
 * an enumerated set of predefined values or a flexible data type.
 */
class AttrDefCSSComposite extends \HTMLPurifier\AttrDef
{
    /**
     * List of objects that may process strings.
     * @type AttrDef[]
     * @todo Make protected
     */
    public defs;
    /**
     * @param AttrDef[] $defs List of AttrDef objects
     */
    public function __construct(array defs) -> void
    {
        let this->defs = defs;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var i, def, result;
    
        for i, def in this->defs {
            let result =  this->defs[i]->validate(stringg, config, context);
            if result !== false {
                return result;
            }
        }
        return false;
    }

}