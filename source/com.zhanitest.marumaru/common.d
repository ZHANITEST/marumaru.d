module com.zhanitest.marumaru.common;
/***
 * 공통부
 * 
 * 라이브러리 구동에 필요한 최소한의 설정 값을 상수로 정의해 사용한다.
 * 
 * Authors: ZHANITEST, github.com/zhanitest/marumaru.d
 * License: LGPL-v2
 */



/***
 * 공통부 데이터
 */
struct CommonData {
    //--------------------------------------------------------------------------------
    // 호스트 값 - host url
    //--------------------------------------------------------------------------------
    public static const string HOST = "https://marumaru.cloud";
    
    //--------------------------------------------------------------------------------
    // 보드주소 값 - board name(part of full url)
    //--------------------------------------------------------------------------------
    public static const string BOARD = "bbs/cmoic";

    //--------------------------------------------------------------------------------
    // 이미지 미러 리스트 - image mirror list
    //--------------------------------------------------------------------------------
    public static const string[] IMG_MIRROR = [
        "https://marumaru.cloud",
        "http://wasabisyrup.com" // Legacy
    ];
    
    //--------------------------------------------------------------------------------
    // SSL 인증서 기본경로 - SSL cert path
    //--------------------------------------------------------------------------------
    public static const string SSL_PATH = "./cacert.pem";

    //--------------------------------------------------------------------------------
    // SSL 인증서 업데이트 경로
    //--------------------------------------------------------------------------------
    public static const string SSL_DOWNLOAD_URL = "https://curl.se/ca/cacert.pem";
}

/***
 * 개발용 설정 값
 */
struct DevData {
    //--------------------------------------------------------------------------------
    // Request의 디버깅 로그 레벨 값
    //--------------------------------------------------------------------------------
    public static const REQUEST_LOG_LEVEL = 2;

    //--------------------------------------------------------------------------------
    // fakeRequest의 경로
    //--------------------------------------------------------------------------------
    public static const REQUEST_PATH = "./testdata/";
}

/***
 * 유저에이전트 설정 값
 */
struct UserAgent {
    //--------------------------------------------------------------------------------
    // Chrome
    //--------------------------------------------------------------------------------
    @property public static string[string] Chrome(){
        return [
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            "Accept-Encoding":"gzip, deflate, br",
            "Accept-Language":"ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Cache-Control":"max-age=0",
            //"If-Modified-Since":"Tue, 01 Jun 2021 16:22:16 GMT",
            "sec-ch-ua": `"Chromium";v="91", " Not;A Brand";v="99"`,
            "sec-ch-ua-mobile": "?0",
            "sec-fetch-dest": "document",
            "sec-fetch-mode" : "navigate",
            "sec-fetch-site" : "none",
            "sec-fetch-user" : "?1",
            "Upgrade-Insecure-Requests":"1",
            "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36"];
    }
    
    //--------------------------------------------------------------------------------
    // Edge
    //--------------------------------------------------------------------------------
    @property public static string[string] Edge(){
        return [
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            "Accept-Encoding":"gzip, deflate, br",
            "Accept-Language":"ko-KR,ko;q=0.8,en-US;q=0.5,en;q=0.3",
            "Cache-Control":"max-age=0",
            //"If-Modified-Since":"Tue, 01 Jun 2021 16:22:16 GMT",
            "Referer":"https://marumaru.cloud/",
            "sec-ch-ua": `" Not;A Brand";v="99", "Microsoft Edge";v="91", "Chromium";v="91"`,
            "sec-ch-ua-mobile": "?0",
            "sec-fetch-dest": "document",
            "sec-fetch-mode" : "navigate",
            "sec-fetch-site" : "same-origin",
            "sec-fetch-user" : "?1",
            "Upgrade-Insecure-Requests":"1",
            "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0"];
    }
    
    //--------------------------------------------------------------------------------
    // Firefox
    //--------------------------------------------------------------------------------
    @property public static string[string] Firefox(){
        return ["Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                "Accept-Encoding":"gzip, deflate, br",
                "Accept-Language":"ko-KR,ko;q=0.8,en-US;q=0.5,en;q=0.3",
                "Cache-Control":"max-age=0",
                "Connection":"keep-alive",
                "Host":"marumaru.cloud",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0",
                //"If-Modified-Since":"Tue, 01 Jun 2021 16:22:16 GMT",
                "Referer":"https://marumaru.cloud/",
                "TE":"Trailers",
                "Upgrade-Insecure-Requests":"1",
                "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0"];
    }
}