module testUnit;

import com.zhanitest.marumaru.unit;
import std.stdio;

unittest {
    // ComicPage 파싱 테스트
    ComicPage page = new ComicPage("22739/35937");
    page.fakeLoad();
    
    // URL 조립체크
    assert(page.url=="https://marumaru.cloud/bbs/cmoic/22739/35937",
        page.url);

    // getTitle 타이틀 얻기
    assert(page.title=="잘 자, 푼푼 1-1권",
        page.title);

}