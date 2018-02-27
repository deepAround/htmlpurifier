namespace HTMLPurifier\Lexer;

use HTMLPurifier\Lexer;
use HTMLPurifier\Queue;
use HTMLPurifier\TokenFactory;
use HTMLPurifier\Token\TokenStart;
use DOMDocument;
/**
 * Parser that uses PHP 5's DOM extension (part of the core).
 *
 * In PHP 5, the DOM XML extension was revamped into DOM and added to the core.
 * It gives us a forgiving HTML parser, which we use to transform the HTML
 * into a DOM, and then into the tokens.  It is blazingly fast (for large
 * documents, it performs twenty times faster than
 * LexerDirectLex,and is the default choice for PHP 5.
 *
 * @note Any empty elements will have empty tokens associated with them, even if
 * this is prohibited by the spec. This is cannot be fixed until the spec
 * comes into play.
 *
 * @note PHP's DOM extension does not actually parse any entities, we use
 *       our own function to do that.
 *
 * @warning DOM tends to drop whitespace, which may wreak havoc on indenting.
 *          If this is a huge problem, due to the fact that HTML is hand
 *          edited and you are unable to get a parser cache that caches the
 *          the output of HTML Purifier while keeping the original HTML lying
 *          around, you may want to run Tidy on the resulting output or use
 *          DirectLex
 */
class LexerDOMLex extends Lexer
{
    /**
     * @type TokenFactory
     */
    protected factory;
    public function __construct() -> void
    {
        // setup the factory
        parent::__construct();
        let this->factory =  new TokenFactory();
    }
    
    /**
     * @param string $html
     * @param Config $config
     * @param Context $context
     * @return Token[]
     */
    public function tokenizeHTML(string html, <Config> config, <Context> context) -> array
    {
        var char, comment, tmpArray3f49c1abbae4518f2617f09b7689830a, old, tmpArray9fca575a57ccede39d454179e5307d11, doc, tmpArray7a9493ca6835419c3f99d3484ea4eac8, body, div, tokens;
    
        let html =  this->normalize(html, config, context);
        // attempt to armor stray angled brackets that cannot possibly
        // form tags and thus are probably being used as emoticons
        if config->get("Core.AggressivelyFixLt") {
            let char = "[^a-z!\\/]";
            let comment = "/<!--(.*?)(-->|\\z)/is";
            let tmpArray3f49c1abbae4518f2617f09b7689830a = [this, "callbackArmorCommentEntities"];
            let html =  preg_replace_callback(comment, tmpArray3f49c1abbae4518f2617f09b7689830a, html);
            do {
                let old = html;
                let html =  preg_replace("/<({char})/i", "&lt;\\1", html);
            } while (html !== old);
            let tmpArray9fca575a57ccede39d454179e5307d11 = [this, "callbackUndoCommentSubst"];
            let html =  preg_replace_callback(comment, tmpArray9fca575a57ccede39d454179e5307d11, html);
        }
        // preprocess html, essential for UTF-8
        let html =  this->wrapHTML(html, config, context);
        let doc =  new DOMDocument();
        let doc->encoding = "UTF-8";
        // theoretically, the above has this covered
        let tmpArray7a9493ca6835419c3f99d3484ea4eac8 = [this, "muteErrorHandler"];
        set_error_handler(tmpArray7a9493ca6835419c3f99d3484ea4eac8);
        doc->loadHTML(html);
        restore_error_handler();
        let body =  doc->getElementsByTagName("html")->item(0)->getElementsByTagName("body")->item(0);
        // <body>
        let div =  body->getElementsByTagName("div")->item(0);
        // <div>
        let tokens =  [];
        this->tokenizeDOM(div, tokens, config);
        // If the div has a sibling, that means we tripped across
        // a premature </div> tag.  So remove the div we parsed,
        // and then tokenize the rest of body.  We can't tokenize
        // the sibling directly as we'll lose the tags in that case.
        if div->nextSibling {
            body->removeChild(div);
            this->tokenizeDOM(body, tokens, config);
        }
        return tokens;
    }
    
    /**
     * Iterative function that tokenizes a node, putting it into an accumulator.
     * To iterate is human, to recurse divine - L. Peter Deutsch
     * @param DOMNode $node DOMNode to be tokenized.
     * @param Token[] $tokens   Array-list of already tokenized tokens.
     * @return Token of node appended to previously passed tokens.
     */
    protected function tokenizeDOM(<\DOMNode> node, array tokens, config) -> <Token>
    {
        var level, nodes, tmpArray8547a76e09fe1b05df2094879c0ac4de, closingNodes, collect, needEndingTag, childNode;
    
        let level = 0;
        let nodes =  [level : new Queue(tmpArray8547a76e09fe1b05df2094879c0ac4de)];
        let closingNodes =  [];
        do {
            while (!(nodes[level]->isEmpty())) {
                let node =  nodes[level]->shift();
                // FIFO
                let collect =  level > 0 ? true  : false;
                let needEndingTag =  this->createStartNode(node, tokens, collect, config);
                if needEndingTag {
                    let closingNodes[level][] = node;
                }
                if node->childNodes && node->childNodes->length {
                    let level++;
                    let nodes[level] = new Queue();
                    for childNode in node->childNodes {
                        nodes[level]->push(childNode);
                    }
                }
            }
            let level--;
            if level && isset closingNodes[level] {
                let node =  array_pop(closingNodes[level]);
                while (node) {
                    this->createEndNode(node, tokens);
                let node =  array_pop(closingNodes[level]);
                }
            }
        } while (level > 0);
    }
    
    /**
     * Portably retrieve the tag name of a node; deals with older versions
     * of libxml like 2.7.6
     * @param DOMNode $node
     */
    protected function getTagName(<\DOMNode> node)
    {
        if property_exists(node, "tagName") {
            return node->tagName;
        } else {
            if property_exists(node, "nodeName") {
                return node->nodeName;
            } else {
                if property_exists(node, "localName") {
                    return node->localName;
                }
            }
        }
        return null;
    }
    
    /**
     * Portably retrieve the data of a node; deals with older versions
     * of libxml like 2.7.6
     * @param DOMNode $node
     */
    protected function getData(<\DOMNode> node)
    {
        if property_exists(node, "data") {
            return node->data;
        } else {
            if property_exists(node, "nodeValue") {
                return node->nodeValue;
            } else {
                if property_exists(node, "textContent") {
                    return node->textContent;
                }
            }
        }
        return null;
    }
    
    /**
     * @param DOMNode $node DOMNode to be tokenized.
     * @param Token[] $tokens   Array-list of already tokenized tokens.
     * @param bool $collect  Says whether or start and close are collected, set to
     *                    false at first recursion because it's the implicit DIV
     *                    tag you're dealing with.
     * @return bool if the token needs an endtoken
     * @todo data and tagName properties don't seem to exist in DOMNode?
     */
    protected function createStartNode(<\DOMNode> node, array tokens, bool collect, config) -> bool
    {
        var data, last, new_data, attr, tag_name;
    
        // intercept non element nodes. WE MUST catch all of them,
        // but we're not getting the character reference nodes because
        // those should have been preprocessed
        if node->nodeType === XML_TEXT_NODE {
            let data =  this->getData(node);
            // Handle variable data property
            if data !== null {
                let tokens[] =  this->factory->createText(data);
            }
            return false;
        } elseif node->nodeType === XML_CDATA_SECTION_NODE {
            // undo libxml's special treatment of <script> and <style> tags
            let last =  end(tokens);
            let data =  node->data;
            // (note $node->tagname is already normalized)
            if last instanceof TokenStart && (last->name == "script" || last->name == "style") {
                let new_data =  trim(data);
                if substr(new_data, 0, 4) === "<!--" {
                    let data =  substr(new_data, 4);
                    if substr(data, -3) === "-->" {
                        let data =  substr(data, 0, -3);
                    } else {
                    }
                }
            }
            let tokens[] =  this->factory->createText(this->parseText(data, config));
            return false;
        } elseif node->nodeType === XML_COMMENT_NODE {
            // this is code is only invoked for comments in script/style in versions
            // of libxml pre-2.6.28 (regular comments, of course, are still
            // handled regularly)
            let tokens[] =  this->factory->createComment(node->data);
            return false;
        } elseif node->nodeType !== XML_ELEMENT_NODE {
            // not-well tested: there may be other nodes we have to grab
            return false;
        }
        let attr =  node->hasAttributes() ? this->transformAttrToAssoc(node->attributes)  : [];
        let tag_name =  this->getTagName(node);
        // Handle variable tagName property
        if empty(tag_name) {
            return (bool) node->childNodes->length;
        }
        // We still have to make sure that the element actually IS empty
        if !(node->childNodes->length) {
            if collect {
                let tokens[] =  this->factory->createEmpty(tag_name, attr);
            }
            return false;
        } else {
            if collect {
                let tokens[] =  this->factory->createStart(tag_name, attr);
            }
            return true;
        }
    }
    
    /**
     * @param DOMNode $node
     * @param Token[] $tokens
     */
    protected function createEndNode(<\DOMNode> node, array tokens) -> void
    {
        var tag_name;
    
        let tag_name =  this->getTagName(node);
        // Handle variable tagName property
        let tokens[] =  this->factory->createEnd(tag_name);
    }
    
    /**
     * Converts a DOMNamedNodeMap of DOMAttr objects into an assoc array.
     *
     * @param DOMNamedNodeMap $node_map DOMNamedNodeMap of DOMAttr objects.
     * @return array Associative array of attributes.
     */
    protected function transformAttrToAssoc(<\DOMNamedNodeMap> node_map) -> array
    {
        var tmpArray40cd750bba9870f18aada2478b24840a, myArray, attr;
    
        // NamedNodeMap is documented very well, so we're using undocumented
        // features, namely, the fact that it implements Iterator and
        // has a ->length attribute
        if node_map->length === 0 {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        let myArray =  [];
        for attr in node_map {
            let myArray[attr->name] = attr->value;
        }
        return myArray;
    }
    
    /**
     * An error handler that mutes all errors
     * @param int $errno
     * @param string $errstr
     */
    public function muteErrorHandler(int errno, string errstr) -> void
    {
    }
    
    /**
     * Callback function for undoing escaping of stray angled brackets
     * in comments
     * @param array $matches
     * @return string
     */
    public function callbackUndoCommentSubst(array matches) -> string
    {
        var tmpArray8cdc684c0ef4d057edc31a3d1baeb6fb;
    
        let tmpArray8cdc684c0ef4d057edc31a3d1baeb6fb = ["&amp;" : "&", "&lt;" : "<"];
        return "<!--" . strtr(matches[1], tmpArray8cdc684c0ef4d057edc31a3d1baeb6fb) . matches[2];
    }
    
    /**
     * Callback function that entity-izes ampersands in comments so that
     * callbackUndoCommentSubst doesn't clobber them
     * @param array $matches
     * @return string
     */
    public function callbackArmorCommentEntities(array matches) -> string
    {
        return "<!--" . str_replace("&", "&amp;", matches[1]) . matches[2];
    }
    
    /**
     * Wraps an HTML fragment in the necessary HTML
     * @param string $html
     * @param Config $config
     * @param Context $context
     * @return string
     */
    protected function wrapHTML(string html, <Config> config, <Context> context, use_div = true) -> string
    {
        var def, ret;
    
        let def =  config->getDefinition("HTML");
        let ret = "";
        if !(empty(def->doctype->dtdPublic)) || !(empty(def->doctype->dtdSystem)) {
            let ret .= "<!DOCTYPE html ";
            if !(empty(def->doctype->dtdPublic)) {
                let ret .= "PUBLIC \"" . def->doctype->dtdPublic . "\" ";
            }
            if !(empty(def->doctype->dtdSystem)) {
                let ret .= "\"" . def->doctype->dtdSystem . "\" ";
            }
            let ret .= ">";
        }
        let ret .= "<html><head>";
        let ret .= "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />";
        // No protection if $html contains a stray </div>!
        let ret .= "</head><body>";
        if use_div {
            let ret .= "<div>";
        }
        let ret .= html;
        if use_div {
            let ret .= "</div>";
        }
        let ret .= "</body></html>";
        return ret;
    }

}