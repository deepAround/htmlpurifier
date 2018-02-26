<?php
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
    public $name = 'Iframe';

    /**
     * @type bool
     */
    public $safe = false;

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        if ($config->get('HTML.SafeIframe')) {
            $this->safe = true;
        }
        $this->addElement(
            'iframe',
            'Inline',
            'Flow',
            'Common',
            array(
                'src' => 'URI#embedded',
                'width' => 'Length',
                'height' => 'Length',
                'name' => 'ID',
                'scrolling' => 'Enum#yes,no,auto',
                'frameborder' => 'Enum#0,1',
                'longdesc' => 'URI',
                'marginheight' => 'Pixels',
                'marginwidth' => 'Pixels',
            )
        );
    }
}

// vim: et sw=4 sts=4
