namespace HTMLPurifier;

/**
 * A UTF-8 specific character encoder that handles cleaning and transforming.
 * @note All functions in this class should be static.
 */
class Encoder
{
    /**
     * Constructor throws fatal error if you attempt to instantiate class
     */
    protected function __construct() -> void
    {
        trigger_error("Cannot instantiate encoder, call methods statically", E_USER_ERROR);
    }
    
    /**
     * Error-handler that mutes errors, alternative to shut-up operator.
     */
    public static function muteErrorHandler() -> void
    {
    }
    
    /**
     * iconv wrapper which mutes errors, but doesn't work around bugs.
     * @param string $in Input encoding
     * @param string $out Output encoding
     * @param string $text The text to convert
     * @return string
     */
    public static function unsafeIconv(string in, string out, string text) -> string
    {
        var tmpArray19735e7c6f2531c9b262b7512b52280a, r;
    
        let tmpArray19735e7c6f2531c9b262b7512b52280a = ["Encoder", "muteErrorHandler"];
        set_error_handler(tmpArray19735e7c6f2531c9b262b7512b52280a);
        let r =  iconv(in, out, text);
        restore_error_handler();
        return r;
    }
    
    /**
     * iconv wrapper which mutes errors and works around bugs.
     * @param string $in Input encoding
     * @param string $out Output encoding
     * @param string $text The text to convert
     * @param int $max_chunk_size
     * @return string
     */
    public static function iconv(string in, string out, string text, int max_chunk_size = 8000) -> string
    {
        var code, c, r, i, chunk_size, chunk;
    
        let code =  self::testIconvTruncateBug();
        if code == self::ICONV_OK {
            return self::unsafeIconv(in, out, text);
        } elseif code == self::ICONV_TRUNCATES {
            // we can only work around this if the input character set
            // is utf-8
            if in == "utf-8" {
                if max_chunk_size < 4 {
                    trigger_error("max_chunk_size is too small", E_USER_WARNING);
                    return false;
                }
                // split into 8000 byte chunks, but be careful to handle
                // multibyte boundaries properly
                let c =  strlen(text);
                if c <= max_chunk_size {
                    return self::unsafeIconv(in, out, text);
                }
                let r = "";
                let i = 0;
                while (true) {
                    if i + max_chunk_size >= c {
                        let r .= self::unsafeIconv(in, out, substr(text, i));
                        break;
                    }
                    // wibble the boundary
                    if 128 != (192 & ord(text[i + max_chunk_size])) {
                        let chunk_size = max_chunk_size;
                    } elseif 128 != (192 & ord(text[i + max_chunk_size - 1])) {
                        let chunk_size =  max_chunk_size - 1;
                    } elseif 128 != (192 & ord(text[i + max_chunk_size - 2])) {
                        let chunk_size =  max_chunk_size - 2;
                    } elseif 128 != (192 & ord(text[i + max_chunk_size - 3])) {
                        let chunk_size =  max_chunk_size - 3;
                    } else {
                        return false;
                    }
                    let chunk =  substr(text, i, chunk_size);
                    // substr doesn't mind overlong lengths
                    let r .= self::unsafeIconv(in, out, chunk);
                    let i += chunk_size;
                }
                return r;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    
    /**
     * Cleans a UTF-8 string for well-formedness and SGML validity
     *
     * It will parse according to UTF-8 and return a valid UTF8 string, with
     * non-SGML codepoints excluded.
     *
     * Specifically, it will permit:
     * \x{9}\x{A}\x{D}\x{20}-\x{7E}\x{A0}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}
     * Source: https://www.w3.org/TR/REC-xml/#NT-Char
     * Arguably this function should be modernized to the HTML5 set
     * of allowed characters:
     * https://www.w3.org/TR/html5/syntax.html#preprocessing-the-input-stream
     * which simultaneously expand and restrict the set of allowed characters.
     *
     * @param string $str The string to clean
     * @param bool $force_php
     * @return string
     *
     * @note Just for reference, the non-SGML code points are 0 to 31 and
     *       127 to 159, inclusive.  However, we allow code points 9, 10
     *       and 13, which are the tab, line feed and carriage return
     *       respectively. 128 and above the code points map to multibyte
     *       UTF-8 representations.
     *
     * @note Fallback code adapted from utf8ToUnicode by Henri Sivonen and
     *       hsivonen@iki.fi at <http://iki.fi/hsivonen/php-utf8/> under the
     *       LGPL license.  Notes on what changed are inside, but in general,
     *       the original code transformed UTF-8 text into an array of integer
     *       Unicode codepoints. Understandably, transforming that back to
     *       a string would be somewhat expensive, so the function was modded to
     *       directly operate on the string.  However, this discourages code
     *       reuse, and the logic enumerated here would be useful for any
     *       function that needs to be able to understand UTF-8 characters.
     *       As of right now, only smart lossless character encoding converters
     *       would need that, and I'm probably not going to implement them.
     */
    public static function cleanUTF8(string str, bool force_php = false) -> string
    {
        var mState, mUcs4, mBytes, out, char, len, i, in, shift, tmp;
    
        // UTF-8 validity is checked since PHP 4.3.5
        // This is an optimization: if the string is already valid UTF-8, no
        // need to do PHP stuff. 99% of the time, this will be the case.
        if preg_match("/^[\\x{9}\\x{A}\\x{D}\\x{20}-\\x{7E}\\x{A0}-\\x{D7FF}\\x{E000}-\\x{FFFD}\\x{10000}-\\x{10FFFF}]*$/Du", str) {
            return str;
        }
        let mState = 0;
        // cached expected number of octets after the current octet
        // until the beginning of the next UTF8 character sequence
        let mUcs4 = 0;
        // cached Unicode character
        let mBytes = 1;
        // cached expected number of octets in the current sequence
        // original code involved an $out that was an array of Unicode
        // codepoints.  Instead of having to convert back into UTF-8, we've
        // decided to directly append valid UTF-8 characters onto a string
        // $out once they're done.  $char accumulates raw bytes, while $mUcs4
        // turns into the Unicode code point, so there's some redundancy.
        let out = "";
        let char = "";
        let len =  strlen(str);
        let i = 0;
        for i in range(0, len) {
            let in =  ord(str[i]);
            let char .= str[i];
            // append byte to char
            if 0 == mState {
                // When mState is zero we expect either a US-ASCII character
                // or a multi-octet sequence.
                if 0 == (128 & in) {
                    // US-ASCII, pass straight through.
                    if (in <= 31 || in == 127) && !((in == 9 || in == 13 || in == 10)) {
                        echo "not allowed";
                    } else {
                        let out .= char;
                    }
                    // reset
                    let char = "";
                    let mBytes = 1;
                } elseif 192 == (224 & in) {
                    // First octet of 2 octet sequence
                    let mUcs4 = in;
                    let mUcs4 =  (mUcs4 & 31) << 6;
                    let mState = 1;
                    let mBytes = 2;
                } elseif 224 == (240 & in) {
                    // First octet of 3 octet sequence
                    let mUcs4 = in;
                    let mUcs4 =  (mUcs4 & 15) << 12;
                    let mState = 2;
                    let mBytes = 3;
                } elseif 240 == (248 & in) {
                    // First octet of 4 octet sequence
                    let mUcs4 = in;
                    let mUcs4 =  (mUcs4 & 7) << 18;
                    let mState = 3;
                    let mBytes = 4;
                } elseif 248 == (252 & in) {
                    // First octet of 5 octet sequence.
                    //
                    // This is illegal because the encoded codepoint must be
                    // either:
                    // (a) not the shortest form or
                    // (b) outside the Unicode range of 0-0x10FFFF.
                    // Rather than trying to resynchronize, we will carry on
                    // until the end of the sequence and let the later error
                    // handling code catch it.
                    let mUcs4 = in;
                    let mUcs4 =  (mUcs4 & 3) << 24;
                    let mState = 4;
                    let mBytes = 5;
                } elseif 252 == (254 & in) {
                    // First octet of 6 octet sequence, see comments for 5
                    // octet sequence.
                    let mUcs4 = in;
                    let mUcs4 =  (mUcs4 & 1) << 30;
                    let mState = 5;
                    let mBytes = 6;
                } else {
                    // Current octet is neither in the US-ASCII range nor a
                    // legal first octet of a multi-octet sequence.
                    let mState = 0;
                    let mUcs4 = 0;
                    let mBytes = 1;
                    let char = "";
                }
            } else {
                // When mState is non-zero, we expect a continuation of the
                // multi-octet sequence
                if 128 == (192 & in) {
                    // Legal continuation.
                    let shift =  (mState - 1) * 6;
                    let tmp = in;
                    let tmp =  (tmp & 63) << shift;
                    let mUcs4 = mUcs4 | tmp;
                    let mState--;
                    if 0 == mState {
                        // End of the multi-octet sequence. mUcs4 now contains
                        // the final Unicode codepoint to be output
                        // Check for illegal sequences and codepoints.
                        // From Unicode 3.1, non-shortest form is illegal
                        if 2 == mBytes && mUcs4 < 128 || 3 == mBytes && mUcs4 < 2048 || 4 == mBytes && mUcs4 < 65536 || 4 < mBytes || (mUcs4 & 4294965248) == 55296 || mUcs4 > 1114111 {
                            echo "not allowed";
                        } elseif 65279 != mUcs4 && (9 == mUcs4 || 10 == mUcs4 || 13 == mUcs4 || 32 <= mUcs4 && 126 >= mUcs4 || 160 <= mUcs4 && 55295 >= mUcs4 || 57344 <= mUcs4 && 65533 >= mUcs4 || 65536 <= mUcs4 && 1114111 >= mUcs4) {
                            let out .= char;
                        }
                        // initialize UTF8 cache (reset)
                        let mState = 0;
                        let mUcs4 = 0;
                        let mBytes = 1;
                        let char = "";
                    }
                } else {
                    // ((0xC0 & (*in) != 0x80) && (mState != 0))
                    // Incomplete multi-octet sequence.
                    // used to result in complete fail, but we'll reset
                    let mState = 0;
                    let mUcs4 = 0;
                    let mBytes = 1;
                    let char = "";
                }
            }
        }
        return out;
    }
    
    /**
     * Translates a Unicode codepoint into its corresponding UTF-8 character.
     * @note Based on Feyd's function at
     *       <http://forums.devnetwork.net/viewtopic.php?p=191404#191404>,
     *       which is in public domain.
     * @note While we're going to do code point parsing anyway, a good
     *       optimization would be to refuse to translate code points that
     *       are non-SGML characters.  However, this could lead to duplication.
     * @note This is very similar to the unichr function in
     *       maintenance/generate-entity-file.php (although this is superior,
     *       due to its sanity checks).
     */
    // +----------+----------+----------+----------+
    // | 33222222 | 22221111 | 111111   |          |
    // | 10987654 | 32109876 | 54321098 | 76543210 | bit
    // +----------+----------+----------+----------+
    // |          |          |          | 0xxxxxxx | 1 byte 0x00000000..0x0000007F
    // |          |          | 110yyyyy | 10xxxxxx | 2 byte 0x00000080..0x000007FF
    // |          | 1110zzzz | 10yyyyyy | 10xxxxxx | 3 byte 0x00000800..0x0000FFFF
    // | 11110www | 10wwzzzz | 10yyyyyy | 10xxxxxx | 4 byte 0x00010000..0x0010FFFF
    // +----------+----------+----------+----------+
    // | 00000000 | 00011111 | 11111111 | 11111111 | Theoretical upper limit of legal scalars: 2097151 (0x001FFFFF)
    // | 00000000 | 00010000 | 11111111 | 11111111 | Defined upper limit of legal scalar codes
    // +----------+----------+----------+----------+
    public static function unichr(code)
    {
        var x, y, z, w, ret;
    
        if code > 1114111 or code < 0 or code >= 55296 and code <= 57343 {
            // bits are set outside the "valid" range as defined
            // by UNICODE 4.1.0
            return "";
        }
        let x = 0;
        let w = 0;
        let z = 0;
        let y = 0;
        ;
        if code < 128 {
            // regular ASCII character
            let x = code;
        } else {
            // set up bits for UTF-8
            let x =  code & 63 | 128;
            if code < 2048 {
                let y =  (code & 2047) >> 6 | 192;
            } else {
                let y =  (code & 4032) >> 6 | 128;
                if code < 65536 {
                    let z =  code >> 12 & 15 | 224;
                } else {
                    let z =  code >> 12 & 63 | 128;
                    let w =  code >> 18 & 7 | 240;
                }
            }
        }
        // set up the actual character
        let ret = "";
        if w {
            let ret .= chr(w);
        }
        if z {
            let ret .= chr(z);
        }
        if y {
            let ret .= chr(y);
        }
        let ret .= chr(x);
        return ret;
    }
    
    /**
     * @return bool
     */
    public static function iconvAvailable() -> bool
    {
        var iconv;
    
        
            let iconv =  null;
        if iconv === null {
            let iconv =  function_exists("iconv") && self::testIconvTruncateBug() != self::ICONV_UNUSABLE;
        }
        return iconv;
    }
    
    /**
     * Convert a string to UTF-8 based on configuration.
     * @param string $str The string to convert
     * @param Config $config
     * @param Context $context
     * @return string
     */
    public static function convertToUTF8(string str, <Config> config, <Context> context) -> string
    {
        var encoding, iconv, bug;
    
        let encoding =  config->get("Core.Encoding");
        if encoding === "utf-8" {
            return str;
        }
        
            let iconv =  null;
        if iconv === null {
            let iconv =  self::iconvAvailable();
        }
        if iconv && !(config->get("Test.ForceNoIconv")) {
            // unaffected by bugs, since UTF-8 support all characters
            let str =  self::unsafeIconv(encoding, "utf-8//IGNORE", str);
            if str === false {
                // $encoding is not a valid encoding
                trigger_error("Invalid encoding " . encoding, E_USER_ERROR);
                return "";
            }
            // If the string is bjorked by Shift_JIS or a similar encoding
            // that doesn't support all of ASCII, convert the naughty
            // characters to their true byte-wise ASCII/UTF-8 equivalents.
            let str =  strtr(str, self::testEncodingSupportsASCII(encoding));
            return str;
        } elseif encoding === "iso-8859-1" {
            let str =  utf8_encode(str);
            return str;
        }
        let bug =  Encoder::testIconvTruncateBug();
        if bug == self::ICONV_OK {
            trigger_error("Encoding not supported, please install iconv", E_USER_ERROR);
        } else {
            trigger_error("You have a buggy version of iconv, see https://bugs.php.net/bug.php?id=48147 " . "and http://sourceware.org/bugzilla/show_bug.cgi?id=13541", E_USER_ERROR);
        }
    }
    
    /**
     * Converts a string from UTF-8 based on configuration.
     * @param string $str The string to convert
     * @param Config $config
     * @param Context $context
     * @return string
     * @note Currently, this is a lossy conversion, with unexpressable
     *       characters being omitted.
     */
    public static function convertFromUTF8(string str, <Config> config, <Context> context) -> string
    {
        var encoding, escape, iconv, ascii_fix, clear_fix, utf8, native;
    
        let encoding =  config->get("Core.Encoding");
        let escape =  config->get("Core.EscapeNonASCIICharacters");
        if escape {
            let str =  self::convertToASCIIDumbLossless(str);
        }
        if encoding === "utf-8" {
            return str;
        }
        
            let iconv =  null;
        if iconv === null {
            let iconv =  self::iconvAvailable();
        }
        if iconv && !(config->get("Test.ForceNoIconv")) {
            // Undo our previous fix in convertToUTF8, otherwise iconv will barf
            let ascii_fix =  self::testEncodingSupportsASCII(encoding);
            if !(escape) && !(empty(ascii_fix)) {
                let clear_fix =  [];
                for utf8, native in ascii_fix {
                    let clear_fix[utf8] = "";
                }
                let str =  strtr(str, clear_fix);
            }
            let str =  strtr(str, array_flip(ascii_fix));
            // Normal stuff
            let str =  self::iconv("utf-8", encoding . "//IGNORE", str);
            return str;
        } elseif encoding === "iso-8859-1" {
            let str =  utf8_decode(str);
            return str;
        }
        trigger_error("Encoding not supported", E_USER_ERROR);
    }
    
    /**
     * Lossless (character-wise) conversion of HTML to ASCII
     * @param string $str UTF-8 string to be converted to ASCII
     * @return string ASCII encoded string with non-ASCII character entity-ized
     * @warning Adapted from MediaWiki, claiming fair use: this is a common
     *       algorithm. If you disagree with this license fudgery,
     *       implement it yourself.
     * @note Uses decimal numeric entities since they are best supported.
     * @note This is a DUMB function: it has no concept of keeping
     *       character entities that the projected character encoding
     *       can allow. We could possibly implement a smart version
     *       but that would require it to also know which Unicode
     *       codepoints the charset supported (not an easy task).
     * @note Sort of with cleanUTF8() but it assumes that $str is
     *       well-formed UTF-8
     */
    public static function convertToASCIIDumbLossless(string str) -> string
    {
        var bytesleft, result, working, len, i, bytevalue;
    
        let bytesleft = 0;
        let result = "";
        let working = 0;
        let len =  strlen(str);
        let i = 0;
        for i in range(0, len) {
            let bytevalue =  ord(str[i]);
            if bytevalue <= 127 {
                //0xxx xxxx
                let result .= chr(bytevalue);
                let bytesleft = 0;
            } elseif bytevalue <= 191 {
                //10xx xxxx
                let working =  working << 6;
                let working += bytevalue & 63;
                let bytesleft--;
                if bytesleft <= 0 {
                    let result .= "&#" . working . ";";
                }
            } elseif bytevalue <= 223 {
                //110x xxxx
                let working =  bytevalue & 31;
                let bytesleft = 1;
            } elseif bytevalue <= 239 {
                //1110 xxxx
                let working =  bytevalue & 15;
                let bytesleft = 2;
            } else {
                //1111 0xxx
                let working =  bytevalue & 7;
                let bytesleft = 3;
            }
        }
        return result;
    }
    
    /** No bugs detected in iconv. */
    const ICONV_OK = 0;
    /** Iconv truncates output if converting from UTF-8 to another
     *  character set with //IGNORE, and a non-encodable character is found */
    const ICONV_TRUNCATES = 1;
    /** Iconv does not support //IGNORE, making it unusable for
     *  transcoding purposes */
    const ICONV_UNUSABLE = 2;
    /**
     * glibc iconv has a known bug where it doesn't handle the magic
     * //IGNORE stanza correctly.  In particular, rather than ignore
     * characters, it will return an EILSEQ after consuming some number
     * of characters, and expect you to restart iconv as if it were
     * an E2BIG.  Old versions of PHP did not respect the errno, and
     * returned the fragment, so as a result you would see iconv
     * mysteriously truncating output. We can work around this by
     * manually chopping our input into segments of about 8000
     * characters, as long as PHP ignores the error code.  If PHP starts
     * paying attention to the error code, iconv becomes unusable.
     *
     * @return int Error code indicating severity of bug.
     */
    public static function testIconvTruncateBug() -> int
    {
        var code, r, c;
    
        
            let code =  null;
        if code === null {
            // better not use iconv, otherwise infinite loop!
            let r =  self::unsafeIconv("utf-8", "ascii//IGNORE", "α" . str_repeat("a", 9000));
            if r === false {
                let code =  self::ICONV_UNUSABLE;
            } else {
            let c =  strlen(r);
            if c < 9000 {
                let code =  self::ICONV_TRUNCATES;
            }
             elseif c > 9000 {
                trigger_error("Your copy of iconv is extremely buggy. Please notify HTML Purifier maintainers: " . "include your iconv version as per phpversion()", E_USER_ERROR);
            } else {
                let code =  self::ICONV_OK;
            }}
        }
        return code;
    }
    
    /**
     * This expensive function tests whether or not a given character
     * encoding supports ASCII. 7/8-bit encodings like Shift_JIS will
     * fail this test, and require special processing. Variable width
     * encodings shouldn't ever fail.
     *
     * @param string $encoding Encoding name to test, as per iconv format
     * @param bool $bypass Whether or not to bypass the precompiled arrays.
     * @return Array of UTF-8 characters to their corresponding ASCII,
     *      which can be used to "undo" any overzealous iconv action.
     */
    public static function testEncodingSupportsASCII(string encoding, bool bypass = false) -> array
    {
        var encodings, lenc, tmpArray02e1d3e2dc0e9ff2abb97df33ad11000, tmpArray6fb0bb7ef77b908abcdf880d1276f4e8, tmpArray40cd750bba9870f18aada2478b24840a, ret, i, c, r;
    
        // All calls to iconv here are unsafe, proof by case analysis:
        // If ICONV_OK, no difference.
        // If ICONV_TRUNCATE, all calls involve one character inputs,
        // so bug is not triggered.
        // If ICONV_UNUSABLE, this call is irrelevant
        
            let encodings =  [];
        if !(bypass) {
            if isset encodings[encoding] {
                return encodings[encoding];
            }
            let lenc =  strtolower(encoding);
            switch (lenc) {
                case "shift_jis":
                    let tmpArray02e1d3e2dc0e9ff2abb97df33ad11000 = ["¥" : "\\", "‾" : "~"];
                    return tmpArray02e1d3e2dc0e9ff2abb97df33ad11000;
                case "johab":
                    let tmpArray6fb0bb7ef77b908abcdf880d1276f4e8 = ["₩" : "\\"];
                    return tmpArray6fb0bb7ef77b908abcdf880d1276f4e8;
            }
            if strpos(lenc, "iso-8859-") === 0 {
                let tmpArray40cd750bba9870f18aada2478b24840a = [];
                return tmpArray40cd750bba9870f18aada2478b24840a;
            }
        }
        let ret =  [];
        if self::unsafeIconv("UTF-8", encoding, "a") === false {
            return false;
        }
        let i = 32;
        for i in range(32, 126) {
            // all printable ASCII chars
            let c =  chr(i);
            // UTF-8 char
            let r =  self::unsafeIconv("UTF-8", "{encoding}//IGNORE", c);
            // initial conversion
            if r === "" || r === c && self::unsafeIconv(encoding, "UTF-8//IGNORE", r) !== c {
                // Reverse engineer: what's the UTF-8 equiv of this byte
                // sequence? This assumes that there's no variable width
                // encoding that doesn't support ASCII.
                let ret[self::unsafeIconv(encoding, "UTF-8//IGNORE", c)] = c;
            }
        }
        let encodings[encoding] = ret;
        return ret;
    }

}