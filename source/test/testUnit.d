module testUnit;

import com.zhanitest.marumaru.unit;
import com.zhanitest.marumaru.utils;
import com.zhanitest.marumaru.common;
import std.conv:to;

unittest {
    //==========================================================
    // Comic 유닛테스트
    //==========================================================
    Comic comic = new Comic("22739");
    
    // URL 조립체크
    // 기대값: https://marumaru.cloud/bbs/cmoic/22739
    assert(comic.url == CommonData.HOST~"/"~CommonData.BOARD~"/22739",
        comic.url);

    //comic.fakeLoad(); /* 로컬 테스트 */
    comic.load(); /* 리얼 테스트 */
    
    // 제목 얻기 테스트
    assert("잘 자, 푼푼"==comic.getTitle(),
        comic.getTitle());

    // 링크 얻기 테스트 #1 - 길이
    assert(28==comic.getPageLinks().length,
        comic.getPageLinks().length.to!string());
    
    // 링크 얻기 테스트 #2 - 내용
    int chkDigit = 0;
    foreach(pageLink; comic.getPageLinks()) {
        if(pageLink.name == "잘 자, 푼푼 13-3권")
            chkDigit += 1;
    }
    assert(chkDigit==1, chkDigit.to!string());

    //==========================================================
    // ComicPage 유닛테스트
    //==========================================================
    ComicPage page = new ComicPage("22739", "35937"); // == ComicPage("22739/35937");
    //Utils.downloadSslCert();
    page.fakeLoad(); /* 로컬 테스트 */
    //page.load(); /* 리얼 테스트 */
    
    // URL 조립체크
    // 기대값: https://marumaru.cloud/bbs/cmoic/22739/35937
    assert(CommonData.HOST~"/"~CommonData.BOARD~"/22739/35937"==page.url,
        page.url);

    // getTitle 타이틀 얻기
    assert("잘 자, 푼푼 1-1권"==page.getTitle(),
        page.getTitle());

    assert(page.getImageUrls().length == 118
        , page.getImageUrls().length.to!string());
}