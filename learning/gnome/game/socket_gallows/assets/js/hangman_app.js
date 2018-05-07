import HangmanSocket from "./hangman_socket.js"

window.onload = () => {
	let hangman = new HangmanSocket()

	hangman.connect_to_hangman()
}
