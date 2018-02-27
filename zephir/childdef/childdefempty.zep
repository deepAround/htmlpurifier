namespace HTMLPurifier\ChildDef;

/**
 * Definition that disallows all elements.
 * @warning validateChildren() in this class is actually never called, because
 *          empty elements are corrected in Strategy_MakeWellFormed
 *          before child definitions are parsed in earnest by
 *          Strategy_FixNesting.
 */
class ChildDefEmpty extends \HTMLPurifier\ChildDef
{
    /**
     * @type bool
     */
    public allow_empty = true;
    /**
     * @type string
     */
    public type = "empty";
    public function __construct() -> void
    {
    }
    
    /**
     * @param Node[] $children
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> array
    {
        var tmpArray40cd750bba9870f18aada2478b24840a;
    
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return tmpArray40cd750bba9870f18aada2478b24840a;
    }

}