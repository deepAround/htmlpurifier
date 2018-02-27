namespace HTMLPurifier;

use HTMLPurifier\Node\NodeElement;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
/**
 * Converts a stream of Token into an Node,
 * and back again.
 *
 * @note This transformation is not an equivalence.  We mutate the input
 * token stream to make it so; see all [MUT] markers in code.
 */
class Arborize
{
    public static function arborize(tokens, config, context)
    {
        var definition, parent, stack, token, r, node;
    
        let definition =  config->getHTMLDefinition();
        let parent =  new TokenStart(definition->info_parent);
        let stack =  [parent->toNode()];
        for token in tokens {
            let token->skip =  null;
            // [MUT]
            let token->carryover =  null;
            // [MUT]
            if token instanceof TokenEnd {
                let token->start =  null;
                // [MUT]
                let r =  array_pop(stack);
                //assert($r->name === $token->name);
                //assert(empty($token->attr));
                let r->endCol =  token->col;
                let r->endLine =  token->line;
                let r->endArmor =  token->armor;
                continue;
            }
            let node =  token->toNode();
            let stack[count(stack) - 1]->children[] = node;
            if token instanceof TokenStart {
                let stack[] = node;
            }
        }
        //assert(count($stack) == 1);
        return stack[0];
    }
    
    public static function flatten(node, config, context)
    {
        var level, nodes, tmpArray59b167b451ddb6903a66bc546bac55a7, closingTokens, tokens, start, end, tmpListStartEnd, childNode, token;
    
        let level = 0;
        let nodes =  [level : new Queue(tmpArray59b167b451ddb6903a66bc546bac55a7)];
        let closingTokens =  [];
        let tokens =  [];
        do {
            while (!(nodes[level]->isEmpty())) {
                let node =  nodes[level]->shift();
                // FIFO
                let tmpListStartEnd = node->toTokenPair();
                let start = tmpListStartEnd[0];
                let end = tmpListStartEnd[1];
                if level > 0 {
                    let tokens[] = start;
                }
                if end !== NULL {
                    let closingTokens[level][] = end;
                }
                if node instanceof NodeElement {
                    let level++;
                    let nodes[level] = new Queue();
                    for childNode in node->children {
                        nodes[level]->push(childNode);
                    }
                }
            }
            let level--;
            if level && isset closingTokens[level] {
                let token =  array_pop(closingTokens[level]);
                while (token) {
                    let tokens[] = token;
                let token =  array_pop(closingTokens[level]);
                }
            }
        } while (level > 0);
        return tokens;
    }

}