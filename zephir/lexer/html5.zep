namespace HTMLPurifier\Lexer;

/*
Copyright 2007 Jeroen van der Meer <http://jero.net/>
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
class HTML5
{
    protected data;
    protected char;
    protected eof;
    protected state;
    protected tree;
    protected token;
    protected content_model;
    protected escape = false;
    protected entities = ["AElig;", "AElig", "AMP;", "AMP", "Aacute;", "Aacute", "Acirc;", "Acirc", "Agrave;", "Agrave", "Alpha;", "Aring;", "Aring", "Atilde;", "Atilde", "Auml;", "Auml", "Beta;", "COPY;", "COPY", "Ccedil;", "Ccedil", "Chi;", "Dagger;", "Delta;", "ETH;", "ETH", "Eacute;", "Eacute", "Ecirc;", "Ecirc", "Egrave;", "Egrave", "Epsilon;", "Eta;", "Euml;", "Euml", "GT;", "GT", "Gamma;", "Iacute;", "Iacute", "Icirc;", "Icirc", "Igrave;", "Igrave", "Iota;", "Iuml;", "Iuml", "Kappa;", "LT;", "LT", "Lambda;", "Mu;", "Ntilde;", "Ntilde", "Nu;", "OElig;", "Oacute;", "Oacute", "Ocirc;", "Ocirc", "Ograve;", "Ograve", "Omega;", "Omicron;", "Oslash;", "Oslash", "Otilde;", "Otilde", "Ouml;", "Ouml", "Phi;", "Pi;", "Prime;", "Psi;", "QUOT;", "QUOT", "REG;", "REG", "Rho;", "Scaron;", "Sigma;", "THORN;", "THORN", "TRADE;", "Tau;", "Theta;", "Uacute;", "Uacute", "Ucirc;", "Ucirc", "Ugrave;", "Ugrave", "Upsilon;", "Uuml;", "Uuml", "Xi;", "Yacute;", "Yacute", "Yuml;", "Zeta;", "aacute;", "aacute", "acirc;", "acirc", "acute;", "acute", "aelig;", "aelig", "agrave;", "agrave", "alefsym;", "alpha;", "amp;", "amp", "and;", "ang;", "apos;", "aring;", "aring", "asymp;", "atilde;", "atilde", "auml;", "auml", "bdquo;", "beta;", "brvbar;", "brvbar", "bull;", "cap;", "ccedil;", "ccedil", "cedil;", "cedil", "cent;", "cent", "chi;", "circ;", "clubs;", "cong;", "copy;", "copy", "crarr;", "cup;", "curren;", "curren", "dArr;", "dagger;", "darr;", "deg;", "deg", "delta;", "diams;", "divide;", "divide", "eacute;", "eacute", "ecirc;", "ecirc", "egrave;", "egrave", "empty;", "emsp;", "ensp;", "epsilon;", "equiv;", "eta;", "eth;", "eth", "euml;", "euml", "euro;", "exist;", "fnof;", "forall;", "frac12;", "frac12", "frac14;", "frac14", "frac34;", "frac34", "frasl;", "gamma;", "ge;", "gt;", "gt", "hArr;", "harr;", "hearts;", "hellip;", "iacute;", "iacute", "icirc;", "icirc", "iexcl;", "iexcl", "igrave;", "igrave", "image;", "infin;", "int;", "iota;", "iquest;", "iquest", "isin;", "iuml;", "iuml", "kappa;", "lArr;", "lambda;", "lang;", "laquo;", "laquo", "larr;", "lceil;", "ldquo;", "le;", "lfloor;", "lowast;", "loz;", "lrm;", "lsaquo;", "lsquo;", "lt;", "lt", "macr;", "macr", "mdash;", "micro;", "micro", "middot;", "middot", "minus;", "mu;", "nabla;", "nbsp;", "nbsp", "ndash;", "ne;", "ni;", "not;", "not", "notin;", "nsub;", "ntilde;", "ntilde", "nu;", "oacute;", "oacute", "ocirc;", "ocirc", "oelig;", "ograve;", "ograve", "oline;", "omega;", "omicron;", "oplus;", "or;", "ordf;", "ordf", "ordm;", "ordm", "oslash;", "oslash", "otilde;", "otilde", "otimes;", "ouml;", "ouml", "para;", "para", "part;", "permil;", "perp;", "phi;", "pi;", "piv;", "plusmn;", "plusmn", "pound;", "pound", "prime;", "prod;", "prop;", "psi;", "quot;", "quot", "rArr;", "radic;", "rang;", "raquo;", "raquo", "rarr;", "rceil;", "rdquo;", "real;", "reg;", "reg", "rfloor;", "rho;", "rlm;", "rsaquo;", "rsquo;", "sbquo;", "scaron;", "sdot;", "sect;", "sect", "shy;", "shy", "sigma;", "sigmaf;", "sim;", "spades;", "sub;", "sube;", "sum;", "sup1;", "sup1", "sup2;", "sup2", "sup3;", "sup3", "sup;", "supe;", "szlig;", "szlig", "tau;", "there4;", "theta;", "thetasym;", "thinsp;", "thorn;", "thorn", "tilde;", "times;", "times", "trade;", "uArr;", "uacute;", "uacute", "uarr;", "ucirc;", "ucirc", "ugrave;", "ugrave", "uml;", "uml", "upsih;", "upsilon;", "uuml;", "uuml", "weierp;", "xi;", "yacute;", "yacute", "yen;", "yen", "yuml;", "yuml", "zeta;", "zwj;", "zwnj;"];
    const PCDATA = 0;
    const RCDATA = 1;
    const CDATA = 2;
    const PLAINTEXT = 3;
    const DOCTYPE = 0;
    const STARTTAG = 1;
    const ENDTAG = 2;
    const COMMENT = 3;
    const CHARACTR = 4;
    const EOF = 5;
    public function __construct(data) -> void
    {
        let this->data = data;
        let this->char =  -1;
        let this->eof =  strlen(data);
        let this->tree =  new HTML5TreeConstructer();
        let this->content_model =  self::PCDATA;
        let this->state = "data";
        while (this->state !== null) {
            this->{this->state . "State"}();
        }
    }
    
    public function save()
    {
        return this->tree->save();
    }
    
    protected function char()
    {
        return  this->char < this->eof ? this->data[this->char]  : false;
    }
    
    protected function character(s, l = 0)
    {
        if s + l < this->eof {
            if l === 0 {
                return this->data[s];
            } else {
                return substr(this->data, s, l);
            }
        }
    }
    
    protected function characters(char_class, start)
    {
        return preg_replace("#^([" . char_class . "]+).*#s", "\\1", substr(this->data, start));
    }
    
    protected function dataState() -> void
    {
        var char, tmpArray90b18447cc37ac45ac2a0e004cccfe00, tmpArray2f989d7829cbaaec04235731c852b479, tmpArray10c09225b270cacfaf372181c158f5f9, len, tmpArray005ea61b3dc664e651ab8a407b206ac9;
    
        // Consume the next input character
        let this->char++;
        let char =  this->char();
        if char === "&" && (this->content_model === self::PCDATA || this->content_model === self::RCDATA) {
            /* U+0026 AMPERSAND (&)
            			 When the content model flag is set to one of the PCDATA or RCDATA
            			 states: switch to the entity data state. Otherwise: treat it as per
            			 the "anything else"    entry below. */
            let this->state = "entityData";
        } elseif char === "-" {
            /* If the content model flag is set to either the RCDATA state or
            			 the CDATA state, and the escape flag is false, and there are at
            			 least three characters before this one in the input stream, and the
            			 last four characters in the input stream, including this one, are
            			 U+003C LESS-THAN SIGN, U+0021 EXCLAMATION MARK, U+002D HYPHEN-MINUS,
            			 and U+002D HYPHEN-MINUS ("<!--"), then set the escape flag to true. */
            if (this->content_model === self::RCDATA || this->content_model === self::CDATA) && this->escape === false && this->char >= 3 && this->character(this->char - 4, 4) === "<!--" {
                let this->escape =  true;
            }
            /* In any case, emit the input character as a character token. Stay
            				 in the data state. */
            let tmpArray90b18447cc37ac45ac2a0e004cccfe00 = ["type" : self::CHARACTR, "data" : char];
            this->emitToken(tmpArray90b18447cc37ac45ac2a0e004cccfe00);
        } elseif char === "<" && (this->content_model === self::PCDATA || (this->content_model === self::RCDATA || this->content_model === self::CDATA) && this->escape === false) {
            /* When the content model flag is set to the PCDATA state: switch
            				 to the tag open state.
            				 
            				 When the content model flag is set to either the RCDATA state or
            				 the CDATA state and the escape flag is false: switch to the tag
            				 open state.
            				 
            				 Otherwise: treat it as per the "anything else" entry below. */
            let this->state = "tagOpen";
        } elseif char === ">" {
            /* If the content model flag is set to either the RCDATA state or
            			 the CDATA state, and the escape flag is true, and the last three
            			 characters in the input stream including this one are U+002D
            			 HYPHEN-MINUS, U+002D HYPHEN-MINUS, U+003E GREATER-THAN SIGN ("-->"),
            			 set the escape flag to false. */
            if (this->content_model === self::RCDATA || this->content_model === self::CDATA) && this->escape === true && this->character(this->char, 3) === "-->" {
                let this->escape =  false;
            }
            /* In any case, emit the input character as a character token.
            				 Stay in the data state. */
            let tmpArray2f989d7829cbaaec04235731c852b479 = ["type" : self::CHARACTR, "data" : char];
            this->emitToken(tmpArray2f989d7829cbaaec04235731c852b479);
        } elseif this->char === this->eof {
            /* EOF
            			 Emit an end-of-file token. */
            this->eof();
        } elseif this->content_model === self::PLAINTEXT {
            /* When the content model flag is set to the PLAINTEXT state
            			 THIS DIFFERS GREATLY FROM THE SPEC: Get the remaining characters of
            			 the text and emit it as a character token. */
            let tmpArray10c09225b270cacfaf372181c158f5f9 = ["type" : self::CHARACTR, "data" : substr(this->data, this->char)];
            this->emitToken(tmpArray10c09225b270cacfaf372181c158f5f9);
            this->eof();
        } else {
            /* Anything else
            			 THIS DIFFERS GREATLY FROM THE SPEC: Get as many character that
            			 otherwise would also be treated as a character token and emit it
            			 as a single character token. Stay in the data state. */
            let len =  strcspn(this->data, "<&", this->char);
            let char =  substr(this->data, this->char, len);
            let this->char += len - 1;
            let tmpArray005ea61b3dc664e651ab8a407b206ac9 = ["type" : self::CHARACTR, "data" : char];
            this->emitToken(tmpArray005ea61b3dc664e651ab8a407b206ac9);
            let this->state = "data";
        }
    }
    
    protected function entityDataState() -> void
    {
        var entity, char, tmpArray3d4e1d3508ba2a76a76bf5c102c34ee2;
    
        // Attempt to consume an entity.
        let entity =  this->entity();
        // If nothing is returned, emit a U+0026 AMPERSAND character token.
        // Otherwise, emit the character token that was returned.
        let char =  !(entity) ? "&"  : entity;
        let tmpArray3d4e1d3508ba2a76a76bf5c102c34ee2 = ["type" : self::CHARACTR, "data" : char];
        this->emitToken(tmpArray3d4e1d3508ba2a76a76bf5c102c34ee2);
        // Finally, switch to the data state.
        let this->state = "data";
    }
    
    protected function tagOpenState() -> void
    {
        var tmpArrayf3bddc750f5f1cfd38e884e13ca78544, char, tmpArray902d0edfb2937f0c839597d14c913550, tmpArrayd754f9c7d530111d93989bd40533098d;
    
        if self::RCDATA || self::CDATA {
            /* If the next input character is a U+002F SOLIDUS (/) character,
            				 consume it and switch to the close tag open state. If the next
            				 input character is not a U+002F SOLIDUS (/) character, emit a
            				 U+003C LESS-THAN SIGN character token and switch to the data
            				 state to process the next input character. */
            if this->character(this->char + 1) === "/" {
                let this->char++;
                let this->state = "closeTagOpen";
            } else {
                let tmpArrayf3bddc750f5f1cfd38e884e13ca78544 = ["type" : self::CHARACTR, "data" : "<"];
                this->emitToken(tmpArrayf3bddc750f5f1cfd38e884e13ca78544);
                let this->state = "data";
            }
        } else {
            // If the content model flag is set to the PCDATA state
            // Consume the next input character:
            let this->char++;
            let char =  this->char();
            if char === "!" {
                /* U+0021 EXCLAMATION MARK (!)
                					 Switch to the markup declaration open state. */
                let this->state = "markupDeclarationOpen";
            } elseif char === "/" {
                /* U+002F SOLIDUS (/)
                					 Switch to the close tag open state. */
                let this->state = "closeTagOpen";
            } elseif preg_match("/^[A-Za-z]$/", char) {
                /* U+0041 LATIN LETTER A through to U+005A LATIN LETTER Z
                					 Create a new start tag token, set its tag name to the lowercase
                					 version of the input character (add 0x0020 to the character's code
                					 point), then switch to the tag name state. (Don't emit the token
                					 yet; further details will be filled in before it is emitted.) */
                let this->token =  ["name" : strtolower(char), "type" : self::STARTTAG, "attr" : []];
                let this->state = "tagName";
            } elseif char === ">" {
                /* U+003E GREATER-THAN SIGN (>)
                					 Parse error. Emit a U+003C LESS-THAN SIGN character token and a
                					 U+003E GREATER-THAN SIGN character token. Switch to the data state. */
                let tmpArray902d0edfb2937f0c839597d14c913550 = ["type" : self::CHARACTR, "data" : "<>"];
                this->emitToken(tmpArray902d0edfb2937f0c839597d14c913550);
                let this->state = "data";
            } elseif char === "?" {
                /* U+003F QUESTION MARK (?)
                					 Parse error. Switch to the bogus comment state. */
                let this->state = "bogusComment";
            } else {
                /* Anything else
                					 Parse error. Emit a U+003C LESS-THAN SIGN character token and
                					 reconsume the current input character in the data state. */
                let tmpArrayd754f9c7d530111d93989bd40533098d = ["type" : self::CHARACTR, "data" : "<"];
                this->emitToken(tmpArrayd754f9c7d530111d93989bd40533098d);
                let this->char--;
                let this->state = "data";
            }
        }
    }
    
    protected function closeTagOpenState() -> void
    {
        var next_node, the_same, tmpArray4883048cb0b8829949f8a69251a8bee8, char, tmpArray77d17853f09771227bf39aee19110e06;
    
        let next_node =  strtolower(this->characters("A-Za-z", this->char + 1));
        let the_same =  count(this->tree->stack) > 0 && next_node === end(this->tree->stack)->nodeName;
        if (this->content_model === self::RCDATA || this->content_model === self::CDATA) && (!(the_same) || the_same && (!(preg_match("/[\\t\\n\\x0b\\x0c >\\/]/", this->character(this->char + 1 + strlen(next_node)))) || this->eof === this->char)) {
            /* If the content model flag is set to the RCDATA or CDATA states then
            				 examine the next few characters. If they do not match the tag name of
            				 the last start tag token emitted (case insensitively), or if they do but
            				 they are not immediately followed by one of the following characters:
            				 * U+0009 CHARACTER TABULATION
            				 * U+000A LINE FEED (LF)
            				 * U+000B LINE TABULATION
            				 * U+000C FORM FEED (FF)
            				 * U+0020 SPACE
            				 * U+003E GREATER-THAN SIGN (>)
            				 * U+002F SOLIDUS (/)
            				 * EOF
            				 ...then there is a parse error. Emit a U+003C LESS-THAN SIGN character
            				 token, a U+002F SOLIDUS character token, and switch to the data state
            				 to process the next input character. */
            let tmpArray4883048cb0b8829949f8a69251a8bee8 = ["type" : self::CHARACTR, "data" : "</"];
            this->emitToken(tmpArray4883048cb0b8829949f8a69251a8bee8);
            let this->state = "data";
        } else {
            /* Otherwise, if the content model flag is set to the PCDATA state,
            				 or if the next few characters do match that tag name, consume the
            				 next input character: */
            let this->char++;
            let char =  this->char();
            if preg_match("/^[A-Za-z]$/", char) {
                /* U+0041 LATIN LETTER A through to U+005A LATIN LETTER Z
                					 Create a new end tag token, set its tag name to the lowercase version
                					 of the input character (add 0x0020 to the character's code point), then
                					 switch to the tag name state. (Don't emit the token yet; further details
                					 will be filled in before it is emitted.) */
                let this->token =  ["name" : strtolower(char), "type" : self::ENDTAG];
                let this->state = "tagName";
            } elseif char === ">" {
                /* U+003E GREATER-THAN SIGN (>)
                					 Parse error. Switch to the data state. */
                let this->state = "data";
            } elseif this->char === this->eof {
                /* EOF
                					 Parse error. Emit a U+003C LESS-THAN SIGN character token and a U+002F
                					 SOLIDUS character token. Reconsume the EOF character in the data state. */
                let tmpArray77d17853f09771227bf39aee19110e06 = ["type" : self::CHARACTR, "data" : "</"];
                this->emitToken(tmpArray77d17853f09771227bf39aee19110e06);
                let this->char--;
                let this->state = "data";
            } else {
                /* Parse error. Switch to the bogus comment state. */
                let this->state = "bogusComment";
            }
        }
    }
    
    protected function tagNameState() -> void
    {
        var char;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            /* U+0009 CHARACTER TABULATION
            			 U+000A LINE FEED (LF)
            			 U+000B LINE TABULATION
            			 U+000C FORM FEED (FF)
            			 U+0020 SPACE
            			 Switch to the before attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif char === ">" {
            /* U+003E GREATER-THAN SIGN (>)
            			 Emit the current tag token. Switch to the data state. */
            this->emitToken(this->token);
            let this->state = "data";
        } elseif this->char === this->eof {
            /* EOF
            			 Parse error. Emit the current tag token. Reconsume the EOF
            			 character in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } elseif char === "/" {
            /* U+002F SOLIDUS (/)
            			 Parse error unless this is a permitted slash. Switch to the before
            			 attribute name state. */
            let this->state = "beforeAttributeName";
        } else {
            /* Anything else
            			 Append the current input character to the current tag token's tag name.
            			 Stay in the tag name state. */
            let this->token["name"] .= strtolower(char);
            let this->state = "tagName";
        }
    }
    
    protected function beforeAttributeNameState() -> void
    {
        var char;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            /* U+0009 CHARACTER TABULATION
            			 U+000A LINE FEED (LF)
            			 U+000B LINE TABULATION
            			 U+000C FORM FEED (FF)
            			 U+0020 SPACE
            			 Stay in the before attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif char === ">" {
            /* U+003E GREATER-THAN SIGN (>)
            			 Emit the current tag token. Switch to the data state. */
            this->emitToken(this->token);
            let this->state = "data";
        } elseif char === "/" {
            /* U+002F SOLIDUS (/)
            			 Parse error unless this is a permitted slash. Stay in the before
            			 attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif this->char === this->eof {
            /* EOF
            			 Parse error. Emit the current tag token. Reconsume the EOF
            			 character in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Anything else
            			 Start a new attribute in the current tag token. Set that attribute's
            			 name to the current input character, and its value to the empty string.
            			 Switch to the attribute name state. */
            let this->token["attr"][] =  ["name" : strtolower(char), "value" : null];
            let this->state = "attributeName";
        }
    }
    
    protected function attributeNameState() -> void
    {
        var char, last;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            /* U+0009 CHARACTER TABULATION
            			 U+000A LINE FEED (LF)
            			 U+000B LINE TABULATION
            			 U+000C FORM FEED (FF)
            			 U+0020 SPACE
            			 Stay in the before attribute name state. */
            let this->state = "afterAttributeName";
        } elseif char === "=" {
            /* U+003D EQUALS SIGN (=)
            			 Switch to the before attribute value state. */
            let this->state = "beforeAttributeValue";
        } elseif char === ">" {
            /* U+003E GREATER-THAN SIGN (>)
            			 Emit the current tag token. Switch to the data state. */
            this->emitToken(this->token);
            let this->state = "data";
        } elseif char === "/" && this->character(this->char + 1) !== ">" {
            /* U+002F SOLIDUS (/)
            			 Parse error unless this is a permitted slash. Switch to the before
            			 attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif this->char === this->eof {
            /* EOF
            			 Parse error. Emit the current tag token. Reconsume the EOF
            			 character in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Anything else
            			 Append the current input character to the current attribute's name.
            			 Stay in the attribute name state. */
            let last =  count(this->token["attr"]) - 1;
            let this->token["attr"][last]["name"] .= strtolower(char);
            let this->state = "attributeName";
        }
    }
    
    protected function afterAttributeNameState() -> void
    {
        var char;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            /* U+0009 CHARACTER TABULATION
            			 U+000A LINE FEED (LF)
            			 U+000B LINE TABULATION
            			 U+000C FORM FEED (FF)
            			 U+0020 SPACE
            			 Stay in the after attribute name state. */
            let this->state = "afterAttributeName";
        } elseif char === "=" {
            /* U+003D EQUALS SIGN (=)
            			 Switch to the before attribute value state. */
            let this->state = "beforeAttributeValue";
        } elseif char === ">" {
            /* U+003E GREATER-THAN SIGN (>)
            			 Emit the current tag token. Switch to the data state. */
            this->emitToken(this->token);
            let this->state = "data";
        } elseif char === "/" && this->character(this->char + 1) !== ">" {
            /* U+002F SOLIDUS (/)
            			 Parse error unless this is a permitted slash. Switch to the
            			 before attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif this->char === this->eof {
            /* EOF
            			 Parse error. Emit the current tag token. Reconsume the EOF
            			 character in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Anything else
            			 Start a new attribute in the current tag token. Set that attribute's
            			 name to the current input character, and its value to the empty string.
            			 Switch to the attribute name state. */
            let this->token["attr"][] =  ["name" : strtolower(char), "value" : null];
            let this->state = "attributeName";
        }
    }
    
    protected function beforeAttributeValueState() -> void
    {
        var char, last;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            /* U+0009 CHARACTER TABULATION
            			 U+000A LINE FEED (LF)
            			 U+000B LINE TABULATION
            			 U+000C FORM FEED (FF)
            			 U+0020 SPACE
            			 Stay in the before attribute value state. */
            let this->state = "beforeAttributeValue";
        } elseif char === "\"" {
            /* U+0022 QUOTATION MARK (")
            			 Switch to the attribute value (double-quoted) state. */
            let this->state = "attributeValueDoubleQuoted";
        } elseif char === "&" {
            /* U+0026 AMPERSAND (&)
            			 Switch to the attribute value (unquoted) state and reconsume
            			 this input character. */
            let this->char--;
            let this->state = "attributeValueUnquoted";
        } elseif char === "'" {
            /* U+0027 APOSTROPHE (')
            			 Switch to the attribute value (single-quoted) state. */
            let this->state = "attributeValueSingleQuoted";
        } elseif char === ">" {
            /* U+003E GREATER-THAN SIGN (>)
            			 Emit the current tag token. Switch to the data state. */
            this->emitToken(this->token);
            let this->state = "data";
        } else {
            /* Anything else
            			 Append the current input character to the current attribute's value.
            			 Switch to the attribute value (unquoted) state. */
            let last =  count(this->token["attr"]) - 1;
            let this->token["attr"][last]["value"] .= char;
            let this->state = "attributeValueUnquoted";
        }
    }
    
    protected function attributeValueDoubleQuotedState() -> void
    {
        var char, last;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if char === "\"" {
            /* U+0022 QUOTATION MARK (")
            			 Switch to the before attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif char === "&" {
            /* U+0026 AMPERSAND (&)
            			 Switch to the entity in attribute value state. */
            this->entityInAttributeValueState("double");
        } elseif this->char === this->eof {
            /* EOF
            			 Parse error. Emit the current tag token. Reconsume the character
            			 in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Anything else
            			 Append the current input character to the current attribute's value.
            			 Stay in the attribute value (double-quoted) state. */
            let last =  count(this->token["attr"]) - 1;
            let this->token["attr"][last]["value"] .= char;
            let this->state = "attributeValueDoubleQuoted";
        }
    }
    
    protected function attributeValueSingleQuotedState() -> void
    {
        var char, last;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if char === "'" {
            /* U+0022 QUOTATION MARK (')
            			 Switch to the before attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif char === "&" {
            /* U+0026 AMPERSAND (&)
            			 Switch to the entity in attribute value state. */
            this->entityInAttributeValueState("single");
        } elseif this->char === this->eof {
            /* EOF
            			 Parse error. Emit the current tag token. Reconsume the character
            			 in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Anything else
            			 Append the current input character to the current attribute's value.
            			 Stay in the attribute value (single-quoted) state. */
            let last =  count(this->token["attr"]) - 1;
            let this->token["attr"][last]["value"] .= char;
            let this->state = "attributeValueSingleQuoted";
        }
    }
    
    protected function attributeValueUnquotedState() -> void
    {
        var char, last;
    
        // Consume the next input character:
        let this->char++;
        let char =  this->character(this->char);
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            /* U+0009 CHARACTER TABULATION
            			 U+000A LINE FEED (LF)
            			 U+000B LINE TABULATION
            			 U+000C FORM FEED (FF)
            			 U+0020 SPACE
            			 Switch to the before attribute name state. */
            let this->state = "beforeAttributeName";
        } elseif char === "&" {
            /* U+0026 AMPERSAND (&)
            			 Switch to the entity in attribute value state. */
            this->entityInAttributeValueState();
        } elseif char === ">" {
            /* U+003E GREATER-THAN SIGN (>)
            			 Emit the current tag token. Switch to the data state. */
            this->emitToken(this->token);
            let this->state = "data";
        } else {
            /* Anything else
            			 Append the current input character to the current attribute's value.
            			 Stay in the attribute value (unquoted) state. */
            let last =  count(this->token["attr"]) - 1;
            let this->token["attr"][last]["value"] .= char;
            let this->state = "attributeValueUnquoted";
        }
    }
    
    protected function entityInAttributeValueState() -> void
    {
        var entity, char, last;
    
        // Attempt to consume an entity.
        let entity =  this->entity();
        // If nothing is returned, append a U+0026 AMPERSAND character to the
        // current attribute's value. Otherwise, emit the character token that
        // was returned.
        let char =  !(entity) ? "&"  : entity;
        let last =  count(this->token["attr"]) - 1;
        let this->token["attr"][last]["value"] .= char;
    }
    
    protected function bogusCommentState() -> void
    {
        var data, tmpArraybdda42faba1adb34a78926a44794db05;
    
        /* Consume every character up to the first U+003E GREATER-THAN SIGN
        		 character (>) or the end of the file (EOF), whichever comes first. Emit
        		 a comment token whose data is the concatenation of all the characters
        		 starting from and including the character that caused the state machine
        		 to switch into the bogus comment state, up to and including the last
        		 consumed character before the U+003E character, if any, or up to the
        		 end of the file otherwise. (If the comment was started by the end of
        		 the file (EOF), the token is empty.) */
        let data =  this->characters("^>", this->char);
        let tmpArraybdda42faba1adb34a78926a44794db05 = ["data" : data, "type" : self::COMMENT];
        this->emitToken(tmpArraybdda42faba1adb34a78926a44794db05);
        let this->char += strlen(data);
        /* Switch to the data state. */
        let this->state = "data";
        /* If the end of the file was reached, reconsume the EOF character. */
        if this->char === this->eof {
            let this->char =  this->eof - 1;
        }
    }
    
    protected function markupDeclarationOpenState() -> void
    {
        /* If the next two characters are both U+002D HYPHEN-MINUS (-)
        		 characters, consume those two characters, create a comment token whose
        		 data is the empty string, and switch to the comment state. */
        if this->character(this->char + 1, 2) === "--" {
            let this->char += 2;
            let this->state = "comment";
            let this->token =  ["data" : null, "type" : self::COMMENT];
        } elseif strtolower(this->character(this->char + 1, 7)) === "doctype" {
            let this->char += 7;
            let this->state = "doctype";
        } else {
            let this->char++;
            let this->state = "bogusComment";
        }
    }
    
    protected function commentState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        /* U+002D HYPHEN-MINUS (-) */
        if char === "-" {
            /* Switch to the comment dash state  */
            let this->state = "commentDash";
        } elseif this->char === this->eof {
            /* Parse error. Emit the comment token. Reconsume the EOF character
            			 in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Append the input character to the comment token's data. Stay in
            			 the comment state. */
            let this->token["data"] .= char;
        }
    }
    
    protected function commentDashState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        /* U+002D HYPHEN-MINUS (-) */
        if char === "-" {
            /* Switch to the comment end state  */
            let this->state = "commentEnd";
        } elseif this->char === this->eof {
            /* Parse error. Emit the comment token. Reconsume the EOF character
            			 in the data state. */
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            /* Append a U+002D HYPHEN-MINUS (-) character and the input
            			 character to the comment token's data. Switch to the comment state. */
            let this->token["data"] .= "-" . char;
            let this->state = "comment";
        }
    }
    
    protected function commentEndState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        if char === ">" {
            this->emitToken(this->token);
            let this->state = "data";
        } elseif char === "-" {
            let this->token["data"] .= "-";
        } elseif this->char === this->eof {
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            let this->token["data"] .= "--" . char;
            let this->state = "comment";
        }
    }
    
    protected function doctypeState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            let this->state = "beforeDoctypeName";
        } else {
            let this->char--;
            let this->state = "beforeDoctypeName";
        }
    }
    
    protected function beforeDoctypeNameState() -> void
    {
        var char, tmpArrayce837f921bad8378ed979822459a45ab, tmpArraybfda85c3ac114a4897e0a643cdca29fb;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            echo "not allowed";
        } elseif preg_match("/^[a-z]$/", char) {
            let this->token =  ["name" : strtoupper(char), "type" : self::DOCTYPE, "error" : true];
            let this->state = "doctypeName";
        } elseif char === ">" {
            let tmpArrayce837f921bad8378ed979822459a45ab = ["name" : null, "type" : self::DOCTYPE, "error" : true];
            this->emitToken(tmpArrayce837f921bad8378ed979822459a45ab);
            let this->state = "data";
        } elseif this->char === this->eof {
            let tmpArraybfda85c3ac114a4897e0a643cdca29fb = ["name" : null, "type" : self::DOCTYPE, "error" : true];
            this->emitToken(tmpArraybfda85c3ac114a4897e0a643cdca29fb);
            let this->char--;
            let this->state = "data";
        } else {
            let this->token =  ["name" : char, "type" : self::DOCTYPE, "error" : true];
            let this->state = "doctypeName";
        }
    }
    
    protected function doctypeNameState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            let this->state = "AfterDoctypeName";
        } elseif char === ">" {
            this->emitToken(this->token);
            let this->state = "data";
        } elseif preg_match("/^[a-z]$/", char) {
            let this->token["name"] .= strtoupper(char);
        } elseif this->char === this->eof {
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            let this->token["name"] .= char;
        }
        let this->token["error"] =  this->token["name"] === "HTML" ? false  : true;
    }
    
    protected function afterDoctypeNameState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        if preg_match("/^[\\t\\n\\x0b\\x0c ]$/", char) {
            echo "not allowed";
        } elseif char === ">" {
            this->emitToken(this->token);
            let this->state = "data";
        } elseif this->char === this->eof {
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
            let this->token["error"] = true;
            let this->state = "bogusDoctype";
        }
    }
    
    protected function bogusDoctypeState() -> void
    {
        var char;
    
        /* Consume the next input character: */
        let this->char++;
        let char =  this->char();
        if char === ">" {
            this->emitToken(this->token);
            let this->state = "data";
        } elseif this->char === this->eof {
            this->emitToken(this->token);
            let this->char--;
            let this->state = "data";
        } else {
        }
    }
    
    protected function entity()
    {
        var start, char, char_class, e_name, entity, cond, len, c, id;
    
        let start =  this->char;
        // This section defines how to consume an entity. This definition is
        // used when parsing entities in text and in attributes.
        // The behaviour depends on the identity of the next character (the
        // one immediately after the U+0026 AMPERSAND character):
        switch (this->character(this->char + 1)) {
            // U+0023 NUMBER SIGN (#)
            case "#":
                // The behaviour further depends on the character after the
                // U+0023 NUMBER SIGN:
                switch (this->character(this->char + 1)) {
                    // U+0078 LATIN SMALL LETTER X
                    // U+0058 LATIN CAPITAL LETTER X
                    case "x":
                    case "X":
                        // Follow the steps below, but using the range of
                        // characters U+0030 DIGIT ZERO through to U+0039 DIGIT
                        // NINE, U+0061 LATIN SMALL LETTER A through to U+0066
                        // LATIN SMALL LETTER F, and U+0041 LATIN CAPITAL LETTER
                        // A, through to U+0046 LATIN CAPITAL LETTER F (in other
                        // words, 0-9, A-F, a-f).
                        let char = 1;
                        let char_class = "0-9A-Fa-f";
                        break;
                    // Anything else
                    default:
                        // Follow the steps below, but using the range of
                        // characters U+0030 DIGIT ZERO through to U+0039 DIGIT
                        // NINE (i.e. just 0-9).
                        let char = 0;
                        let char_class = "0-9";
                        break;
                }
                // Consume as many characters as match the range of characters
                // given above.
                let this->char++;
                let e_name =  this->characters(char_class, this->char + char + 1);
                let entity =  this->character(start, this->char);
                let cond =  strlen(e_name) > 0;
                // The rest of the parsing happens below.
                break;
            // Anything else
            default:
                // Consume the maximum number of characters possible, with the
                // consumed characters case-sensitively matching one of the
                // identifiers in the first column of the entities table.
                let e_name =  this->characters("0-9A-Za-z;", this->char + 1);
                let len =  strlen(e_name);
                let c = 1;
                for c in range(1, len) {
                    let id =  substr(e_name, 0, c);
                    let this->char++;
                    if in_array(id, this->entities) {
                        if e_name[c - 1] !== ";" {
                            if c < len && e_name[c] == ";" {
                                let this->char++;
                            }
                        }
                        let entity = id;
                        break;
                    }
                }
                let cond =  isset entity;
                // The rest of the parsing happens below.
                break;
        }
        if !(cond) {
            // If no match can be made, then this is a parse error. No
            // characters are consumed, and nothing is returned.
            let this->char = start;
            return false;
        }
        // Return a character token for the character corresponding to the
        // entity name (as given by the second column of the entities table).
        return html_entity_decode("&" . rtrim(entity, ";") . ";", ENT_QUOTES, "UTF-8");
    }
    
    protected function emitToken(token) -> void
    {
        var emit;
    
        let emit =  this->tree->emitToken(token);
        if is_int(emit) {
            let this->content_model = emit;
        } elseif token["type"] === self::ENDTAG {
            let this->content_model =  self::PCDATA;
        }
    }
    
    protected function EOF() -> void
    {
        var tmpArray0ca326f6509792c1b99251281f3388c6;
    
        let this->state =  null;
        let tmpArray0ca326f6509792c1b99251281f3388c6 = ["type" : self::EOF];
        this->tree->emitToken(tmpArray0ca326f6509792c1b99251281f3388c6);
    }

}