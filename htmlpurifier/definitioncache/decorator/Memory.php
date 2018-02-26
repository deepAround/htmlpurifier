<?php
namespace HTMLPurifier\DefinitionCache\Decorator;

use HTMLPurifier\DefinitionCache\DefinitionCacheDecorator;

/**
 * Definition cache decorator class that saves all cache retrievals
 * to PHP's memory; good for unit tests or circumstances where
 * there are lots of configuration objects floating around.
 */
class DefinitionCacheDecoratorMemory extends DefinitionCacheDecorator
{
    /**
     * @type array
     */
    protected $definitions;

    /**
     * @type string
     */
    public $name = 'Memory';

    /**
     * @return DefinitionCacheDecoratorMemory
     */
    public function copy()
    {
        return new DefinitionCacheDecoratorMemory();
    }

    /**
     * @param Definition $def
     * @param Config $config
     * @return mixed
     */
    public function add($def, $config)
    {
        $status = parent::add($def, $config);
        if ($status) {
            $this->definitions[$this->generateKey($config)] = $def;
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
        if ($status) {
            $this->definitions[$this->generateKey($config)] = $def;
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
        if ($status) {
            $this->definitions[$this->generateKey($config)] = $def;
        }
        return $status;
    }

    /**
     * @param Config $config
     * @return mixed
     */
    public function get($config)
    {
        $key = $this->generateKey($config);
        if (isset($this->definitions[$key])) {
            return $this->definitions[$key];
        }
        $this->definitions[$key] = parent::get($config);
        return $this->definitions[$key];
    }
}

// vim: et sw=4 sts=4
