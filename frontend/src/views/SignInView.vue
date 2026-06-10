<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

import { login, register } from '../services/auth'

const router = useRouter()
const authMode = ref<'login' | 'register'>('login')
const submittingAuth = ref(false)
const authEmail = ref('')
const authPassword = ref('')
const authConfirmPassword = ref('')
const authError = ref('')

async function submitAuth() {
  authError.value = ''

  if (authMode.value === 'register' && authPassword.value !== authConfirmPassword.value) {
    authError.value = 'Passwords do not match.'
    return
  }

  submittingAuth.value = true

  try {
    if (authMode.value === 'login') {
      await login({ email: authEmail.value.trim(), password: authPassword.value })
    } else {
      await register({ email: authEmail.value.trim(), password: authPassword.value })
    }

    await router.push('/dashboard')
  } catch {
    authError.value = 'Could not complete sign in. Check your credentials and try again.'
  } finally {
    submittingAuth.value = false
  }
}
</script>

<template>
  <main class="page shell">
    <div class="ambient ambient-left"></div>
    <div class="ambient ambient-right"></div>

    <section class="auth-layout">
      <div class="hero-card">
        <p class="eyebrow">Todo Studio</p>
        <h1>Sign in and get to work.</h1>
        <p class="hero-copy">
          Use your account to access your private task dashboard.
        </p>
      </div>

      <section class="auth-card">
        <div class="segmented-control">
          <button :class="{ active: authMode === 'login' }" type="button" @click="authMode = 'login'">
            Sign in
          </button>
          <button :class="{ active: authMode === 'register' }" type="button" @click="authMode = 'register'">
            Create account
          </button>
        </div>

        <form class="auth-form" @submit.prevent="submitAuth">
          <label>
            <span>Email</span>
            <input v-model="authEmail" type="email" autocomplete="email" placeholder="you@example.com" />
          </label>

          <label>
            <span>Password</span>
            <input
              v-model="authPassword"
              type="password"
              autocomplete="current-password"
              placeholder="Enter your password"
            />
          </label>

          <label v-if="authMode === 'register'">
            <span>Confirm password</span>
            <input
              v-model="authConfirmPassword"
              type="password"
              autocomplete="new-password"
              placeholder="Repeat your password"
            />
          </label>

          <p v-if="authError" class="notice notice-error">{{ authError }}</p>

          <button class="primary-action" type="submit" :disabled="submittingAuth">
            {{ submittingAuth ? 'Working...' : authMode === 'login' ? 'Sign in' : 'Create account' }}
          </button>
        </form>
      </section>
    </section>
  </main>
</template>
