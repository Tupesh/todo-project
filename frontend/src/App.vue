<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { createTodo, deleteTodo, fetchTodos, updateTodo } from './services/todos'
import type { Todo } from './types'

const todos = ref<Todo[]>([])
const newTitle = ref('')
const loading = ref(false)
const error = ref('')

const remainingCount = computed(() => todos.value.filter((todo) => !todo.completed).length)

async function loadTodos() {
  loading.value = true
  error.value = ''

  try {
    todos.value = await fetchTodos()
  } catch (err) {
    error.value = 'Could not load todos. Check backend and database configuration.'
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
  } catch (err) {
    error.value = 'Could not create todo.'
  }
}

async function toggleTodo(todo: Todo) {
  try {
    const updated = await updateTodo(todo.id, { completed: !todo.completed })
    todos.value = todos.value.map((item) => (item.id === updated.id ? updated : item))
  } catch (err) {
    error.value = 'Could not update todo.'
  }
}

async function removeTodo(todo: Todo) {
  try {
    await deleteTodo(todo.id)
    todos.value = todos.value.filter((item) => item.id !== todo.id)
  } catch (err) {
    error.value = 'Could not delete todo.'
  }
}

onMounted(loadTodos)
</script>

<template>
  <main class="container">
    <section class="panel">
      <h1>Todo App</h1>
      <p class="subtitle">FastAPI + PostgreSQL + Vue 3</p>

      <form class="todo-form" @submit.prevent="addTodo">
        <input v-model="newTitle" type="text" placeholder="Add a task" />
        <button type="submit">Add</button>
      </form>

      <p v-if="error" class="error">{{ error }}</p>
      <p class="status">{{ remainingCount }} remaining</p>

      <p v-if="loading">Loading todos...</p>

      <ul v-else class="todo-list">
        <li v-for="todo in todos" :key="todo.id" class="todo-item">
          <label>
            <input :checked="todo.completed" type="checkbox" @change="toggleTodo(todo)" />
            <span :class="{ done: todo.completed }">{{ todo.title }}</span>
          </label>
          <button class="delete" @click="removeTodo(todo)">Delete</button>
        </li>
      </ul>
    </section>
  </main>
</template>
