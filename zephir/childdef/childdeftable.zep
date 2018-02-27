namespace HTMLPurifier\ChildDef;

use HTMLPurifier\Node\NodeComment;
use HTMLPurifier\Node\NodeElement;
/**
 * Definition for tables.  The general idea is to extract out all of the
 * essential bits, and then reconstruct it later.
 *
 * This is a bit confusing, because the DTDs and the W3C
 * validators seem to disagree on the appropriate definition. The
 * DTD claims:
 *
 *      (CAPTION?, (COL*|COLGROUP*), THEAD?, TFOOT?, TBODY+)
 *
 * But actually, the HTML4 spec then has this to say:
 *
 *      The TBODY start tag is always required except when the table
 *      contains only one table body and no table head or foot sections.
 *      The TBODY end tag may always be safely omitted.
 *
 * So the DTD is kind of wrong.  The validator is, unfortunately, kind
 * of on crack.
 *
 * The definition changed again in XHTML1.1; and in my opinion, this
 * formulation makes the most sense.
 *
 *      caption?, ( col* | colgroup* ), (( thead?, tfoot?, tbody+ ) | ( tr+ ))
 *
 * Essentially, we have two modes: thead/tfoot/tbody mode, and tr mode.
 * If we encounter a thead, tfoot or tbody, we are placed in the former
 * mode, and we *must* wrap any stray tr segments with a tbody. But if
 * we don't run into any of them, just have tr tags is OK.
 */
class ChildDefTable extends \HTMLPurifier\ChildDef
{
    /**
     * @type bool
     */
    public allow_empty = false;
    /**
     * @type string
     */
    public type = "table";
    /**
     * @type array
     */
    public elements = ["tr" : true, "tbody" : true, "thead" : true, "tfoot" : true, "caption" : true, "colgroup" : true, "col" : true];
    public function __construct() -> void
    {
    }
    
    /**
     * @param array $children
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> array
    {
        var caption, thead, tfoot, initial_ws, after_caption_ws, after_thead_ws, after_tfoot_ws, cols, content, tbody_mode, node, ret, current_tr_tbody;
    
        if empty(children) {
            return false;
        }
        // only one of these elements is allowed in a table
        let caption =  false;
        let thead =  false;
        let tfoot =  false;
        // whitespace
        let initial_ws =  [];
        let after_caption_ws =  [];
        let after_thead_ws =  [];
        let after_tfoot_ws =  [];
        // as many of these as you want
        let cols =  [];
        let content =  [];
        let tbody_mode =  false;
        // if true, then we need to wrap any stray
        // <tr>s with a <tbody>.
        let ws_accum = initial_ws;
        for node in children {
            if node instanceof NodeComment {
                let ws_accum[] = node;
                continue;
            }
            switch (node->name) {
                case "tbody":
                    let tbody_mode =  true;
                // fall through
                case "tr":
                    let content[] = node;
                    let ws_accum = content;
                    break;
                case "caption":
                    // there can only be one caption!
                    if caption !== false {
                        break;
                    }
                    let caption = node;
                    let ws_accum = after_caption_ws;
                    break;
                case "thead":
                    let tbody_mode =  true;
                    // XXX This breaks rendering properties with
                    // Firefox, which never floats a <thead> to
                    // the top. Ever. (Our scheme will float the
                    // first <thead> to the top.)  So maybe
                    // <thead>s that are not first should be
                    // turned into <tbody>? Very tricky, indeed.
                    if thead === false {
                        let thead = node;
                        let ws_accum = after_thead_ws;
                    } else {
                        // Oops, there's a second one! What
                        // should we do?  Current behavior is to
                        // transmutate the first and last entries into
                        // tbody tags, and then put into content.
                        // Maybe a better idea is to *attach
                        // it* to the existing thead or tfoot?
                        // We don't do this, because Firefox
                        // doesn't float an extra tfoot to the
                        // bottom like it does for the first one.
                        let node->name = "tbody";
                        let content[] = node;
                        let ws_accum = content;
                    }
                    break;
                case "tfoot":
                    // see above for some aveats
                    let tbody_mode =  true;
                    if tfoot === false {
                        let tfoot = node;
                        let ws_accum = after_tfoot_ws;
                    } else {
                        let node->name = "tbody";
                        let content[] = node;
                        let ws_accum = content;
                    }
                    break;
                case "colgroup":
                case "col":
                    let cols[] = node;
                    let ws_accum = cols;
                    break;
                case "#PCDATA":
                    // How is whitespace handled? We treat is as sticky to
                    // the *end* of the previous element. So all of the
                    // nonsense we have worked on is to keep things
                    // together.
                    if !(empty(node->is_whitespace)) {
                        let ws_accum[] = node;
                    }
                    break;
            }
        }
        if empty(content) {
            return false;
        }
        let ret = initial_ws;
        if caption !== false {
            let ret[] = caption;
            let ret =  array_merge(ret, after_caption_ws);
        }
        if cols !== false {
            let ret =  array_merge(ret, cols);
        }
        if thead !== false {
            let ret[] = thead;
            let ret =  array_merge(ret, after_thead_ws);
        }
        if tfoot !== false {
            let ret[] = tfoot;
            let ret =  array_merge(ret, after_tfoot_ws);
        }
        if tbody_mode {
            // we have to shuffle tr into tbody
            let current_tr_tbody =  null;
            for node in content {
                switch (node->name) {
                    case "tbody":
                        let current_tr_tbody =  null;
                        let ret[] = node;
                        break;
                    case "tr":
                        if current_tr_tbody === null {
                            let current_tr_tbody =  new NodeElement("tbody");
                            let ret[] = current_tr_tbody;
                        }
                        let current_tr_tbody->children[] = node;
                        break;
                    case "#PCDATA":
                        //assert($node->is_whitespace);
                        if current_tr_tbody === null {
                            let ret[] = node;
                        } else {
                            let current_tr_tbody->children[] = node;
                        }
                        break;
                }
            }
        } else {
            let ret =  array_merge(ret, content);
        }
        return ret;
    }

}