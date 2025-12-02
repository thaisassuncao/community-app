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

    const url = `/messages/${this.messageIdValue}/reactions`
    console.log('POST to:', url)

    fetch(url, {
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
    .then(response => {
      console.log('Response status:', response.status)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.text()
    })
    .then(html => {
      console.log('Turbo stream HTML:', html)
      Turbo.renderStreamMessage(html)
      button.classList.remove('loading')
    })
    .catch(error => {
      console.error('Error creating reaction:', error)
      button.classList.remove('loading')
      alert('Erro ao adicionar reação. Tente novamente.')
    })
  }
}
