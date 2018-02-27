namespace HTMLPurifier\Lexer;

use DOMDocument;
use DOMDocumentType;
use DOMException;
/**
 * Experimental HTML5-based parser using Jeroen van der Meer's PH5P library.
 * Occupies space in the HTML5 pseudo-namespace, which may cause conflicts.
 *
 * @note
 *    Recent changes to PHP's DOM extension have resulted in some fatal
 *    error conditions with the original version of PH5P. Pending changes,
 *    this lexer will punt to DirectLex if DOM throws an exception.
 */
class LexerPH5P extends LexerDOMLex
{
    /**
     * @param string $html
     * @param Config $config
     * @param Context $context
     * @return Token[]
     */
    public function tokenizeHTML(string html, <Config> config, <Context> context) -> array
    {
        var new_html, parser, doc, e, lexer, tokens;
    
        let new_html =  this->normalize(html, config, context);
        let new_html =  this->wrapHTML(new_html, config, context, false);
        try {
            let parser =  new HTML5(new_html);
            let doc =  parser->save();
        } catch DOMException, e {
            // Uh oh, it failed. Punt to DirectLex.
            let lexer =  new LexerDirectLex();
            context->register("PH5PError", e);
            // save the error, so we can detect it
            return lexer->tokenizeHTML(html, config, context);
        }
        let tokens =  [];
        this->tokenizeDOM(doc->getElementsByTagName("html")->item(0)->getElementsByTagName("body")->item(0), tokens, config);
        return tokens;
    }

}