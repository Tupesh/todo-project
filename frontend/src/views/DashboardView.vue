<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import { clearStoredAuthToken, fetchMe } from '../services/auth'
import { createTodo, deleteTodo, fetchTodos, updateTodo } from '../services/todos'
import type { Todo, User } from '../types'

const router = useRouter()
const loading = ref(true)
const loadingTodos = ref(false)
const todos = ref<Todo[]>([])
const currentUser = ref<User | null>(null)
const newTitle = ref('')
const error = ref('')

const remainingCount = computed(() => todos.value.filter((todo) => !todo.completed).length)
const completedCount = computed(() => todos.value.filter((todo) => todo.completed).length)
const hasTodos = computed(() => todos.value.length > 0)

function clearSession() {
  clearStoredAuthToken()
  currentUser.value = null
  todos.value = []
}

async function loadTodos() {
  loadingTodos.value = true
  error.value = ''

  try {
    todos.value = await fetchTodos()
  } catch {
    clearSession()
    await router.push('/signin')
  } finally {
    loadingTodos.value = false
  }
}

async function initialize() {
  try {
    currentUser.value = await fetchMe()
    await loadTodos()
  } catch {
    clearSession()
    await router.push('/signin')
  } finally {
    loading.value = false
  }
}

async function addTodo() {
  const title = newTitle.value.trim()
  if (!title) {
    return
  }

  try {
    const created = await createTodo({ title })
    todos.value = [created, ...todos.value]
    newTitle.value = ''
  } catch {
    error.value = 'Could not create todo.'
  }
}

async function toggleTodo(todo: Todo) {
  try {
    const updated = await updateTodo(todo.id, { completed: !todo.completed })
    todos.value = todos.value.map((item) => (item.id === updated.id ? updated : item))
  } catch {
    error.value = 'Could not update todo.'
  }
}

async function removeTodo(todo: Todo) {
  try {
    await deleteTodo(todo.id)
    todos.value = todos.value.filter((item) => item.id !== todo.id)
  } catch {
    error.value = 'Could not delete todo.'
  }
}

async function signOut() {
  clearSession()
  await router.push('/signin')
}

onMounted(initialize)
</script>

<template>
  <main class="page shell">
    <div class="ambient ambient-left"></div>
    <div class="ambient ambient-right"></div>

    <section v-if="loading" class="loading-screen card">
      <div class="spinner"></div>
      <p>Preparing your dashboard...</p>
    </section>

    <section v-else class="workspace">
      <header class="workspace-header">
        <div>
          <p class="eyebrow">Dashboard</p>
          <h1>Welcome, {{ currentUser?.email }}</h1>
          <p class="hero-copy">Only your tasks are visible here.</p>
        </div>
        <button class="secondary-action" type="button" @click="signOut">Sign out</button>
      </header>

      <section class="workspace-grid">
        <article class="panel card accent-card">
          <p class="eyebrow">Overview</p>
          <div class="metric-row">
            <div>
              <span>Total</span>
              <strong>{{ todos.length }}</strong>
            </div>
            <div>
              <span>Done</span>
              <strong>{{ completedCount }}</strong>
            </div>
            <div>
              <span>Left</span>
              <strong>{{ remainingCount }}</strong>
            </div>
          </div>

          <form class="todo-form" @submit.prevent="addTodo">
            <input v-model="newTitle" type="text" placeholder="Add a task" />
            <button class="primary-action" type="submit">Add task</button>
          </form>

          <p v-if="error" class="notice notice-error">{{ error }}</p>
          <p class="notice notice-muted">{{ remainingCount }} tasks still need attention.</p>
        </article>

        <article class="panel card">
          <div class="section-header">
            <div>
              <p class="eyebrow">Tasks</p>
              <h2>Your list</h2>
            </div>
            <span class="badge">{{ todos.length }} items</span>
          </div>

          <p v-if="loadingTodos" class="empty-state">Loading your tasks...</p>

          <div v-else-if="!hasTodos" class="empty-state">
            <strong>No tasks yet.</strong>
            <span>Create your first task to get started.</span>
          </div>

          <ul v-else class="todo-list">
            <li v-for="todo in todos" :key="todo.id" class="todo-item">
              <label class="todo-label">
                <input :checked="todo.completed" type="checkbox" @change="toggleTodo(todo)" />
                <span :class="{ done: todo.completed }">{{ todo.title }}</span>
              </label>

              <button class="delete" type="button" @click="removeTodo(todo)">Delete</button>
            </li>
          </ul>
        </article>
      </section>
    </section>
  </main>
</template>
