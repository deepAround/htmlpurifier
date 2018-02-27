namespace HTMLPurifier\Filter;

use HTMLPurifier\Filter;
class FilterYouTube extends Filter
{
    /**
     * @type string
     */
    public name = "YouTube";
    /**
     * @param string $html
     * @param Config $config
     * @param Context $context
     * @return string
     */
    public function preFilter(string html, <Config> config, <Context> context) -> string
    {
        var pre_regex, pre_replace;
    
        let pre_regex =  "#<object[^>]+>.+?" . "(?:http:)?//www.youtube.com/((?:v|cp)/[A-Za-z0-9\\-_=]+).+?</object>#s";
        let pre_replace = "<span class=\"youtube-embed\">\\1</span>";
        return preg_replace(pre_regex, pre_replace, html);
    }
    
    /**
     * @param string $html
     * @param Config $config
     * @param Context $context
     * @return string
     */
    public function postFilter(string html, <Config> config, <Context> context) -> string
    {
        var post_regex, tmpArraya41bb862a0cc520a49258e676f08ac5a;
    
        let post_regex = "#<span class=\"youtube-embed\">((?:v|cp)/[A-Za-z0-9\\-_=]+)</span>#";
        let tmpArraya41bb862a0cc520a49258e676f08ac5a = [this, "postFilterCallback"];
        return preg_replace_callback(post_regex, tmpArraya41bb862a0cc520a49258e676f08ac5a, html);
    }
    
    /**
     * @param $url
     * @return string
     */
    protected function armorUrl(url) -> string
    {
        return str_replace("--", "-&#45;", url);
    }
    
    /**
     * @param array $matches
     * @return string
     */
    protected function postFilterCallback(array matches) -> string
    {
        var url;
    
        let url =  this->armorUrl(matches[1]);
        return "<object width=\"425\" height=\"350\" type=\"application/x-shockwave-flash\" " . "data=\"//www.youtube.com/" . url . "\">" . "<param name=\"movie\" value=\"//www.youtube.com/" . url . "\"></param>" . "<!--[if IE]>" . "<embed src=\"//www.youtube.com/" . url . "\"" . "type=\"application/x-shockwave-flash\"" . "wmode=\"transparent\" width=\"425\" height=\"350\" />" . "<![endif]-->" . "</object>";
    }

}