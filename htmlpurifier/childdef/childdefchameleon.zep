namespace HTMLPurifier\ChildDef;

/**
 * Definition that uses different definitions depending on context.
 *
 * The del and ins tags are notable because they allow different types of
 * elements depending on whether or not they're in a block or inline context.
 * Chameleon allows this behavior to happen by using two different
 * definitions depending on context.  While this somewhat generalized,
 * it is specifically intended for those two tags.
 */
class ChildDefChameleon extends \HTMLPurifier\ChildDef
{
    /**
     * Instance of the definition object to use when inline. Usually stricter.
     * @type ChildDefOptional
     */
    public inlinee;
    /**
     * Instance of the definition object to use when block.
     * @type ChildDefOptional
     */
    public block;
    /**
     * @type string
     */
    public type = "chameleon";
    /**
     * @param array $inline List of elements to allow when inline.
     * @param array $block List of elements to allow when block.
     */
    public function __construct(array inlinee, array block) -> void
    {
        let this->inlinee =  new ChildDefOptional(inlinee);
        let this->block =  new ChildDefOptional(block);
        let this->elements =  this->block->elements;
    }
    
    /**
     * @param Node[] $children
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> bool
    {
        if context->get("IsInline") === false {
            return this->block->validateChildren(children, config, context);
        } else {
            return this->inlinee->validateChildren(children, config, context);
        }
    }

}