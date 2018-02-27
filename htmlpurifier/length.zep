namespace HTMLPurifier;

use HTMLPurifier\AttrDef\Css\AttrDefCSSNumber;
/**
 * Represents a measurable length, with a string numeric magnitude
 * and a unit. This object is immutable.
 */
class Length
{
    /**
     * String numeric magnitude.
     * @type string
     */
    protected n;
    /**
     * String unit. False is permitted if $n = 0.
     * @type string|bool
     */
    protected unit;
    /**
     * Whether or not this length is valid. Null if not calculated yet.
     * @type bool
     */
    protected isValid;
    /**
     * Array Lookup array of units recognized by CSS 3
     * @type array
     */
    protected static allowedUnits = ["em" : true, "ex" : true, "px" : true, "in" : true, "cm" : true, "mm" : true, "pt" : true, "pc" : true, "ch" : true, "rem" : true, "vw" : true, "vh" : true, "vmin" : true, "vmax" : true];
    /**
     * @param string $n Magnitude
     * @param bool|string $u Unit
     */
    public function __construct(string n = "0", u = false) -> void
    {
        let this->n =  (string) n;
        let this->unit =  u !== false ? (string) u  : false;
    }
    
    /**
     * @param string $s Unit string, like '2em' or '3.4in'
     * @return Length
     * @warning Does not perform validation.
     */
    public static function make(string s) -> <Length>
    {
        var n_length, n, unit;
    
        if s instanceof Length {
            return s;
        }
        let n_length =  strspn(s, "1234567890.+-");
        let n =  substr(s, 0, n_length);
        let unit =  substr(s, n_length);
        if unit === "" {
            let unit =  false;
        }
        return new Length(n, unit);
    }
    
    /**
     * Validates the number and unit.
     * @return bool
     */
    protected function validate() -> bool
    {
        var def, result;
    
        // Special case:
        if this->n === "+0" || this->n === "-0" {
            let this->n = "0";
        }
        if this->n === "0" && this->unit === false {
            return true;
        }
        if !(ctype_lower(this->unit)) {
            let this->unit =  strtolower(this->unit);
        }
        if !(isset Length::allowedUnits[this->unit]) {
            return false;
        }
        // Hack:
        let def =  new AttrDefCSSNumber();
        let result =  def->validate(this->n, false, false);
        if result === false {
            return false;
        }
        let this->n = result;
        return true;
    }
    
    /**
     * Returns string representation of number.
     * @return string
     */
    public function toString() -> string
    {
        if !(this->isValid()) {
            return false;
        }
        return this->n . this->unit;
    }
    
    /**
     * Retrieves string numeric magnitude.
     * @return string
     */
    public function getN() -> string
    {
        return this->n;
    }
    
    /**
     * Retrieves string unit.
     * @return string
     */
    public function getUnit() -> string
    {
        return this->unit;
    }
    
    /**
     * Returns true if this length unit is valid.
     * @return bool
     */
    public function isValid() -> bool
    {
        if this->isValid === null {
            let this->isValid =  this->validate();
        }
        return this->isValid;
    }
    
    /**
     * Compares two lengths, and returns 1 if greater, -1 if less and 0 if equal.
     * @param Length $l
     * @return int
     * @warning If both values are too large or small, this calculation will
     *          not work properly
     */
    public function compareTo(<Length> l) -> int
    {
        var converter;
    
        if l === false {
            return false;
        }
        if l->unit !== this->unit {
            let converter =  new UnitConverter();
            let l =  converter->convert(l, this->unit);
            if l === false {
                return false;
            }
        }
        return this->n - l->n;
    }

}