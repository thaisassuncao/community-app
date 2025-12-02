// Architecture Decision: Manual controller registration instead of auto-loading
// Why: Simpler and more explicit than trying to auto-discover controllers
// This ensures all controllers are properly loaded and registered with Stimulus

import { application } from "./application.js"
import ReactionsController from "./reactions_controller.js"
import MessageFormController from "./message_form_controller.js"
import HelloController from "./hello_controller.js"

application.register("reactions", ReactionsController)
application.register("message-form", MessageFormController)
application.register("hello", HelloController)
