namespace HTMLPurifier;

/**
 * Abstract base token class that all others inherit from.
 */
abstract class Token
{
    /**
     * Line number node was on in source document. Null if unknown.
     * @type int
     */
    public line;
    /**
     * Column of line node was on in source document. Null if unknown.
     * @type int
     */
    public col;
    /**
     * Lookup array of processing that this token is exempt from.
     * Currently, valid values are "ValidateAttributes" and
     * "MakeWellFormed_TagClosedError"
     * @type array
     */
    public armor = [];
    /**
     * Used during MakeWellFormed.  See Note [Injector skips]
     * @type
     */
    public skip;
    /**
     * @type
     */
    public rewind;
    /**
     * @type
     */
    public carryover;
    /**
     * @param string $n
     * @return null|string
     */
    public function __get(string n)
    {
        if n === "type" {
            trigger_error("Deprecated type property called; use instanceof", E_USER_NOTICE);
            switch (get_class(this)) {
                case "Token_Start":
                    return "start";
                case "Token_Empty":
                    return "empty";
                case "Token_End":
                    return "end";
                case "Token_Text":
                    return "text";
                case "Token_Comment":
                    return "comment";
                default:
                    return null;
            }
        }
    }
    
    /**
     * Sets the position of the token in the source document.
     * @param int $l
     * @param int $c
     */
    public function position(int l = null, int c = null) -> void
    {
        let this->line = l;
        let this->col = c;
    }
    
    /**
     * Convenience function for DirectLex settings line/col position.
     * @param int $l
     * @param int $c
     */
    public function rawPosition(int l, int c) -> void
    {
        if c === -1 {
            let l++;
        }
        let this->line = l;
        let this->col = c;
    }
    
    /**
     * Converts a token into its corresponding node.
     */
    public abstract function toNode() -> void;

}