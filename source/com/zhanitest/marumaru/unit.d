module com.zhanitest.marumaru.unit;
/***
 * 유닛 - Unit
 * 
 * 데이터를 처리하기 위한 관련 클래스를 정의한다.
 * 유닛에 정의된 클래스는 피처(feature)로 합성된 에이블(*able) 클래스를 상속해 구현한다.
 * 
 * Authors: ZHANITEST, github.com/zhanitest/marumaru.d
 * License: LGPL-v2
 */
import std.string:indexOf, strip, split;
import std.regex:matchAll, ctRegex, replaceAll;
import std.array:appender;
import libdominator;
import com.zhanitest.marumaru.common;
import com.zhanitest.marumaru.feature;


/***
 * 요청가능한 객체
 *
 * 웹 상의 원격지에 HTTP/HTTPS요청이 가능한 하위 피처(Features)들로 이루어진 일련의 기능집합이다.
 */
class Requestable {
    private string Rurl;            /// 응답을 요청하기 위한 원격지 URL. `ClientFeature`에 전달된다.
    private ClientFeature client;   /// 요청용 리퀘스트 오브젝트. `com.zhanitest.marumaru.feature` 참조.
    debug{ private string fakeId;   /// 디버그 시 fakeLoad 등 로컬테스트 목적으로 사용되는 파일ID.
    } 

    this(string url, string fakeId) {
        this.Rurl = url;
        this.fakeId = fakeId;
    }

    /***
     * 읽어오기
     * 
     * 웹 상의 원격지로 요청을 보내 응답을 로드한다.
     */
    public void load() {
        this.client = new ClientFeature(this.Rurl);
        this.client.request();
    }

    /***
     * (테스트용) 가짜로 읽어오기
     *
     * 디버그(`debug`) 모드에서만 활성화된다.
     * 웹 상의 원격지 대신 로컬파일을 읽어와 실제 요청을 보내는 것과 같은 효과를 낸다.
     * 테스트파일의 경로는 `com.zhanitest.marumaru.common`에 정의되어있다.
     */
    debug{
        public void fakeLoad() {
            this.client = new ClientFeature(this.Rurl);
            this.client.fakeRequest(fakeId);
        }
    }

    /***
     * HTML 본문 얻기
     *
     * `this.load` 혹은 `this.fakeLoad`를 호출하면서 필드에 적재한 HTML 값을 돌려준다.
     * Returns: HTML 본문. 기본 값은 빈 문자열(length==0).
     */
    @property public string html() {
        return this.client.getHtml();
    }
}

/***
 * 만화(작품) 클래스
 * 
 * 인스턴스 생성 시 만화ID를 반드시 필요료 한다.
 * 인스턴스 초기화 후 **반드시 load를 호출해야 정상동작** 한다.
 *
 * Example:
 * ---
 * Comic comic = new Comic("20342"); // 만화 클래스, 작품명 (ex. GTO)
 * comic.load(); // 초기화 후 반드시 호출해야 한다.
 * ---
 */
class Comic : Requestable {
    private string RcomicId;        /// 작품ID (Read-only)
    private PageLink[] RpageLinks;  /// 페이지URL 모음 (Read-only)

    /*** URL를 취득한다. (ex. `https://example.org/1234/4567`) */
    @property string url()      { return this.Rurl; }

    /***
     * 생성자
     *
     * 만화ID만 받는 경우로 공통부(cotmmond.d)의 기본 값으로 URL을 조립한다.
     * 
     * Params:
     *  comicId = 만화ID
     */
    public this(string comicId){
        auto sb = appender!string;
        sb.put(CommonData.HOST);
        sb.put("/");
        sb.put(CommonData.BOARD);
        sb.put("/");
        sb.put(comicId);
        this.RcomicId = comicId;
        super(sb.data, RcomicId);
    }
    
    /***
     * 제목 얻기
     *
     * 현재 페이지의 제목을 얻는다.
     *
     * Returns: 페이지 제목
     */
    public string getTitle() {
        const string pattern = `<title>MARUMARU - 마루마루 - ([』『】【><.,?;:'"|~+=)(\]\[!@#$%^&*★☆\w\d- 가-힣]+)<\/title>`;
        auto rx = matchAll(this.html, pattern);
        if(rx.empty()) {
            throw new Exception("Regex result is empty!", this.html);
        }
        return strip(rx.front[1]);
	}

    /***
     * 페이지 얻기
     *
     * 페이지 목록을 얻는다.
     * 
     * Returns: 링크 구조체 배열
     * 
     * Example:
     * ---
     * Comic comic = new Comic("22739");
     * comic.load();
     * foreach(e; comic.getPageLinks()) {
     *   writeln(e);
     *   // PageLink("https://marumaru.cloud/bbs/cmoic/22739/36359", "/bbs/cmoic/22739/36359", "22739", "36359")
     * }
     * ---
     */
    public PageLink[] getPageLinks() {
        PageLink[] result;
        const string pattern =`<a href="(\/bbs\/cmoic\/[\d]+\/[\d]+)">[\r\n\t ]+([』『】【><.,?;:'"|~+=)(\]\[!@#$%^&*★☆\w\d- 가-힣]+)[\n\t ]+<\/a>`;
        auto rx = matchAll(this.html, pattern);
        if(rx.empty()) {
            throw new Exception("Regex result is empty!");
        }
        foreach(r; rx) {
            // r[0] = 원문
            // r[1] = href(Attribute)
            // r[2] = InnerHTML
            auto sbForUrl = appender!string;
            sbForUrl.put(CommonData.HOST);
            sbForUrl.put(r[1]);
            result ~= PageLink(r[2], sbForUrl.data);
        }
        return result;
    }
}


/***
 * 만화페이지
 */
class ComicPage : Requestable {
    private string RcomicId;    /// 작품ID   (Read-only)
    private string RpageId;     /// 페이지ID (Read-only)
    private string RuniqueId;   /// 고유ID   (Read-only)

    /*** 고유ID(uniqueId)를 취득한다. (ex. `1234/4567`) */
    @property string uniqueId() { return this.RuniqueId; }
    /*** URL를 취득한다. (ex. `https://example.org/1234/4567`) */
    @property string url()      { return this.Rurl; }

    /***
     * 생성자
     *  - 만화ID만 받는 경우로 공통부(cotmmond.d)의 기본 값으로 URL을 조립한다.
     * Params:
     *  id = `만화ID/페이지ID` 형태의 문자열 (ex. 1234/3457)
     */
    public this(string uniqueId){
        auto sb = appender!string;
        sb.put(CommonData.HOST);
        sb.put("/");
        sb.put(CommonData.BOARD);
        sb.put("/");
        sb.put(uniqueId);
        this.RuniqueId = uniqueId;
        string[] idDummy = this.RuniqueId.split("/");
        this.RcomicId = idDummy[0];
        this.RpageId = idDummy[1];
        super(sb.data, uniqueId);
    }
    
    /***
     * 생성자
     * 
     * 만화ID만 받는 경우로 공통부(cotmmond.d)의 기본 값으로 URL을 조립한다.
     *
     * Params:
     *  comicId = 만화ID
     *  pageId = 페이지ID
     */
    public this(string comicId, string pageId){
        auto sbForUrl = appender!string;
        auto sbForUniqId = appender!string;
        
        sbForUniqId.put(comicId);
        sbForUniqId.put("/");
        sbForUniqId.put(pageId);
        this.RuniqueId = sbForUniqId.data; // ID조립

        sbForUrl.put(CommonData.HOST);
        sbForUrl.put("/");
        sbForUrl.put(CommonData.BOARD);
        sbForUrl.put("/");
        sbForUrl.put(this.RuniqueId);
        super(sbForUrl.data, this.RuniqueId);
    }

    /***
     * 제목 취득
     *
     * 현재 페이지의 제목을 얻는다.
     *
     * Returns: 페이지 제목
     */
	public string getTitle() {
        const string pattern = `<meta property="og:title" content="([』『】【><.,?;:'"|~+=)(\]\[!@#$%^&*★☆\w\d- 가-힣]+)" \/>`;
        auto rx = matchAll(this.html, pattern);
        if(rx.empty()) {
            throw new Exception("Regex result is empty!");
        }
        return strip(rx.front[1]);
	}

    /***
     * 이미지 URL 취득
     *
     * 현재 페이지에 존재하는 이미지URL을 얻는다.
     *
     * Returns: 이미지URL 배열
     */
    public string[] getImageUrls() {
        string[] result;
        Dominator dom = new Dominator(this.html);
        Node node = dom.filterDom("div{class:view-img}")[0]; // 어차피 요소는 1개

        // div[class=view-img] 안에 있는 자식엘리먼트중
        foreach(Node imgElement; node.getChildren()) {
            // img태그만!
            if(imgElement.getTag() == "img") {
                // 그 중에서,
                foreach(Attribute attr; imgElement.getAttributes()) {
                    // src만 취득
                    if(attr.key == "src" && attr.values.length == 1)
                        result ~=attr.values[0];
                }
            }
        }
        return result;
    }
}

/***
 * 만화(작품) 링크
 */
struct PageLink{
    public string name;     /// 페이지 이름
    public string url;      /// 페이지 URL
    public string comicId;  /// 만화ID
    public string pageId;   /// 페이지ID
    
    /***
     * 생성자
     * 
     * Params:
     *  name = 페이지이름
     *  url = 페이지URL
     */
    this(string name, string url) {
        string[] urlSplit = url.split("/");
        this.name = name;
        this.url = url;
        this.comicId = urlSplit[$-2]; // 끝에서 두번째
        this.pageId = urlSplit[$-1]; // 끝에서 첫번째
    }
}