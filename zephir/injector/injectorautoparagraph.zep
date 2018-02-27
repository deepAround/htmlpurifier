namespace HTMLPurifier\Injector;

use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
/**
 * Injector that auto paragraphs text in the root node based on
 * double-spacing.
 * @todo Ensure all states are unit tested, including variations as well.
 * @todo Make a graph of the flow control for this Injector.
 */
class InjectorAutoParagraph extends Injector
{
    /**
     * @type string
     */
    public name = "AutoParagraph";
    /**
     * @type array
     */
    public needed = ["p"];
    /**
     * @return TokenStart
     */
    protected function _pStart() -> <TokenStart>
    {
        var par;
    
        let par =  new TokenStart("p");
        let par->armor["MakeWellFormed_TagClosedError"] = true;
        return par;
    }
    
    /**
     * @param TokenText $token
     */
    public function handleText(<TokenText> token) -> void
    {
        var text, i, nesting;
    
        let text =  token->data;
        // Does the current parent allow <p> tags?
        if this->allowsElement("p") {
            if empty(this->currentNesting) || strpos(text, "

") !== false {
                // Note that we have differing behavior when dealing with text
                // in the anonymous root node, or a node inside the document.
                // If the text as a double-newline, the treatment is the same;
                // if it doesn't, see the next if-block if you're in the document.
                let i = null;
                let nesting = null;
                ;
                if !(this->forwardUntilEndToken(i, current, nesting)) && token->is_whitespace {
                    echo "not allowed";
                } else {
                    if !(token->is_whitespace) || this->_isInline(current) {
                        // State 1.2: PAR1
                        //            ----
                        // State 1.3: PAR1\n\nPAR2
                        //            ------------
                        // State 1.4: <div>PAR1\n\nPAR2 (see State 2)
                        //                 ------------
                        let token =  [this->_pStart()];
                        this->_splitText(text, token);
                    } else {
                    }
                }
            } else {
                // State 2:   <div>PAR1... (similar to 1.4)
                //                 ----
                // We're in an element that allows paragraph tags, but we're not
                // sure if we're going to need them.
                if this->_pLookAhead() {
                    // State 2.1: <div>PAR1<b>PAR1\n\nPAR2
                    //                 ----
                    // Note: This will always be the first child, since any
                    // previous inline element would have triggered this very
                    // same routine, and found the double newline. One possible
                    // exception would be a comment.
                    let token =  [this->_pStart(), token];
                } else {
                }
            }
        } elseif !(empty(this->currentNesting)) && this->currentNesting[count(this->currentNesting) - 1]->name == "p" {
            // State 3.1: ...<p>PAR1
            //                  ----
            // State 3.2: ...<p>PAR1\n\nPAR2
            //                  ------------
            let token =  [];
            this->_splitText(text, token);
        } else {
        }
    }
    
    /**
     * @param Token $token
     */
    public function handleElement(<Token> token) -> void
    {
        var i;
    
        // We don't have to check if we're already in a <p> tag for block
        // tokens, because the tag would have been autoclosed by MakeWellFormed.
        if this->allowsElement("p") {
            if !(empty(this->currentNesting)) {
                if this->_isInline(token) {
                    // State 1: <div>...<b>
                    //                  ---
                    // Check if this token is adjacent to the parent token
                    // (seek backwards until token isn't whitespace)
                    let i =  null;
                    this->backward(i, prev);
                    if !(prev instanceof TokenStart) {
                        // Token wasn't adjacent
                        if prev instanceof TokenText && substr(prev->data, -2) === "

" {
                            // State 1.1.4: <div><p>PAR1</p>\n\n<b>
                            //                                  ---
                            // Quite frankly, this should be handled by splitText
                            let token =  [this->_pStart(), token];
                        } else {
                        }
                    } else {
                        // State 1.2.1: <div><b>
                        //                   ---
                        // Lookahead to see if <p> is needed.
                        if this->_pLookAhead() {
                            // State 1.3.1: <div><b>PAR1\n\nPAR2
                            //                   ---
                            let token =  [this->_pStart(), token];
                        } else {
                        }
                    }
                } else {
                }
            } else {
                if this->_isInline(token) {
                    // State 3.1: <b>
                    //            ---
                    // This is where the {p} tag is inserted, not reflected in
                    // inputTokens yet, however.
                    let token =  [this->_pStart(), token];
                } else {
                }
                let i =  null;
                if this->backward(i, prev) {
                    if !(prev instanceof TokenText) {
                        // State 3.1.1: ...</p>{p}<b>
                        //                        ---
                        // State 3.2.1: ...</p><div>
                        //                     -----
                        if !(is_array(token)) {
                            let token =  [token];
                        }
                        array_unshift(token, new TokenText("

"));
                    } else {
                    }
                }
            }
        } else {
        }
    }
    
    /**
     * Splits up a text in paragraph tokens and appends them
     * to the result stream that will replace the original
     * @param string $data String text data that will be processed
     *    into paragraphs
     * @param Token[] $result Reference to array of tokens that the
     *    tags will be appended onto
     */
    protected function _splitText(string data, array result)
    {
        var raw_paragraphs, paragraphs, needs_start, needs_end, c, i, par;
    
        let raw_paragraphs =  explode("

", data);
        let paragraphs =  [];
        // without empty paragraphs
        let needs_start =  false;
        let needs_end =  false;
        let c =  count(raw_paragraphs);
        if c == 1 {
            // There were no double-newlines, abort quickly. In theory this
            // should never happen.
            let result[] = new TokenText(data);
            return;
        }
        let i = 0;
        for i in range(0, c) {
            let par = raw_paragraphs[i];
            if trim(par) !== "" {
                let paragraphs[] = par;
            } else {
                if i == 0 {
                    // Double newline at the front
                    if empty(result) {
                        // The empty result indicates that the AutoParagraph
                        // injector did not add any start paragraph tokens.
                        // This means that we have been in a paragraph for
                        // a while, and the newline means we should start a new one.
                        let result[] = new TokenEnd("p");
                        let result[] = new TokenText("

");
                        // However, the start token should only be added if
                        // there is more processing to be done (i.e. there are
                        // real paragraphs in here). If there are none, the
                        // next start paragraph tag will be handled by the
                        // next call to the injector
                        let needs_start =  true;
                    } else {
                        // We just started a new paragraph!
                        // Reinstate a double-newline for presentation's sake, since
                        // it was in the source code.
                        array_unshift(result, new TokenText("

"));
                    }
                } elseif i + 1 == c {
                    // Double newline at the end
                    // There should be a trailing </p> when we're finally done.
                    let needs_end =  true;
                }
            }
        }
        // Check if this was just a giant blob of whitespace. Move this earlier,
        // perhaps?
        if empty(paragraphs) {
            return;
        }
        // Add the start tag indicated by \n\n at the beginning of $data
        if needs_start {
            let result[] =  this->_pStart();
        }
        // Append the paragraphs onto the result
        for par in paragraphs {
            let result[] = new TokenText(par);
            let result[] = new TokenEnd("p");
            let result[] = new TokenText("

");
            let result[] =  this->_pStart();
        }
        // Remove trailing start token; Injector will handle this later if
        // it was indeed needed. This prevents from needing to do a lookahead,
        // at the cost of a lookbehind later.
        array_pop(result);
        // If there is no need for an end tag, remove all of it and let
        // MakeWellFormed close it later.
        if !(needs_end) {
            array_pop(result);
            // removes \n\n
            array_pop(result);
        }
    }
    
    /**
     * Returns true if passed token is inline (and, ergo, allowed in
     * paragraph tags)
     * @param Token $token
     * @return bool
     */
    protected function _isInline(<Token> token) -> bool
    {
        return isset this->htmlDefinition->info["p"]->child->elements[token->name];
    }
    
    /**
     * Looks ahead in the token list and determines whether or not we need
     * to insert a <p> tag.
     * @return bool
     */
    protected function _pLookAhead() -> bool
    {
        var nesting, ok, i, result;
    
        if this->currentToken instanceof TokenStart {
            let nesting = 1;
        } else {
            let nesting = 0;
        }
        let ok =  false;
        let i =  null;
        while (this->forwardUntilEndToken(i, current, nesting)) {
            let result =  this->_checkNeedsP(current);
            if result !== null {
                let ok = result;
                break;
            }
        }
        return ok;
    }
    
    /**
     * Determines if a particular token requires an earlier inline token
     * to get a paragraph. This should be used with _forwardUntilEndToken
     * @param Token $current
     * @return bool
     */
    protected function _checkNeedsP(<Token> current) -> bool
    {
        if current instanceof TokenStart {
            if !(this->_isInline(current)) {
                // <div>PAR1<div>
                //      ----
                // Terminate early, since we hit a block element
                return false;
            }
        } elseif current instanceof TokenText {
            if strpos(current->data, "

") !== false {
                // <div>PAR1<b>PAR1\n\nPAR2
                //      ----
                return true;
            } else {
            }
        }
        return null;
    }

}