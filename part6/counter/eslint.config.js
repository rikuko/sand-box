import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'
import stylistic from '@stylistic/eslint-plugin'

export default defineConfig([
  globalIgnores([ 'dist' ]),
  {
    plugins: {
      '@stylistic': stylistic
    },
    files: [ '**/*.{js,jsx}' ],
    extends: [
      js.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    rules: {
      'no-unused-vars': [ 'error', { varsIgnorePattern: '^[A-Z_]' } ],
      'indent': [ 'error', 2 ],
      'no-extra-semi': 'error',
      'quotes': [ 'error', 'single' ],
      'array-bracket-spacing': [ 'error', 'always' ],
      'arrow-spacing': [ 'error', { 'before': true, 'after': true } ],
      '@stylistic/jsx-curly-spacing': [ 'error', { 'when': 'always' } ]
    },
  },
])
