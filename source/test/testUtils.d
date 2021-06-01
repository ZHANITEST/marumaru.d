module testUtils;

import com.zhanitest.marumaru.utils;
import std.stdio;

unittest {
    // stripSpecialChar 테스트
    assert("TEST" == Utils.stripSpecialChar("><TE?ST<"),
        Utils.stripSpecialChar("><TE?ST<"));
}