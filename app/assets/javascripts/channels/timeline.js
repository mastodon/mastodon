App.timeline = App.cable.subscriptions.create("TimelineChannel", {
  connected: function() {
    console.log('Connected');
  },

  disconnected: function() {
    console.log('Disconnected');
  },

  received: function(data) {
    console.log(JSON.parse(data.message));
  }
});
