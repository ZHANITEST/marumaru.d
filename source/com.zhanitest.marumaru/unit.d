module com.zhanitest.marumaru.unit;

import std.string:indexOf, strip;
import std.regex:matchAll, ctRegex, replaceAll;
import std.array:appender;
import libdominator;
import com.zhanitest.marumaru.common;
import com.zhanitest.marumaru.feature;

/***
 * 만화페이지
 */
class ComicPage{
    private string Rid;    // 만화ID (Read-only)
    private string Rurl;   // 만화URL (Read-only)
    private string Rhtml;  // HTML본문 (Read-only)
    @property string id()   { return this.Rid; }
    @property string url()  { return this.Rurl; }
    @property string html() { return this.Rhtml; }
    private ClientFeature client;  // 요청용 리퀘스트 오브젝트

    /***
     * 생성
     *  - 만화ID만 받는 경우로 공통부(commond.d)의 기본 값으로 URL을 조립한다.
     * Params:
     *  id = 만화ID
     */
    public this(string id){
        auto sb = appender!string;
        sb.put(CommonData.HOST);
        sb.put("/");
        sb.put(CommonData.BOARD);
        sb.put("/");
        sb.put(id);
        this.Rurl = sb.data;
        this.Rid = id;
    }

    /***
     * 생성자
     *  - URL을 직접 지정
     * Params:
     *  url = 완성형URL(ex. example.org/bbs/comics)
     *  id = 만화ID
     */
    public this(string url, string id){
        auto sb = appender!string;
        sb.put(url);
        sb.put("/");
        sb.put(id);
        this.Rurl = sb.data;
        this.Rid = id;
    }

    /***
     * 읽어오기 [=요청]
     */
    public void load() {
        this.client = new ClientFeature(url);
        this.client.request();
        this.Rhtml = this.client.html;
    }

    /***
     * 제목 얻기
     */
	@property
    public string title() {
        const string pattern = `<meta property="og:title" content="([><.,?;:'"|~+=)(\]\[!@#$%^&*★\w\d- 가-힣]+)" \/>`;
        auto rx = matchAll(this.Rhtml, pattern);
        if(rx.empty()) {
            throw new Exception("Regex result is empty!");
        }
        return strip(rx.front[1]);
	}

    /***
     * 이미지 URL 얻기
     */
    public string[] getImageUrl() {
        Dominator dom = new Dominator(this.Rhtml);
        string[] data;
        return data; // -- 중셉
    }

    debug{
        /***
        * (테스트용) 가짜로 읽어오기 [=요청]
        */
        public void fakeLoad() {
            this.client = new ClientFeature(Rurl);
            this.client.fakeRequest(Rid);
            this.Rhtml = this.client.html;
        }
    }
}