namespace HTMLPurifier\Injector;

use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
/**
 * Injector that converts configuration directive syntax %Namespace.Directive
 * to links
 */
class InjectorPurifierLinkify extends Injector
{
    /**
     * @type string
     */
    public name = "PurifierLinkify";
    /**
     * @type string
     */
    public docURL;
    /**
     * @type array
     */
    public needed = ["a" : ["href"]];
    /**
     * @param Config $config
     * @param Context $context
     * @return string
     */
    public function prepare(<Config> config, <Context> context) -> string
    {
        let this->docURL =  config->get("AutoFormat.PurifierLinkify.DocURL");
        return parent::prepare(config, context);
    }
    
    /**
     * @param Token $token
     */
    public function handleText(<Token> token)
    {
        var bits, i, c, l, tmpArray2449f82e328dc58a1a2dbfd00c9d50a2;
    
        if !(this->allowsElement("a")) {
            return;
        }
        if strpos(token->data, "%") === false {
            return;
        }
        let bits =  preg_split("#%([a-z0-9]+\\.[a-z0-9]+)#Si", token->data, -1, PREG_SPLIT_DELIM_CAPTURE);
        let token =  [];
        // $i = index
        // $c = count
        // $l = is link
        let i = 0;
        let c =  count(bits);
        let l =  false;
        for i in range(0, c) {
            if !(l) {
                if bits[i] === "" {
                    continue;
                }
                let token[] = new TokenText(bits[i]);
            } else {
                let token[] = new TokenStart("a", ["href" : str_replace("%s", bits[i], this->docURL)]);
                let token[] = new TokenText("%" . bits[i]);
                let token[] = new TokenEnd("a");
            }
        }
    }

}