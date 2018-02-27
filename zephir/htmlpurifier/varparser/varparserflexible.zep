namespace HTMLPurifier\VarParser;

use HTMLPurifier\VarParser;
use HTMLPurifier\VarParserException;
/**
 * Performs safe variable parsing based on types which can be used by
 * users. This may not be able to represent all possible data inputs,
 * however.
 */
class VarParserFlexible extends VarParser
{
    /**
     * @param mixed $var
     * @param int $type
     * @param bool $allow_null
     * @return array|bool|float|int|mixed|null|string
     * @throws VarParserException
     */
    protected function parseImplementation(varr, int type, bool allow_null)
    {
        var tmpArray40cd750bba9870f18aada2478b24840a, i, j, nvar, keypair, c, keys, new, key, value;
    
        if allow_null && varr === null {
            return null;
        }
        if self::MIXED || self::ISTRING || self::STRING || self::TEXT || self::ITEXT {
            return varr;
        } elseif self::ALIST || self::HASH || self::LOOKUP {
            if is_string(varr) {
                // special case: technically, this is an array with
                // a single empty string item, but having an empty
                // array is more intuitive
                if varr == "" {
                    let tmpArray40cd750bba9870f18aada2478b24840a = [];
                    return tmpArray40cd750bba9870f18aada2478b24840a;
                }
                if strpos(varr, "
") === false && strpos(varr, "") === false {
                    // simplistic string to array method that only works
                    // for simple lists of tag names or alphanumeric characters
                    let varr =  explode(",", varr);
                } else {
                    let varr =  preg_split("/(,|[\\n\\r]+)/", varr);
                }
                // remove spaces
                for i, j in varr {
                    let varr[i] =  trim(j);
                }
                if type === self::HASH {
                    // key:value,key2:value2
                    let nvar =  [];
                    for keypair in varr {
                        let c =  explode(":", keypair, 2);
                        if !(isset c[1]) {
                            continue;
                        }
                        let nvar[trim(c[0])] =  trim(c[1]);
                    }
                    let varr = nvar;
                }
            }
            if !(is_array(varr)) {
                break;
            }
            let keys =  array_keys(varr);
            if keys === array_keys(keys) {
                if type == self::ALIST {
                    return varr;
                } elseif type == self::LOOKUP {
                    let new =  [];
                    for key in varr {
                        let new[key] = true;
                    }
                    return new;
                } else {
                    break;
                }
            }
            if type === self::ALIST {
                trigger_error("Array list did not have consecutive integer indexes", E_USER_WARNING);
                return array_values(varr);
            }
            if type === self::LOOKUP {
                for key, value in varr {
                    if value !== true {
                        trigger_error("Lookup array has non-true value at key '{key}'; " . "maybe your input array was not indexed numerically", E_USER_WARNING);
                    }
                    let varr[key] = true;
                }
            }
            return varr;
        } elseif self::BOOL {
            if is_int(varr) && (varr === 0 || varr === 1) {
                let varr =  (bool) varr;
            } elseif is_string(varr) {
                if varr == "on" || varr == "true" || varr == "1" {
                    let varr =  true;
                } elseif varr == "off" || varr == "false" || varr == "0" {
                    let varr =  false;
                } else {
                    throw new VarParserException("Unrecognized value '{varr}' for {type}");
                }
            }
            return varr;
        } elseif self::FLOAT {
            if is_string(varr) && is_numeric(varr) || is_int(varr) {
                let varr =  (double) varr;
            }
            return varr;
        } elseif self::INT {
            if is_string(varr) && ctype_digit(varr) {
                let varr =  (int) varr;
            }
            return varr;
        } else {
            this->errorInconsistent(__CLASS__, type);
        }
        this->errorGeneric(varr, type);
    }

}