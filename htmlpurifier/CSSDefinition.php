<?php
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

    public $type = 'CSS';

    /**
     * Assoc array of attribute name to definition object.
     * @type AttrDef[]
     */
    public $info = array();

    /**
     * Constructs the info array.  The meat of this class.
     * @param Config $config
     */
    protected function doSetup($config)
    {
        $this->info['text-align'] = new AttrDefEnum(
            array('left', 'right', 'center', 'justify'),
            false
        );

        $border_style =
            $this->info['border-bottom-style'] =
            $this->info['border-right-style'] =
            $this->info['border-left-style'] =
            $this->info['border-top-style'] = new AttrDefEnum(
                array(
                    'none',
                    'hidden',
                    'dotted',
                    'dashed',
                    'solid',
                    'double',
                    'groove',
                    'ridge',
                    'inset',
                    'outset'
                ),
                false
            );

        $this->info['border-style'] = new AttrDefCSSMultiple($border_style);

        $this->info['clear'] = new AttrDefEnum(
            array('none', 'left', 'right', 'both'),
            false
        );
        $this->info['float'] = new AttrDefEnum(
            array('none', 'left', 'right'),
            false
        );
        $this->info['font-style'] = new AttrDefEnum(
            array('normal', 'italic', 'oblique'),
            false
        );
        $this->info['font-variant'] = new AttrDefEnum(
            array('normal', 'small-caps'),
            false
        );

        $uri_or_none = new AttrDefCSSComposite(
            array(
                new AttrDefEnum(array('none')),
                new AttrDefCSSURI()
            )
        );

        $this->info['list-style-position'] = new AttrDefEnum(
            array('inside', 'outside'),
            false
        );
        $this->info['list-style-type'] = new AttrDefEnum(
            array(
                'disc',
                'circle',
                'square',
                'decimal',
                'lower-roman',
                'upper-roman',
                'lower-alpha',
                'upper-alpha',
                'none'
            ),
            false
        );
        $this->info['list-style-image'] = $uri_or_none;

        $this->info['list-style'] = new AttrDefCSSListStyle($config);

        $this->info['text-transform'] = new AttrDefEnum(
            array('capitalize', 'uppercase', 'lowercase', 'none'),
            false
        );
        $this->info['color'] = new AttrDefCSSColor();

        $this->info['background-image'] = $uri_or_none;
        $this->info['background-repeat'] = new AttrDefEnum(
            array('repeat', 'repeat-x', 'repeat-y', 'no-repeat')
        );
        $this->info['background-attachment'] = new AttrDefEnum(
            array('scroll', 'fixed')
        );
        $this->info['background-position'] = new AttrDefCSSBackgroundPosition();

        $border_color =
            $this->info['border-top-color'] =
            $this->info['border-bottom-color'] =
            $this->info['border-left-color'] =
            $this->info['border-right-color'] =
            $this->info['background-color'] = new AttrDefCSSComposite(
                array(
                    new AttrDefEnum(array('transparent')),
                    new AttrDefCSSColor()
                )
            );

        $this->info['background'] = new AttrDefCSSBackground($config);

        $this->info['border-color'] = new AttrDefCSSMultiple($border_color);

        $border_width =
            $this->info['border-top-width'] =
            $this->info['border-bottom-width'] =
            $this->info['border-left-width'] =
            $this->info['border-right-width'] = new AttrDefCSSComposite(
                array(
                    new AttrDefEnum(array('thin', 'medium', 'thick')),
                    new AttrDefCSSLength('0') //disallow negative
                )
            );

        $this->info['border-width'] = new AttrDefCSSMultiple($border_width);

        $this->info['letter-spacing'] = new AttrDefCSSComposite(
            array(
                new AttrDefEnum(array('normal')),
                new AttrDefCSSLength()
            )
        );

        $this->info['word-spacing'] = new AttrDefCSSComposite(
            array(
                new AttrDefEnum(array('normal')),
                new AttrDefCSSLength()
            )
        );

        $this->info['font-size'] = new AttrDefCSSComposite(
            array(
                new AttrDefEnum(
                    array(
                        'xx-small',
                        'x-small',
                        'small',
                        'medium',
                        'large',
                        'x-large',
                        'xx-large',
                        'larger',
                        'smaller'
                    )
                ),
                new AttrDefCSSPercentage(),
                new AttrDefCSSLength()
            )
        );

        $this->info['line-height'] = new AttrDefCSSComposite(
            array(
                new AttrDefEnum(array('normal')),
                new AttrDefCSSNumber(true), // no negatives
                new AttrDefCSSLength('0'),
                new AttrDefCSSPercentage(true)
            )
        );

        $margin =
            $this->info['margin-top'] =
            $this->info['margin-bottom'] =
            $this->info['margin-left'] =
            $this->info['margin-right'] = new AttrDefCSSComposite(
                array(
                    new AttrDefCSSLength(),
                    new AttrDefCSSPercentage(),
                    new AttrDefEnum(array('auto'))
                )
            );

        $this->info['margin'] = new AttrDefCSSMultiple($margin);

        // non-negative
        $padding =
            $this->info['padding-top'] =
            $this->info['padding-bottom'] =
            $this->info['padding-left'] =
            $this->info['padding-right'] = new AttrDefCSSComposite(
                array(
                    new AttrDefCSSLength('0'),
                    new AttrDefCSSPercentage(true)
                )
            );

        $this->info['padding'] = new AttrDefCSSMultiple($padding);

        $this->info['text-indent'] = new AttrDefCSSComposite(
            array(
                new AttrDefCSSLength(),
                new AttrDefCSSPercentage()
            )
        );

        $trusted_wh = new AttrDefCSSComposite(
            array(
                new AttrDefCSSLength('0'),
                new AttrDefCSSPercentage(true),
                new AttrDefEnum(array('auto'))
            )
        );
        $max = $config->get('CSS.MaxImgLength');

        $this->info['min-width'] =
        $this->info['max-width'] =
        $this->info['min-height'] =
        $this->info['max-height'] =
        $this->info['width'] =
        $this->info['height'] =
            $max === null ?
                $trusted_wh :
                new AttrDefSwitch(
                    'img',
                    // For img tags:
                    new AttrDefCSSComposite(
                        array(
                            new AttrDefCSSLength('0', $max),
                            new AttrDefEnum(array('auto'))
                        )
                    ),
                    // For everyone else:
                    $trusted_wh
                );

        $this->info['text-decoration'] = new AttrDefCSSTextDecoration();

        $this->info['font-family'] = new AttrDefCSSFontFamily();

        // this could use specialized code
        $this->info['font-weight'] = new AttrDefEnum(
            array(
                'normal',
                'bold',
                'bolder',
                'lighter',
                '100',
                '200',
                '300',
                '400',
                '500',
                '600',
                '700',
                '800',
                '900'
            ),
            false
        );

        // MUST be called after other font properties, as it references
        // a CSSDefinition object
        $this->info['font'] = new AttrDefCSSFont($config);

        // same here
        $this->info['border'] =
        $this->info['border-bottom'] =
        $this->info['border-top'] =
        $this->info['border-left'] =
        $this->info['border-right'] = new AttrDefCSSBorder($config);

        $this->info['border-collapse'] = new AttrDefEnum(
            array('collapse', 'separate')
        );

        $this->info['caption-side'] = new AttrDefEnum(
            array('top', 'bottom')
        );

        $this->info['table-layout'] = new AttrDefEnum(
            array('auto', 'fixed')
        );

        $this->info['vertical-align'] = new AttrDefCSSComposite(
            array(
                new AttrDefEnum(
                    array(
                        'baseline',
                        'sub',
                        'super',
                        'top',
                        'text-top',
                        'middle',
                        'bottom',
                        'text-bottom'
                    )
                ),
                new AttrDefCSSLength(),
                new AttrDefCSSPercentage()
            )
        );

        $this->info['border-spacing'] = new AttrDefCSSMultiple(new AttrDefCSSLength(), 2);

        // These CSS properties don't work on many browsers, but we live
        // in THE FUTURE!
        $this->info['white-space'] = new AttrDefEnum(
            array('nowrap', 'normal', 'pre', 'pre-wrap', 'pre-line')
        );

        if ($config->get('CSS.Proprietary')) {
            $this->doSetupProprietary($config);
        }

        if ($config->get('CSS.AllowTricky')) {
            $this->doSetupTricky($config);
        }

        if ($config->get('CSS.Trusted')) {
            $this->doSetupTrusted($config);
        }

        $allow_important = $config->get('CSS.AllowImportant');
        // wrap all attr-defs with decorator that handles !important
        foreach ($this->info as $k => $v) {
            $this->info[$k] = new AttrDefCSSImportantDecorator($v, $allow_important);
        }

        $this->setupConfigStuff($config);
    }

    /**
     * @param Config $config
     */
    protected function doSetupProprietary($config)
    {
        // Internet Explorer only scrollbar colors
        $this->info['scrollbar-arrow-color'] = new AttrDefCSSColor();
        $this->info['scrollbar-base-color'] = new AttrDefCSSColor();
        $this->info['scrollbar-darkshadow-color'] = new AttrDefCSSColor();
        $this->info['scrollbar-face-color'] = new AttrDefCSSColor();
        $this->info['scrollbar-highlight-color'] = new AttrDefCSSColor();
        $this->info['scrollbar-shadow-color'] = new AttrDefCSSColor();

        // vendor specific prefixes of opacity
        $this->info['-moz-opacity'] = new AttrDefCSSAlphaValue();
        $this->info['-khtml-opacity'] = new AttrDefCSSAlphaValue();

        // only opacity, for now
        $this->info['filter'] = new AttrDefCSSFilter();

        // more CSS3
        $this->info['page-break-after'] =
        $this->info['page-break-before'] = new AttrDefEnum(
            array(
                'auto',
                'always',
                'avoid',
                'left',
                'right'
            )
        );
        $this->info['page-break-inside'] = new AttrDefEnum(array('auto', 'avoid'));

        $border_radius = new AttrDefCSSComposite(
            array(
                new AttrDefCSSPercentage(true), // disallow negative
                new AttrDefCSSLength('0') // disallow negative
            ));

        $this->info['border-top-left-radius'] =
        $this->info['border-top-right-radius'] =
        $this->info['border-bottom-right-radius'] =
        $this->info['border-bottom-left-radius'] = new AttrDefCSSMultiple($border_radius, 2);
        // TODO: support SLASH syntax
        $this->info['border-radius'] = new AttrDefCSSMultiple($border_radius, 4);

    }

    /**
     * @param Config $config
     */
    protected function doSetupTricky($config)
    {
        $this->info['display'] = new AttrDefEnum(
            array(
                'inline',
                'block',
                'list-item',
                'run-in',
                'compact',
                'marker',
                'table',
                'inline-block',
                'inline-table',
                'table-row-group',
                'table-header-group',
                'table-footer-group',
                'table-row',
                'table-column-group',
                'table-column',
                'table-cell',
                'table-caption',
                'none'
            )
        );
        $this->info['visibility'] = new AttrDefEnum(
            array('visible', 'hidden', 'collapse')
        );
        $this->info['overflow'] = new AttrDefEnum(array('visible', 'hidden', 'auto', 'scroll'));
        $this->info['opacity'] = new AttrDefCSSAlphaValue();
    }

    /**
     * @param Config $config
     */
    protected function doSetupTrusted($config)
    {
        $this->info['position'] = new AttrDefEnum(
            array('static', 'relative', 'absolute', 'fixed')
        );
        $this->info['top'] =
        $this->info['left'] =
        $this->info['right'] =
        $this->info['bottom'] = new AttrDefCSSComposite(
            array(
                new AttrDefCSSLength(),
                new AttrDefCSSPercentage(),
                new AttrDefEnum(array('auto')),
            )
        );
        $this->info['z-index'] = new AttrDefCSSComposite(
            array(
                new AttrDefInteger(),
                new AttrDefEnum(array('auto')),
            )
        );
    }

    /**
     * Performs extra config-based processing. Based off of
     * HTMLDefinition.
     * @param Config $config
     * @todo Refactor duplicate elements into common class (probably using
     *       composition, not inheritance).
     */
    protected function setupConfigStuff($config)
    {
        // setup allowed elements
        $support = "(for information on implementing this, see the " .
            "support forums) ";
        $allowed_properties = $config->get('CSS.AllowedProperties');
        if ($allowed_properties !== null) {
            foreach ($this->info as $name => $d) {
                if (!isset($allowed_properties[$name])) {
                    unset($this->info[$name]);
                }
                unset($allowed_properties[$name]);
            }
            // emit errors
            foreach ($allowed_properties as $name => $d) {
                // :TODO: Is this htmlspecialchars() call really necessary?
                $name = htmlspecialchars($name);
                trigger_error("Style attribute '$name' is not supported $support", E_USER_WARNING);
            }
        }

        $forbidden_properties = $config->get('CSS.ForbiddenProperties');
        if ($forbidden_properties !== null) {
            foreach ($this->info as $name => $d) {
                if (isset($forbidden_properties[$name])) {
                    unset($this->info[$name]);
                }
            }
        }
    }
}

// vim: et sw=4 sts=4
