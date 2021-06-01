module com.zhanitest.marumaru.feature;

import requests;
import com.zhanitest.marumaru.common;

/***
 * 클라이언트 피처:: 웹 요청 및 응답을 받는다
 *  OpenSSL 인증서 위치 기본 값 = cacert.pem
 */
class ClientFeature {
    private string url;     /// 만화 URL
    private string sslPath; /// SSL 인증서 위치
    private string Rhtml;    /// 요청결과
    @property public string html() { return this.Rhtml; }
    
    /***
     * 생성자
     * Params:
     *  url = 파싱 할 만화URL
     */
    public this(string url) {
        this.url = url;
        this.sslPath = CommonData.SSL_PATH;
    }

    /***
     * 인증서 위치 설정
     * Params:
     *  sslPath = 재설정할 SSL 인증서 위치
     */
    public void setSslPath(string sslPath) {
        this.sslPath = sslPath;
    }

    /***
     * 입력받은 url로 리퀘스트 요청
     */
    public void request() {
        Request req = Request();
        debug {
            req.verbosity = DevData.REQUEST_LOG_LEVEL; // Request 디버깅 레벨
        }
    }

    /***
     * (테스트용) 입력받은 url로 리퀘스트 요청
     *  - 이 메소드는 debug 빌드에서만 활성화됨. 프로덕션 환경에서는 비활성화.
     */
    debug{
        import std.array:appender;
        import std.stdio:File;
        import std.string:replace;
        import std.file:exists;
        import std.stdio:writeln;
        public void fakeRequest(string id) {
            writeln("FakeRequest to => " ~ id);
            string testFileName = DevData.REQUEST_PATH ~ id.replace("/", "_") ~ ".txt";
                    
            if(!exists(testFileName)) {
                throw new Exception("Can't find test file! - " ~testFileName);
            }
            auto sb = appender!string;
            File f = File(testFileName, "r");
            while(!f.eof()){
                sb.put(f.readln());
            }
            f.close();
            this.Rhtml = sb.data;
        }
    }
}