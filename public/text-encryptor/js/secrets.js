var secrets = (function() {
  'use strict';

  function decode(key, cipher) {
    var arrKey = key.split('');
    var arrCipher = cipher.split('');
    var arrKeyNum = uniEncode(arrKey);
    var arrCipherNum = uniEncode(arrCipher);
    var arrKeystream = [];
    for (var i = 0; i < arrCipherNum.length; i++) {
      var mult = returnInt(i / arrKeyNum.length);
      var pos = i % arrKeyNum.length;
      arrKeystream.push(arrKeyNum[pos] + mult);
    }
    var arrTextNum = [];
    for (var j = 0; j < arrCipherNum.length; j++) {
      arrTextNum.push((arrCipherNum[j] + 65536 - arrKeystream[j]) % 65536);
    }
    var arrText = uniDecode(arrTextNum);
    var text = arrText.join('');
    return text;
  }

  function encode(key, text) {
    var arrKey = key.split('');
    var arrText = text.split('');
    var arrKeyNum = uniEncode(arrKey);
    var arrTextNum = uniEncode(arrText);
    var arrKeystream = [];
    for (var i = 0; i < arrTextNum.length; i++) {
      var mult = returnInt(i / arrKeyNum.length);
      var pos = i % arrKeyNum.length;
      arrKeystream.push(arrKeyNum[pos] + mult);
    }
    var arrCipherNum = [];
    for (var j = 0; j < arrTextNum.length; j++) {
      arrCipherNum.push((arrTextNum[j] + arrKeystream[j]) % 65536);
    }
    var arrCipher = uniDecode(arrCipherNum);
    var cipher = arrCipher.join('');
    return cipher;
  }

  function returnInt(n) {
    return parseInt(n, 10);
  }

  function uniDecode(arr) {
    return arr.map(function(x) {
      return String.fromCharCode(x);
    });
  }

  function uniEncode(arr) {
    return arr.map(function(x) {
      return x.charCodeAt(0);
    });
  }

  return {
    decode: decode,
    encode: encode,
    uniDecode: uniDecode,
    uniEncode: uniEncode
  };

}());