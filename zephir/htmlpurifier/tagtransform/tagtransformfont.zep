namespace HTMLPurifier\TagTransform;

use HTMLPurifier\TagTransform;
use HTMLPurifier\Token\TokenEnd;
/**
 * Transforms FONT tags to the proper form (SPAN with CSS styling)
 *
 * This transformation takes the three proprietary attributes of FONT and
 * transforms them into their corresponding CSS attributes.  These are color,
 * face, and size.
 *
 * @note Size is an interesting case because it doesn't map cleanly to CSS.
 *       Thanks to
 *       http://style.cleverchimp.com/font_size_intervals/altintervals.html
 *       for reasonable mappings.
 * @warning This doesn't work completely correctly; specifically, this
 *          TagTransform operates before well-formedness is enforced, so
 *          the "active formatting elements" algorithm doesn't get applied.
 */
class TagTransformFont extends TagTransform
{
    /**
     * @type string
     */
    public transform_to = "span";
    /**
     * @type array
     */
    protected _size_lookup = ["0" : "xx-small", "1" : "xx-small", "2" : "small", "3" : "medium", "4" : "large", "5" : "x-large", "6" : "xx-large", "7" : "300%", "-1" : "smaller", "-2" : "60%", "+1" : "larger", "+2" : "150%", "+3" : "200%", "+4" : "300%"];
    /**
     * @param Token_Tag $tag
     * @param Config $config
     * @param Context $context
     * @return Token_End|string
     */
    public function transform(tag, <Config> config, <Context> context)
    {
        var new_tag, attr, prepend_style, size;
    
        if tag instanceof TokenEnd {
            let new_tag =  clone tag;
            let new_tag->name =  this->transform_to;
            return new_tag;
        }
        let attr =  tag->attr;
        let prepend_style = "";
        // handle color transform
        if isset attr["color"] {
            let prepend_style .= "color:" . attr["color"] . ";";
            unset attr["color"];
        
        }
        // handle face transform
        if isset attr["face"] {
            let prepend_style .= "font-family:" . attr["face"] . ";";
            unset attr["face"];
        
        }
        // handle size transform
        if isset attr["size"] {
            // normalize large numbers
            if attr["size"] !== "" {
                if attr["size"][0] == "+" || attr["size"][0] == "-" {
                    let size =  (int) attr["size"];
                    if size < -2 {
                        let attr["size"] = "-2";
                    }
                    if size > 4 {
                        let attr["size"] = "+4";
                    }
                } else {
                    let size =  (int) attr["size"];
                    if size > 7 {
                        let attr["size"] = "7";
                    }
                }
            }
            if isset this->_size_lookup[attr["size"]] {
                let prepend_style .= "font-size:" . this->_size_lookup[attr["size"]] . ";";
            }
            unset attr["size"];
        
        }
        if prepend_style {
            let attr["style"] =  isset attr["style"] ? prepend_style . attr["style"]  : prepend_style;
        }
        let new_tag =  clone tag;
        let new_tag->name =  this->transform_to;
        let new_tag->attr = attr;
        return new_tag;
    }

}