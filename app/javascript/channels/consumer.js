// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

// Make ActionCable available globally for debugging
import * as ActionCable from "@rails/actioncable"
window.ActionCable = ActionCable;

window.consumer = createConsumer();

export default window.consumer;
