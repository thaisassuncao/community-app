import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["username", "content", "submit"]

  connect() {
    const savedUsername = sessionStorage.getItem('username')
    if (savedUsername && this.hasUsernameTarget) {
      this.usernameTarget.value = savedUsername
    }
  }

  submit(event) {
    if (this.hasUsernameTarget && this.usernameTarget.value) {
      sessionStorage.setItem('username', this.usernameTarget.value)
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.textContent = 'Enviando...'
    }
  }

  clear() {
    if (this.hasContentTarget) {
      this.contentTarget.value = ''
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.textContent = 'Enviar Mensagem'
    }
  }
}
