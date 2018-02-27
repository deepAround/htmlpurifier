namespace HTMLPurifier;

use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrDef\AttrDefInteger;
use HTMLPurifier\AttrDef\AttrDefSwitch;
use HTMLPurifier\AttrDef\Css\AttrDefCSSAlphaValue;
use HTMLPurifier\AttrDef\Css\AttrDefCSSBackground;
use HTMLPurifier\AttrDef\Css\AttrDefCSSBackgroundPosition;
use HTMLPurifier\AttrDef\Css\AttrDefCSSBorder;
use HTMLPurifier\AttrDef\Css\AttrDefCSSColor;
use HTMLPurifier\AttrDef\Css\AttrDefCSSComposite;
use HTMLPurifier\AttrDef\Css\AttrDefCSSFilter;
use HTMLPurifier\AttrDef\Css\AttrDefCSSFont;
use HTMLPurifier\AttrDef\Css\AttrDefCSSFontFamily;
use HTMLPurifier\AttrDef\Css\AttrDefCSSImportantDecorator;
use HTMLPurifier\AttrDef\Css\AttrDefCSSLength;
use HTMLPurifier\AttrDef\Css\AttrDefCSSListStyle;
use HTMLPurifier\AttrDef\Css\AttrDefCSSMultiple;
use HTMLPurifier\AttrDef\Css\AttrDefCSSNumber;
use HTMLPurifier\AttrDef\Css\AttrDefCSSPercentage;
use HTMLPurifier\AttrDef\Css\AttrDefCSSTextDecoration;
use HTMLPurifier\AttrDef\Css\AttrDefCSSURI;
/**
 * Defines allowed CSS attributes and what their values are.
 * @see HTMLDefinition
 */
class CSSDefinition extends Definition
{
    public type = "CSS";
    /**
     * Assoc array of attribute name to definition object.
     * @type AttrDef[]
     */
    public info = [];
    /**
     * Constructs the info array.  The meat of this class.
     * @param Config $config
     */
    protected function doSetup(<Config> config) -> void
    {
        var tmpArray7cef9b6e8008c34068931922568ddff1, border_style, tmpArraycba5140c1d527cb3cadcdb76d50435d2, tmpArray24ace7047ab8c8b74a9bf524ea7f19fd, tmpArrayf15c8ca05d441fd9d3a24b8dad01643c, tmpArray888a8a1607f19a04017f3ffe4983474c, tmpArrayf4249b8d2e5cb068d4e187c6d5137cb2, uri_or_none, tmpArraycfaa94a4ca932d43520885ca715b244b, tmpArray18cbb024b7142b47d42db817639d1e69, tmpArrayc397432dcb660a4bc416a7e362e8ac75, tmpArraycd0c610446a8d38a2403f915b279f47c, tmpArrayab1ac274d3cc676640f3d9a57cda3c5e, tmpArrayb6182548796ae5db14d7374f7a37c1f0, tmpArray5d9c3b652e7a46d0f3785487299d81fb, border_color, tmpArrayb30adc638e3865d24165238b29823671, tmpArray41f995a3ef184903c63933a41a383ff1, border_width, tmpArray3a41e580486ba05f8e72b0fa6210ffa5, tmpArraye2b1ba31fd171df8575b32f49da8001f, tmpArrayda2fe65b17bf2e9bb7cfbf7fcd3ae1ec, tmpArray182f61fd9b6d47dd1a581a8891224623, tmpArrayaf4f1b9bec7fbe638bc565c44625403f, tmpArraydaec120d852050bc07ab0e2dd75b12db, tmpArray9ad9799bffbd0b3ff2d50f9c0be21cb7, tmpArraye8149e46033774783b4b4fdb9c147034, tmpArray5736eca31352edf623cb017a2d3821f7, tmpArraydf8e1d9bbc52d72253dc87e7da8804f5, margin, tmpArrayb8b4e18bef5fed6761d782b3c23d4013, tmpArrayf8a63c1e0fe2205e5d793f06fde3eb76, padding, tmpArray25a93ff2b2fd849be7b63cbe0352187b, tmpArray5b034aefc1b8e785551c76a743e45c13, trusted_wh, tmpArraye96d24cb4ea99881913c1d52ba4179f9, tmpArrayeb44b4e34105780cc74b7b5be365eba0, max, tmpArraycbc27ca0642f82b35c79a5a057890d73, tmpArray948ea4e613dfae534d74ac932d1705cf, tmpArray71bd4dfa165743730b58ad2e6be3963e, tmpArraya2dd1c9b374f73520510b5d73f129e53, tmpArrayd9f9dd1d6d8e7b58d8ba2a3cb40142fb, tmpArrayeb26f293945a0578861933f799a5c213, tmpArraycdf2d80944ad32af009b342f724f29c0, tmpArrayfab556855498e904a6c9cd5027a6534c, tmpArray69480fc9c6d1091c7b0dbc4c8c356d9b, allow_important, k, v;
    
        let this->info["text-align"] = new AttrDefEnum(["left", "right", "center", "justify"], false);
        let border_style = new AttrDefEnum(["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"], false);
        let this->info["border-top-style"] = new AttrDefEnum(["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"], false);
        let this->info["border-left-style"] = new AttrDefEnum(["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"], false);
        let this->info["border-right-style"] = new AttrDefEnum(["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"], false);
        let this->info["border-bottom-style"] = new AttrDefEnum(["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"], false);
        ;
        let this->info["border-style"] = new AttrDefCSSMultiple(border_style);
        let this->info["clear"] = new AttrDefEnum(["none", "left", "right", "both"], false);
        let this->info["float"] = new AttrDefEnum(["none", "left", "right"], false);
        let this->info["font-style"] = new AttrDefEnum(["normal", "italic", "oblique"], false);
        let this->info["font-variant"] = new AttrDefEnum(["normal", "small-caps"], false);
        let uri_or_none =  new AttrDefCSSComposite([new AttrDefEnum(tmpArray18cbb024b7142b47d42db817639d1e69), new AttrDefCSSURI()]);
        let this->info["list-style-position"] = new AttrDefEnum(["inside", "outside"], false);
        let this->info["list-style-type"] = new AttrDefEnum(["disc", "circle", "square", "decimal", "lower-roman", "upper-roman", "lower-alpha", "upper-alpha", "none"], false);
        let this->info["list-style-image"] = uri_or_none;
        let this->info["list-style"] = new AttrDefCSSListStyle(config);
        let this->info["text-transform"] = new AttrDefEnum(["capitalize", "uppercase", "lowercase", "none"], false);
        let this->info["color"] = new AttrDefCSSColor();
        let this->info["background-image"] = uri_or_none;
        let this->info["background-repeat"] = new AttrDefEnum(["repeat", "repeat-x", "repeat-y", "no-repeat"]);
        let this->info["background-attachment"] = new AttrDefEnum(["scroll", "fixed"]);
        let this->info["background-position"] = new AttrDefCSSBackgroundPosition();
        let border_color = new AttrDefCSSComposite([new AttrDefEnum(tmpArray41f995a3ef184903c63933a41a383ff1), new AttrDefCSSColor()]);
        let this->info["background-color"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArray41f995a3ef184903c63933a41a383ff1), new AttrDefCSSColor()]);
        let this->info["border-right-color"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArray41f995a3ef184903c63933a41a383ff1), new AttrDefCSSColor()]);
        let this->info["border-left-color"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArray41f995a3ef184903c63933a41a383ff1), new AttrDefCSSColor()]);
        let this->info["border-bottom-color"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArray41f995a3ef184903c63933a41a383ff1), new AttrDefCSSColor()]);
        let this->info["border-top-color"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArray41f995a3ef184903c63933a41a383ff1), new AttrDefCSSColor()]);
        ;
        let this->info["background"] = new AttrDefCSSBackground(config);
        let this->info["border-color"] = new AttrDefCSSMultiple(border_color);
        let border_width = new AttrDefCSSComposite([new AttrDefEnum(tmpArraye2b1ba31fd171df8575b32f49da8001f), new AttrDefCSSLength("0")]);
        let this->info["border-right-width"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraye2b1ba31fd171df8575b32f49da8001f), new AttrDefCSSLength("0")]);
        let this->info["border-left-width"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraye2b1ba31fd171df8575b32f49da8001f), new AttrDefCSSLength("0")]);
        let this->info["border-bottom-width"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraye2b1ba31fd171df8575b32f49da8001f), new AttrDefCSSLength("0")]);
        let this->info["border-top-width"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraye2b1ba31fd171df8575b32f49da8001f), new AttrDefCSSLength("0")]);
        ;
        let this->info["border-width"] = new AttrDefCSSMultiple(border_width);
        let this->info["letter-spacing"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArray182f61fd9b6d47dd1a581a8891224623), new AttrDefCSSLength()]);
        let this->info["word-spacing"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraydaec120d852050bc07ab0e2dd75b12db), new AttrDefCSSLength()]);
        let this->info["font-size"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraye8149e46033774783b4b4fdb9c147034), new AttrDefCSSPercentage(), new AttrDefCSSLength()]);
        let this->info["line-height"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArraydf8e1d9bbc52d72253dc87e7da8804f5), new AttrDefCSSNumber(true), new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true)]);
        let margin = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage(), new AttrDefEnum(tmpArrayf8a63c1e0fe2205e5d793f06fde3eb76)]);
        let this->info["margin-right"] = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage(), new AttrDefEnum(tmpArrayf8a63c1e0fe2205e5d793f06fde3eb76)]);
        let this->info["margin-left"] = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage(), new AttrDefEnum(tmpArrayf8a63c1e0fe2205e5d793f06fde3eb76)]);
        let this->info["margin-bottom"] = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage(), new AttrDefEnum(tmpArrayf8a63c1e0fe2205e5d793f06fde3eb76)]);
        let this->info["margin-top"] = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage(), new AttrDefEnum(tmpArrayf8a63c1e0fe2205e5d793f06fde3eb76)]);
        ;
        let this->info["margin"] = new AttrDefCSSMultiple(margin);
        // non-negative
        let padding = new AttrDefCSSComposite([new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true)]);
        let this->info["padding-right"] = new AttrDefCSSComposite([new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true)]);
        let this->info["padding-left"] = new AttrDefCSSComposite([new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true)]);
        let this->info["padding-bottom"] = new AttrDefCSSComposite([new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true)]);
        let this->info["padding-top"] = new AttrDefCSSComposite([new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true)]);
        ;
        let this->info["padding"] = new AttrDefCSSMultiple(padding);
        let this->info["text-indent"] = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage()]);
        let trusted_wh =  new AttrDefCSSComposite([new AttrDefCSSLength("0"), new AttrDefCSSPercentage(true), new AttrDefEnum(tmpArrayeb44b4e34105780cc74b7b5be365eba0)]);
        let max =  config->get("CSS.MaxImgLength");
        let this->info["height"] =  max === null ? trusted_wh  : new AttrDefSwitch("img", new AttrDefCSSComposite([new AttrDefCSSLength("0", max), new AttrDefEnum(tmpArray948ea4e613dfae534d74ac932d1705cf)]), trusted_wh);
        let this->info["width"] = this->info["height"];
        let this->info["max-height"] = this->info["width"];
        let this->info["min-height"] = this->info["max-height"];
        let this->info["max-width"] = this->info["min-height"];
        let this->info["min-width"] = this->info["max-width"];
        let this->info["text-decoration"] = new AttrDefCSSTextDecoration();
        let this->info["font-family"] = new AttrDefCSSFontFamily();
        // this could use specialized code
        let this->info["font-weight"] = new AttrDefEnum(["normal", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900"], false);
        // MUST be called after other font properties, as it references
        // a CSSDefinition object
        let this->info["font"] = new AttrDefCSSFont(config);
        // same here
        let this->info["border-right"] = new AttrDefCSSBorder(config);
        let this->info["border-left"] = this->info["border-right"];
        let this->info["border-top"] = this->info["border-left"];
        let this->info["border-bottom"] = this->info["border-top"];
        let this->info["border"] = this->info["border-bottom"];
        let this->info["border-collapse"] = new AttrDefEnum(["collapse", "separate"]);
        let this->info["caption-side"] = new AttrDefEnum(["top", "bottom"]);
        let this->info["table-layout"] = new AttrDefEnum(["auto", "fixed"]);
        let this->info["vertical-align"] = new AttrDefCSSComposite([new AttrDefEnum(tmpArrayfab556855498e904a6c9cd5027a6534c), new AttrDefCSSLength(), new AttrDefCSSPercentage()]);
        let this->info["border-spacing"] = new AttrDefCSSMultiple(new AttrDefCSSLength(), 2);
        // These CSS properties don't work on many browsers, but we live
        // in THE FUTURE!
        let this->info["white-space"] = new AttrDefEnum(["nowrap", "normal", "pre", "pre-wrap", "pre-line"]);
        if config->get("CSS.Proprietary") {
            this->doSetupProprietary(config);
        }
        if config->get("CSS.AllowTricky") {
            this->doSetupTricky(config);
        }
        if config->get("CSS.Trusted") {
            this->doSetupTrusted(config);
        }
        let allow_important =  config->get("CSS.AllowImportant");
        // wrap all attr-defs with decorator that handles !important
        for k, v in this->info {
            let this->info[k] = new AttrDefCSSImportantDecorator(v, allow_important);
        }
        this->setupConfigStuff(config);
    }
    
    /**
     * @param Config $config
     */
    protected function doSetupProprietary(<Config> config) -> void
    {
        var tmpArray0f69cc77a1a5bb4efc01537e51704d6a, tmpArray3214318c23f67e3a58a4c4b1bbe6a68b, border_radius, tmpArray84f41f3a97e38a42814f690ca0b5f809;
    
        // Internet Explorer only scrollbar colors
        let this->info["scrollbar-arrow-color"] = new AttrDefCSSColor();
        let this->info["scrollbar-base-color"] = new AttrDefCSSColor();
        let this->info["scrollbar-darkshadow-color"] = new AttrDefCSSColor();
        let this->info["scrollbar-face-color"] = new AttrDefCSSColor();
        let this->info["scrollbar-highlight-color"] = new AttrDefCSSColor();
        let this->info["scrollbar-shadow-color"] = new AttrDefCSSColor();
        // vendor specific prefixes of opacity
        let this->info["-moz-opacity"] = new AttrDefCSSAlphaValue();
        let this->info["-khtml-opacity"] = new AttrDefCSSAlphaValue();
        // only opacity, for now
        let this->info["filter"] = new AttrDefCSSFilter();
        // more CSS3
        let this->info["page-break-before"] = new AttrDefEnum(["auto", "always", "avoid", "left", "right"]);
        let this->info["page-break-after"] = this->info["page-break-before"];
        let this->info["page-break-inside"] = new AttrDefEnum(["auto", "avoid"]);
        let border_radius =  new AttrDefCSSComposite([new AttrDefCSSPercentage(true), new AttrDefCSSLength("0")]);
        let this->info["border-bottom-left-radius"] = new AttrDefCSSMultiple(border_radius, 2);
        let this->info["border-bottom-right-radius"] = this->info["border-bottom-left-radius"];
        let this->info["border-top-right-radius"] = this->info["border-bottom-right-radius"];
        let this->info["border-top-left-radius"] = this->info["border-top-right-radius"];
        // TODO: support SLASH syntax
        let this->info["border-radius"] = new AttrDefCSSMultiple(border_radius, 4);
    }
    
    /**
     * @param Config $config
     */
    protected function doSetupTricky(<Config> config) -> void
    {
        var tmpArraye8c6598080f88baead96c49b16798776, tmpArrayda3e5f40b766672d2afa1a3ffec3e83e, tmpArray99980ac452ec028bf94985ad4f2a39ea;
    
        let this->info["display"] = new AttrDefEnum(["inline", "block", "list-item", "run-in", "compact", "marker", "table", "inline-block", "inline-table", "table-row-group", "table-header-group", "table-footer-group", "table-row", "table-column-group", "table-column", "table-cell", "table-caption", "none"]);
        let this->info["visibility"] = new AttrDefEnum(["visible", "hidden", "collapse"]);
        let this->info["overflow"] = new AttrDefEnum(["visible", "hidden", "auto", "scroll"]);
        let this->info["opacity"] = new AttrDefCSSAlphaValue();
    }
    
    /**
     * @param Config $config
     */
    protected function doSetupTrusted(<Config> config) -> void
    {
        var tmpArrayf7a1248f35ffcf9f805c96f7ae3957e2, tmpArraydf26feb7c119510192b2030a5bcddcb8, tmpArray0c869f23db5ba0a27b70d3f067f42aed, tmpArray8af73f4abc8e087e974f49eb733c5c0f, tmpArrayc915fa9fe2a9014c901c6576b8ef03e3;
    
        let this->info["position"] = new AttrDefEnum(["static", "relative", "absolute", "fixed"]);
        let this->info["bottom"] = new AttrDefCSSComposite([new AttrDefCSSLength(), new AttrDefCSSPercentage(), new AttrDefEnum(tmpArray0c869f23db5ba0a27b70d3f067f42aed)]);
        let this->info["right"] = this->info["bottom"];
        let this->info["left"] = this->info["right"];
        let this->info["top"] = this->info["left"];
        let this->info["z-index"] = new AttrDefCSSComposite([new AttrDefInteger(), new AttrDefEnum(tmpArrayc915fa9fe2a9014c901c6576b8ef03e3)]);
    }
    
    /**
     * Performs extra config-based processing. Based off of
     * HTMLDefinition.
     * @param Config $config
     * @todo Refactor duplicate elements into common class (probably using
     *       composition, not inheritance).
     */
    protected function setupConfigStuff(<Config> config) -> void
    {
        var support, allowed_properties, name, d, forbidden_properties;
    
        // setup allowed elements
        let support =  "(for information on implementing this, see the " . "support forums) ";
        let allowed_properties =  config->get("CSS.AllowedProperties");
        if allowed_properties !== null {
            for name, d in this->info {
                if !(isset allowed_properties[name]) {
                    unset this->info[name];
                
                }
                unset allowed_properties[name];
            
            }
            // emit errors
            for name, d in allowed_properties {
                // :TODO: Is this htmlspecialchars() call really necessary?
                let name =  htmlspecialchars(name);
                trigger_error("Style attribute '{name}' is not supported {support}", E_USER_WARNING);
            }
        }
        let forbidden_properties =  config->get("CSS.ForbiddenProperties");
        if forbidden_properties !== null {
            for name, d in this->info {
                if isset forbidden_properties[name] {
                    unset this->info[name];
                
                }
            }
        }
    }

}