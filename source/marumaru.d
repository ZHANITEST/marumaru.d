/**
 *  [ marumaru.d ]
 *  lgpl-v2, By ZHANITEST(github.com/zhanitest)
 */
module marumaru;

import std.uri;
import std.array;
import std.stdio;
import std.file;
import std.conv;
import std.string;
import std.outbuffer;
static import re = std.regex;
import requests;
import libdominator;

/**
 * 디렉토리 중복에 상관없이 생성
 */
void makeDir( string path ){
	string[] keywords = split(path, "/");
	string stack = "./";
	foreach(p; keywords){
		stack ~= stripChar(p)~"/";
		if( !exists(stack) )
			{ mkdir(stack); }
	}
}

/**
 * 특수문자 제거
 */
string stripChar( string text, string keyword=" " ){
	string result = text;
	string[] table = [ "/", ":", "*", "?", "<", ">", "|", "？" ];
	foreach( t; table ){
		result = result.replace(t, "");
	}
	return result;
}

/**
 *  HTML코드에서 이미지파일주소만 추출
 */
protected static string[] stripFileUrl(string html){
    string target = html;
    string[] result = [];

    string[] patthens = [
        "/storage/gallery/[A-z0-9-]+/[\\S_)(]+.[JjPpEeGg]+",
        //  \/storage\/gallery\/[A-z0-9-]+\/[\S_)(]+.[JjPpEeGg]+
        "/storage/gallery/[A-z0-9-]+/[\\S_)(]+ [\\S_)(]+\\.[JjPpEeGg]+",
        "/storage/gallery/[A-z0-9-]+/[\\S_)( ]+\\.[JjPpEeGg]{3,4}"
    ];

    foreach(p; patthens){
        auto r = re.matchAll(html, regex(p));
        if(r.empty==false){
            foreach(e; r){
                writeln(e[0]);
                result ~= e[0];
            }
        }
        else{
            writeln("can't match!");
            File f = File("HTML.txt", "w");
            f.write(target);
            f.close();
        }
    }
    writeln(result.length);
    return result;
}

/**
 *  리퀘스트 날리기
 */
string req(string url){
    auto rq = Request();
    rq.addHeaders(
        [
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Encoding":"gzip, deflate",
            "Accept-Language":"ko-KR,ko;q=0.8,en-US;q=0.5,en;q=0.3",
            "Cache-Control":"max-age=0",
            "Connection":"keep-alive",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:58.0) Gecko/20100101 Firefox/58.0"
        ]
    );
    Response rp = rq.get(encode(url)); // url 인코딩 추가
    return to!string(rp.responseBody);
}

/**
 *  만화페이지(from marumaru.in)
 */
class comicPage{
    protected:
    string id;
    string html;
    
    public:
    /**
     *  생성자
     */
    this(string id){
        this(
            to!int(id)
        );
    }

    /**
     *  생성자
     */
    this(int id){
        this.id = to!string(id);
        this.html = req("http://marumaru.in/magna/"~this.id);
    }

    /**
     *  제목 얻기
     */
	string getTitle(){
		auto re_result = re.match(
            this.html, ctRegex!(r"<h1>(.+)<\/h1>")
        );
		string title;
		
		foreach( e; re_result )
			{ title = e[1]; }

		// <h1>~</h1> 태그 안에 또다른 태그가 존재한다면,
		if( title.indexOf("<") != -1 || title.indexOf(">") != -1 ){
			title = re.replaceAll( title, ctRegex!(" *</*[fontspa]+ *[stycolrface =\"#\\d\\w,:;\\.\\-\\(\\)]*> *"), "" );
		}
		return title;
	}

    /**
     *  만화 데이터 얻기
     */
    comic getLink(){
        comic result;
        link[] list;
        Dominator dom = new Dominator(this.html);
        foreach(nd; dom.filterDom("a")){
            foreach(ab; nd.getAttributes()){
                // lambda
                string value;
                auto x = (string keyword){
                    foreach(v; ab.values)
                        { if(v.indexOf(keyword)>-1) {value=v; return true;} }
                    return false;
                };

                // key=href면서, 해당 도메인(bool x())이 포함된 경우,
                if(ab.key=="href" && x("archives") ){
                    auto removeTag = (string target){
                        return re.replaceAll(target, ctRegex!("<[^>]*>"), "");
                    };
				    
                    link l;
                    l.title = removeTag(dom.getInner(nd));
                    l.url = value;
                    list ~= l;
                }

            }
        }
        result.title = this.getTitle();
        result.id = this.id;
        result.links = list;
        return result;
    }
}

/**
 *  링크 단위
 */
struct link{
    string title;
    string url;
}

/**
 *  만화 단위
 */
struct comic{
    string title;
    string id;
    link[] links;

    /**
     *  호스팅 URL로 정보 얻기
     *
     *  example:
     *      string[string] r
     *      writeln(r["TITLE"]~":"~r["INDEX"]);
     */
    static string[string] getInfo(string hosting_url){
        string html = req(hosting_url);

        auto rx_id = re.matchAll(hosting_url, "<div class=\"article-title\" title=\"(.+)\">");
        auto rx_title = re.matchAll(html, "<span class=\"title-subject\">(.+)</span>");
        
        string[string] result;
        result["INDEX"] = rx_id.front[1];
        result["TITLE"] = rx_title.front[1];
        
        return result;
    }

    /**
     *  호스팅 URL로 직접 URL 얻기
     */
    static string[] getFileUrl(string hosting_url){
		string[] urls;
		string html = req(hosting_url);
        string let = re.matchFirst(hosting_url, ctRegex!("[shenyucomicswabrp]+.com"))[0];

		// 암호 걸린 만화일 경우
		if(html.indexOf("Protected")>-1){
			auto res = postContent(
				hosting_url, queryParams("password", "qndxkr", "pass", "qndxkr")
			);
			OutBuffer buf = new OutBuffer();
			buf.write(res.data);
			html = buf.toString();
		}

		Dominator dom = new Dominator(html);
		Node[] nodes = dom.filterDom("img");

		foreach(node; nodes){
			foreach(ab; node.getAttributes()){
				string v = ab.values[0];
                if(v.indexOf("/storage/gallery/")>-1){
					urls ~= "http://"~let~v;
				}
			}
		}

		// {임시} 조건 하나 더 검사... + 아예 파싱된 게 제로면 다시 따온다
		//	regex vs indexOf
		if( urls.length==0 || urls[0].indexOf("jpg")<0 && urls[0].indexOf("jpeg")<0 && urls[0].indexOf("JPG")<0 && urls[0].indexOf("JPEG")<0 )
		{
            foreach(u; stripFileUrl(html)){
                urls ~= "http://"~let~u;
            }
		}
		return urls;
    }

    /**
     *  인덱스로 파일 URL 얻기
     */
    string[] getFileUrl(int index){
        return this.getFileUrl(this.links[index].url);
    }
}



unittest{
    /*
    comicpage(marumaru.in/magna/<ID>)
      - LINK1
      - LINK2
      - LINK3
    
    hostpage(LINK1)
      - IMG1
      - IMG2
    */

    // comicpage test

    writeln("===== Function Test =====");
    string temp = req("http://wasabisyrup.com/archives/57Gm5SVLfbk");
    assert(temp.indexOf("you have been blocked")==-1);
    writeln("req Pass!"); 
    

    writeln("===== ComicPage Test =====");
    //int test_id = 252870; // 흑백렌즈http://wasabisyrup.com/archives/57Gm5SVLfbk
    int test_id = 278089; // http://wasabisyrup.com/archives/0fvOcx55kl8
    auto c = new comicPage(test_id);
    writeln("Init Pass!"); 
    
    assert(c.getTitle()!=""); // getTitle
    writeln("getTitle Pass!");

    comic guichan = c.getLink();
    assert(guichan.links.length>0); // getLink-2
    assert(guichan.links[0].url=="http://wasabisyrup.com/archives/0fvOcx55kl8");
    writeln("getLink-2 Pass!");

    assert(c.html.indexOf("vContent")>0); // innerHTML
    writeln("c.html.indexOf Pass!");


    writeln("===== Comic Test =====");
    assert(guichan.getFileUrl(0).length!=0);
    writeln("getFileUrl Pass!");
    /*
    assert(
        guichan.getFileUrl(0)[0] == 
        "http://wasabisyrup.com/storage/gallery/57Gm5SVLfbk/P0134_KF975Wxo07A.jpg",
        "lose"
    );*/
}