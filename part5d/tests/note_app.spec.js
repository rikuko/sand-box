const { test, expect, describe, beforeEach } = require('@playwright/test')

describe('Note app', () => {
    beforeEach(async ({ page, request }) => {
        request.post('http://localhost:3001/api/testin/reset')
        await request.post('http://localhost:3001/api/users', {
            date: {
                name: 'Ricky Roto',
                username: 'rkos',
                password: 'salainen'
            }
        })
        await page.goto('http://localhost:5173')
    })

    test('front page can be opened', async ({ page }) => {
        const locator = page.getByText('Notes')
        await expect(locator).toBeVisible()
        await expect(page.getByText('Note app, Department of Computer Science, University of Helsinki 2025')).toBeVisible()
    })

    test('user can log in', async ({ page }) => {
        await page.getByRole('button', { name: 'Login' }).click()
        await page.getByLabel('Username').fill('rkos')
        await page.getByLabel('Password').fill('salainen')

        await page.getByRole('button', { name: 'Login' }).click()

        await expect(page.getByText('Ricky Roto logged in')).toBeVisible()
    })

    describe('when logged in', () => {
        beforeEach(async ({ page }) => {
            await page.getByRole('button', { name: 'Login' }).click()
            await page.getByLabel('Username').fill('rkos')
            await page.getByLabel('Password').fill('salainen')
            await page.getByRole('button', { name: 'Login' }).click()
        })
        test('a new note can be created', async ({ page }) => {
            await page.getByRole('button', { name: 'New note' }).click()
            await page.getByRole('textbox').fill('A Note created by Playwright')
            await page.getByRole('button', { name: 'Save' }).click()
            await expect(page.getByText('A Note created by Playwright')).toBeVisible()
        })
    })
})

//! Tietokannan kontrollointi melkein valmis. Tarkasta ja jatka!