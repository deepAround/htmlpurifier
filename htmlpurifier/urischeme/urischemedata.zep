namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;
/**
 * Implements data: URI for base64 encoded images supported by GD.
 */
class URISchemeData extends URIScheme
{
    /**
     * @type bool
     */
    public browsable = true;
    /**
     * @type array
     */
    public allowed_types = ["image/jpeg" : true, "image/gif" : true, "image/png" : true];
    // this is actually irrelevant since we only write out the path
    // component
    /**
     * @type bool
     */
    public may_omit_host = true;
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function doValidate(uri, <Config> config, <Context> context) -> bool
    {
        var result, is_base64, charset, content_type, metadata, data, tmpListMetadataData, metas, cur, raw_data, file, image_code, tmpArrayc763439ef68e3b6af00bd973ec0f228b, info, real_content_type;
    
        let result =  explode(",", uri->path, 2);
        let is_base64 =  false;
        let charset =  null;
        let content_type =  null;
        if count(result) == 2 {
            let tmpListMetadataData = result;
            let metadata = tmpListMetadataData[0];
            let data = tmpListMetadataData[1];
            // do some legwork on the metadata
            let metas =  explode(";", metadata);
            while (!(empty(metas))) {
                let cur =  array_shift(metas);
                if cur == "base64" {
                    let is_base64 =  true;
                    break;
                }
                if substr(cur, 0, 8) == "charset=" {
                    // doesn't match if there are arbitrary spaces, but
                    // whatever dude
                    if charset !== null {
                        continue;
                    }
                    // garbage
                    let charset =  substr(cur, 8);
                } else {
                    if content_type !== null {
                        continue;
                    }
                    // garbage
                    let content_type = cur;
                }
            }
        } else {
            let data = result[0];
        }
        if content_type !== null && empty(this->allowed_types[content_type]) {
            return false;
        }
        if charset !== null {
            // error; we don't allow plaintext stuff
            let charset =  null;
        }
        let data =  rawurldecode(data);
        if is_base64 {
            let raw_data =  base64_decode(data);
        } else {
            let raw_data = data;
        }
        if strlen(raw_data) < 12 {
            // error; exif_imagetype throws exception with small files,
            // and this likely indicates a corrupt URI/failed parse anyway
            return false;
        }
        // XXX probably want to refactor this into a general mechanism
        // for filtering arbitrary content types
        if function_exists("sys_get_temp_dir") {
            let file =  tempnam(sys_get_temp_dir(), "");
        } else {
            let file =  tempnam("/tmp", "");
        }
        file_put_contents(file, raw_data);
        if function_exists("exif_imagetype") {
            let image_code =  exif_imagetype(file);
            unlink(file);
        } elseif function_exists("getimagesize") {
            let tmpArrayc763439ef68e3b6af00bd973ec0f228b = [this, "muteErrorHandler"];
            set_error_handler(tmpArrayc763439ef68e3b6af00bd973ec0f228b);
            let info =  getimagesize(file);
            restore_error_handler();
            unlink(file);
            if info == false {
                return false;
            }
            let image_code = info[2];
        } else {
            trigger_error("could not find exif_imagetype or getimagesize functions", E_USER_ERROR);
        }
        let real_content_type =  image_type_to_mime_type(image_code);
        if real_content_type != content_type {
            // we're nice guys; if the content type is something else we
            // support, change it over
            if empty(this->allowed_types[real_content_type]) {
                return false;
            }
            let content_type = real_content_type;
        }
        // ok, it's kosher, rewrite what we need
        let uri->userinfo =  null;
        let uri->host =  null;
        let uri->port =  null;
        let uri->fragment =  null;
        let uri->query =  null;
        let uri->path =  "{content_type};base64," . base64_encode(raw_data);
        return true;
    }
    
    /**
     * @param int $errno
     * @param string $errstr
     */
    public function muteErrorHandler(int errno, string errstr) -> void
    {
    }

}