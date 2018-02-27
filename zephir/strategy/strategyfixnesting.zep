namespace HTMLPurifier\Strategy;

use HTMLPurifier\Arborize;
use HTMLPurifier\Node\NodeElement;
/**
 * Takes a well formed list of tokens and fixes their nesting.
 *
 * HTML elements dictate which elements are allowed to be their children,
 * for example, you can't have a p tag in a span tag.  Other elements have
 * much more rigorous definitions: tables, for instance, require a specific
 * order for their elements.  There are also constraints not expressible by
 * document type definitions, such as the chameleon nature of ins/del
 * tags and global child exclusions.
 *
 * The first major objective of this strategy is to iterate through all
 * the nodes and determine whether or not their children conform to the
 * element's definition.  If they do not, the child definition may
 * optionally supply an amended list of elements that is valid or
 * require that the entire node be deleted (and the previous node
 * rescanned).
 *
 * The second objective is to ensure that explicitly excluded elements of
 * an element do not appear in its children.  Code that accomplishes this
 * task is pervasive through the strategy, though the two are distinct tasks
 * and could, theoretically, be seperated (although it's not recommended).
 *
 * @note Whether or not unrecognized children are silently dropped or
 *       translated into text depends on the child definitions.
 *
 * @todo Enable nodes to be bubbled out of the structure.  This is
 *       easier with our new algorithm.
 */
class StrategyFixNesting extends \HTMLPurifier\Strategy
{
    /**
     * @param Token[] $tokens
     * @param Config $config
     * @param Context $context
     * @return array|Token[]
     */
    public function execute(array tokens, <Config> config, <Context> context)
    {
        var top_node, definition, excludes_enabled, is_inline, exclude_stack, node, token, d, tmpListTokenD, parent_def, stack, excludes, ix, tmpListNodeIs_inlineExcludesIx, go, def, child, tmpIx1, children, result;
    
        //####################################################################//
        // Pre-processing
        // O(n) pass to convert to a tree, so that we can efficiently
        // refer to substrings
        let top_node =  Arborize::arborize(tokens, config, context);
        // get a copy of the HTML definition
        let definition =  config->getHTMLDefinition();
        let excludes_enabled =  !(config->get("Core.DisableExcludes"));
        // setup the context variable 'IsInline', for chameleon processing
        // is 'false' when we are not inline, 'true' when it must always
        // be inline, and an integer when it is inline for a certain
        // branch of the document tree
        let is_inline =  definition->info_parent_def->descendants_are_inline;
        context->register("IsInline", is_inline);
        // setup error collector
        let e = context->get("ErrorCollector", true);
        //####################################################################//
        // Loop initialization
        // stack that contains all elements that are excluded
        // it is organized by parent elements, similar to $stack,
        // but it is only populated when an element with exclusions is
        // processed, i.e. there won't be empty exclusions.
        let exclude_stack =  [definition->info_parent_def->excludes];
        // variable that contains the start token while we are processing
        // nodes. This enables error reporting to do its job
        let node = top_node;
        // dummy token
        let tmpListTokenD = node->toTokenPair();
        let token = tmpListTokenD[0];
        let d = tmpListTokenD[1];
        context->register("CurrentNode", node);
        context->register("CurrentToken", token);
        //####################################################################//
        // Loop
        // We need to implement a post-order traversal iteratively, to
        // avoid running into stack space limits.  This is pretty tricky
        // to reason about, so we just manually stack-ify the recursive
        // variant:
        //
        //  function f($node) {
        //      foreach ($node->children as $child) {
        //          f($child);
        //      }
        //      validate($node);
        //  }
        //
        // Thus, we will represent a stack frame as array($node,
        // $is_inline, stack of children)
        // e.g. array_reverse($node->children) - already processed
        // children.
        let parent_def =  definition->info_parent_def;
        let stack =  [[top_node, parent_def->descendants_are_inline, parent_def->excludes, 0]];
        while (!(empty(stack))) {
            let tmpListNodeIs_inlineExcludesIx = array_pop(stack);
            let node = tmpListNodeIs_inlineExcludesIx[0];
            let is_inline = tmpListNodeIs_inlineExcludesIx[1];
            let excludes = tmpListNodeIs_inlineExcludesIx[2];
            let ix = tmpListNodeIs_inlineExcludesIx[3];
            // recursive call
            let go =  false;
            let def =  empty(stack) ? definition->info_parent_def  : definition->info[node->name];
            while (isset node->children[ix]) {
                
                let ix++;
                let tmpIx1 = ix;
                
                let child = node->children[tmpIx1];
                if child instanceof NodeElement {
                    let go =  true;
                    let stack[] =  [node, is_inline, excludes, ix];
                    let stack[] =  [child, is_inline || def->descendants_are_inline,  empty(def->excludes) ? excludes  : array_merge(excludes, def->excludes), 0];
                    break;
                }
            }
            if go {
                continue;
            }
            let tmpListTokenD = node->toTokenPair();
            let token = tmpListTokenD[0];
            let d = tmpListTokenD[1];
            // base case
            if excludes_enabled && isset excludes[node->name] {
                let node->dead =  true;
                if e {
                    e->send(E_ERROR, "StrategyFixNesting: Node excluded");
                }
            } else {
                // XXX I suppose it would be slightly more efficient to
                // avoid the allocation here and have children
                // strategies handle it
                let children =  [];
                for child in node->children {
                    if !(child->dead) {
                        let children[] = child;
                    }
                }
                let result =  def->child->validateChildren(children, config, context);
                if result === true {
                    // nop
                    let node->children = children;
                } elseif result === false {
                    let node->dead =  true;
                    if e {
                        e->send(E_ERROR, "StrategyFixNesting: Node removed");
                    }
                } else {
                    let node->children = result;
                    if e {
                        // XXX This will miss mutations of internal nodes. Perhaps defer to the child validators
                        if empty(result) && !(empty(children)) {
                            e->send(E_ERROR, "StrategyFixNesting: Node contents removed");
                        } else {
                            if result != children {
                                e->send(E_WARNING, "StrategyFixNesting: Node reorganized");
                            }
                        }
                    }
                }
            }
        }
        //####################################################################//
        // Post-processing
        // remove context variables
        context->destroy("IsInline");
        context->destroy("CurrentNode");
        context->destroy("CurrentToken");
        //####################################################################//
        // Return
        return Arborize::flatten(node, config, context);
    }

}