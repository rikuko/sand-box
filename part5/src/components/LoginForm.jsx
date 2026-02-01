const LoginForm = ({
  handleSubmit,
  handleUsernameChange,
  handlePasswordChange,
  username,
  password
}) => {
  return (
    <div>
      <h2>Login</h2>

      <form onSubmit={ handleSubmit }>
        <div>
          <label>
          Username
            <input
              type='text'
              value={ username }
              onChange={ handleUsernameChange }
            />
          </label>
        </div>
        <div>
          <label>
          Password
            <input type='password'
              value={ password }
              onChange={ handlePasswordChange }
            />
          </label>
        </div>
        <button type='submit'>Login</button>
      </form>
    </div>
  )
}

export default LoginForm