import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { messageId: Number }

  react(event) {
    event.preventDefault()
    const button = event.currentTarget
    const reactionType = button.dataset.reactionType

    let userId = sessionStorage.getItem('user_id')
    if (!userId) {
      userId = Math.floor(Math.random() * 10000)
      sessionStorage.setItem('user_id', userId)
    }

    button.classList.add('loading')

    fetch(`/messages/${this.messageIdValue}/reactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({
        reaction: {
          user_id: userId,
          reaction_type: reactionType
        }
      })
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
      button.classList.remove('loading')
    })
    .catch(error => {
      console.error('Error:', error)
      button.classList.remove('loading')
    })
  }
}
