namespace HTMLPurifier\ChildDef;

/**
 * Definition that allows a set of elements, and allows no children.
 * @note This is a hack to reuse code from ChildDefRequired,
 *       really, one shouldn't inherit from the other.  Only altered behavior
 *       is to overload a returned false with an array.  Thus, it will never
 *       return false.
 */
class ChildDefOptional extends ChildDefRequired
{
    /**
     * @type bool
     */
    public allow_empty = true;
    /**
     * @type string
     */
    public type = "optional";
    /**
     * @param array $children
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> array
    {
        var result, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let result =  parent::validateChildren(children, config, context);
        // we assume that $children is not modified
        if result === false {
            if empty(children) {
                return true;
            } elseif this->whitespace {
                return children;
            } else {
                let tmpArray40cd750bba9870f18aada2478b24840a = [];
                return tmpArray40cd750bba9870f18aada2478b24840a;
            }
        }
        return result;
    }

}