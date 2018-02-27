namespace HTMLPurifier;

use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
/**
 * Injects tokens into the document while parsing for well-formedness.
 * This enables "formatter-like" functionality such as auto-paragraphing,
 * smiley-ification and linkification to take place.
 *
 * A note on how handlers create changes; this is done by assigning a new
 * value to the $token reference. These values can take a variety of forms and
 * are best described Strategy_MakeWellFormed->processToken()
 * documentation.
 *
 * @todo Allow injectors to request a re-run on their output. This
 *       would help if an operation is recursive.
 */
abstract class Injector
{
    /**
     * Advisory name of injector, this is for friendly error messages.
     * @type string
     */
    public name;
    /**
     * @type HTMLDefinition
     */
    protected htmlDefinition;
    /**
     * Reference to CurrentNesting variable in Context. This is an array
     * list of tokens that we are currently "inside"
     * @type array
     */
    protected currentNesting;
    /**
     * Reference to current token.
     * @type Token
     */
    protected currentToken;
    /**
     * Reference to InputZipper variable in Context.
     * @type Zipper
     */
    protected inputZipper;
    /**
     * Array of elements and attributes this injector creates and therefore
     * need to be allowed by the definition. Takes form of
     * array('element' => array('attr', 'attr2'), 'element2')
     * @type array
     */
    public needed = [];
    /**
     * Number of elements to rewind backwards (relative).
     * @type bool|int
     */
    protected rewindOffset = false;
    /**
     * Rewind to a spot to re-perform processing. This is useful if you
     * deleted a node, and now need to see if this change affected any
     * earlier nodes. Rewinding does not affect other injectors, and can
     * result in infinite loops if not used carefully.
     * @param bool|int $offset
     * @warning HTML Purifier will prevent you from fast-forwarding with this
     *          function.
     */
    public function rewindOffset(offset) -> void
    {
        let this->rewindOffset = offset;
    }
    
    /**
     * Retrieves rewind offset, and then unsets it.
     * @return bool|int
     */
    public function getRewindOffset()
    {
        var r;
    
        let r =  this->rewindOffset;
        let this->rewindOffset =  false;
        return r;
    }
    
    /**
     * Prepares the injector by giving it the config and context objects:
     * this allows references to important variables to be made within
     * the injector. This function also checks if the HTML environment
     * will work with the Injector (see checkNeeded()).
     * @param Config $config
     * @param Context $context
     * @return bool|string Boolean false if success, string of missing needed element/attribute if failure
     */
    public function prepare(<Config> config, <Context> context)
    {
        var result;
    
        let this->htmlDefinition =  config->getHTMLDefinition();
        // Even though this might fail, some unit tests ignore this and
        // still test checkNeeded, so be careful. Maybe get rid of that
        // dependency.
        let result =  this->checkNeeded(config);
        if result !== false {
            return result;
        }
        let this->currentNesting = context->get("CurrentNesting");
        let this->currentToken = context->get("CurrentToken");
        let this->inputZipper = context->get("InputZipper");
        return false;
    }
    
    /**
     * This function checks if the HTML environment
     * will work with the Injector: if p tags are not allowed, the
     * Auto-Paragraphing injector should not be enabled.
     * @param Config $config
     * @return bool|string Boolean false if success, string of missing needed element/attribute if failure
     */
    public function checkNeeded(<Config> config)
    {
        var def, element, attributes, name;
    
        let def =  config->getHTMLDefinition();
        for element, attributes in this->needed {
            if is_int(element) {
                let element = attributes;
            }
            if !(isset def->info[element]) {
                return element;
            }
            if !(is_array(attributes)) {
                continue;
            }
            for name in attributes {
                if !(isset def->info[element]->attr[name]) {
                    return "{element}.{name}";
                }
            }
        }
        return false;
    }
    
    /**
     * Tests if the context node allows a certain element
     * @param string $name Name of element to test for
     * @return bool True if element is allowed, false if it is not
     */
    public function allowsElement(string name) -> bool
    {
        var parent_token, parent, i, node, def;
    
        if !(empty(this->currentNesting)) {
            let parent_token =  array_pop(this->currentNesting);
            let this->currentNesting[] = parent_token;
            let parent = this->htmlDefinition->info[parent_token->name];
        } else {
            let parent =  this->htmlDefinition->info_parent_def;
        }
        if !(isset parent->child->elements[name]) || isset parent->excludes[name] {
            return false;
        }
        // check for exclusion
        if !(empty(this->currentNesting)) {
            let i =  count(this->currentNesting) - 2;
            for i in range(count(this->currentNesting) - 2, 0) {
                let node = this->currentNesting[i];
                let def = this->htmlDefinition->info[node->name];
                if isset def->excludes[name] {
                    return false;
                }
            }
        }
        return true;
    }
    
    /**
     * Iterator function, which starts with the next token and continues until
     * you reach the end of the input tokens.
     * @warning Please prevent previous references from interfering with this
     *          functions by setting $i = null beforehand!
     * @param int $i Current integer index variable for inputTokens
     * @param Token $current Current token variable.
     *          Do NOT use $token, as that variable is also a reference
     * @return bool
     */
    protected function forward(int i, <Token> current) -> bool
    {
        if i === null {
            let i =  count(this->inputZipper->back) - 1;
        } else {
            let i--;
        }
        if i < 0 {
            return false;
        }
        let current = this->inputZipper->back[i];
        return true;
    }
    
    /**
     * Similar to _forward, but accepts a third parameter $nesting (which
     * should be initialized at 0) and stops when we hit the end tag
     * for the node $this->inputIndex starts in.
     * @param int $i Current integer index variable for inputTokens
     * @param Token $current Current token variable.
     *          Do NOT use $token, as that variable is also a reference
     * @param int $nesting
     * @return bool
     */
    protected function forwardUntilEndToken(int i, <Token> current, int nesting) -> bool
    {
        var result;
    
        let result =  this->forward(i, current);
        if !(result) {
            return false;
        }
        if nesting === null {
            let nesting = 0;
        }
        if current instanceof TokenStart {
            let nesting++;
        } elseif current instanceof TokenEnd {
            if nesting <= 0 {
                return false;
            }
            let nesting--;
        }
        return true;
    }
    
    /**
     * Iterator function, starts with the previous token and continues until
     * you reach the beginning of input tokens.
     * @warning Please prevent previous references from interfering with this
     *          functions by setting $i = null beforehand!
     * @param int $i Current integer index variable for inputTokens
     * @param Token $current Current token variable.
     *          Do NOT use $token, as that variable is also a reference
     * @return bool
     */
    protected function backward(int i, <Token> current) -> bool
    {
        if i === null {
            let i =  count(this->inputZipper->front) - 1;
        } else {
            let i--;
        }
        if i < 0 {
            return false;
        }
        let current = this->inputZipper->front[i];
        return true;
    }
    
    /**
     * Handler that is called when a text token is processed
     */
    public function handleText(token) -> void
    {
    }
    
    /**
     * Handler that is called when a start or empty token is processed
     */
    public function handleElement(token) -> void
    {
    }
    
    /**
     * Handler that is called when an end token is processed
     */
    public function handleEnd(token) -> void
    {
        this->notifyEnd(token);
    }
    
    /**
     * Notifier that is called when an end token is processed
     * @param Token $token Current token variable.
     * @note This differs from handlers in that the token is read-only
     * @deprecated
     */
    public function notifyEnd(<Token> token) -> void
    {
    }

}