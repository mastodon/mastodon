document.addEventListener("DOMContentLoaded", function(event) { 
  updateClock();
  setInterval(updateClock, 1000);
});

function getNextOpen(now) {
    var days = [[0, 14], [4, 18], [8, 22], [12], [2, 16], [6, 20], [10]]
    var nowday = now.getUTCDay();
    var nour = now.getUTCHours();

    var open_hour = -1;
    var d = 0;

    while (open_hour == -1) {
        var times = days[(nowday + d) % 7];
        for (var i = 0; i < times.length; ++i) {
            var time = times[i];
            if (time == nour) {
                return "refresh";
            } else if (time > nour || d > 0) {
                open_hour = time;
                break;
            }
        }
        if (open_hour == -1) {
            d += 1;
            nour = -1;
        }
    }

    var open = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + d));
    var ts = open.setUTCHours(open_hour);
    return open;
}

function updateClock() {
    var clock = document.querySelector(".closed-registrations-message .clock");
    var now = new Date();
    var open = getNextOpen(now);

    if (open == "refresh") {
        location.reload();
        return;
    }

    var until = open - now;
    var ms = until % 1000;
    var s =  Math.floor((until / 1000)) % 60;
    var m =  Math.floor((until / 1000 / 60)) % 60;
    var h =  Math.floor((until / 1000 / 60 / 60));
    if (m < 10) m = "0" + m;
    if (s < 10) s = "0" + s;
    clock.innerHTML = h + ":" + m + ":" + s;
}
