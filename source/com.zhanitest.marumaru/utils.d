module com.zhanitest.marumaru.utils;

import std.string:replace;
import std.file:exists,mkdir;
import std.array:split,appender;

/***
  * 유틸리티 클래스
  */
struct Utils {
    /***
     * 디렉토리 중복에 상관없이 생성
     * Params:
     *  path = 생성할 경로
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
}