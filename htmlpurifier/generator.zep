namespace HTMLPurifier;

use HTMLPurifier\Token\TokenComment;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
use stdClass;
/**
 * Generates HTML from tokens.
 * @todo Refactor interface so that configuration/context is determined
 *       upon instantiation, no need for messy generateFromTokens() calls
 * @todo Make some of the more internal functions protected, and have
 *       unit tests work around that
 */
class Generator
{
    /**
     * Whether or not generator should produce XML output.
     * @type bool
     */
    protected _xhtml = true;
    /**
     * :HACK: Whether or not generator should comment the insides of <script> tags.
     * @type bool
     */
    protected _scriptFix = false;
    /**
     * Cache of HTMLDefinition during HTML output to determine whether or
     * not attributes should be minimized.
     * @type HTMLDefinition
     */
    protected _def;
    /**
     * Cache of %Output.SortAttr.
     * @type bool
     */
    protected _sortAttr;
    /**
     * Cache of %Output.FlashCompat.
     * @type bool
     */
    protected _flashCompat;
    /**
     * Cache of %Output.FixInnerHTML.
     * @type bool
     */
    protected _innerHTMLFix;
    /**
     * Stack for keeping track of object information when outputting IE
     * compatibility code.
     * @type array
     */
    protected _flashStack = [];
    /**
     * Configuration for the generator
     * @type Config
     */
    protected config;
    /**
     * @param Config $config
     * @param Context $context
     */
    public function __construct(<Config> config, <Context> context) -> void
    {
        let this->config = config;
        let this->_scriptFix =  config->get("Output.CommentScriptContents");
        let this->_innerHTMLFix =  config->get("Output.FixInnerHTML");
        let this->_sortAttr =  config->get("Output.SortAttr");
        let this->_flashCompat =  config->get("Output.FlashCompat");
        let this->_def =  config->getHTMLDefinition();
        let this->_xhtml =  this->_def->doctype->xml;
    }
    
    /**
     * Generates HTML from an array of tokens.
     * @param Token[] $tokens Array of Token
     * @return string Generated HTML
     */
    public function generateFromTokens(array tokens) -> string
    {
        var html, i, size, tmpI1, tmpI2, tidy, tmpArray9292568e933230da91569d8efbd915b3, nl;
    
        if !(tokens) {
            return "";
        }
        // Basic algorithm
        let html = "";
        let i = 0;
        let size =  count(tokens);
        for i in range(0, size) {
            if this->_scriptFix && tokens[i]->name === "script" && i + 2 < size && tokens[i + 2] instanceof TokenEnd {
                // script special case
                // the contents of the script block must be ONE token
                // for this to work.
                let html .= let i++;
                this->generateFromToken(tokens[i]);
                let html .= let i++;
                this->generateScriptFromToken(tokens[i]);
            }
            let html .= this->generateFromToken(tokens[i]);
        }
        // Tidy cleanup
        if extension_loaded("tidy") && this->config->get("Output.TidyFormat") {
            let tidy =  new Tidy();
            let tmpArray9292568e933230da91569d8efbd915b3 = ["indent" : true, "output-xhtml" : this->_xhtml, "show-body-only" : true, "indent-spaces" : 2, "wrap" : 68];
            tidy->parseString(html, tmpArray9292568e933230da91569d8efbd915b3, "utf8");
            tidy->cleanRepair();
            let html =  (string) tidy;
        }
        // Normalize newlines to system defined value
        if this->config->get("Core.NormalizeNewlines") {
            let nl =  this->config->get("Output.Newline");
            if nl === null {
                let nl =  PHP_EOL;
            }
            if nl !== "
" {
                let html =  str_replace("
", nl, html);
            }
        }
        return html;
    }
    
    /**
     * Generates HTML from a single token.
     * @param Token $token Token object.
     * @return string Generated HTML
     */
    public function generateFromToken(<Token> token) -> string
    {
        var attr, flash, _extra;
    
        if !(token instanceof Token) {
            trigger_error("Cannot generate HTML from non-Token object", E_USER_WARNING);
            return "";
        } elseif token instanceof TokenStart {
            let attr =  this->generateAttributes(token->attr, token->name);
            if this->_flashCompat {
                if token->name == "object" {
                    let flash =  new stdClass();
                    let flash->attr =  token->attr;
                    let flash->param =  [];
                    let this->_flashStack[] = flash;
                }
            }
            return "<" . token->name . ( attr ? " "  : "") . attr . ">";
        } elseif token instanceof TokenEnd {
            let _extra = "";
            if this->_flashCompat {
                if token->name == "object" && !(empty(this->_flashStack)) {
                    echo "not allowed";
                }
            }
            return _extra . "</" . token->name . ">";
        } elseif token instanceof TokenEmpty {
            if this->_flashCompat && token->name == "param" && !(empty(this->_flashStack)) {
                let this->_flashStack[count(this->_flashStack) - 1]->param[token->attr["name"]] = token->attr["value"];
            }
            let attr =  this->generateAttributes(token->attr, token->name);
            return "<" . token->name . ( attr ? " "  : "") . attr . ( this->_xhtml ? " /"  : "") . ">";
        } elseif token instanceof TokenText {
            return this->escape(token->data, ENT_NOQUOTES);
        } elseif token instanceof TokenComment {
            return "<!--" . token->data . "-->";
        } else {
            return "";
        }
    }
    
    /**
     * Special case processor for the contents of script tags
     * @param Token $token Token object.
     * @return string
     * @warning This runs into problems if there's already a literal
     *          --> somewhere inside the script contents.
     */
    public function generateScriptFromToken(<Token> token) -> string
    {
        var data;
    
        if !(token instanceof TokenText) {
            return this->generateFromToken(token);
        }
        // Thanks <http://lachy.id.au/log/2005/05/script-comments>
        let data =  preg_replace("#//\\s*$#", "", token->data);
        return "<!--//--><![CDATA[//><!--" . "
" . trim(data) . "
" . "//--><!]]>";
    }
    
    /**
     * Generates attribute declarations from attribute array.
     * @note This does not include the leading or trailing space.
     * @param array $assoc_array_of_attributes Attribute array
     * @param string $element Name of element attributes are for, used to check
     *        attribute minimization.
     * @return string Generated HTML fragment for insertion.
     */
    public function generateAttributes(array assoc_array_of_attributes, string element = "") -> string
    {
        var html, key, value;
    
        let html = "";
        if this->_sortAttr {
            ksort(assoc_array_of_attributes);
        }
        for key, value in assoc_array_of_attributes {
            if !(this->_xhtml) {
                // Remove namespaced attributes
                if strpos(key, ":") !== false {
                    continue;
                }
                // Check if we should minimize the attribute: val="val" -> val
                if element && !(empty(this->_def->info[element]->attr[key]->minimized)) {
                    let html .= key . " ";
                    continue;
                }
            }
            // Workaround for Internet Explorer innerHTML bug.
            // Essentially, Internet Explorer, when calculating
            // innerHTML, omits quotes if there are no instances of
            // angled brackets, quotes or spaces.  However, when parsing
            // HTML (for example, when you assign to innerHTML), it
            // treats backticks as quotes.  Thus,
            //      <img alt="``" />
            // becomes
            //      <img alt=`` />
            // becomes
            //      <img alt='' />
            // Fortunately, all we need to do is trigger an appropriate
            // quoting style, which we do by adding an extra space.
            // This also is consistent with the W3C spec, which states
            // that user agents may ignore leading or trailing
            // whitespace (in fact, most don't, at least for attributes
            // like alt, but an extra space at the end is barely
            // noticeable).  Still, we have a configuration knob for
            // this, since this transformation is not necesary if you
            // don't process user input with innerHTML or you don't plan
            // on supporting Internet Explorer.
            if this->_innerHTMLFix {
                if strpos(value, "`") !== false {
                    // check if correct quoting style would not already be
                    // triggered
                    if strcspn(value, "\"' <>") === strlen(value) {
                        // protect!
                        let value .= " ";
                    }
                }
            }
            let html .= key . "=\"" . this->escape(value) . "\" ";
        }
        return rtrim(html);
    }
    
    /**
     * Escapes raw text data.
     * @todo This really ought to be protected, but until we have a facility
     *       for properly generating HTML here w/o using tokens, it stays
     *       public.
     * @param string $string String data to escape for HTML.
     * @param int $quote Quoting style, like htmlspecialchars. ENT_NOQUOTES is
     *               permissible for non-attribute output.
     * @return string escaped data.
     */
    public function escape(string stringg, int quote = null) -> string
    {
        // Workaround for APC bug on Mac Leopard reported by sidepodcast
        // http://htmlpurifier.org/phorum/read.php?3,4823,4846
        if quote === null {
            let quote =  ENT_COMPAT;
        }
        return htmlspecialchars(stringg, quote, "UTF-8");
    }

}