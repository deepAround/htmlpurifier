namespace HTMLPurifier\AttrTransform;

// must be called POST validation
/**
 * Adds rel="noopener" to any links which target a different window
 * than the current one.  This is used to prevent malicious websites
 * from silently replacing the original window, which could be used
 * to do phishing.
 * This transform is controlled by %HTML.TargetNoopener.
 */
class AttrTransformTargetNoopener extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var rels;
    
        if isset attr["rel"] {
            let rels =  explode(" ", attr["rel"]);
        } else {
            let rels =  [];
        }
        if isset attr["target"] && !(in_array("noopener", rels)) {
            let rels[] = "noopener";
        }
        if !(empty(rels)) || isset attr["rel"] {
            let attr["rel"] =  implode(" ", rels);
        }
        return attr;
    }

}