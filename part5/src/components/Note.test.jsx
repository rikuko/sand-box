import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import Note from './Note'
import { expect } from 'vitest'

// Test 1.
test('Test 1.: renders content', () => {
  const note = {
    content: 'Component testing is done with react-testing-library',
    important: true
  }
  render(<Note note={ note } />)
  screen.debug()
  const element = screen.getByText('Component testing is done with react-testing-library')

  expect(element).toBeDefined()
})

// Test 2.
test('Test 2.: does not render this', () => {
  const note = {
    content: 'this is a reminder',
    important: true
  }
  render(<Note note={ note } />)

  const element = screen.queryByText('do not want this thing to be rendered')
  screen.debug(element)
  expect(element).toBeNull()
})

//Test 3.
test('Test 3.: renders content', () => {
  const note = {
    content: 'Component testing is done with react-testing-library',
    important: true
  }
  const { container } = render(<Note note={ note } />)
  const div = container.querySelector('.note')
  expect(div).toHaveTextContent('Component testing is done with react-testing-library')
})

// Test 4.
test('Test 4.: clicking the button calls event handler once', async () => {
  const note ={
    content: 'Component testing is done with react-testing-library',
    important: true
  }
  const mockHandler = vi.fn()

  render(<Note note={ note } toggleImportance={ mockHandler } />)

  const user = userEvent.setup()
  const button = screen.getByText('make not important')
  await user.click(button)

  expect(mockHandler.mock.calls).toHaveLength(1)
})