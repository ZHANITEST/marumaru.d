module com.zhanitest.marumaru.feature;
/***
 * 피처 - Feature
 * 
 * 프로그램의 가장 작은 단위로 기능 위주의 클래스를 정의한다.
 * 
 * Authors: ZHANITEST, github.com/zhanitest/marumaru.d
 * License: LGPL-v2
 */
import std.uri:encode;
import std.conv:to;
import requests;
import com.zhanitest.marumaru.common;

/***
 * 클라이언트 피처
 * 
 * 웹 요청 및 응답을 받는 기능을 수행한다.
 * OpenSSL 인증서 위치 기본 값(`./cacert.pem`)은 `com.zhanitest.marumaru.common`을 참조한다.
 */
class ClientFeature {
    private string Rurl;    /// URL
    private string sslPath; /// SSL 인증서 위치
    private string Rhtml;   /// 요청결과
    @property public string html()  { return this.Rhtml; }
    @property public string url()   { return this.Rurl; }
    
    /***
     * 생성자
     * Params:
     *  url = 파싱 할 만화URL
     */
    public this(string url) {
        this.Rurl = url;
        this.Rhtml = "";
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
        req.sslSetCaCert(CommonData.SSL_PATH);
        //req.sslSetVerifyPeer(false);
        debug {
            req.verbosity = DevData.REQUEST_LOG_LEVEL; // Request 디버깅 레벨
        }
        req.addHeaders(UserAgent.Chrome);
        Response res = req.get(encode(this.Rurl)); // url 인코딩 추가
        this.Rhtml = to!string(res.responseBody);
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

    /***
     * 요청결과 받기
     * Return:
     *  요청에 대한 응답 HTML 본문 값
     */
    public string getHtml() {
        return this.Rhtml;
    }
}