namespace HTMLPurifier;

/**
 * Base class for all validating attribute definitions.
 *
 * This family of classes forms the core for not only HTML attribute validation,
 * but also any sort of string that needs to be validated or cleaned (which
 * means CSS properties and composite definitions are defined here too).
 * Besides defining (through code) what precisely makes the string valid,
 * subclasses are also responsible for cleaning the code if possible.
 */
abstract class AttrDef
{
    /**
     * Tells us whether or not an HTML attribute is minimized.
     * Has no meaning in other contexts.
     * @type bool
     */
    public minimized = false;
    /**
     * Tells us whether or not an HTML attribute is required.
     * Has no meaning in other contexts
     * @type bool
     */
    public required = false;
    /**
     * Validates and cleans passed string according to a definition.
     *
     * @param string $string String to be validated and cleaned.
     * @param Config $config Mandatory Config object.
     * @param Context $context Mandatory Context object.
     */
    public abstract function validate(string stringg, <Config> config, <Context> context) -> void;
    
    /**
     * Convenience method that parses a string as if it were CDATA.
     *
     * This method process a string in the manner specified at
     * <http://www.w3.org/TR/html4/types.html#h-6.2> by removing
     * leading and trailing whitespace, ignoring line feeds, and replacing
     * carriage returns and tabs with spaces.  While most useful for HTML
     * attributes specified as CDATA, it can also be applied to most CSS
     * values.
     *
     * @note This method is not entirely standards compliant, as trim() removes
     *       more types of whitespace than specified in the spec. In practice,
     *       this is rarely a problem, as those extra characters usually have
     *       already been removed by Encoder.
     *
     * @warning This processing is inconsistent with XML's whitespace handling
     *          as specified by section 3.3.3 and referenced XHTML 1.0 section
     *          4.7.  However, note that we are NOT necessarily
     *          parsing XML, thus, this behavior may still be correct. We
     *          assume that newlines have been normalized.
     */
    public function parseCDATA(stringg)
    {
        var tmpArray89ffa736b1b77594a2183634ff40963b;
    
        let stringg =  trim(stringg);
        let tmpArray89ffa736b1b77594a2183634ff40963b = ["
", "	", ""];
        let stringg =  str_replace(tmpArray89ffa736b1b77594a2183634ff40963b, " ", stringg);
        return stringg;
    }
    
    /**
     * Factory method for creating this class from a string.
     * @param string $string String construction info
     * @return AttrDef Created AttrDef object corresponding to $string
     */
    public function make(string stringg) -> <AttrDef>
    {
        // default implementation, return a flyweight of this object.
        // If $string has an effect on the returned object (i.e. you
        // need to overload this method), it is best
        // to clone or instantiate new copies. (Instantiation is safer.)
        return this;
    }
    
    /**
     * Removes spaces from rgb(0, 0, 0) so that shorthand CSS properties work
     * properly. THIS IS A HACK!
     * @param string $string a CSS colour definition
     * @return string
     */
    protected function mungeRgb(string stringg) -> string
    {
        var p;
    
        let p = "\\s*(\\d+(\\.\\d+)?([%]?))\\s*";
        if preg_match("/(rgba|hsla)\\(/", stringg) {
            return preg_replace("/(rgba|hsla)\\(" . p . "," . p . "," . p . "," . p . "\\)/", "\\1(\\2,\\5,\\8,\\11)", stringg);
        }
        return preg_replace("/(rgb|hsl)\\(" . p . "," . p . "," . p . "\\)/", "\\1(\\2,\\5,\\8)", stringg);
    }
    
    /**
     * Parses a possibly escaped CSS string and returns the "pure"
     * version of it.
     */
    protected function expandCSSEscape(stringg)
    {
        var ret, i, c, code, a, char;
    
        // flexibly parse it
        let ret = "";
        let i = 0;
        let c =  strlen(stringg);
        for i in range(0, c) {
            if stringg[i] === "\\" {
                let i++;
                if i >= c {
                    let ret .= "\\";
                    break;
                }
                if ctype_xdigit(stringg[i]) {
                    let code = stringg[i];
                    let a = 1;
                    let i++;
                    for a in range(i < c, a < 6) {
                        if !(ctype_xdigit(stringg[i])) {
                            break;
                        }
                        let code .= stringg[i];
                    }
                    // We have to be extremely careful when adding
                    // new characters, to make sure we're not breaking
                    // the encoding.
                    let char =  Encoder::unichr(hexdec(code));
                    if Encoder::cleanUTF8(char) === "" {
                        continue;
                    }
                    let ret .= char;
                    if i < c && trim(stringg[i]) !== "" {
                        let i--;
                    }
                    continue;
                }
                if stringg[i] === "
" {
                    continue;
                }
            }
            let ret .= stringg[i];
        }
        return ret;
    }

}