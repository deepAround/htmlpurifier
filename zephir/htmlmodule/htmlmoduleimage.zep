namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefURI;
use HTMLPurifier\AttrTransform\AttrTransformImgRequired;
/**
 * XHTML 1.1 Image Module provides basic image embedding.
 * @note There is specialized code for removing empty images in
 *       Strategy_RemoveForeignElements
 */
class HTMLModuleImage extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Image";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var max, img, tmpArray099ae056ef6622a9c40f16129aebe47b;
    
        let max =  config->get("HTML.MaxImgLength");
        let tmpArray099ae056ef6622a9c40f16129aebe47b = ["alt*" : "Text", "height" : "Pixels#" . max, "width" : "Pixels#" . max, "longdesc" : "URI", "src*" : new AttrDefURI(true)];
        let img =  this->addElement("img", "Inline", "Empty", "Common", tmpArray099ae056ef6622a9c40f16129aebe47b);
        if max === null || config->get("HTML.Trusted") {
            let img->attr["width"] = "Length";
            let img->attr["height"] = img->attr["width"];
        }
        // kind of strange, but splitting things up would be inefficient
        let img->attr_transform_post[] = new AttrTransformImgRequired();
        let img->attr_transform_pre[] = img->attr_transform_post[];
    }

}