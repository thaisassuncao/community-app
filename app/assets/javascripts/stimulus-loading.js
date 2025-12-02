// Architecture Decision: Custom stimulus-loading implementation
// Why: @hotwired/stimulus-loading is not available as a standalone npm package
// This custom implementation provides the same eager-loading functionality using
// Vite's import.meta.glob (which importmap-rails supports) to automatically
// discover and register all Stimulus controllers in app/javascript/controllers/
// Controllers are registered with kebab-case names (reactions_controller.js -> "reactions")

export function eagerLoadControllersFrom(_under, application) {
  const controllers = import.meta.glob('/app/javascript/controllers/**/*_controller.js', { eager: true });
  for (const [path, module] of Object.entries(controllers)) {
    const name = path.match(/([^/]+)_controller\.js$/)[1].replace(/_/g, '-');
    application.register(name, module.default);
  }
}
