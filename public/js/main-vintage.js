/*
* DOZ - Creative 404 Pages
* Build Date: August 2015
* Author: Madeon08
* Copyright (C) 2015 Madeon08
* This is a premium product available exclusively here : http://themeforest.net/user/Madeon08/portfolio
*/

/* ------------------------------------- */
/* LOVE Text Effect .................... */
/* ------------------------------------- */

/* Codepen Link : http://codepen.io/wagerfield/pen/wftcE */

$(window).load(function() {

    (function () {
    var $animate, $container, $message, $paragraph, MESSAGES, animate, initialise, scramble;
    MESSAGES = [];
    MESSAGES.push({
        delay: 0,
        text: "> Oops, We're sorry, but something went wrong..."
    });
    MESSAGES.push({
        delay: 1200,
        text: '現在メンテナンス中、もしくは何らかの障害が発生しています。'
    });
    MESSAGES.push({
        delay: 2200,
        text: '数時間経っても接続できない場合は、'
    });
    MESSAGES.push({
        delay: 3600,
        text: '公式Discordサーバー、メールにてご連絡下さい。'
    });
    MESSAGES.push({
        delay: 5200,
        text: 'ご迷惑をおかけして申し訳ありません。'
    });
    $container = $('#container');
    $message = $('#message');
    $animate = $('#animate');
    $paragraph = null;
    scramble = function (element, text, options) {
        var $element, addGlitch, character, defaults, ghostCharacter, ghostCharacters, ghostLength, ghostText, ghosts, glitchCharacter, glitchCharacters, glitchIndex, glitchLength, glitchProbability, glitchText, glitches, i, k, letter, object, order, output, parameters, ref, results, settings, shuffle, target, textCharacters, textLength, wrap;
        defaults = {
            probability: 0.2,
            glitches: '-|/\\',
            blank: '',
            duration: text.length * 40,
            ease: 'easeInOutQuad',
            delay: 0
        };
        $element = $(element);
        settings = $.extend(defaults, options);
        shuffle = function () {
            if (Math.random() < 0.5) {
                return 1;
            } else {
                return -1;
            }
        };
        wrap = function (text, classes) {
            return '<span class="' + classes + '">' + text + '</span>';
        };
        glitchText = settings.glitches;
        glitchCharacters = glitchText.split('');
        glitchLength = glitchCharacters.length;
        glitchProbability = settings.probability;
        glitches = function () {
            var j, len, results;
            results = [];
            for (j = 0, len = glitchCharacters.length; j < len; j++) {
                letter = glitchCharacters[j];
                results.push(wrap(letter, 'glitch'));
            }
            return results;
        }();
        ghostText = $element.text();
        ghostCharacters = ghostText.split('');
        ghostLength = ghostCharacters.length;
        ghosts = function () {
            var j, len, results;
            results = [];
            for (j = 0, len = ghostCharacters.length; j < len; j++) {
                letter = ghostCharacters[j];
                results.push(wrap(letter, 'ghost'));
            }
            return results;
        }();
        textCharacters = text.split('');
        textLength = textCharacters.length;
        order = function () {
            results = [];
            for (var j = 0; 0 <= textLength ? j < textLength : j > textLength; 0 <= textLength ? j++ : j--) {
                results.push(j);
            }
            return results;
        }.apply(this).sort(this.shuffle);
        output = [];
        for (i = k = 0, ref = textLength; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
            glitchIndex = Math.floor(Math.random() * (glitchLength - 1));
            glitchCharacter = glitches[glitchIndex];
            ghostCharacter = ghosts[i] || settings.blank;
            addGlitch = Math.random() < glitchProbability;
            character = addGlitch ? glitchCharacter : ghostCharacter;
            output.push(character);
        }
        object = { value: 0 };
        target = { value: 1 };
        parameters = {
            duration: settings.duration,
            ease: settings.ease,
            step: function () {
                var index, l, progress, ref1;
                progress = Math.floor(object.value * (textLength - 1));
                for (i = l = 0, ref1 = progress; 0 <= ref1 ? l <= ref1 : l >= ref1; i = 0 <= ref1 ? ++l : --l) {
                    index = order[i];
                    output[index] = textCharacters[index];
                }
                return $element.html(output.join(''));
            },
            complete: function () {
                return $element.html(text);
            }
        };
        return $(object).delay(settings.delay).animate(target, parameters);
    };
    animate = function () {
        var data, element, index, j, len, options;
        for (index = j = 0, len = MESSAGES.length; j < len; index = ++j) {
            data = MESSAGES[index];
            element = $paragraph.get(index);
            element.innerText = '';
            options = { delay: data.delay };
            scramble(element, data.text, options);
        }
    };
    initialise = function () {
        var index, j, len, text;
        $animate.click(animate);
        for (index = j = 0, len = MESSAGES.length; j < len; index = ++j) {
            text = MESSAGES[index];
            $message.append('<p>');
        }
        $paragraph = $container.find('p');
        animate();
    };
    initialise();
}.call(this));

});