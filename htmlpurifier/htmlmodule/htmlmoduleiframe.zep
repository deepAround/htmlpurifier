namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
/**
 * XHTML 1.1 Iframe Module provides inline frames.
 *
 * @note This module is not considered safe unless an Iframe
 * whitelisting mechanism is specified.  Currently, the only
 * such mechanism is %URL.SafeIframeRegexp
 */
class HTMLModuleIframe extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Iframe";
    /**
     * @type bool
     */
    public safe = false;
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArray2e1e459116d3290fbb229a9d9f10e579;
    
        if config->get("HTML.SafeIframe") {
            let this->safe =  true;
        }
        let tmpArray2e1e459116d3290fbb229a9d9f10e579 = ["src" : "URI#embedded", "width" : "Length", "height" : "Length", "name" : "ID", "scrolling" : "Enum#yes,no,auto", "frameborder" : "Enum#0,1", "longdesc" : "URI", "marginheight" : "Pixels", "marginwidth" : "Pixels"];
        this->addElement("iframe", "Inline", "Flow", "Common", tmpArray2e1e459116d3290fbb229a9d9f10e579);
    }

}