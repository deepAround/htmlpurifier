namespace HTMLPurifier;

/**
 * Parses string hash files. File format is as such:
 *
 *      DefaultKeyValue
 *      KEY: Value
 *      KEY2: Value2
 *      --MULTILINE-KEY--
 *      Multiline
 *      value.
 *
 * Which would output something similar to:
 *
 *      array(
 *          'ID' => 'DefaultKeyValue',
 *          'KEY' => 'Value',
 *          'KEY2' => 'Value2',
 *          'MULTILINE-KEY' => "Multiline\nvalue.\n",
 *      )
 *
 * We use this as an easy to use file-format for configuration schema
 * files, but the class itself is usage agnostic.
 *
 * You can use ---- to forcibly terminate parsing of a single string-hash;
 * this marker is used in multi string-hashes to delimit boundaries.
 */
class StringHashParser
{
    /**
     * @type string
     */
    public default = "ID";
    /**
     * Parses a file that contains a single string-hash.
     * @param string $file
     * @return array
     */
    public function parseFile(string file) -> array
    {
        var fh, ret;
    
        if !(file_exists(file)) {
            return false;
        }
        let fh =  fopen(file, "r");
        if !(fh) {
            return false;
        }
        let ret =  this->parseHandle(fh);
        fclose(fh);
        return ret;
    }
    
    /**
     * Parses a file that contains multiple string-hashes delimited by '----'
     * @param string $file
     * @return array
     */
    public function parseMultiFile(string file) -> array
    {
        var ret, fh;
    
        if !(file_exists(file)) {
            return false;
        }
        let ret =  [];
        let fh =  fopen(file, "r");
        if !(fh) {
            return false;
        }
        while (!(feof(fh))) {
            let ret[] =  this->parseHandle(fh);
        }
        fclose(fh);
        return ret;
    }
    
    /**
     * Internal parser that acepts a file handle.
     * @note While it's possible to simulate in-memory parsing by using
     *       custom stream wrappers, if such a use-case arises we should
     *       factor out the file handle into its own class.
     * @param resource $fh File handle with pointer at start of valid string-hash
     *            block.
     * @return array
     */
    protected function parseHandle(fh) -> array
    {
        var state, single, ret, line, tmpListStateLine;
    
        let state =  false;
        let single =  false;
        let ret =  [];
        do {
            let line =  fgets(fh);
            if line === false {
                break;
            }
            let line =  rtrim(line, "
");
            if !(state) && line === "" {
                continue;
            }
            if line === "----" {
                break;
            }
            if strncmp("--#", line, 3) === 0 {
                // Comment
                continue;
            } elseif strncmp("--", line, 2) === 0 {
                // Multiline declaration
                let state =  trim(line, "- ");
                if !(isset ret[state]) {
                    let ret[state] = "";
                }
                continue;
            } elseif !(state) {
                let single =  true;
                if strpos(line, ":") !== false {
                    // Single-line declaration
                    let tmpListStateLine = explode(":", line, 2);
                    let state = tmpListStateLine[0];
                    let line = tmpListStateLine[1];
                    let line =  trim(line);
                } else {
                    // Use default declaration
                    let state =  this->default;
                }
            }
            if single {
                let ret[state] = line;
                let single =  false;
                let state =  false;
            } else {
                let ret[state] .= "{line}\n";
            }
        } while (!(feof(fh)));
        return ret;
    }

}