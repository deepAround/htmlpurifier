namespace HTMLPurifier\Lexer;

use HTMLPurifier\Exception;
use HTMLPurifier\Lexer;
use HTMLPurifier\Token\TokenComment;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
/**
 * Our in-house implementation of a parser.
 *
 * A pure PHP parser, DirectLex has absolutely no dependencies, making
 * it a reasonably good default for PHP4.  Written with efficiency in mind,
 * it can be four times faster than LexerPEARSax3, although it
 * pales in comparison to LexerDOMLex.
 *
 * @todo Reread XML spec and document differences.
 */
class LexerDirectLex extends Lexer
{
    /**
     * @type bool
     */
    public tracksLineNumbers = true;
    /**
     * Whitespace characters for str(c)spn.
     * @type string
     */
    protected _whitespace = " 	
";
    /**
     * Callback function for script CDATA fudge
     * @param array $matches, in form of array(opening tag, contents, closing tag)
     * @return string
     */
    protected function scriptCallback(matches) -> string
    {
        return matches[1] . htmlspecialchars(matches[2], ENT_COMPAT, "UTF-8") . matches[3];
    }
    
    /**
     * @param String $html
     * @param Config $config
     * @param Context $context
     * @return array|Token[]
     */
    public function tokenizeHTML(string html, <Config> config, <Context> context)
    {
        var tmpArray0583311c85df6016ea24c5b96976d69e, cursor, inside_tag, myArray, maintain_line_numbers, current_line, current_col, length, nl, synchronize_interval, e, loops, rcursor, nl_pos, position_next_lt, position_next_gt, token, strlen_segment, segment, position_comment_end, end, is_end_tag, type, is_self_closing, position_first_space, attribute_string, attr;
    
        // special normalization for script tags without any armor
        // our "armor" heurstic is a < sign any number of whitespaces after
        // the first script tag
        if config->get("HTML.Trusted") {
            let tmpArray0583311c85df6016ea24c5b96976d69e = [this, "scriptCallback"];
            let html =  preg_replace_callback("#(<script[^>]*>)(\\s*[^<].+?)(</script>)#si", tmpArray0583311c85df6016ea24c5b96976d69e, html);
        }
        let html =  this->normalize(html, config, context);
        let cursor = 0;
        // our location in the text
        let inside_tag =  false;
        // whether or not we're parsing the inside of a tag
        let myArray =  [];
        // result array
        // This is also treated to mean maintain *column* numbers too
        let maintain_line_numbers =  config->get("Core.MaintainLineNumbers");
        if maintain_line_numbers === null {
            // automatically determine line numbering by checking
            // if error collection is on
            let maintain_line_numbers =  config->get("Core.CollectErrors");
        }
        if maintain_line_numbers {
            let current_line = 1;
            let current_col = 0;
            let length =  strlen(html);
        } else {
            let current_line =  false;
            let current_col =  false;
            let length =  false;
        }
        context->register("CurrentLine", current_line);
        context->register("CurrentCol", current_col);
        let nl = "
";
        // how often to manually recalculate. This will ALWAYS be right,
        // but it's pretty wasteful. Set to 0 to turn off
        let synchronize_interval =  config->get("Core.DirectLexLineNumberSyncInterval");
        let e =  false;
        if config->get("Core.CollectErrors") {
            let e = context->get("ErrorCollector");
        }
        // for testing synchronization
        let loops = 0;
        let loops++;
        while (loops) {
            // $cursor is either at the start of a token, or inside of
            // a tag (i.e. there was a < immediately before it), as indicated
            // by $inside_tag
            if maintain_line_numbers {
                // $rcursor, however, is always at the start of a token.
                let rcursor =  cursor - (int) inside_tag;
                // Column number is cheap, so we calculate it every round.
                // We're interested at the *end* of the newline string, so
                // we need to add strlen($nl) == 1 to $nl_pos before subtracting it
                // from our "rcursor" position.
                let nl_pos =  strrpos(html, nl, rcursor - length);
                let current_col =  rcursor - ( is_bool(nl_pos) ? 0  : nl_pos + 1);
                // recalculate lines
                if synchronize_interval && cursor > 0 && loops % synchronize_interval === 0 {
                    // time to synchronize!
                    let current_line =  1 + this->substrCount(html, nl, 0, cursor);
                }
            }
            let position_next_lt =  strpos(html, "<", cursor);
            let position_next_gt =  strpos(html, ">", cursor);
            // triggers on "<b>asdf</b>" but not "asdf <b></b>"
            // special case to set up context
            if position_next_lt === cursor {
                let inside_tag =  true;
                let cursor++;
            }
            if !(inside_tag) && position_next_lt !== false {
                // We are not inside tag and there still is another tag to parse
                let token =  new TokenText(this->parseText(substr(html, cursor, position_next_lt - cursor), config));
                if maintain_line_numbers {
                    token->rawPosition(current_line, current_col);
                    let current_line += this->substrCount(html, nl, cursor, position_next_lt - cursor);
                }
                let myArray[] = token;
                let cursor =  position_next_lt + 1;
                let inside_tag =  true;
                continue;
            } elseif !(inside_tag) {
                // We are not inside tag but there are no more tags
                // If we're already at the end, break
                if cursor === strlen(html) {
                    break;
                }
                // Create Text of rest of string
                let token =  new TokenText(this->parseText(substr(html, cursor), config));
                if maintain_line_numbers {
                    token->rawPosition(current_line, current_col);
                }
                let myArray[] = token;
                break;
            } elseif inside_tag && position_next_gt !== false {
                // We are in tag and it is well formed
                // Grab the internals of the tag
                let strlen_segment =  position_next_gt - cursor;
                if strlen_segment < 1 {
                    // there's nothing to process!
                    let token =  new TokenText("<");
                    let cursor++;
                    continue;
                }
                let segment =  substr(html, cursor, strlen_segment);
                if segment === false {
                    // somehow, we attempted to access beyond the end of
                    // the string, defense-in-depth, reported by Nate Abele
                    break;
                }
                // Check if it's a comment
                if substr(segment, 0, 3) === "!--" {
                    // re-determine segment length, looking for -->
                    let position_comment_end =  strpos(html, "-->", cursor);
                    if position_comment_end === false {
                        // uh oh, we have a comment that extends to
                        // infinity. Can't be helped: set comment
                        // end position to end of string
                        if e {
                            e->send(E_WARNING, "Lexer: Unclosed comment");
                        }
                        let position_comment_end =  strlen(html);
                        let end =  true;
                    } else {
                        let end =  false;
                    }
                    let strlen_segment =  position_comment_end - cursor;
                    let segment =  substr(html, cursor, strlen_segment);
                    let token =  new TokenComment(substr(segment, 3, strlen_segment - 3));
                    if maintain_line_numbers {
                        token->rawPosition(current_line, current_col);
                        let current_line += this->substrCount(html, nl, cursor, strlen_segment);
                    }
                    let myArray[] = token;
                    let cursor =  end ? position_comment_end  : position_comment_end + 3;
                    let inside_tag =  false;
                    continue;
                }
                // Check if it's an end tag
                let is_end_tag =  strpos(segment, "/") === 0;
                if is_end_tag {
                    let type =  substr(segment, 1);
                    let token =  new TokenEnd(type);
                    if maintain_line_numbers {
                        token->rawPosition(current_line, current_col);
                        let current_line += this->substrCount(html, nl, cursor, position_next_gt - cursor);
                    }
                    let myArray[] = token;
                    let inside_tag =  false;
                    let cursor =  position_next_gt + 1;
                    continue;
                }
                // Check leading character is alnum, if not, we may
                // have accidently grabbed an emoticon. Translate into
                // text and go our merry way
                if !(ctype_alpha(segment[0])) {
                    // XML:  $segment[0] !== '_' && $segment[0] !== ':'
                    if e {
                        e->send(E_NOTICE, "Lexer: Unescaped lt");
                    }
                    let token =  new TokenText("<");
                    if maintain_line_numbers {
                        token->rawPosition(current_line, current_col);
                        let current_line += this->substrCount(html, nl, cursor, position_next_gt - cursor);
                    }
                    let myArray[] = token;
                    let inside_tag =  false;
                    continue;
                }
                // Check if it is explicitly self closing, if so, remove
                // trailing slash. Remember, we could have a tag like <br>, so
                // any later token processing scripts must convert improperly
                // classified EmptyTags from StartTags.
                let is_self_closing =  strrpos(segment, "/") === strlen_segment - 1;
                if is_self_closing {
                    let strlen_segment--;
                    let segment =  substr(segment, 0, strlen_segment);
                }
                // Check if there are any attributes
                let position_first_space =  strcspn(segment, this->_whitespace);
                if position_first_space >= strlen_segment {
                    if is_self_closing {
                        let token =  new TokenEmpty(segment);
                    } else {
                        let token =  new TokenStart(segment);
                    }
                    if maintain_line_numbers {
                        token->rawPosition(current_line, current_col);
                        let current_line += this->substrCount(html, nl, cursor, position_next_gt - cursor);
                    }
                    let myArray[] = token;
                    let inside_tag =  false;
                    let cursor =  position_next_gt + 1;
                    continue;
                }
                // Grab out all the data
                let type =  substr(segment, 0, position_first_space);
                let attribute_string =  trim(substr(segment, position_first_space));
                if attribute_string {
                    let attr =  this->parseAttributeString(attribute_string, config, context);
                } else {
                    let attr =  [];
                }
                if is_self_closing {
                    let token =  new TokenEmpty(type, attr);
                } else {
                    let token =  new TokenStart(type, attr);
                }
                if maintain_line_numbers {
                    token->rawPosition(current_line, current_col);
                    let current_line += this->substrCount(html, nl, cursor, position_next_gt - cursor);
                }
                let myArray[] = token;
                let cursor =  position_next_gt + 1;
                let inside_tag =  false;
                continue;
            } else {
                // inside tag, but there's no ending > sign
                if e {
                    e->send(E_WARNING, "Lexer: Missing gt");
                }
                let token =  new TokenText("<" . this->parseText(substr(html, cursor), config));
                if maintain_line_numbers {
                    token->rawPosition(current_line, current_col);
                }
                // no cursor scroll? Hmm...
                let myArray[] = token;
                break;
            }
            break;
        let loops++;
        }
        context->destroy("CurrentLine");
        context->destroy("CurrentCol");
        return myArray;
    }
    
    /**
     * PHP 5.0.x compatible substr_count that implements offset and length
     * @param string $haystack
     * @param string $needle
     * @param int $offset
     * @param int $length
     * @return int
     */
    protected function substrCount(string haystack, string needle, int offset, int length) -> int
    {
        var oldVersion;
    
        
        if oldVersion === null {
            let oldVersion =  version_compare(PHP_VERSION, "5.1", "<");
        }
        if oldVersion {
            let haystack =  substr(haystack, offset, length);
            return substr_count(haystack, needle);
        } else {
            return substr_count(haystack, needle, offset, length);
        }
    }
    
    /**
     * Takes the inside of an HTML tag and makes an assoc array of attributes.
     *
     * @param string $string Inside of tag excluding name.
     * @param Config $config
     * @param Context $context
     * @return array Assoc array of attributes.
     */
    public function parseAttributeString(string stringg, <Config> config, <Context> context) -> array
    {
        var tmpArray40cd750bba9870f18aada2478b24840a, e, num_equal, has_space, tmpArraycd37bba5b1f2bb3e466c5eb790e0c919, key, quoted_value, tmpListKeyQuoted_value, tmpArraye4f310d7922cfa235ac801d683431a5d, first_char, last_char, same_quote, open_quote, value, tmpArray6c0eebc9f0a70a0e8bff6c3b3e8a6da0, myArray, cursor, size, old_cursor, key_begin, key_end, char, value_begin, value_end;
    
        let stringg =  (string) stringg;
        // quick typecast
        if stringg == "" {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        // no attributes
        let e =  false;
        if config->get("Core.CollectErrors") {
            let e = context->get("ErrorCollector");
        }
        // let's see if we can abort as quickly as possible
        // one equal sign, no spaces => one attribute
        let num_equal =  substr_count(stringg, "=");
        let has_space =  strpos(stringg, " ");
        if num_equal === 0 && !(has_space) {
            // bool attribute
            let tmpArraycd37bba5b1f2bb3e466c5eb790e0c919 = [stringg : stringg];
            return tmpArraycd37bba5b1f2bb3e466c5eb790e0c919;
        } elseif num_equal === 1 && !(has_space) {
            // only one attribute
            let tmpListKeyQuoted_value = explode("=", stringg);
            let key = tmpListKeyQuoted_value[0];
            let quoted_value = tmpListKeyQuoted_value[1];
            let quoted_value =  trim(quoted_value);
            if !(key) {
                if e {
                    e->send(E_ERROR, "Lexer: Missing attribute key");
                }
                let tmpArray40cd750bba9870f18aada2478b24840a = [];
                return tmpArray40cd750bba9870f18aada2478b24840a;
            }
            if !(quoted_value) {
                let tmpArraye4f310d7922cfa235ac801d683431a5d = [key : ""];
                return tmpArraye4f310d7922cfa235ac801d683431a5d;
            }
            let first_char =  quoted_value[0];
            let last_char =  quoted_value[strlen(quoted_value) - 1];
            let same_quote =  first_char == last_char;
            let open_quote =  first_char == "\"" || first_char == "'";
            if same_quote && open_quote {
                // well behaved
                let value =  substr(quoted_value, 1, strlen(quoted_value) - 2);
            } else {
                // not well behaved
                if open_quote {
                    if e {
                        e->send(E_ERROR, "Lexer: Missing end quote");
                    }
                    let value =  substr(quoted_value, 1);
                } else {
                    let value = quoted_value;
                }
            }
            if value === false {
                let value = "";
            }
            let tmpArray6c0eebc9f0a70a0e8bff6c3b3e8a6da0 = [key : this->parseAttr(value, config)];
            return tmpArray6c0eebc9f0a70a0e8bff6c3b3e8a6da0;
        }
        // setup loop environment
        let myArray =  [];
        // return assoc array of attributes
        let cursor = 0;
        // current position in string (moves forward)
        let size =  strlen(stringg);
        // size of the string (stays the same)
        // if we have unquoted attributes, the parser expects a terminating
        // space, so let's guarantee that there's always a terminating space.
        let stringg .= " ";
        let old_cursor =  -1;
        while (cursor < size) {
            if old_cursor >= cursor {
                throw new Exception("Infinite loop detected");
            }
            let old_cursor = cursor;
            let cursor += let value =  strspn(stringg, this->_whitespace, cursor);
            // grab the key
            let key_begin = cursor;
            //we're currently at the start of the key
            // scroll past all characters that are the key (not whitespace or =)
            let cursor += strcspn(stringg, this->_whitespace . "=", cursor);
            let key_end = cursor;
            // now at the end of the key
            let key =  substr(stringg, key_begin, key_end - key_begin);
            if !(key) {
                if e {
                    e->send(E_ERROR, "Lexer: Missing attribute key");
                }
                let cursor += 1 + strcspn(stringg, this->_whitespace, cursor + 1);
                // prevent infinite loop
                continue;
            }
            // scroll past all whitespace
            let cursor += strspn(stringg, this->_whitespace, cursor);
            if cursor >= size {
                let myArray[key] = key;
                break;
            }
            // if the next character is an equal sign, we've got a regular
            // pair, otherwise, it's a bool attribute
            let first_char =  stringg[cursor];
            if first_char == "=" {
                // key="value"
                let cursor++;
                let cursor += strspn(stringg, this->_whitespace, cursor);
                if cursor === false {
                    let myArray[key] = "";
                    break;
                }
                // we might be in front of a quote right now
                let char =  stringg[cursor];
                if char == "\"" || char == "'" {
                    // it's quoted, end bound is $char
                    let cursor++;
                    let value_begin = cursor;
                    let cursor =  strpos(stringg, char, cursor);
                    let value_end = cursor;
                } else {
                    // it's not quoted, end bound is whitespace
                    let value_begin = cursor;
                    let cursor += strcspn(stringg, this->_whitespace, cursor);
                    let value_end = cursor;
                }
                // we reached a premature end
                if cursor === false {
                    let cursor = size;
                    let value_end = cursor;
                }
                let value =  substr(stringg, value_begin, value_end - value_begin);
                if value === false {
                    let value = "";
                }
                let myArray[key] =  this->parseAttr(value, config);
                let cursor++;
            } else {
                // boolattr
                if key !== "" {
                    let myArray[key] = key;
                } else {
                    // purely theoretical
                    if e {
                        e->send(E_ERROR, "Lexer: Missing attribute key");
                    }
                }
            }
        }
        return myArray;
    }

}