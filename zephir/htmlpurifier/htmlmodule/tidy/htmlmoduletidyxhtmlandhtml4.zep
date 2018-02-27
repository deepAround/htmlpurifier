namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\AttrTransform\AttrTransformBgColor;
use HTMLPurifier\AttrTransform\AttrTransformBoolToCSS;
use HTMLPurifier\AttrTransform\AttrTransformBorder;
use HTMLPurifier\AttrTransform\AttrTransformEnumToCSS;
use HTMLPurifier\AttrTransform\AttrTransformImgSpace;
use HTMLPurifier\AttrTransform\AttrTransformLength;
use HTMLPurifier\HTMLModule\HTMLModuleTidy;
use HTMLPurifier\TagTransform\TagTransformFont;
use HTMLPurifier\TagTransform\TagTransformSimple;
class HTMLModuleTidyXHTMLAndHTML4 extends HTMLModuleTidy
{
    /**
     * @return array
     */
    public function makeFixes() -> array
    {
        var r, tmpArrayfa0c8802eba836838d2f3d7c3a42b9f7, tmpArray6294dd69cc88c85ad16951ad76f4bdc8, tmpArrayc7187b3e000376b2936ad67ae0a573c6, tmpArraye40193ba39825f4172d7d2804805dc60, align_lookup, align_values, v, tmpArray3ea3fad26da7d71659c47749b6a59077, ul_types, ol_types, li_types;
    
        let r =  [];
        // == deprecated tag transforms ===================================
        let r["font"] = new TagTransformFont();
        let r["menu"] = new TagTransformSimple("ul");
        let r["dir"] = new TagTransformSimple("ul");
        let r["center"] = new TagTransformSimple("div", "text-align:center;");
        let r["u"] = new TagTransformSimple("span", "text-decoration:underline;");
        let r["s"] = new TagTransformSimple("span", "text-decoration:line-through;");
        let r["strike"] = new TagTransformSimple("span", "text-decoration:line-through;");
        // == deprecated attribute transforms =============================
        let r["caption@align"] = new AttrTransformEnumToCSS("align", ["left" : "text-align:left;", "right" : "text-align:right;", "top" : "caption-side:top;", "bottom" : "caption-side:bottom;"]);
        // @align for img -------------------------------------------------
        let r["img@align"] = new AttrTransformEnumToCSS("align", ["left" : "float:left;", "right" : "float:right;", "top" : "vertical-align:top;", "middle" : "vertical-align:middle;", "bottom" : "vertical-align:baseline;"]);
        // @align for table -----------------------------------------------
        let r["table@align"] = new AttrTransformEnumToCSS("align", ["left" : "float:left;", "center" : "margin-left:auto;margin-right:auto;", "right" : "float:right;"]);
        // @align for hr -----------------------------------------------
        let r["hr@align"] = new AttrTransformEnumToCSS("align", ["left" : "margin-left:0;margin-right:auto;text-align:left;", "center" : "margin-left:auto;margin-right:auto;text-align:center;", "right" : "margin-left:auto;margin-right:0;text-align:right;"]);
        // @align for h1, h2, h3, h4, h5, h6, p, div ----------------------
        // {{{
        let align_lookup =  [];
        let align_values =  ["left", "right", "center", "justify"];
        for v in align_values {
            let align_lookup[v] = "text-align:{v};";
        }
        // }}}
        let r["div@align"] = new AttrTransformEnumToCSS("align", align_lookup);
        let r["p@align"] = r["div@align"];
        let r["h6@align"] = r["p@align"];
        let r["h5@align"] = r["h6@align"];
        let r["h4@align"] = r["h5@align"];
        let r["h3@align"] = r["h4@align"];
        let r["h2@align"] = r["h3@align"];
        let r["h1@align"] = r["h2@align"];
        // @bgcolor for table, tr, td, th ---------------------------------
        let r["th@bgcolor"] = new AttrTransformBgColor();
        let r["td@bgcolor"] = r["th@bgcolor"];
        let r["table@bgcolor"] = r["td@bgcolor"];
        // @border for img ------------------------------------------------
        let r["img@border"] = new AttrTransformBorder();
        // @clear for br --------------------------------------------------
        let r["br@clear"] = new AttrTransformEnumToCSS("clear", ["left" : "clear:left;", "right" : "clear:right;", "all" : "clear:both;", "none" : "clear:none;"]);
        // @height for td, th ---------------------------------------------
        let r["th@height"] = new AttrTransformLength("height");
        let r["td@height"] = r["th@height"];
        // @hspace for img ------------------------------------------------
        let r["img@hspace"] = new AttrTransformImgSpace("hspace");
        // @noshade for hr ------------------------------------------------
        // this transformation is not precise but often good enough.
        // different browsers use different styles to designate noshade
        let r["hr@noshade"] = new AttrTransformBoolToCSS("noshade", "color:#808080;background-color:#808080;border:0;");
        // @nowrap for td, th ---------------------------------------------
        let r["th@nowrap"] = new AttrTransformBoolToCSS("nowrap", "white-space:nowrap;");
        let r["td@nowrap"] = r["th@nowrap"];
        // @size for hr  --------------------------------------------------
        let r["hr@size"] = new AttrTransformLength("size", "height");
        // @type for li, ol, ul -------------------------------------------
        // {{{
        let ul_types =  ["disc" : "list-style-type:disc;", "square" : "list-style-type:square;", "circle" : "list-style-type:circle;"];
        let ol_types =  ["1" : "list-style-type:decimal;", "i" : "list-style-type:lower-roman;", "I" : "list-style-type:upper-roman;", "a" : "list-style-type:lower-alpha;", "A" : "list-style-type:upper-alpha;"];
        let li_types =  ul_types + ol_types;
        // }}}
        let r["ul@type"] = new AttrTransformEnumToCSS("type", ul_types);
        let r["ol@type"] = new AttrTransformEnumToCSS("type", ol_types, true);
        let r["li@type"] = new AttrTransformEnumToCSS("type", li_types, true);
        // @vspace for img ------------------------------------------------
        let r["img@vspace"] = new AttrTransformImgSpace("vspace");
        // @width for hr, td, th ------------------------------------------
        let r["hr@width"] = new AttrTransformLength("width");
        let r["th@width"] = r["hr@width"];
        let r["td@width"] = r["th@width"];
        return r;
    }

}