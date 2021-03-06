namespace HTMLPurifier;

/**
 * Records errors for particular segments of an HTML document such as tokens,
 * attributes or CSS properties. They can contain error structs (which apply
 * to components of what they represent), but their main purpose is to hold
 * errors applying to whatever struct is being used.
 */
class ErrorStruct
{
    /**
     * Possible values for $children first-key. Note that top-level structures
     * are automatically token-level.
     */
    const TOKEN = 0;
    const ATTR = 1;
    const CSSPROP = 2;
    /**
     * Type of this struct.
     * @type string
     */
    public type;
    /**
     * Value of the struct we are recording errors for. There are various
     * values for this:
     *  - TOKEN: Instance of Token
     *  - ATTR: array('attr-name', 'value')
     *  - CSSPROP: array('prop-name', 'value')
     * @type mixed
     */
    public value;
    /**
     * Errors registered for this structure.
     * @type array
     */
    public errors = [];
    /**
     * Child ErrorStructs that are from this structure. For example, a TOKEN
     * ErrorStruct would contain ATTR ErrorStructs. This is a multi-dimensional
     * array in structure: [TYPE]['identifier']
     * @type array
     */
    public children = [];
    /**
     * @param string $type
     * @param string $id
     * @return mixed
     */
    public function getChild(string type, string id)
    {
        if !(isset this->children[type][id]) {
            let this->children[type][id] = new ErrorStruct();
            let this->children[type][id]->type = type;
        }
        return this->children[type][id];
    }
    
    /**
     * @param int $severity
     * @param string $message
     */
    public function addError(int severity, string message) -> void
    {
        let this->errors[] =  [severity, message];
    }

}