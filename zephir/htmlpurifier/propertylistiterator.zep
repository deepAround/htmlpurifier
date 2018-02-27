namespace HTMLPurifier;

use FilterIterator;
use Iterator;
/**
 * Property list iterator. Do not instantiate this class directly.
 */
class PropertyListIterator extends FilterIterator
{
    /**
     * @type int
     */
    protected l;
    /**
     * @type string
     */
    protected filter;
    /**
     * @param Iterator $iterator Array of data to iterate over
     * @param string $filter Optional prefix to only allow values of
     */
    public function __construct(<Iterator> iterator, string filter = null) -> void
    {
        parent::__construct(iterator);
        let this->l =  strlen(filter);
        let this->filter = filter;
    }
    
    /**
     * @return bool
     */
    public function accept() -> bool
    {
        var key;
    
        let key =  this->getInnerIterator()->key();
        if strncmp(key, this->filter, this->l) !== 0 {
            return false;
        }
        return true;
    }

}