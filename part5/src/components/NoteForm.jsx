import { useState } from 'react'

const NoteForm = ({ createNote }) => {
  const [ newNote, setNewNote ] = useState('')

  const addNote = event => {
    event.preventDefault()
    createNote({
      content: newNote,
      important: true
    })

    setNewNote('')
  }
  return (
    <div>
      <h2>Create new note</h2>

      <form onSubmit={ addNote }>
        <input
          value={ newNote }
          onChange={ event => setNewNote(event.target.value) }
          placeholder='write note content here'
        />
        <button type='submit'>Save</button>
      </form>
    </div>
  )
}

export default NoteForm