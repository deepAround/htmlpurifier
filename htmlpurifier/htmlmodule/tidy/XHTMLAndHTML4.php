<?php
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
    public function makeFixes()
    {
        $r = array();

        // == deprecated tag transforms ===================================

        $r['font'] = new TagTransformFont();
        $r['menu'] = new TagTransformSimple('ul');
        $r['dir'] = new TagTransformSimple('ul');
        $r['center'] = new TagTransformSimple('div', 'text-align:center;');
        $r['u'] = new TagTransformSimple('span', 'text-decoration:underline;');
        $r['s'] = new TagTransformSimple('span', 'text-decoration:line-through;');
        $r['strike'] = new TagTransformSimple('span', 'text-decoration:line-through;');

        // == deprecated attribute transforms =============================

        $r['caption@align'] =
            new AttrTransformEnumToCSS(
                'align',
                array(
                    // we're following IE's behavior, not Firefox's, due
                    // to the fact that no one supports caption-side:right,
                    // W3C included (with CSS 2.1). This is a slightly
                    // unreasonable attribute!
                    'left' => 'text-align:left;',
                    'right' => 'text-align:right;',
                    'top' => 'caption-side:top;',
                    'bottom' => 'caption-side:bottom;' // not supported by IE
                )
            );

        // @align for img -------------------------------------------------
        $r['img@align'] =
            new AttrTransformEnumToCSS(
                'align',
                array(
                    'left' => 'float:left;',
                    'right' => 'float:right;',
                    'top' => 'vertical-align:top;',
                    'middle' => 'vertical-align:middle;',
                    'bottom' => 'vertical-align:baseline;',
                )
            );

        // @align for table -----------------------------------------------
        $r['table@align'] =
            new AttrTransformEnumToCSS(
                'align',
                array(
                    'left' => 'float:left;',
                    'center' => 'margin-left:auto;margin-right:auto;',
                    'right' => 'float:right;'
                )
            );

        // @align for hr -----------------------------------------------
        $r['hr@align'] =
            new AttrTransformEnumToCSS(
                'align',
                array(
                    // we use both text-align and margin because these work
                    // for different browsers (IE and Firefox, respectively)
                    // and the melange makes for a pretty cross-compatible
                    // solution
                    'left' => 'margin-left:0;margin-right:auto;text-align:left;',
                    'center' => 'margin-left:auto;margin-right:auto;text-align:center;',
                    'right' => 'margin-left:auto;margin-right:0;text-align:right;'
                )
            );

        // @align for h1, h2, h3, h4, h5, h6, p, div ----------------------
        // {{{
        $align_lookup = array();
        $align_values = array('left', 'right', 'center', 'justify');
        foreach ($align_values as $v) {
            $align_lookup[$v] = "text-align:$v;";
        }
        // }}}
        $r['h1@align'] =
        $r['h2@align'] =
        $r['h3@align'] =
        $r['h4@align'] =
        $r['h5@align'] =
        $r['h6@align'] =
        $r['p@align'] =
        $r['div@align'] =
            new AttrTransformEnumToCSS('align', $align_lookup);

        // @bgcolor for table, tr, td, th ---------------------------------
        $r['table@bgcolor'] =
        $r['td@bgcolor'] =
        $r['th@bgcolor'] =
            new AttrTransformBgColor();

        // @border for img ------------------------------------------------
        $r['img@border'] = new AttrTransformBorder();

        // @clear for br --------------------------------------------------
        $r['br@clear'] =
            new AttrTransformEnumToCSS(
                'clear',
                array(
                    'left' => 'clear:left;',
                    'right' => 'clear:right;',
                    'all' => 'clear:both;',
                    'none' => 'clear:none;',
                )
            );

        // @height for td, th ---------------------------------------------
        $r['td@height'] =
        $r['th@height'] =
            new AttrTransformLength('height');

        // @hspace for img ------------------------------------------------
        $r['img@hspace'] = new AttrTransformImgSpace('hspace');

        // @noshade for hr ------------------------------------------------
        // this transformation is not precise but often good enough.
        // different browsers use different styles to designate noshade
        $r['hr@noshade'] =
            new AttrTransformBoolToCSS(
                'noshade',
                'color:#808080;background-color:#808080;border:0;'
            );

        // @nowrap for td, th ---------------------------------------------
        $r['td@nowrap'] =
        $r['th@nowrap'] =
            new AttrTransformBoolToCSS(
                'nowrap',
                'white-space:nowrap;'
            );

        // @size for hr  --------------------------------------------------
        $r['hr@size'] = new AttrTransformLength('size', 'height');

        // @type for li, ol, ul -------------------------------------------
        // {{{
        $ul_types = array(
            'disc' => 'list-style-type:disc;',
            'square' => 'list-style-type:square;',
            'circle' => 'list-style-type:circle;'
        );
        $ol_types = array(
            '1' => 'list-style-type:decimal;',
            'i' => 'list-style-type:lower-roman;',
            'I' => 'list-style-type:upper-roman;',
            'a' => 'list-style-type:lower-alpha;',
            'A' => 'list-style-type:upper-alpha;'
        );
        $li_types = $ul_types + $ol_types;
        // }}}

        $r['ul@type'] = new AttrTransformEnumToCSS('type', $ul_types);
        $r['ol@type'] = new AttrTransformEnumToCSS('type', $ol_types, true);
        $r['li@type'] = new AttrTransformEnumToCSS('type', $li_types, true);

        // @vspace for img ------------------------------------------------
        $r['img@vspace'] = new AttrTransformImgSpace('vspace');

        // @width for hr, td, th ------------------------------------------
        $r['td@width'] =
        $r['th@width'] =
        $r['hr@width'] = new AttrTransformLength('width');

        return $r;
    }
}

// vim: et sw=4 sts=4
