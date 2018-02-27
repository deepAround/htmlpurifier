namespace HTMLPurifier\Strategy;

use HTMLPurifier\Generator;
use HTMLPurifier\Zipper;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
use HTMLPurifier\Exception;
/**
 * Takes tokens makes them well-formed (balance end tags, etc.)
 *
 * Specification of the armor attributes this strategy uses:
 *
 *      - MakeWellFormed_TagClosedError: This armor field is used to
 *        suppress tag closed errors for certain tokens [TagClosedSuppress],
 *        in particular, if a tag was generated automatically by HTML
 *        Purifier, we may rely on our infrastructure to close it for us
 *        and shouldn't report an error to the user [TagClosedAuto].
 */
class StrategyMakeWellFormed extends \HTMLPurifier\Strategy
{
    /**
     * Array stream of tokens being processed.
     * @type Token[]
     */
    protected tokens;
    /**
     * Current token.
     * @type Token
     */
    protected token;
    /**
     * Zipper managing the true state.
     * @type Zipper
     */
    protected zipper;
    /**
     * Current nesting of elements.
     * @type array
     */
    protected stack;
    /**
     * Injectors active in this stream processing.
     * @type Injector[]
     */
    protected injectors;
    /**
     * Current instance of Config.
     * @type Config
     */
    protected config;
    /**
     * Current instance of Context.
     * @type Context
     */
    protected context;
    /**
     * @param Token[] $tokens
     * @param Config $config
     * @param Context $context
     * @return Token[]
     * @throws Exception
     */
    public function execute(array tokens, <Config> config, <Context> context) -> array
    {
        var definition, generator, escape_invalid_tags, global_parent_allowed_elements, e, i, zipper, token, tmpListZipperToken, tmpArray40cd750bba9870f18aada2478b24840a, reprocess, stack, injectors, def_injectors, custom_injectors, injector, b, ix, error, rewind_offset, j, top_nesting, r, type, ok, old_token, parent, parent_def, parent_elements, autoclose, wrapname, wrapdef, elements, newtoken, carryover, autoclose_ok, ancestor, wrap_elements, new_token, element, tmpArray0a9ef1b2b0b3bb682c0727ecd160fbfe, current_parent, size, skipped_tags, c, replace;
    
        let definition =  config->getHTMLDefinition();
        // local variables
        let generator =  new Generator(config, context);
        let escape_invalid_tags =  config->get("Core.EscapeInvalidTags");
        // used for autoclose early abortion
        let global_parent_allowed_elements =  definition->info_parent_def->child->getAllowedElements(config);
        let e =  context->get("ErrorCollector", true);
        let i =  false;
        // injector index
        let tmpListZipperToken = Zipper::fromArray(tokens);
        let zipper = tmpListZipperToken[0];
        let token = tmpListZipperToken[1];
        if token === NULL {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        let reprocess =  false;
        // whether or not to reprocess the same token
        let stack =  [];
        // member variables
        let this->stack = stack;
        let this->tokens = tokens;
        let this->token = token;
        let this->zipper = zipper;
        let this->config = config;
        let this->context = context;
        // context variables
        context->register("CurrentNesting", stack);
        context->register("InputZipper", zipper);
        context->register("CurrentToken", token);
        // -- begin INJECTOR --
        let this->injectors =  [];
        let injectors =  config->getBatch("AutoFormat");
        let def_injectors =  definition->info_injector;
        let custom_injectors = injectors["Custom"];
        unset injectors["Custom"];
        
        // special case
        for injector, b in injectors {
            // XXX: Fix with a legitimate lookup table of enabled filters
            if strpos(injector, ".") !== false {
                continue;
            }
            let injector = "Injector_{injector}";
            if !(b) {
                continue;
            }
            let this->injectors[] = new {injector}();
        }
        for injector in def_injectors {
            // assumed to be objects
            let this->injectors[] = injector;
        }
        for injector in custom_injectors {
            if !(injector) {
                continue;
            }
            if is_string(injector) {
                let injector = "Injector_{injector}";
                let injector =  new {injector}();
            }
            let this->injectors[] = injector;
        }
        // give the injectors references to the definition and context
        // variables for performance reasons
        for ix, injector in this->injectors {
            let error =  injector->prepare(config, context);
            if !(error) {
                continue;
            }
            array_splice(this->injectors, ix, 1);
            // rm the injector
            trigger_error("Cannot enable {injector->name} injector because {error} is not allowed", E_USER_WARNING);
        }
        // -- end INJECTOR --
        // a note on reprocessing:
        //      In order to reduce code duplication, whenever some code needs
        //      to make HTML changes in order to make things "correct", the
        //      new HTML gets sent through the purifier, regardless of its
        //      status. This means that if we add a start token, because it
        //      was totally necessary, we don't have to update nesting; we just
        //      punt ($reprocess = true; continue;) and it does that for us.
        // isset is in loop because $tokens size changes during loop exec
        loop {
        
            // check for a rewind
            if is_int(i) {
                // possibility: disable rewinding if the current token has a
                // rewind set on it already. This would offer protection from
                // infinite loop, but might hinder some advanced rewinding.
                let rewind_offset =  this->injectors[i]->getRewindOffset();
                if is_int(rewind_offset) {
                    let j = 0;
                    for j in range(0, rewind_offset) {
                        if empty(zipper->front) {
                            break;
                        }
                        let token =  zipper->prev(token);
                        // indicate that other injectors should not process this token,
                        // but we need to reprocess it.  See Note [Injector skips]
                        unset token->skip[i];
                        
                        let token->rewind = i;
                        if token instanceof TokenStart {
                            array_pop(this->stack);
                        } elseif token instanceof TokenEnd {
                            let this->stack[] = token->start;
                        }
                    }
                }
                let i =  false;
            }
            // handle case of document end
            if token === NULL {
                // kill processing if stack is empty
                if empty(this->stack) {
                    break;
                }
                // peek
                let top_nesting =  array_pop(this->stack);
                let this->stack[] = top_nesting;
                // send error [TagClosedSuppress]
                if e && !(isset top_nesting->armor["MakeWellFormed_TagClosedError"]) {
                    e->send(E_NOTICE, "StrategyMakeWellFormed: Tag closed by document end", top_nesting);
                }
                // append, don't splice, since this is the end
                let token =  new TokenEnd(top_nesting->name);
                // punt!
                let reprocess =  true;
                continue;
            }
            //echo '<br>'; printZipper($zipper, $token);//printTokens($this->stack);
            //flush();
            // quick-check: if it's not a tag, no need to process
            if empty(token->is_tag) {
                if token instanceof TokenText {
                    for i, injector in this->injectors {
                        if isset token->skip[i] {
                            // See Note [Injector skips]
                            continue;
                        }
                        if token->rewind !== null && token->rewind !== i {
                            continue;
                        }
                        // XXX fuckup
                        let r = token;
                        injector->handleText(r);
                        let token =  this->processToken(r, i);
                        let reprocess =  true;
                        break;
                    }
                }
                // another possibility is a comment
                continue;
            }
            if isset definition->info[token->name] {
                let type =  definition->info[token->name]->child->type;
            } else {
                let type =  false;
            }
            // quick tag checks: anything that's *not* an end tag
            let ok =  false;
            if type === "empty" && token instanceof TokenStart {
                // claims to be a start tag but is empty
                let token =  new TokenEmpty(token->name, token->attr, token->line, token->col, token->armor);
                let ok =  true;
            } elseif type && type !== "empty" && token instanceof TokenEmpty {
                // claims to be empty but really is a start tag
                // NB: this assignment is required
                let old_token = token;
                let token =  new TokenEnd(token->name);
                let token =  this->insertBefore(new TokenStart(old_token->name, old_token->attr, old_token->line, old_token->col, old_token->armor));
                // punt (since we had to modify the input stream in a non-trivial way)
                let reprocess =  true;
                continue;
            } elseif token instanceof TokenEmpty {
                // real empty token
                let ok =  true;
            } elseif token instanceof TokenStart {
                // start tag
                // ...unless they also have to close their parent
                if !(empty(this->stack)) {
                    // Performance note: you might think that it's rather
                    // inefficient, recalculating the autoclose information
                    // for every tag that a token closes (since when we
                    // do an autoclose, we push a new token into the
                    // stream and then /process/ that, before
                    // re-processing this token.)  But this is
                    // necessary, because an injector can make an
                    // arbitrary transformations to the autoclosing
                    // tokens we introduce, so things may have changed
                    // in the meantime.  Also, doing the inefficient thing is
                    // "easy" to reason about (for certain perverse definitions
                    // of "easy")
                    let parent =  array_pop(this->stack);
                    let this->stack[] = parent;
                    let parent_def =  null;
                    let parent_elements =  null;
                    let autoclose =  false;
                    if isset definition->info[parent->name] {
                        let parent_def = definition->info[parent->name];
                        let parent_elements =  parent_def->child->getAllowedElements(config);
                        let autoclose =  !(isset parent_elements[token->name]);
                    }
                    if autoclose && definition->info[token->name]->wrap {
                        // Check if an element can be wrapped by another
                        // element to make it valid in a context (for
                        // example, <ul><ul> needs a <li> in between)
                        let wrapname =  definition->info[token->name]->wrap;
                        let wrapdef = definition->info[wrapname];
                        let elements =  wrapdef->child->getAllowedElements(config);
                        if isset elements[token->name] && isset parent_elements[wrapname] {
                            let newtoken =  new TokenStart(wrapname);
                            let token =  this->insertBefore(newtoken);
                            let reprocess =  true;
                            continue;
                        }
                    }
                    let carryover =  false;
                    if autoclose && parent_def->formatting {
                        let carryover =  true;
                    }
                    if autoclose {
                        // check if this autoclose is doomed to fail
                        // (this rechecks $parent, which his harmless)
                        let autoclose_ok =  isset global_parent_allowed_elements[token->name];
                        if !(autoclose_ok) {
                            for ancestor in this->stack {
                                let elements =  definition->info[ancestor->name]->child->getAllowedElements(config);
                                if isset elements[token->name] {
                                    let autoclose_ok =  true;
                                    break;
                                }
                                if definition->info[token->name]->wrap {
                                    let wrapname =  definition->info[token->name]->wrap;
                                    let wrapdef = definition->info[wrapname];
                                    let wrap_elements =  wrapdef->child->getAllowedElements(config);
                                    if isset wrap_elements[token->name] && isset elements[wrapname] {
                                        let autoclose_ok =  true;
                                        break;
                                    }
                                }
                            }
                        }
                        if autoclose_ok {
                            // errors need to be updated
                            let new_token =  new TokenEnd(parent->name);
                            let new_token->start = parent;
                            // [TagClosedSuppress]
                            if e && !(isset parent->armor["MakeWellFormed_TagClosedError"]) {
                                if !(carryover) {
                                    e->send(E_NOTICE, "StrategyMakeWellFormed: Tag auto closed", parent);
                                } else {
                                    e->send(E_NOTICE, "StrategyMakeWellFormed: Tag carryover", parent);
                                }
                            }
                            if carryover {
                                let element =  clone parent;
                                // [TagClosedAuto]
                                let element->armor["MakeWellFormed_TagClosedError"] = true;
                                let element->carryover =  true;
                                let tmpArray0a9ef1b2b0b3bb682c0727ecd160fbfe = [new_token, token, element];
                                let token =  this->processToken(tmpArray0a9ef1b2b0b3bb682c0727ecd160fbfe);
                            } else {
                                let token =  this->insertBefore(new_token);
                            }
                        } else {
                            let token =  this->remove();
                        }
                        let reprocess =  true;
                        continue;
                    }
                }
                let ok =  true;
            }
            if ok {
                for i, injector in this->injectors {
                    if isset token->skip[i] {
                        // See Note [Injector skips]
                        continue;
                    }
                    if token->rewind !== null && token->rewind !== i {
                        continue;
                    }
                    let r = token;
                    injector->handleElement(r);
                    let token =  this->processToken(r, i);
                    let reprocess =  true;
                    break;
                }
                if !(reprocess) {
                    // ah, nothing interesting happened; do normal processing
                    if token instanceof TokenStart {
                        let this->stack[] = token;
                    } elseif token instanceof TokenEnd {
                        throw new Exception("Improper handling of end tag in start code; possible error in MakeWellFormed");
                    }
                }
                continue;
            }
            // sanity check: we should be dealing with a closing tag
            if !(token instanceof TokenEnd) {
                throw new Exception("Unaccounted for tag token in input stream, bug in HTML Purifier");
            }
            // make sure that we have something open
            if empty(this->stack) {
                if escape_invalid_tags {
                    if e {
                        e->send(E_WARNING, "StrategyMakeWellFormed: Unnecessary end tag to text");
                    }
                    let token =  new TokenText(generator->generateFromToken(token));
                } else {
                    if e {
                        e->send(E_WARNING, "StrategyMakeWellFormed: Unnecessary end tag removed");
                    }
                    let token =  this->remove();
                }
                let reprocess =  true;
                continue;
            }
            // first, check for the simplest case: everything closes neatly.
            // Eventually, everything passes through here; if there are problems
            // we modify the input stream accordingly and then punt, so that
            // the tokens get processed again.
            let current_parent =  array_pop(this->stack);
            if current_parent->name == token->name {
                let token->start = current_parent;
                for i, injector in this->injectors {
                    if isset token->skip[i] {
                        // See Note [Injector skips]
                        continue;
                    }
                    if token->rewind !== null && token->rewind !== i {
                        continue;
                    }
                    let r = token;
                    injector->handleEnd(r);
                    let token =  this->processToken(r, i);
                    let this->stack[] = current_parent;
                    let reprocess =  true;
                    break;
                }
                continue;
            }
            // okay, so we're trying to close the wrong tag
            // undo the pop previous pop
            let this->stack[] = current_parent;
            // scroll back the entire nest, trying to find our tag.
            // (feature could be to specify how far you'd like to go)
            let size =  count(this->stack);
            // -2 because -1 is the last element, but we already checked that
            let skipped_tags =  false;
            let j =  size - 2;
            for j in range(size - 2, 0) {
                if this->stack[j]->name == token->name {
                    let skipped_tags =  array_slice(this->stack, j);
                    break;
                }
            }
            // we didn't find the tag, so remove
            if skipped_tags === false {
                if escape_invalid_tags {
                    if e {
                        e->send(E_WARNING, "StrategyMakeWellFormed: Stray end tag to text");
                    }
                    let token =  new TokenText(generator->generateFromToken(token));
                } else {
                    if e {
                        e->send(E_WARNING, "StrategyMakeWellFormed: Stray end tag removed");
                    }
                    let token =  this->remove();
                }
                let reprocess =  true;
                continue;
            }
            // do errors, in REVERSE $j order: a,b,c with </a></b></c>
            let c =  count(skipped_tags);
            if e {
                let j =  c - 1;
                for j in range(c - 1, 0) {
                    // notice we exclude $j == 0, i.e. the current ending tag, from
                    // the errors... [TagClosedSuppress]
                    if !(isset skipped_tags[j]->armor["MakeWellFormed_TagClosedError"]) {
                        e->send(E_NOTICE, "StrategyMakeWellFormed: Tag closed by element end", skipped_tags[j]);
                    }
                }
            }
            // insert tags, in FORWARD $j order: c,b,a with </a></b></c>
            let replace =  [token];
            let j = 1;
            for j in range(1, c) {
                // ...as well as from the insertions
                let new_token =  new TokenEnd(skipped_tags[j]->name);
                let new_token->start = skipped_tags[j];
                array_unshift(replace, new_token);
                if isset definition->info[new_token->name] && definition->info[new_token->name]->formatting {
                    // [TagClosedAuto]
                    let element =  clone skipped_tags[j];
                    let element->carryover =  true;
                    let element->armor["MakeWellFormed_TagClosedError"] = true;
                    let replace[] = element;
                }
            }
            let token =  this->processToken(replace);
            let reprocess =  true;
            continue;
        
            // only increment if we don't need to reprocess
             reprocess ? let reprocess =  false  : (let token =  zipper->next(token));
        }
        context->destroy("CurrentToken");
        context->destroy("CurrentNesting");
        context->destroy("InputZipper");
        unset this->injectors;
        unset this->stack;
        unset this->tokens;
        
        return zipper->toArray(token);
    }
    
    /**
     * Processes arbitrary token values for complicated substitution patterns.
     * In general:
     *
     * If $token is an array, it is a list of tokens to substitute for the
     * current token. These tokens then get individually processed. If there
     * is a leading integer in the list, that integer determines how many
     * tokens from the stream should be removed.
     *
     * If $token is a regular token, it is swapped with the current token.
     *
     * If $token is false, the current token is deleted.
     *
     * If $token is an integer, that number of tokens (with the first token
     * being the current one) will be deleted.
     *
     * @param Token|array|int|bool $token Token substitution value
     * @param Injector|int $injector Injector that performed the substitution; default is if
     *        this is not an injector related operation.
     * @throws Exception
     */
    protected function processToken(token, injector = -1)
    {
        var tmp, delete, old, r, tmpListOldR, oldskip, object;
    
        // Zend OpCache miscompiles $token = array($token), so
        // avoid this pattern.  See: https://github.com/ezyang/htmlpurifier/issues/108
        // normalize forms of token
        if is_object(token) {
            let tmp = token;
            let token =  [1, tmp];
        }
        if is_int(token) {
            let tmp = token;
            let token =  [tmp];
        }
        if token === false {
            let token =  [1];
        }
        if !(is_array(token)) {
            throw new Exception("Invalid token type from injector");
        }
        if !(is_int(token[0])) {
            array_unshift(token, 1);
        }
        if token[0] === 0 {
            throw new Exception("Deleting zero tokens is not valid");
        }
        // $token is now an array with the following form:
        // array(number nodes to delete, new node 1, new node 2, ...)
        let delete =  array_shift(token);
        let tmpListOldR = this->zipper->splice(this->token, delete, token);
        let old = tmpListOldR[0];
        let r = tmpListOldR[1];
        if injector > -1 {
            // See Note [Injector skips]
            // Determine appropriate skips.  Here's what the code does:
            //  *If* we deleted one or more tokens, copy the skips
            //  of those tokens into the skips of the new tokens (in $token).
            //  Also, mark the newly inserted tokens as having come from
            //  $injector.
            let oldskip =  isset old[0] ? old[0]->skip  : [];
            for object in token {
                let object->skip = oldskip;
                let object->skip[injector] = true;
            }
        }
        return r;
    }
    
    /**
     * Inserts a token before the current token. Cursor now points to
     * this token.  You must reprocess after this.
     * @param Token $token
     */
    protected function insertBefore(<Token> token)
    {
        var splice, tmpArray6f8815266ebded8ed193d742760dfd0a;
    
        // NB not $this->zipper->insertBefore(), due to positioning
        // differences
        let tmpArray6f8815266ebded8ed193d742760dfd0a = [token];
        let splice =  this->zipper->splice(this->token, 0, tmpArray6f8815266ebded8ed193d742760dfd0a);
        return splice[1];
    }
    
    /**
     * Removes current token. Cursor now points to new token occupying previously
     * occupied space.  You must reprocess after this.
     */
    protected function remove()
    {
        return this->zipper->delete();
    }

}