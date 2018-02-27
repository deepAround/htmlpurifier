namespace HTMLPurifier;

use ArrayObject;
/**
 * This is in almost every respect equivalent to an array except
 * that it keeps track of which keys were accessed.
 *
 * @warning For the sake of backwards compatibility with early versions
 *     of PHP 5, you must not use the $hash[$key] syntax; if you do
 *     our version of offsetGet is never called.
 */
class StringHash extends ArrayObject
{
    /**
     * @type array
     */
    protected accessed = [];
    /**
     * Retrieves a value, and logs the access.
     * @param mixed $index
     * @return mixed
     */
    public function offsetGet(index)
    {
        let this->accessed[index] = true;
        return parent::offsetGet(index);
    }
    
    /**
     * Returns a lookup array of all array indexes that have been accessed.
     * @return array in form array($index => true).
     */
    public function getAccessed() -> array
    {
        return this->accessed;
    }
    
    /**
     * Resets the access array.
     */
    public function resetAccessed() -> void
    {
        let this->accessed =  [];
    }

}