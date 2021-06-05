module com.zhanitest.marumaru.utils;
/***
 * 유틸리티- Utils
 * 
 * 프로그램 핵심 로직과 관련이 크게 없는 부수적인 기능을 구현한다.
 * 
 * Authors: ZHANITEST, github.com/zhanitest/marumaru.d
 * License: LGPL-v2
 */
import std.string:replace;
import std.file:exists,mkdir,remove;
import std.array:split,appender;
import std.net.curl:download;
import com.zhanitest.marumaru.common;

/***
  * 유틸리티 구조체
  *
  * Example:
  * ---
  * Utils.makeDir("./make/directories/with/no/error");
  * assert("Hello"==Utils.stripSpecialChar("/Hell<o")); // Hello
  * ---
  */
struct Utils {
    /***
     * 디렉토리 생성
     * 
     * 디렉토리 중복에 상관 없이 입력받은 문자열을 기반으로 디렉토리를 모두 생성한다.
     *
     * Params:
     *  path = 생성할 디렉토리 경로
     */
    public static void makeDir(string path){
        string[] keywords = split(path, "/");
        string stack = "./";
        foreach(p; keywords){
        stack ~= stripSpecialChar(p)~"/";
            if( !exists(stack) )
            { mkdir(stack); }
        }
    }

    /***
     * 입력받은 문자열에 특수문자를 제거한다
     * Params:
     *  text = 원문
     *  keyword = (선택)기본 값=화이트스페이스
     */
    public static string stripSpecialChar(string text){
        auto result = appender!string;
        foreach(char c; text) {
            if( c !='/' && c!=':' && c!='*' && c!='?' && c!='<' && c!='>' && c!='|' && c!='？')
                result.put(c);
        } 
        return result.data;
    }

    /***
     * cacert.pem 다운로드
     * 
     * D언어 표준라이브러리에 내장된 curl(`std.net.curl`)을 이용해 SSL인증서를 다운로드 받는다.
     *
     * Returns: 다운로드 정상여부 (true or false)
     */
    public static bool downloadSslCert() {
        if(exists(CommonData.SSL_PATH)) {
            remove(CommonData.SSL_PATH);
        }
        download(CommonData.SSL_DOWNLOAD_URL, CommonData.SSL_PATH);
        return exists(CommonData.SSL_PATH);
    }
}