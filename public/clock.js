document.addEventListener("DOMContentLoaded", function(event) { 
  updateClock();
  setInterval(updateClock, 1000);
});

function updateClock() {
    var clock = document.querySelector(".closed-registrations-message .clock");
    var now = new Date();
    var open = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
    var ts = open.setUTCHours(19);
    if (open - now < 0) {
      open = new Date(ts + 24*60*60*1000);
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
