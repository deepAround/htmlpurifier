namespace HTMLPurifier\DefinitionCache;

use HTMLPurifier\DefinitionCache;
class DefinitionCacheSerializer extends DefinitionCache
{
    /**
     * @param Definition $def
     * @param Config $config
     * @return int|bool
     */
    public function add(<Definition> def, <Config> config)
    {
        var file;
    
        if !(this->checkDefType(def)) {
            return;
        }
        let file =  this->generateFilePath(config);
        if file_exists(file) {
            return false;
        }
        if !(this->_prepareDir(config)) {
            return false;
        }
        return this->_write(file, serialize(def), config);
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return int|bool
     */
    public function set(<Definition> def, <Config> config)
    {
        var file;
    
        if !(this->checkDefType(def)) {
            return;
        }
        let file =  this->generateFilePath(config);
        if !(this->_prepareDir(config)) {
            return false;
        }
        return this->_write(file, serialize(def), config);
    }
    
    /**
     * @param Definition $def
     * @param Config $config
     * @return int|bool
     */
    public function replace(<Definition> def, <Config> config)
    {
        var file;
    
        if !(this->checkDefType(def)) {
            return;
        }
        let file =  this->generateFilePath(config);
        if !(file_exists(file)) {
            return false;
        }
        if !(this->_prepareDir(config)) {
            return false;
        }
        return this->_write(file, serialize(def), config);
    }
    
    /**
     * @param Config $config
     * @return bool|Config
     */
    public function get(<Config> config)
    {
        var file;
    
        let file =  this->generateFilePath(config);
        if !(file_exists(file)) {
            return false;
        }
        return unserialize(file_get_contents(file));
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function remove(<Config> config) -> bool
    {
        var file;
    
        let file =  this->generateFilePath(config);
        if !(file_exists(file)) {
            return false;
        }
        return unlink(file);
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function flush(<Config> config) -> bool
    {
        var dir, dh, filename;
    
        if !(this->_prepareDir(config)) {
            return false;
        }
        let dir =  this->generateDirectoryPath(config);
        let dh =  opendir(dir);
        // Apparently, on some versions of PHP, readdir will return
        // an empty string if you pass an invalid argument to readdir.
        // So you need this test.  See #49.
        if dh === false {
            return false;
        }
        let filename =  readdir(dh);
        while (filename !== false) {
            if empty(filename) {
                continue;
            }
            if filename[0] === "." {
                continue;
            }
            unlink(dir . "/" . filename);
        let filename =  readdir(dh);
        }
        closedir(dh);
        return true;
    }
    
    /**
     * @param Config $config
     * @return bool
     */
    public function cleanup(<Config> config) -> bool
    {
        var dir, dh, filename, key;
    
        if !(this->_prepareDir(config)) {
            return false;
        }
        let dir =  this->generateDirectoryPath(config);
        let dh =  opendir(dir);
        // See #49 (and above).
        if dh === false {
            return false;
        }
        let filename =  readdir(dh);
        while (filename !== false) {
            if empty(filename) {
                continue;
            }
            if filename[0] === "." {
                continue;
            }
            let key =  substr(filename, 0, strlen(filename) - 4);
            if this->isOld(key, config) {
                unlink(dir . "/" . filename);
            }
        let filename =  readdir(dh);
        }
        closedir(dh);
        return true;
    }
    
    /**
     * Generates the file path to the serial file corresponding to
     * the configuration and definition name
     * @param Config $config
     * @return string
     * @todo Make protected
     */
    public function generateFilePath(<Config> config) -> string
    {
        var key;
    
        let key =  this->generateKey(config);
        return this->generateDirectoryPath(config) . "/" . key . ".ser";
    }
    
    /**
     * Generates the path to the directory contain this cache's serial files
     * @param Config $config
     * @return string
     * @note No trailing slash
     * @todo Make protected
     */
    public function generateDirectoryPath(<Config> config) -> string
    {
        var base;
    
        let base =  this->generateBaseDirectoryPath(config);
        return base . "/" . this->type;
    }
    
    /**
     * Generates path to base directory that contains all definition type
     * serials
     * @param Config $config
     * @return mixed|string
     * @todo Make protected
     */
    public function generateBaseDirectoryPath(<Config> config)
    {
        var base;
    
        let base =  config->get("Cache.SerializerPath");
        let base =  is_null(base) ? PREFIX . "/HTMLPurifier/DefinitionCache/Serializer"  : base;
        return base;
    }
    
    /**
     * Convenience wrapper function for file_put_contents
     * @param string $file File name to write to
     * @param string $data Data to write into file
     * @param Config $config
     * @return int|bool Number of bytes written if success, or false if failure.
     */
    protected function _write(string file, string data, <Config> config)
    {
        var result, chmod;
    
        let result =  file_put_contents(file, data);
        if result !== false {
            // set permissions of the new file (no execute)
            let chmod =  config->get("Cache.SerializerPermissions");
            if chmod !== null {
                chmod(file, chmod & 438);
            }
        }
        return result;
    }
    
    /**
     * Prepares the directory that this type stores the serials in
     * @param Config $config
     * @return bool True if successful
     */
    protected function _prepareDir(<Config> config) -> bool
    {
        var directory, chmod, base;
    
        let directory =  this->generateDirectoryPath(config);
        let chmod =  config->get("Cache.SerializerPermissions");
        if chmod === null {
            if !(mkdir(directory)) && !(is_dir(directory)) {
                trigger_error("Could not create directory " . directory . "", E_USER_WARNING);
                return false;
            }
            return true;
        }
        if !(is_dir(directory)) {
            let base =  this->generateBaseDirectoryPath(config);
            if !(is_dir(base)) {
                trigger_error("Base directory " . base . " does not exist,
                    please create or change using %Cache.SerializerPath", E_USER_WARNING);
                return false;
            } elseif !(this->_testPermissions(base, chmod)) {
                return false;
            }
            if !(mkdir(directory, chmod)) && !(is_dir(directory)) {
                trigger_error("Could not create directory " . directory . "", E_USER_WARNING);
                return false;
            }
            if !(this->_testPermissions(directory, chmod)) {
                return false;
            }
        } elseif !(this->_testPermissions(directory, chmod)) {
            return false;
        }
        return true;
    }
    
    /**
     * Tests permissions on a directory and throws out friendly
     * error messages and attempts to chmod it itself if possible
     * @param string $dir Directory path
     * @param int $chmod Permissions
     * @return bool True if directory is writable
     */
    protected function _testPermissions(string dir, int chmod) -> bool
    {
        // early abort, if it is writable, everything is hunky-dory
        if is_writable(dir) {
            return true;
        }
        if !(is_dir(dir)) {
            // generally, you'll want to handle this beforehand
            // so a more specific error message can be given
            trigger_error("Directory " . dir . " does not exist", E_USER_WARNING);
            return false;
        }
        if function_exists("posix_getuid") && chmod !== null {
            // POSIX system, we can give more specific advice
            if fileowner(dir) === posix_getuid() {
                // we can chmod it ourselves
                let chmod =  chmod | 448;
                if chmod(dir, chmod) {
                    return true;
                }
            } elseif filegroup(dir) === posix_getgid() {
                let chmod =  chmod | 56;
            } else {
                // PHP's probably running as nobody, so we'll
                // need to give global permissions
                let chmod =  chmod | 511;
            }
            trigger_error("Directory " . dir . " not writable, " . "please chmod to " . decoct(chmod), E_USER_WARNING);
        } else {
            // generic error message
            trigger_error("Directory " . dir . " not writable, " . "please alter file permissions", E_USER_WARNING);
        }
        return false;
    }

}