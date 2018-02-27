namespace HTMLPurifier\VarParser;

use HTMLPurifier\VarParser;
use HTMLPurifier\VarParserException;
/**
 * This variable parser uses PHP's internal code engine. Because it does
 * this, it can represent all inputs; however, it is dangerous and cannot
 * be used by users.
 */
class VarParserNative extends VarParser
{
    /**
     * @param mixed $var
     * @param int $type
     * @param bool $allow_null
     * @return null|string
     */
    protected function parseImplementation(varr, int type, bool allow_null)
    {
        return this->evalExpression(varr);
    }
    
    /**
     * @param string $expr
     * @return mixed
     * @throws VarParserException
     */
    protected function evalExpression(string expr)
    {
        var varr, result;
    
        let varr =  null;
        let result =  eval("\$var = {expr};");
        if result === false {
            throw new VarParserException("Fatal error in evaluated code");
        }
        return varr;
    }

}