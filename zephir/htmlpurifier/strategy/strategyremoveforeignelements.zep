namespace HTMLPurifier\Strategy;

use HTMLPurifier\AttrValidator;
use HTMLPurifier\Generator;
use HTMLPurifier\Token\TokenComment;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
/**
 * Removes all unrecognized tags from the list of tokens.
 *
 * This strategy iterates through all the tokens and removes unrecognized
 * tokens. If a token is not recognized but a TagTransform is defined for
 * that element, the element will be transformed accordingly.
 */
class StrategyRemoveForeignElements extends \HTMLPurifier\Strategy
{
    /**
     * @param Token[] $tokens
     * @param Config $config
     * @param Context $context
     * @return array|Token[]
     */
    public function execute(array tokens, <Config> config, <Context> context)
    {
        var definition, generator, result, escape_invalid_tags, remove_invalid_img, trusted, comment_lookup, comment_regexp, check_comments, remove_script_contents, hidden_elements, attr_validator, remove_until, textify_comments, token, e, original_name, ok, name, data, trailing_hyphen, found_double_hyphen;
    
        let definition =  config->getHTMLDefinition();
        let generator =  new Generator(config, context);
        let result =  [];
        let escape_invalid_tags =  config->get("Core.EscapeInvalidTags");
        let remove_invalid_img =  config->get("Core.RemoveInvalidImg");
        // currently only used to determine if comments should be kept
        let trusted =  config->get("HTML.Trusted");
        let comment_lookup =  config->get("HTML.AllowedComments");
        let comment_regexp =  config->get("HTML.AllowedCommentsRegexp");
        let check_comments =  comment_lookup !== [] || comment_regexp !== null;
        let remove_script_contents =  config->get("Core.RemoveScriptContents");
        let hidden_elements =  config->get("Core.HiddenElements");
        // remove script contents compatibility
        if remove_script_contents === true {
            let hidden_elements["script"] = true;
        } elseif remove_script_contents === false && isset hidden_elements["script"] {
            unset hidden_elements["script"];
        
        }
        let attr_validator =  new AttrValidator();
        // removes tokens until it reaches a closing tag with its value
        let remove_until =  false;
        // converts comments into text tokens when this is equal to a tag name
        let textify_comments =  false;
        let token =  false;
        context->register("CurrentToken", token);
        let e =  false;
        if config->get("Core.CollectErrors") {
            let e = context->get("ErrorCollector");
        }
        for token in tokens {
            if remove_until {
                if empty(token->is_tag) || token->name !== remove_until {
                    continue;
                }
            }
            if !(empty(token->is_tag)) {
                // DEFINITION CALL
                // before any processing, try to transform the element
                if isset definition->info_tag_transform[token->name] {
                    let original_name =  token->name;
                    // there is a transformation for this tag
                    // DEFINITION CALL
                    let token =  definition->info_tag_transform[token->name]->transform(token, config, context);
                    if e {
                        e->send(E_NOTICE, "StrategyRemoveForeignElements: Tag transform", original_name);
                    }
                }
                if isset definition->info[token->name] {
                    // mostly everything's good, but
                    // we need to make sure required attributes are in order
                    if (token instanceof TokenStart || token instanceof TokenEmpty) && definition->info[token->name]->required_attr && (token->name != "img" || remove_invalid_img) {
                        attr_validator->validateToken(token, config, context);
                        let ok =  true;
                        for name in definition->info[token->name]->required_attr {
                            if !(isset token->attr[name]) {
                                let ok =  false;
                                break;
                            }
                        }
                        if !(ok) {
                            if e {
                                e->send(E_ERROR, "StrategyRemoveForeignElements: Missing required attribute", name);
                            }
                            continue;
                        }
                        let token->armor["ValidateAttributes"] = true;
                    }
                    if isset hidden_elements[token->name] && token instanceof TokenStart {
                        let textify_comments =  token->name;
                    } elseif token->name === textify_comments && token instanceof TokenEnd {
                        let textify_comments =  false;
                    }
                } elseif escape_invalid_tags {
                    // invalid tag, generate HTML representation and insert in
                    if e {
                        e->send(E_WARNING, "StrategyRemoveForeignElements: Foreign element to text");
                    }
                    let token =  new TokenText(generator->generateFromToken(token));
                } else {
                    // check if we need to destroy all of the tag's children
                    // CAN BE GENERICIZED
                    if isset hidden_elements[token->name] {
                        if token instanceof TokenStart {
                            let remove_until =  token->name;
                        } elseif token instanceof TokenEmpty {
                        } else {
                            let remove_until =  false;
                        }
                        if e {
                            e->send(E_ERROR, "StrategyRemoveForeignElements: Foreign meta element removed");
                        }
                    } else {
                        if e {
                            e->send(E_ERROR, "StrategyRemoveForeignElements: Foreign element removed");
                        }
                    }
                    continue;
                }
            } elseif token instanceof TokenComment {
                // textify comments in script tags when they are allowed
                if textify_comments !== false {
                    let data =  token->data;
                    let token =  new TokenText(data);
                } elseif trusted || check_comments {
                    // always cleanup comments
                    let trailing_hyphen =  false;
                    if e {
                        // perform check whether or not there's a trailing hyphen
                        if substr(token->data, -1) == "-" {
                            let trailing_hyphen =  true;
                        }
                    }
                    let token->data =  rtrim(token->data, "-");
                    let found_double_hyphen =  false;
                    while (strpos(token->data, "--") !== false) {
                        let found_double_hyphen =  true;
                        let token->data =  str_replace("--", "-", token->data);
                    }
                    if trusted || !(empty(comment_lookup[trim(token->data)])) || comment_regexp !== null && preg_match(comment_regexp, trim(token->data)) {
                        // OK good
                        if e {
                            if trailing_hyphen {
                                e->send(E_NOTICE, "StrategyRemoveForeignElements: Trailing hyphen in comment removed");
                            }
                            if found_double_hyphen {
                                e->send(E_NOTICE, "StrategyRemoveForeignElements: Hyphens in comment collapsed");
                            }
                        }
                    } else {
                        if e {
                            e->send(E_NOTICE, "StrategyRemoveForeignElements: Comment removed");
                        }
                        continue;
                    }
                } else {
                    // strip comments
                    if e {
                        e->send(E_NOTICE, "StrategyRemoveForeignElements: Comment removed");
                    }
                    continue;
                }
            } elseif token instanceof TokenText {
            } else {
                continue;
            }
            let result[] = token;
        }
        if remove_until && e {
            // we removed tokens until the end, throw error
            e->send(E_ERROR, "StrategyRemoveForeignElements: Token removed to end", remove_until);
        }
        context->destroy("CurrentToken");
        return result;
    }

}