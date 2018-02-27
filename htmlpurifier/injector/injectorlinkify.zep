namespace HTMLPurifier\Injector;

use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
/**
 * Injector that converts http, https and ftp text URLs to actual links.
 */
class InjectorLinkify extends Injector
{
    /**
     * @type string
     */
    public name = "Linkify";
    /**
     * @type array
     */
    public needed = ["a" : ["href"]];
    /**
     * @param Token $token
     */
    public function handleText(<Token> token)
    {
        var bits, i, c, l, tmpArray5eea18bcc9d0d4fe2af3a02b682a18f5;
    
        if !(this->allowsElement("a")) {
            return;
        }
        if strpos(token->data, "://") === false {
            // our really quick heuristic failed, abort
            // this may not work so well if we want to match things like
            // "google.com", but then again, most people don't
            return;
        }
        // there is/are URL(s). Let's split the string.
        // We use this regex:
        // https://gist.github.com/gruber/249502
        // but with @cscott's backtracking fix and also
        // the Unicode characters un-Unicodified.
        let bits =  preg_split("/\\b((?:[a-z][\\w\\-]+:(?:\\/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}\\/)(?:[^\\s()<>]|\\((?:[^\\s()<>]|(?:\\([^\\s()<>]+\\)))*\\))+(?:\\((?:[^\\s()<>]|(?:\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?\\x{00ab}\\x{00bb}\\x{201c}\\x{201d}\\x{2018}\\x{2019}]))/iu", token->data, -1, PREG_SPLIT_DELIM_CAPTURE);
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
                let token[] = new TokenStart("a", ["href" : bits[i]]);
                let token[] = new TokenText(bits[i]);
                let token[] = new TokenEnd("a");
            }
        }
    }

}