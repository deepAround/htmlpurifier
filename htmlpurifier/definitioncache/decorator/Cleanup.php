<?php
namespace HTMLPurifier\DefinitionCache\Decorator;

use HTMLPurifier\DefinitionCache\DefinitionCacheDecorator;

/**
 * Definition cache decorator class that cleans up the cache
 * whenever there is a cache miss.
 */
class DefinitionCacheDecoratorCleanup extends DefinitionCacheDecorator
{
    /**
     * @type string
     */
    public $name = 'Cleanup';

    /**
     * @return DefinitionCacheDecoratorCleanup
     */
    public function copy()
    {
        return new DefinitionCacheDecoratorCleanup();
    }

    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function add($def, $config)
    {
        $status = parent::add($def, $config);
        if (!$status) {
            parent::cleanup($config);
        }
        return $status;
    }

    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function set($def, $config)
    {
        $status = parent::set($def, $config);
        if (!$status) {
            parent::cleanup($config);
        }
        return $status;
    }

    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function replace($def, $config)
    {
        $status = parent::replace($def, $config);
        if (!$status) {
            parent::cleanup($config);
        }
        return $status;
    }

    /**
     * @param Config $config
     * @return mixed
     */
    public function get($config)
    {
        $ret = parent::get($config);
        if (!$ret) {
            parent::cleanup($config);
        }
        return $ret;
    }
}

// vim: et sw=4 sts=4
