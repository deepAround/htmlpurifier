namespace HTMLPurifier\AttrDef\Css;

/**
 * Framework class for strings that involve multiple values.
 *
 * Certain CSS properties such as border-width and margin allow multiple
 * lengths to be specified.  This class can take a vanilla border-width
 * definition and multiply it, usually into a max of four.
 *
 * @note Even though the CSS specification isn't clear about it, inherit
 *       can only be used alone: it will never manifest as part of a multi
 *       shorthand declaration.  Thus, this class does not allow inherit.
 */
class AttrDefCSSMultiple extends \HTMLPurifier\AttrDef
{
    /**
     * Instance of component definition to defer validation to.
     * @type AttrDef
     * @todo Make protected
     */
    public single;
    /**
     * Max number of values allowed.
     * @todo Make protected
     */
    public max;
    /**
     * @param AttrDef $single AttrDef to multiply
     * @param int $max Max number of values allowed (usually four)
     */
    public function __construct(<AttrDef> single, int max = 4) -> void
    {
        let this->single = single;
        let this->max = max;
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var parts, length, final, i, num, result;
    
        let stringg =  this->mungeRgb(this->parseCDATA(stringg));
        if stringg === "" {
            return false;
        }
        let parts =  explode(" ", stringg);
        // parseCDATA replaced \r, \t and \n
        let length =  count(parts);
        let final = "";
        let i = 0;
        let num = 0;
        for i in range(i < length, num < this->max) {
            if ctype_space(parts[i]) {
                continue;
            }
            let result =  this->single->validate(parts[i], config, context);
            if result !== false {
                let final .= result . " ";
                let num++;
            }
        }
        if final === "" {
            return false;
        }
        return rtrim(final);
    }

}