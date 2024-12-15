(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer('/cable');

  // Debug logging
  App.cable.subscriptions.create = function() {
    const subscription = ActionCable.Subscriptions.prototype.create.apply(this, arguments);
    console.log('Created subscription:', subscription);
    return subscription;
  };

  // Connection monitoring
  App.cable.connection.monitor.reconnectAttempts = 10;
  App.cable.connection.events.disconnect = function() {
    console.log('Disconnected from Action Cable');
  };
  App.cable.connection.events.connect = function() {
    console.log('Connected to Action Cable');
  };
}).call(this); 
