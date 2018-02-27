namespace HTMLPurifier\Filter;

use HTMLPurifier\Filter;
use HTMLPurifier\Exception;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrDef\Css\AttrDefCSSIdent;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLID;
// why is this a top level function? Because PHP 5.2.0 doesn't seem to
// understand how to interpret this filter if it's a static method.
// It's all really silly, but if we go this route it might be reasonable
// to coalesce all of these methods into one.
function Filterextractstyleblocks_muteerrorhandler()
{
}
/**
 * This filter extracts <style> blocks from input HTML, cleans them up
 * using CSSTidy, and then places them in $purifier->context->get('StyleBlocks')
 * so they can be used elsewhere in the document.
 *
 * @note
 *      See tests/HTMLPurifier/Filter/ExtractStyleBlocksTest.php for
 *      sample usage.
 *
 * @note
 *      This filter can also be used on stylesheets not included in the
 *      document--something purists would probably prefer. Just directly
 *      call FilterExtractStyleBlocks->cleanCSS()
 */
class FilterExtractStyleBlocks extends Filter
{
    /**
     * @type string
     */
    public name = "ExtractStyleBlocks";
    /**
     * @type array
     */
    protected _styleMatches = [];
    /**
     * @type csstidy
     */
    protected _tidy;
    /**
     * @type AttrDef_HTML_ID
     */
    protected _id_attrdef;
    /**
     * @type AttrDef_CSS_Ident
     */
    protected _class_attrdef;
    /**
     * @type AttrDef_Enum
     */
    protected _enum_attrdef;
    public function __construct() -> void
    {
        var tmpArraya4b1945a386bc514ade30c1bbf7140ab;
    
        let this->_tidy =  new csstidy();
        this->_tidy->set_cfg("lowercase_s", false);
        let this->_id_attrdef =  new AttrDefHTMLID(true);
        let this->_class_attrdef =  new AttrDefCSSIdent();
        let this->_enum_attrdef =  new AttrDefEnum(["first-child", "link", "visited", "active", "hover", "focus"]);
    }
    
    /**
     * Save the contents of CSS blocks to style matches
     * @param array $matches preg_replace style $matches array
     */
    protected function styleCallback(array matches) -> void
    {
        let this->_styleMatches[] = matches[1];
    }
    
    /**
     * Removes inline <style> tags from HTML, saves them for later use
     * @param string $html
     * @param Config $config
     * @param Context $context
     * @return string
     * @todo Extend to indicate non-text/css style blocks
     */
    public function preFilter(string html, <Config> config, <Context> context) -> string
    {
        var tidy, tmpArraydeb02191d80efd5ed8a0c5417da1c014, style_blocks, style;
    
        let tidy =  config->get("Filter.ExtractStyleBlocks.TidyImpl");
        if tidy !== null {
            let this->_tidy = tidy;
        }
        // NB: this must be NON-greedy because if we have
        // <style>foo</style>  <style>bar</style>
        // we must not grab foo</style>  <style>bar
        let tmpArraydeb02191d80efd5ed8a0c5417da1c014 = [this, "styleCallback"];
        let html =  preg_replace_callback("#<style(?:\\s.*)?>(.*)<\\/style>#isU", tmpArraydeb02191d80efd5ed8a0c5417da1c014, html);
        let style_blocks =  this->_styleMatches;
        let this->_styleMatches =  [];
        // reset
        context->register("StyleBlocks", style_blocks);
        // $context must not be reused
        if this->_tidy {
            for style in style_blocks {
                let style =  this->cleanCSS(style, config, context);
            }
        }
        return html;
    }
    
    /**
     * Takes CSS (the stuff found in <style>) and cleans it.
     * @warning Requires CSSTidy <http://csstidy.sourceforge.net/>
     * @param string $css CSS styling to clean
     * @param Config $config
     * @param Context $context
     * @throws Exception
     * @return string Cleaned CSS
     */
    public function cleanCSS(string css, <Config> config, <Context> context) -> string
    {
        var scope, scopes, css_definition, html_definition, new_css, k, decls, new_decls, selector, style, selectors, new_selectors, sel, basic_selectors, nsel, delim, i, c, x, components, sdelim, nx, j, cc, y, attrdef, r, s, name, value, def, ret, tmpArraya721021a4dd8cb644cbc7186753f9080, tmpArrayeb1d10c27a63342a6f15d29cdd7b8f14;
    
        // prepare scope
        let scope =  config->get("Filter.ExtractStyleBlocks.Scope");
        if scope !== null {
            let scopes =  array_map("trim", explode(",", scope));
        } else {
            let scopes =  [];
        }
        // remove comments from CSS
        let css =  trim(css);
        if strncmp("<!--", css, 4) === 0 {
            let css =  substr(css, 4);
        }
        if strlen(css) > 3 && substr(css, -3) == "-->" {
            let css =  substr(css, 0, -3);
        }
        let css =  trim(css);
        set_error_handler("Filterextractstyleblocks_muteerrorhandler");
        this->_tidy->parse(css);
        restore_error_handler();
        let css_definition =  config->getDefinition("CSS");
        let html_definition =  config->getDefinition("HTML");
        let new_css =  [];
        for k, decls in this->_tidy->css {
            // $decls are all CSS declarations inside an @ selector
            let new_decls =  [];
            for selector, style in decls {
                let selector =  trim(selector);
                if selector === "" {
                    continue;
                }
                // should not happen
                // Parse the selector
                // Here is the relevant part of the CSS grammar:
                //
                // ruleset
                //   : selector [ ',' S* selector ]* '{' ...
                // selector
                //   : simple_selector [ combinator selector | S+ [ combinator? selector ]? ]?
                // combinator
                //   : '+' S*
                //   : '>' S*
                // simple_selector
                //   : element_name [ HASH | class | attrib | pseudo ]*
                //   | [ HASH | class | attrib | pseudo ]+
                // element_name
                //   : IDENT | '*'
                //   ;
                // class
                //   : '.' IDENT
                //   ;
                // attrib
                //   : '[' S* IDENT S* [ [ '=' | INCLUDES | DASHMATCH ] S*
                //     [ IDENT | STRING ] S* ]? ']'
                //   ;
                // pseudo
                //   : ':' [ IDENT | FUNCTION S* [IDENT S*]? ')' ]
                //   ;
                //
                // For reference, here are the relevant tokens:
                //
                // HASH         #{name}
                // IDENT        {ident}
                // INCLUDES     ==
                // DASHMATCH    |=
                // STRING       {string}
                // FUNCTION     {ident}\(
                //
                // And the lexical scanner tokens
                //
                // name         {nmchar}+
                // nmchar       [_a-z0-9-]|{nonascii}|{escape}
                // nonascii     [\240-\377]
                // escape       {unicode}|\\[^\r\n\f0-9a-f]
                // unicode      \\{h}}{1,6}(\r\n|[ \t\r\n\f])?
                // ident        -?{nmstart}{nmchar*}
                // nmstart      [_a-z]|{nonascii}|{escape}
                // string       {string1}|{string2}
                // string1      \"([^\n\r\f\\"]|\\{nl}|{escape})*\"
                // string2      \'([^\n\r\f\\"]|\\{nl}|{escape})*\'
                //
                // We'll implement a subset (in order to reduce attack
                // surface); in particular:
                //
                //      - No Unicode support
                //      - No escapes support
                //      - No string support (by proxy no attrib support)
                //      - element_name is matched against allowed
                //        elements (some people might find this
                //        annoying...)
                //      - Pseudo-elements one of :first-child, :link,
                //        :visited, :active, :hover, :focus
                // handle ruleset
                let selectors =  array_map("trim", explode(",", selector));
                let new_selectors =  [];
                for sel in selectors {
                    // split on +, > and spaces
                    let basic_selectors =  preg_split("/\\s*([+> ])\\s*/", sel, -1, PREG_SPLIT_DELIM_CAPTURE);
                    // even indices are chunks, odd indices are
                    // delimiters
                    let nsel =  null;
                    let delim =  null;
                    // guaranteed to be non-null after
                    // two loop iterations
                    let i = 0;
                    let c =  count(basic_selectors);
                    for i in range(0, c) {
                        let x = basic_selectors[i];
                        if i % 2 {
                            // delimiter
                            if x === " " {
                                let delim = " ";
                            } else {
                                let delim =  " " . x . " ";
                            }
                        } else {
                            // simple selector
                            let components =  preg_split("/([#.:])/", x, -1, PREG_SPLIT_DELIM_CAPTURE);
                            let sdelim =  null;
                            let nx =  null;
                            let j = 0;
                            let cc =  count(components);
                            for j in range(0, cc) {
                                let y = components[j];
                                if j === 0 {
                                    let y =  strtolower(y);
                                    if y === "*" || isset html_definition->info[y] {
                                        let nx = y;
                                    } else {
                                    }
                                } elseif j % 2 {
                                    // set delimiter
                                    let sdelim = y;
                                } else {
                                    let attrdef =  null;
                                    if sdelim === "#" {
                                        let attrdef =  this->_id_attrdef;
                                    } elseif sdelim === "." {
                                        let attrdef =  this->_class_attrdef;
                                    } elseif sdelim === ":" {
                                        let attrdef =  this->_enum_attrdef;
                                    } else {
                                        throw new Exception("broken invariant sdelim and preg_split");
                                    }
                                    let r =  attrdef->validate(y, config, context);
                                    if r !== false {
                                        if r !== true {
                                            let y = r;
                                        }
                                        if nx === null {
                                            let nx = "";
                                        }
                                        let nx .= sdelim . y;
                                    }
                                }
                            }
                            if nx !== null {
                                if nsel === null {
                                    let nsel = nx;
                                } else {
                                    let nsel .= delim . nx;
                                }
                            } else {
                            }
                        }
                    }
                    if nsel !== null {
                        if !(empty(scopes)) {
                            for s in scopes {
                                let new_selectors[] = "{s} {nsel}";
                            }
                        } else {
                            let new_selectors[] = nsel;
                        }
                    }
                }
                if empty(new_selectors) {
                    continue;
                }
                let selector =  implode(", ", new_selectors);
                for name, value in style {
                    if !(isset css_definition->info[name]) {
                        unset style[name];
                        
                        continue;
                    }
                    let def = css_definition->info[name];
                    let ret =  def->validate(value, config, context);
                    if ret === false {
                        unset style[name];
                    
                    } else {
                        let style[name] = ret;
                    }
                }
                let new_decls[selector] = style;
            }
            let new_css[k] = new_decls;
        }
        // remove stuff that shouldn't be used, could be reenabled
        // after security risks are analyzed
        let this->_tidy->css = new_css;
        let this->_tidy->import =  [];
        let this->_tidy->charset =  null;
        let this->_tidy->namespacee =  null;
        let css =  this->_tidy->print->plain();
        // we are going to escape any special characters <>& to ensure
        // that no funny business occurs (i.e. </style> in a font-family prop).
        if config->get("Filter.ExtractStyleBlocks.Escaping") {
            let tmpArraya721021a4dd8cb644cbc7186753f9080 = ["<", ">", "&"];
            let tmpArrayeb1d10c27a63342a6f15d29cdd7b8f14 = ["\\3C ", "\\3E ", "\\26 "];
            let css =  str_replace(tmpArraya721021a4dd8cb644cbc7186753f9080, tmpArrayeb1d10c27a63342a6f15d29cdd7b8f14, css);
        }
        return css;
    }

}